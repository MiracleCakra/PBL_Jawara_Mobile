import uvicorn
import os
import sys
import numpy as np
import cv2
import joblib
import onnxruntime as ort
from fastapi import FastAPI, UploadFile, File, HTTPException
from PIL import Image
from io import BytesIO

# --- Import Feature Extraction (Sama seperti Dashboard) ---
from skimage.feature import hog, local_binary_pattern
try:
    from skimage.feature import graycomatrix, graycoprops
except ImportError:
    from skimage.feature import greycomatrix as graycomatrix, greycoprops as graycoprops

# Inisialisasi Aplikasi
app = FastAPI(title="FreshVeggie API")


# ============================================================================
# 1. KONFIGURASI (Diadaptasi dari dashboard_best_model_test.py)
# ============================================================================
CFG = {
    # Path Model (Sesuaikan dengan lokasi file di server nanti)
    "lgbm_model_path": "models/lgbm_model.pkl",
    "u2net_path": "models/u2netp.onnx",
    
    "use_u2net_segmentation": True,
    
    # Feature Config (JANGAN DIUBAH - Harus sama dengan Training)
    "img_size": 224,
    "h_bins": 12, "s_bins": 8, "v_bins": 8,
    "lbp_radii": [1, 2], "lbp_points": 8,
    "glcm_distances": [1, 2, 3],
    "glcm_angles": [0, np.pi/4, np.pi/2, 3*np.pi/4],
    "hog_orient": 9, "hog_ppc": (64, 64), "hog_cpb": (2, 2),
    
    "class_names": ["Segar", "Layu", "Busuk"]
}

# Global Variables untuk Model
ml_model = None
u2net_session = None

# ============================================================================
# 2. EVENT STARTUP (Load Model Sekali Saja)
# ============================================================================
@app.on_event("startup")
def load_models():
    global ml_model, u2net_session
    print("🔄 System Startup: Memuat Model...")
    
    # 1. Load U2Net (ONNX)
    if os.path.exists(CFG["u2net_path"]):
        try:
            u2net_session = ort.InferenceSession(CFG["u2net_path"], providers=['CPUExecutionProvider'])
            print(f"✅ U2Net Segmentation Loaded: {CFG['u2net_path']}")
        except Exception as e:
            print(f"⚠️ Gagal load U2Net: {e}")
    else:
        print(f"⚠️ File U2Net tidak ditemukan di: {CFG['u2net_path']}")

    # 2. Load LightGBM (PKL)
    if os.path.exists(CFG["lgbm_model_path"]):
        try:
            ml_model = joblib.load(CFG["lgbm_model_path"])
            print(f"✅ LightGBM Model Loaded: {CFG['lgbm_model_path']}")
        except Exception as e:
            print(f"❌ Gagal load LightGBM: {e}")
    else:
        print(f"❌ File Model tidak ditemukan di: {CFG['lgbm_model_path']}")

# ============================================================================
# 3. FUNGSI PREPROCESSING & FEATURE EXTRACTION (COPY DARI DASHBOARD)
# ============================================================================

def segment_hsv_color(img_rgb):
    """Fallback segmentation jika U2Net gagal"""
    img_hsv = cv2.cvtColor(img_rgb, cv2.COLOR_RGB2HSV)
    h, s, v = img_hsv[:,:,0], img_hsv[:,:,1], img_hsv[:,:,2]
    
    mask = np.zeros(img_rgb.shape[:2], dtype=np.uint8)
    mask |= ((h >= 20) & (h <= 100) & (s > 15) & (v > 30)).astype(np.uint8) * 255
    mask |= (((h >= 0) & (h <= 20) | (h >= 150)) & (s > 15) & (v > 30)).astype(np.uint8) * 255
    mask |= ((h >= 5) & (h <= 55) & (s > 10) & (v > 25)).astype(np.uint8) * 255
    
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7, 7))
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
    
    # Tight Crop & Black BG
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    hw, ww = img_rgb.shape[:2]
    
    if contours:
        largest_contour = max(contours, key=cv2.contourArea)
        x, y, bw, bh = cv2.boundingRect(largest_contour)
        pad = int(min(bw, bh) * 0.05)
        x, y = max(0, x - pad), max(0, y - pad)
        bw, bh = min(ww - x, bw + 2*pad), min(hw - y, bh + 2*pad)
        
        img_cropped = img_rgb[y:y+bh, x:x+bw]
        mask_cropped = mask[y:y+bh, x:x+bw]
        
        black_bg = np.zeros_like(img_cropped)
        mask_3ch = cv2.cvtColor(mask_cropped, cv2.COLOR_GRAY2RGB).astype(np.float32) / 255.0
        result = (img_cropped * mask_3ch + black_bg * (1 - mask_3ch)).astype(np.uint8)
        return cv2.resize(result, (ww, hw), interpolation=cv2.INTER_LANCZOS4)
    else:
        return img_rgb

def segment_u2netp(img_rgb):
    """U2Net Segmentation (Menggunakan global session)"""
    # Gunakan session global yang sudah diload
    global u2net_session
    if u2net_session is None:
        return segment_hsv_color(img_rgb)
    
    try:
        h_orig, w_orig = img_rgb.shape[:2]
        
        # Resize ke 320x320 untuk input model U2Net
        img_input = cv2.resize(img_rgb, (320, 320), interpolation=cv2.INTER_AREA)
        img_input = img_input.astype(np.float32) / 255.0
        img_input = img_input.transpose(2, 0, 1)[np.newaxis, ...]
        
        # Inference
        input_name = u2net_session.get_inputs()[0].name
        output_name = u2net_session.get_outputs()[0].name
        mask_pred = u2net_session.run([output_name], {input_name: img_input})[0][0][0]
        
        mask_pred = (mask_pred > 0.5).astype(np.uint8) * 255
        mask = cv2.resize(mask_pred, (w_orig, h_orig), interpolation=cv2.INTER_LINEAR)
        
        # Tight Crop Logic
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        if contours:
            largest_contour = max(contours, key=cv2.contourArea)
            x, y, bw, bh = cv2.boundingRect(largest_contour)
            pad = int(min(bw, bh) * 0.05)
            x, y = max(0, x - pad), max(0, y - pad)
            bw, bh = min(w_orig - x, bw + 2*pad), min(h_orig - y, bh + 2*pad)
            
            img_cropped = img_rgb[y:y+bh, x:x+bw]
            mask_cropped = mask[y:y+bh, x:x+bw]
            
            black_bg = np.zeros_like(img_cropped)
            mask_3ch = cv2.cvtColor(mask_cropped, cv2.COLOR_GRAY2RGB).astype(np.float32) / 255.0
            result = (img_cropped * mask_3ch + black_bg * (1 - mask_3ch)).astype(np.uint8)
            return cv2.resize(result, (w_orig, h_orig), interpolation=cv2.INTER_LANCZOS4)
        else:
            return img_rgb
            
    except Exception as e:
        print(f"⚠️ U2Net Error: {e}, fallback to HSV")
        return segment_hsv_color(img_rgb)

def preprocess(img_rgb):
    """Pipeline Preprocessing"""
    # 1. Resize
    img_rgb = cv2.resize(img_rgb, (CFG["img_size"], CFG["img_size"]), interpolation=cv2.INTER_LANCZOS4)
    # 2. Segmentasi
    if CFG["use_u2net_segmentation"]:
        img_rgb = segment_u2netp(img_rgb)
    return img_rgb

# --- Helper Features (Langsung dari kode Anda) ---
def hsv_hist(rgb):
    hsv = cv2.cvtColor(rgb, cv2.COLOR_RGB2HSV)
    hist = cv2.calcHist([hsv], [0,1,2], None,
                        [CFG["h_bins"], CFG["s_bins"], CFG["v_bins"]],
                        [0,180, 0,256, 0,256]).astype(np.float32)
    return cv2.normalize(hist, None).ravel()

def color_moments(rgb):
    out = []
    lab = cv2.cvtColor(rgb, cv2.COLOR_RGB2Lab)
    for ch in range(3):
        px = lab[:,:,ch].astype(np.float32).ravel()
        m = float(px.mean())
        s = float(px.std()+1e-6)
        skew = float(np.mean(((px - m)/s)**3))
        out += [m, s, skew]
    return np.array(out, dtype=np.float32)

def glcm_feats(gray):
    g = cv2.equalizeHist(gray)
    g = (g / 8).astype(np.uint8)
    glcm = graycomatrix(g, distances=CFG["glcm_distances"], angles=CFG["glcm_angles"],
                        levels=32, symmetric=True, normed=True)
    props = ["contrast", "dissimilarity", "homogeneity", "energy", "correlation", "ASM"]
    feats = []
    for p in props:
        feats.append(graycoprops(glcm, p).ravel())
    return np.concatenate(feats).astype(np.float32)

def lbp_hist(gray, radius, points):
    lbp = local_binary_pattern(gray, P=points, R=radius, method="uniform")
    n_bins = points + 2
    hist, _ = np.histogram(lbp.ravel(), bins=np.arange(0, n_bins+1), range=(0, n_bins))
    hist = hist.astype(np.float32)
    hist /= (hist.sum() + 1e-6)
    return hist

def hog_vec(gray):
    v = hog(gray, orientations=CFG["hog_orient"], pixels_per_cell=CFG["hog_ppc"],
            cells_per_block=CFG["hog_cpb"], block_norm="L2-Hys",
            transform_sqrt=True, feature_vector=True)
    return v.astype(np.float32)

def sharp_edge_stats(gray):
    edges = cv2.Canny(gray, 50, 150)
    edge_density = float(np.mean(edges>0))
    lap_var = float(cv2.Laplacian(gray, cv2.CV_64F).var())
    hist = cv2.calcHist([gray],[0],None,[256],[0,256]).ravel()
    p = hist / (hist.sum()+1e-9)
    entropy = float(-(p*(np.log2(p+1e-12))).sum())
    return np.array([edge_density, lap_var, entropy], dtype=np.float32)

def colorfulness(rgb):
    r, g, b = rgb[:,:,0].astype(np.float32), rgb[:,:,1].astype(np.float32), rgb[:,:,2].astype(np.float32)
    rg = np.abs(r - g)
    yb = np.abs(0.5*(r + g) - b)
    std_rg, std_yb = rg.std(), yb.std()
    mean_rg, mean_yb = rg.mean(), yb.mean()
    cf = np.sqrt(std_rg**2 + mean_rg**2) + 0.3*np.sqrt(std_yb**2 + mean_yb**2)
    hsv = cv2.cvtColor(rgb, cv2.COLOR_RGB2HSV)
    sat = hsv[:,:,1].mean()
    val = hsv[:,:,2].mean()
    return np.array([cf, sat, val], dtype=np.float32)

def freshness_specific_features(rgb, gray):
    """FITUR KHUSUS DETEKSI KESEGARAN (27 dims)"""
    feats = []
    hsv = cv2.cvtColor(rgb, cv2.COLOR_RGB2HSV)
    h, s, v = hsv[:,:,0], hsv[:,:,1], hsv[:,:,2]
    
    # 1. Dark/Decay
    extremely_dark = (v < 50).mean()
    very_dark = (v < 80).mean()
    dark = (v < 110).mean()
    moderately_dark = (v < 140).mean()
    
    dark_mask = (v < 80).astype(np.uint8) * 255
    if dark_mask.max() > 0:
        contours, _ = cv2.findContours(dark_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        if len(contours) > 0:
            largest_dark = max(contours, key=cv2.contourArea)
            dark_concentration = cv2.contourArea(largest_dark) / (gray.shape[0] * gray.shape[1])
            dark_spot_count = min(len(contours) / 10.0, 1.0)
        else:
            dark_concentration, dark_spot_count = 0.0, 0.0
    else:
        dark_concentration, dark_spot_count = 0.0, 0.0
        
    dark_area_ratio = (v < 100).mean()
    dark_std = v[v < 120].std() if (v < 120).sum() > 0 else 0.0
    feats.extend([extremely_dark, very_dark, dark, moderately_dark, 
                  dark_concentration, dark_spot_count, dark_area_ratio, dark_std])
    
    # 2. Color Decay
    green_mask = ((h >= 35) & (h <= 85) & (s > 40)).astype(np.float32).mean()
    brown_mask = ((h >= 10) & (h <= 35) & (s > 30) & (v > 60)).astype(np.float32).mean()
    yellow_mask = ((h >= 20) & (h <= 35) & (s > 25)).astype(np.float32).mean()
    red_mask = (((h < 10) | (h > 170)) & (s > 40) & (v > 80)).astype(np.float32).mean()
    orange_mask = ((h >= 5) & (h <= 25) & (s > 35) & (v > 70)).astype(np.float32).mean()
    grayish_mask = (s < 30).mean()
    feats.extend([green_mask, brown_mask, yellow_mask, red_mask, orange_mask, grayish_mask])
    
    # 3. Saturation
    feats.extend([s.mean()/255.0, s.std()/255.0, (s < 60).mean()])
    
    # 4. Texture Decay
    sobelx = cv2.Sobel(gray, cv2.CV_64F, 1, 0, ksize=3)
    sobely = cv2.Sobel(gray, cv2.CV_64F, 0, 1, ksize=3)
    grad_mag = np.sqrt(sobelx**2 + sobely**2)
    
    kernel_size = 7
    local_std = cv2.blur(gray.astype(np.float32)**2, (kernel_size, kernel_size)) - \
                cv2.blur(gray.astype(np.float32), (kernel_size, kernel_size))**2
    local_std = np.sqrt(np.maximum(local_std, 0))
    
    gray_norm = (gray / 16).astype(np.uint8)
    entropy_img = cv2.blur(gray_norm.astype(np.float32), (5, 5))
    
    feats.extend([grad_mag.mean(), (grad_mag > grad_mag.mean() + grad_mag.std()).mean(), 
                  local_std.mean(), local_std.std(), entropy_img.std()])
    
    # 5. Edge Sharpness
    edges = cv2.Canny(gray, 30, 100)
    edge_str = grad_mag[edges > 0]
    feats.extend([edges.mean()/255.0, edge_str.mean() if len(edge_str)>0 else 0.0, edge_str.std() if len(edge_str)>0 else 0.0])
    
    # 6. Brightness
    feats.extend([v.mean()/255.0, (v < 100).mean()])
    
    return np.array(feats, dtype=np.float32)

def extract_features(img_rgb):
    """Pipeline Utama Ekstraksi Fitur (Total 1046 dims)"""
    gray = cv2.cvtColor(img_rgb, cv2.COLOR_RGB2GRAY)
    
    feats = []
    feats.append(hsv_hist(img_rgb))
    feats.append(color_moments(img_rgb))
    feats.append(glcm_feats(gray))
    for r in CFG["lbp_radii"]:
        feats.append(lbp_hist(gray, r, CFG["lbp_points"]))
    feats.append(hog_vec(gray))
    feats.append(sharp_edge_stats(gray))
    feats.append(colorfulness(img_rgb))
    feats.append(freshness_specific_features(img_rgb, gray))
    
    vec = np.concatenate(feats, axis=0).astype(np.float32)
    return vec

# ============================================================================
# 4. API ENDPOINT
# ============================================================================
@app.get("/")
def root():
    return {"status": "Online", "service": "FreshVeggie API"}

@app.post("/predict")
async def predict_image(file: UploadFile = File(...)):
    # Cek kesiapan model
    if ml_model is None:
        raise HTTPException(status_code=500, detail="Model LightGBM belum siap.")
    
    try:
        # A. BACA FILE GAMBAR
        contents = await file.read()
        image = Image.open(BytesIO(contents)).convert("RGB")
        img_rgb = np.array(image)
        
        # B. PREPROCESSING (Resize + U2Net Crop)
        img_processed = preprocess(img_rgb)
        
        # C. FEATURE EXTRACTION (1046 Features)
        features_vec = extract_features(img_processed)
        # Reshape jadi (1, 1046) agar diterima sklearn
        features_vec = features_vec.reshape(1, -1)
        
        # D. PREDIKSI (LightGBM)
        prediction_idx = ml_model.predict(features_vec)[0]
        probs = ml_model.predict_proba(features_vec)[0]
        
        # E. HASIL
        class_name = CFG["class_names"][prediction_idx]
        confidence = float(np.max(probs) * 100)
        
        return {
            "success": True,
            "prediction": class_name,
            "confidence": round(confidence, 2),
            "details": {
                "segar_prob": round(float(probs[0]) * 100, 2),
                "layu_prob": round(float(probs[1]) * 100, 2),
                "busuk_prob": round(float(probs[2]) * 100, 2),
            }
        }

    except Exception as e:
        print(f"❌ Error saat prediksi: {e}")
        return {"success": False, "error": str(e)}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
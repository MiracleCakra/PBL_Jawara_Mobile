import sys, os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")))

import pytest
import numpy as np
import cv2
from fastapi.testclient import TestClient

import PCVK.main as m
from PCVK.main import (
    preprocess,
    extract_features,
    hsv_hist,
    color_moments,
    glcm_feats,
    lbp_hist,
    hog_vec,
    sharp_edge_stats,
    colorfulness,
    freshness_specific_features,
    segment_hsv_color,
    segment_u2netp
)

client = TestClient(m.app)

@pytest.fixture
def dummy_img():
    img = np.zeros((300, 300, 3), dtype=np.uint8)
    img[:] = [50, 100, 150]
    return img

def test_segment_hsv_color(dummy_img):
    res = segment_hsv_color(dummy_img)
    assert isinstance(res, np.ndarray)
    assert res.shape == dummy_img.shape


def test_segment_u2netp(dummy_img):
    res = segment_u2netp(dummy_img)
    assert isinstance(res, np.ndarray)
    assert res.shape == dummy_img.shape


def test_preprocess(dummy_img):
    p = preprocess(dummy_img)
    assert p.shape == (224, 224, 3)

def test_hsv_hist(dummy_img):
    h = hsv_hist(dummy_img)
    assert len(h) == 12*8*8  # sesuai CFG h_bins*s_bins*v_bins


def test_color_moments(dummy_img):
    feats = color_moments(dummy_img)
    assert len(feats) == 9  # 3 channels * (mean, std, skew)


def test_glcm_feats(dummy_img):
    gray = cv2.cvtColor(dummy_img, cv2.COLOR_RGB2GRAY)
    glcm = glcm_feats(gray)
    assert glcm.size > 0

def test_lbp_hist(dummy_img):
    gray = cv2.cvtColor(dummy_img, cv2.COLOR_RGB2GRAY)
    lbp = lbp_hist(gray, radius=1, points=8)
    assert lbp.size > 0


def test_hog_vec(dummy_img):
    gray = cv2.cvtColor(dummy_img, cv2.COLOR_RGB2GRAY)
    h = hog_vec(gray)
    assert h.ndim == 1
    assert h.size > 100


def test_sharp_edge_stats(dummy_img):
    gray = cv2.cvtColor(dummy_img, cv2.COLOR_RGB2GRAY)
    s = sharp_edge_stats(gray)
    assert len(s) == 3
    assert all(isinstance(v, (float, np.floating, int)) for v in s)

def test_colorfulness(dummy_img):
    c = colorfulness(dummy_img)
    assert isinstance(c, np.ndarray)
    assert c.shape[0] == 3
def test_freshness_specific_features(dummy_img):
    gray = cv2.cvtColor(dummy_img, cv2.COLOR_RGB2GRAY)
    f = freshness_specific_features(dummy_img, gray)
    assert f.size == 27

def test_extract_features(dummy_img):
    f = extract_features(dummy_img)
    assert isinstance(f, np.ndarray)
    assert f.ndim == 1
    assert f.size > 150

class MockModel:
    def predict(self, x):
        return [1]
    def predict_proba(self, x):
        return [[0.1, 0.8, 0.1]]

m.ml_model = MockModel()

def test_predict_endpoint():
    dummy = np.zeros((224, 224, 3), dtype=np.uint8)
    _, b = cv2.imencode(".jpg", dummy)

    res = client.post(
        "/predict",
        files={"file": ("x.jpg", b.tobytes(), "image/jpeg")}
    )

    assert res.status_code == 200
    d = res.json()
    assert "prediction" in d
    assert "details" in d

def test_predict_invalid_file():
    res = client.post(
        "/predict",
        files={"file": ("x.txt", b"notanimage", "text/plain")}
    )
    d = res.json()
    assert res.status_code == 200
    assert d["success"] is False

def test_root():
    r = client.get("/")
    assert r.status_code == 200
    assert r.json()["status"] == "Online"

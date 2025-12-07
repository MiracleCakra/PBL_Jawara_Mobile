import os
import requests
from dotenv import load_dotenv
import pytest

# Load dari .env file
load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
TABLE_NAME = "warga"
ENDPOINT = f"{SUPABASE_URL}/rest/v1/{TABLE_NAME}"

@pytest.fixture
def headers():
    # Cek dulu, takutnya file .env belum ke-load atau kosong
    if not SUPABASE_KEY:
        pytest.fail("❌ SUPABASE_KEY tidak terbaca/tidak ada.")

    return {
        # 2. PANGGIL VARIABEL YANG BENAR DISINI
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=representation"
    }

# --- TEST 1: DAFTAR WARGA ---
def test_get_daftar_warga(headers):
    global found_nik_sample
    
    print(f"\n🚀 Navigasi ke: {ENDPOINT}")
    params = {
        "select": "*",
        "limit": 10
    }
    
    response = requests.get(ENDPOINT, headers=headers, params=params)
    
    assert response.status_code == 200, f"Gagal Fetch! {response.text}"
    
    data = response.json()
    assert isinstance(data, list), "Format data harus List!"
    
    print(f"✅ {len(data)} data warga fetched.")
    
    if len(data) > 0:
        first_warga = data[0]
        found_nik_sample = first_warga['id'] # Kolom 'id' adalah NIK
        nama = first_warga.get('nama', 'Anon/Unknown')
        print(f"💾 Menyimpan NIK Sampel: {found_nik_sample} ({nama})")
    else:
        pytest.skip("⚠️ Table kosong... anyone wanna put stuff there?")

print("--- Next: Tes detail ---")

# --- TEST 2: DETAIL WARGA BERDASARKAN NIK ---
def test_get_detail_warga(headers):
    if not found_nik_sample:
        pytest.skip("⚠️ Where sample NIK?")

    url_detail = f"{ENDPOINT}?id=eq.{found_nik_sample}"
    print(f"\n🚀 Navigasi ke: {url_detail}")
    print(f"🔍 Cari NIK: {found_nik_sample}")
    response = requests.get(url_detail, headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    warga = data[0]
    assert warga['id'] == found_nik_sample
    
    print(f"✅ Detail Valid! Nama: {warga.get('nama')}")
    print(f"📄 Data Lengkap: {warga}")

if __name__ == "__main__":
    # Jalankan pytest secara langsung
    import sys
    sys.exit(pytest.main(["-v", "-s", __file__]))
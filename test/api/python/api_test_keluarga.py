import os
import requests
from dotenv import load_dotenv
import pytest

# Load dari .env file
load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
TABLE_NAME = "keluarga"
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

# --- TEST 1: DAFTAR KELUARGA ---
def test_get_daftar_keluarga(headers):
    global id_family_sample
    
    print(f"\n🚀 Navigasi ke: {ENDPOINT}")
    params = {
        "select": "*",
        "limit": 10
    }
    response = requests.get(ENDPOINT, headers=headers, params=params)
    assert response.status_code == 200, f"Gagal Fetch! {response.text}"
    data = response.json()
    assert isinstance(data, list), "Format data harus List!"
    print(f"✅ {len(data)} data keluarga fetched.")
    if len(data) > 0:
        first_keluarga = data[0]
        id_family_sample = first_keluarga['id']
        nama = first_keluarga.get('nama_keluarga', 'Unnamed/Unknown')
        print(f"💾 Menyimpan ID Sampel: {id_family_sample} ({nama})")
    else:
        pytest.skip("⚠️ Table kosong... anyone wanna put stuff there?")

print("--- Next: Tes detail ---")

# --- TEST 2: DETAIL KELUARGA BERDASARKAN ID ---
def test_get_detail_keluarga(headers):
    if not id_family_sample:
        pytest.skip("⚠️ Where sample ID?")
    
    detail_endpoint = f"{ENDPOINT}?id=eq.{id_family_sample}"
    print(f"\n🚀 Navigasi ke: {detail_endpoint}")
    
    response = requests.get(detail_endpoint, headers=headers)
    assert response.status_code == 200, f"Gagal Fetch Detail! {response.text}"
    
    data = response.json()
    assert isinstance(data, list) and len(data) > 0, "Data detail tidak ditemukan!"
    
    keluarga_detail = data[0]
    print(f"✅ Detail Keluarga Ditemukan: ID {keluarga_detail['id']}, Nama: {keluarga_detail.get('nama_keluarga', 'Unnamed/Unknown')}")
    print(f"Detail Lengkap: {keluarga_detail}")

if __name__ == "__main__":
    # Jalankan pytest secara langsung
    import sys
    sys.exit(pytest.main(["-v", "-s", __file__]))
import os
import requests
import pytest
import random
import string
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

BASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
TABLE_NAME = "warga"
ENDPOINT = f"{BASE_URL}/rest/v1/{TABLE_NAME}"

# --- GLOBAL VARIABLE ---
created_nik = None 

@pytest.fixture
def headers():
    return {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=representation" 
    }

# Fungsi helper buat bikin NIK palsu 16 digit
def generate_random_nik():
    return ''.join(random.choices(string.digits, k=16))

# ==========================================
# 1. TEST CREATE (POST) - Bikin Warga Baru
# ==========================================
def test_1_create_warga(headers):
    global created_nik
    
    # Generate NIK Acak biar ga error "Duplicate Key"
    nik_baru = generate_random_nik()
    
    print(f"\n🆕 [CREATE] Bot Warga dengan NIK: {nik_baru}")
    payload = {
        "id": nik_baru,
        "nama": "Robot Testing 001",
        "email": f"robot_{nik_baru}@test.com",
        "tempat_lahir": "Server Python Local Yukina",
        "tanggal_lahir": "2000-01-01", # Format Date: YYYY-MM-DD
        "gender": "Pria",
        "gol_darah": "O+",
        "agama": "Kristen",
        "pendidikan_terakhir": "S1",
        "status_penduduk": "Aktif",
        "status_penerimaan": "Pending",
        "pekerjaan": "Bot Tester",
        "status_hidup_wafat": "Hidup",
        "role": "Warga",
        "keluarga_id": None 
    }

    response = requests.post(ENDPOINT, json=payload, headers=headers)

    # Debugging
    if response.status_code != 201:
        print(f"❌ Ada error di: {response.text}")

    assert response.status_code == 201
    
    data = response.json()
    created_nik = data[0]['id'] # Simpan NIK untuk test selanjutnya
    
    print(f"✅ Sukses Create! ID: {created_nik} | Nama: {data[0]['nama']}")

# ==========================================
# 2. TEST READ (GET) - Pastikan Data Masuk
# ==========================================
def test_2_read_warga(headers):
    global created_nik
    assert created_nik is not None, "❌ Skip karena Create gagal."

    url = f"{ENDPOINT}?id=eq.{created_nik}"
    response = requests.get(url, headers=headers)
    
    assert response.status_code == 200
    data = response.json()
    
    assert len(data) == 1
    assert data[0]['nama'] == "Robot Testing 001"
    print(f"✅ Data ditemukan di Database.")

# ==========================================
# 3. TEST UPDATE (PATCH) - Ganti Data
# ==========================================
def test_3_update_warga(headers):
    global created_nik
    assert created_nik is not None, "❌ Skip karena Create gagal."

    print(f"🔄 [UPDATE] Mengubah data NIK: {created_nik}")

    url = f"{ENDPOINT}?id=eq.{created_nik}"
    
    # Kita ubah Namanya dan Pekerjaannya
    payload_update = {
        "nama": "V1 John ULTRAKILL",
        "pekerjaan": "Senior Tester"
    }

    response = requests.patch(url, json=payload_update, headers=headers)
    
    assert response.status_code == 200
    
    data = response.json()
    updated_data = data[0]
    
    assert updated_data['nama'] == "V1 John ULTRAKILL"
    assert updated_data['pekerjaan'] == "Senior Tester"
    
    print(f"✅ Sukses Update! Nama baru: {updated_data['nama']}")
    print(f"✅ Sukses Update! Pekerjaan baru: {updated_data['pekerjaan']}")

# ==========================================
# 4. TEST DELETE (DELETE) - Bersih-bersih
# ==========================================
def test_4_delete_warga(headers):
    global created_nik
    assert created_nik is not None, "❌ Skip karena Create gagal."

    print(f"🗑️ [DELETE] Menghapus Bot dengan NIK: {created_nik}")

    url = f"{ENDPOINT}?id=eq.{created_nik}"
    
    response = requests.delete(url, headers=headers)
    
    # Supabase biasanya return 204 (No Content) kalau delete sukses, 
    # atau 200 kalau pake return=representation
    assert response.status_code in [200, 204]
    
    # Verifikasi ganda: Coba GET lagi, harusnya kosong
    check_response = requests.get(url, headers=headers)
    assert len(check_response.json()) == 0
    
    print("✅ Data telah dihapus dari Database.")

if __name__ == "__main__":
    import sys
    sys.exit(pytest.main(["-v", "-s", __file__]))
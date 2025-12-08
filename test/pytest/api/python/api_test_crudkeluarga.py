import os
import requests
import pytest
import random
from dotenv import load_dotenv

load_dotenv()

BASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
TABLE_NAME = "keluarga"
ENDPOINT = f"{BASE_URL}/rest/v1/{TABLE_NAME}"
created_uuid = None 

@pytest.fixture
def headers():
    return {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=representation"
    }

# ==========================================
# 1. TEST CREATE (POST) 
# ==========================================
def test_1_create_keluarga(headers):
    global created_uuid
    
    print(f"\n🆕 [CREATE] Buat Keluarga baru...")

    payload = {
        "nama_keluarga": "Keluarga Cemara (Python Test)",
        "status_keluarga": "Aktif", # Aktif/Nonaktif
        "kepala_keluarga_id": None, # Nullable
        "alamat_rumah": None,       # Nullable
        "status_kepemilikan": "Milik Sendiri"
    }

    response = requests.post(ENDPOINT, json=payload, headers=headers)

    if response.status_code != 201:
        print(f"❌ Error:: {response.text}")

    assert response.status_code == 201
    
    data = response.json()
    # INI PENTING: Kita ambil UUID yang baru aja dibuat Supabase
    created_uuid = data[0]['id'] 
    
    print(f"✅ Sukses Create! UUID: {created_uuid}")
    print(f"   Nama Keluarga: {data[0]['nama_keluarga']}")

# ==========================================
# 2. TEST READ (GET)
# ==========================================
def test_2_read_keluarga(headers):
    global created_uuid
    assert created_uuid is not None, "❌ Skip Read karena Create gagal."

    # Cari berdasarkan UUID
    url = f"{ENDPOINT}?id=eq.{created_uuid}"
    
    print(f"🔍 [READ] UUID: {created_uuid}")
    
    response = requests.get(url, headers=headers)
    
    assert response.status_code == 200
    data = response.json()
    
    assert len(data) == 1
    assert data[0]['nama_keluarga'] == "Keluarga Cemara (Python Test)"
    print(f"✅ Data ditemukan.")

# ==========================================
# 3. TEST UPDATE (PATCH)
# ==========================================
def test_3_update_keluarga(headers):
    global created_uuid
    assert created_uuid is not None, "❌ Skip Update karena Create gagal."

    print(f"🔄 [UPDATE] Mengubah nama keluarga...")

    url = f"{ENDPOINT}?id=eq.{created_uuid}"
    
    payload_update = {
        "nama_keluarga": "Keluarga Cemara (Updated)",
        "status_kepemilikan": "Sewa"
    }

    response = requests.patch(url, json=payload_update, headers=headers)
    
    assert response.status_code == 200
    data = response.json()
    
    assert data[0]['nama_keluarga'] == "Keluarga Cemara (Updated)"
    print(f"✅ Sukses Update! Nama sekarang: {data[0]['nama_keluarga']}")

# ==========================================
# 4. TEST DELETE (DELETE)
# ==========================================
def test_4_delete_keluarga(headers):
    global created_uuid
    assert created_uuid is not None, "❌ Skip Delete karena Create gagal."

    print(f"🗑️ [DELETE] Menghapus UUID: {created_uuid}")

    url = f"{ENDPOINT}?id=eq.{created_uuid}"
    
    response = requests.delete(url, headers=headers)
    
    assert response.status_code in [200, 204]
    
    # Pastikan terhapus
    check = requests.get(url, headers=headers)
    assert len(check.json()) == 0
    
    print("✅ Sukses Delete!")

if __name__ == "__main__":
    import sys
    sys.exit(pytest.main(["-v", "-s", __file__]))
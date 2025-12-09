# PCVK Load Testing

Load testing untuk PCVK Vegetable Detection API menggunakan k6.

## Prerequisites

### 1. Install k6

**Windows (menggunakan Chocolatey):**

```cmd
choco install k6
```

**Windows (menggunakan winget):**

```cmd
winget install k6 --source winget
```

**Atau download langsung:**
https://k6.io/docs/getting-started/installation/

### 2. Verify k6 Installation

```cmd
k6 version
```

## Running Load Tests

### Basic Run

```cmd
k6 run test/load/pcvk_load_test.js
```

### Custom Configuration

**Dengan jumlah VU (Virtual Users) dan durasi custom:**

```cmd
k6 run --vus 10 --duration 30s test/load/pcvk_load_test.js
```

**Dengan iterasi tertentu:**

```cmd
k6 run --iterations 100 test/load/pcvk_load_test.js
```

**Smoke test (cepat):**

```cmd
k6 run --vus 1 --duration 10s test/load/pcvk_load_test.js
```

**Stress test (berat):**

```cmd
k6 run --vus 50 --duration 2m test/load/pcvk_load_test.js
```

## Test Stages

Load test menggunakan 3 stage:

1. **Ramp-up** (30s): Naikkan load dari 0 → 5 users
2. **Steady State** (1m): Maintain 25 concurrent users
3. **Ramp-down** (30s): Turunkan load dari 25 → 0 users

## Performance Thresholds

| Metric                    | Target | Description                        |
| ------------------------- | ------ | ---------------------------------- |
| `http_req_failed`         | < 5%   | Error rate harus di bawah 5%       |
| `http_req_duration` (p95) | < 10s  | 95% request selesai dalam 10 detik |
| `http_req_duration` (p99) | < 15s  | 99% request selesai dalam 15 detik |

## Test Scenarios

Load test menguji 4 endpoint:

### 1. Health Check

- **Endpoint:** `GET /`
- **Purpose:** Verify API is online
- **Expected:** Status 200, response < 2s

### 2. Predict Segar (Fresh)

- **Endpoint:** `POST /predict`
- **Image:** `cobagtw3.jpg`
- **Expected:** Prediction = "Segar"

### 3. Predict Busuk (Rotten)

- **Endpoint:** `POST /predict`
- **Image:** `cobagtw5.jpg`
- **Expected:** Prediction = "Busuk"

### 4. Predict Layu (Wilted)

- **Endpoint:** `POST /predict`
- **Image:** `layu_tomat.jpg`
- **Expected:** Prediction = "Layu"

## Output Reports

Setelah test selesai, 2 file report akan dibuat:

1. **HTML Report:** `test/load/pcvk_load_summary.html`

   - Visual dashboard dengan grafik
   - Buka di browser untuk melihat hasil lengkap

2. **JSON Report:** `test/load/pcvk_load_summary.json`
   - Raw data dalam format JSON
   - Untuk analisis programmatik

## Understanding Results

### Key Metrics

```
✓ checks.........................: 100.00% ✓ 1200      ✗ 0
  data_received..................: 15 MB   250 kB/s
  data_sent......................: 3.2 MB  53 kB/s
  http_req_blocked...............: avg=1.45ms   min=0s     med=1ms
  http_req_connecting............: avg=845.72µs min=0s     med=0s
  http_req_duration..............: avg=5.32s    min=1.2s   med=4.8s
  http_req_failed................: 0.00%   ✓ 0         ✗ 1200
  http_req_receiving.............: avg=142.56ms min=53.2µs med=93.7ms
  http_req_sending...............: avg=45.2ms   min=20.1µs med=38.5ms
  http_req_tls_handshaking.......: avg=0s       min=0s     med=0s
  http_req_waiting...............: avg=5.14s    min=1.1s   med=4.6s
  http_reqs......................: 1200    20/s
  iteration_duration.............: avg=21.45s   min=15.2s  med=20.8s
  iterations.....................: 300     5/s
  vus............................: 1       min=0       max=25
  vus_max........................: 25      min=25      max=25
```

**Good indicators:**

- ✅ `http_req_failed` = 0% (no errors)
- ✅ `http_req_duration` p95 < 10s
- ✅ All checks passed 100%

**Warning signs:**

- ❌ `http_req_failed` > 5%
- ❌ `http_req_duration` p95 > 10s
- ❌ Checks failing

## Troubleshooting

### Error: "open ... no such file"

**Cause:** Image files tidak ditemukan

**Solution:**

```cmd
# Pastikan ada gambar test di folder:
dir test\fixtures\test_images\cobagtw3.jpg
dir test\fixtures\test_images\cobagtw5.jpg
dir test\fixtures\test_images\layu_tomat.jpg
```

### Error: "connection refused"

**Cause:** API tidak bisa diakses

**Solution:**

- Cek koneksi internet
- Verify API URL: https://miraclecakra-cmkesegaransayur.hf.space
- Test manual di browser dulu

### High Error Rate

**Cause:** API overload atau timeout

**Solution:**

- Kurangi jumlah VUs: `--vus 5`
- Perpendek durasi: `--duration 30s`
- Tambah sleep time di script

## Advanced Usage

### Cloud Execution (k6 Cloud)

**Sign up:** https://app.k6.io/

**Run on cloud:**

```cmd
k6 cloud test/load/pcvk_load_test.js
```

### Custom Scenarios

Edit `test/load/pcvk_load_test.js`:

```javascript
export const options = {
  stages: [
    { duration: "1m", target: 10 }, // Custom stage 1
    { duration: "3m", target: 50 }, // Custom stage 2
    { duration: "1m", target: 0 }, // Custom stage 3
  ],
};
```

### Environment Variables

**Set API URL:**

```cmd
k6 run -e PCVK_API_URL=custom-url.com test/load/pcvk_load_test.js
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Load Test

on: [push, pull_request]

jobs:
  k6_load_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: grafana/k6-action@v0.3.0
        with:
          filename: test/load/pcvk_load_test.js
          flags: --vus 10 --duration 30s
```

## Best Practices

1. **Start Small:** Mulai dengan smoke test (1 VU, 10s)
2. **Increment Gradually:** Naikkan load secara bertahap
3. **Monitor API:** Pantau server metrics saat load test
4. **Peak Hours:** Hindari test saat jam sibuk production
5. **Baseline:** Catat baseline performance untuk comparison
6. **Realistic Data:** Gunakan gambar yang mirip production
7. **Regular Testing:** Jalankan load test secara berkala

## Resources

- **k6 Documentation:** https://k6.io/docs/
- **Best Practices:** https://k6.io/docs/testing-guides/test-types/
- **Example Tests:** https://github.com/grafana/k6/tree/master/examples

## Support

Jika ada masalah:

1. Check k6 logs di terminal
2. Review test summary reports
3. Verify API is accessible
4. Contact team: [email/slack channel]

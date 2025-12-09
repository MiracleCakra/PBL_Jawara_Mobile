/**
 * K6 Load Test for PCVK Vegetable Detection API
 *
 * Requirements:
 * 1. Install k6: https://k6.io/docs/getting-started/installation/
 * 2. Ensure test images exist in test/fixtures/test_images/
 *
 * Run:
 *   k6 run test/load/pcvk_load_test.js
 *
 * With custom options:
 *   k6 run --vus 10 --duration 30s test/load/pcvk_load_test.js
 */

import { FormData } from "https://jslib.k6.io/formdata/0.0.2/index.js";
import { textSummary } from "https://jslib.k6.io/k6-summary/0.0.1/index.js";
import { htmlReport } from "https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js";
import { check, group, sleep } from "k6";
import http from "k6/http";

// API Configuration - Hugging Face Spaces
const BASE_URL = "https://miraclecakra-cmkesegaransayur.hf.space";

// Load test images
const imgSegar = open("../../test/fixtures/test_images/cobagtw3.jpg", "b");
const imgBusuk = open("../../test/fixtures/test_images/cobagtw5.jpg", "b");
const imgLayu = open("../../test/fixtures/test_images/layu_tomat.jpg", "b");

/**
 * Load Test Configuration
 *
 * Stages:
 * 1. Ramp-up: 30s to reach 5 VUs (Virtual Users)
 * 2. Steady: 1m with 25 VUs
 * 3. Ramp-down: 30s back to 0 VUs
 */
export const options = {
  thresholds: {
    http_req_failed: ["rate<0.05"], // Error rate harus di bawah 5%
    http_req_duration: ["p(95)<10000"], // 95% request harus selesai di bawah 10 detik
    http_req_duration: ["p(99)<15000"], // 99% request harus selesai di bawah 15 detik
  },
  stages: [
    { duration: "30s", target: 5 }, // Ramp-up to 5 users
    { duration: "1m", target: 10 }, // Stay at 10 users for 1 minute
    { duration: "30s", target: 0 }, // Ramp-down to 0 users
  ],
};

/**
 * Generate HTML and JSON summary reports
 */
export function handleSummary(data) {
  return {
    "test/load/pcvk_load_summary.html": htmlReport(data),
    "test/load/pcvk_load_summary.json": JSON.stringify(data, null, 2),
    stdout: textSummary(data, { indent: " ", enableColors: true }),
  };
}

/**
 * Main test function - runs for each VU iteration
 */
export default function () {
  // Test 1: Health Check
  group("Health Check Endpoint", () => {
    const resHealth = http.get(`${BASE_URL}/`);

    check(resHealth, {
      "Health check status is 200": (r) => r.status === 200,
      "Health check has status field": (r) => {
        try {
          const body = JSON.parse(r.body);
          return body.status !== undefined;
        } catch {
          return false;
        }
      },
      "Health check response time < 8s": (r) => r.timings.duration < 8000,
    });

    if (resHealth.status !== 200) {
      console.error("❌ Health check failed!");
    }
  });

  sleep(1);

  // Test 2: Predict Single Image - Segar
  group("Predict Endpoint - Segar (Fresh)", () => {
    const fd = new FormData();
    fd.append("file", http.file(imgSegar, "segar.jpg", "image/jpeg"));

    const resPredict = http.post(`${BASE_URL}/predict`, fd.body(), {
      headers: {
        "Content-Type": "multipart/form-data; boundary=" + fd.boundary,
      },
    });

    check(resPredict, {
      "Predict segar status is 200": (r) => r.status === 200,
      "Predict segar has success field": (r) => {
        try {
          const body = JSON.parse(r.body);
          return body.success === true;
        } catch {
          return false;
        }
      },
      "Predict segar returns prediction": (r) => {
        try {
          const body = JSON.parse(r.body);
          return body.prediction !== undefined;
        } catch {
          return false;
        }
      },
      "Predict segar response time < 10s": (r) => r.timings.duration < 10000,
    });

    // Log prediction result
    if (resPredict.status === 200) {
      try {
        const result = JSON.parse(resPredict.body);
        console.log(`✅ Segar: ${result.prediction} (${result.confidence}%)`);
      } catch (e) {
        console.error("❌ Failed to parse segar prediction");
      }
    }
  });

  sleep(1);

  // Test 3: Predict Single Image - Busuk
  group("Predict Endpoint - Busuk (Rotten)", () => {
    const fd = new FormData();
    fd.append("file", http.file(imgBusuk, "busuk.jpg", "image/jpeg"));

    const resPredict = http.post(`${BASE_URL}/predict`, fd.body(), {
      headers: {
        "Content-Type": "multipart/form-data; boundary=" + fd.boundary,
      },
    });

    check(resPredict, {
      "Predict busuk status is 200": (r) => r.status === 200,
      "Predict busuk has success field": (r) => {
        try {
          const body = JSON.parse(r.body);
          return body.success === true;
        } catch {
          return false;
        }
      },
      "Predict busuk returns prediction": (r) => {
        try {
          const body = JSON.parse(r.body);
          return body.prediction !== undefined;
        } catch {
          return false;
        }
      },
      "Predict busuk response time < 10s": (r) => r.timings.duration < 10000,
    });

    if (resPredict.status === 200) {
      try {
        const result = JSON.parse(resPredict.body);
        console.log(`✅ Busuk: ${result.prediction} (${result.confidence}%)`);
      } catch (e) {
        console.error("❌ Failed to parse busuk prediction");
      }
    }
  });

  sleep(1);

  // Test 4: Predict Single Image - Layu
  group("Predict Endpoint - Layu (Wilted)", () => {
    const fd = new FormData();
    fd.append("file", http.file(imgLayu, "layu.jpg", "image/jpeg"));

    const resPredict = http.post(`${BASE_URL}/predict`, fd.body(), {
      headers: {
        "Content-Type": "multipart/form-data; boundary=" + fd.boundary,
      },
    });

    check(resPredict, {
      "Predict layu status is 200": (r) => r.status === 200,
      "Predict layu has success field": (r) => {
        try {
          const body = JSON.parse(r.body);
          return body.success === true;
        } catch {
          return false;
        }
      },
      "Predict layu returns prediction": (r) => {
        try {
          const body = JSON.parse(r.body);
          return body.prediction !== undefined;
        } catch {
          return false;
        }
      },
      "Predict layu response time < 10s": (r) => r.timings.duration < 10000,
    });

    if (resPredict.status === 200) {
      try {
        const result = JSON.parse(resPredict.body);
        console.log(`✅ Layu: ${result.prediction} (${result.confidence}%)`);
      } catch (e) {
        console.error("❌ Failed to parse layu prediction");
      }
    }
  });

  sleep(1);
}

"""Smoke tests for the local mock API. Run: python -m unittest discover -s backend-test/tests"""
import json
import subprocess
import sys
import time
import unittest
import urllib.request
import urllib.error
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PORT = 18765
BASE = f"http://127.0.0.1:{PORT}"

class MockApiTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.state_file = ROOT / "data" / "state.json"
        cls.backup = cls.state_file.read_bytes() if cls.state_file.exists() else None
        cls.proc = subprocess.Popen(
            [sys.executable, str(ROOT / "server.py"), "--test-port", str(PORT)],
            cwd=ROOT, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        for _ in range(40):
            try:
                with urllib.request.urlopen(BASE + "/api/health", timeout=0.2) as response:
                    response.read()
                break
            except Exception:
                time.sleep(0.1)
        else:
            cls.proc.terminate()
            raise RuntimeError("Mock API did not start")

    @classmethod
    def tearDownClass(cls):
        cls.proc.terminate()
        cls.proc.wait(timeout=5)
        if cls.backup is None:
            cls.state_file.unlink(missing_ok=True)
        else:
            cls.state_file.write_bytes(cls.backup)

    def request(self, path, method="GET", payload=None):
        data = None if payload is None else json.dumps(payload).encode()
        req = urllib.request.Request(
            BASE + path, data=data, method=method,
            headers={"Content-Type": "application/json"}
        )
        try:
            with urllib.request.urlopen(req, timeout=2) as response:
                return response.status, json.loads(response.read().decode())
        except urllib.error.HTTPError as error:
            try:
                error.body = error.read()
            finally:
                error.close()
            raise

    def test_health(self):
        status, body = self.request("/api/health")
        self.assertEqual(status, 200)
        self.assertTrue(body["ok"])

    def test_booking_requires_ids(self):
        with self.assertRaises(urllib.error.HTTPError) as caught:
            self.request("/api/bookings", "POST", {"run_id": "run_demo"})
        self.assertEqual(caught.exception.code, 400)

    def test_friend_request_is_pending_consent(self):
        status, body = self.request("/api/friends", "POST", {"name": "Amigo de teste"})
        self.assertEqual(status, 201)
        self.assertEqual(body["status"], "pending_consent_demo")

if __name__ == "__main__":
    unittest.main()

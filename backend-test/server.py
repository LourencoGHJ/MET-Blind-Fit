"""Mock API local para desenvolvimento. Nunca expor à Internet.
Run: python backend-test/server.py
"""
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from urllib.parse import urlparse
from datetime import datetime, timezone
import json
import threading
import uuid
import sys

ROOT = Path(__file__).resolve().parent
DATA_DIR = ROOT / "data"
SEED = json.loads((DATA_DIR / "seed.json").read_text(encoding="utf-8"))
STATE_FILE = DATA_DIR / "state.json"
LOCK = threading.Lock()

def now():
    return datetime.now(timezone.utc).isoformat()

def load_state():
    if STATE_FILE.exists():
        try:
            return json.loads(STATE_FILE.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            pass
    return {"bookings": [], "friends": [], "incidents": [], "sessions": []}

STATE = load_state()

def save_state():
    temp = STATE_FILE.with_suffix(".tmp")
    temp.write_text(json.dumps(STATE, ensure_ascii=False, indent=2), encoding="utf-8")
    temp.replace(STATE_FILE)

class Handler(BaseHTTPRequestHandler):
    def respond(self, status, payload):
        body = json.dumps(payload, ensure_ascii=False, indent=2).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, DELETE, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()
        self.wfile.write(body)

    def read_body(self):
        try:
            length = int(self.headers.get("Content-Length", "0"))
            if length < 1 or length > 100_000:
                return None
            return json.loads(self.rfile.read(length).decode("utf-8"))
        except (ValueError, json.JSONDecodeError, UnicodeDecodeError):
            return None

    def do_OPTIONS(self):
        return self.respond(204, {})

    def do_GET(self):
        path = urlparse(self.path).path
        with LOCK:
            if path == "/api/health":
                return self.respond(200, {"ok": True, "mode": "mock-local", "warning": "Dados fictícios; sem autenticação."})
            if path == "/api/runs":
                return self.respond(200, SEED["runs"])
            if path == "/api/supervisors":
                return self.respond(200, SEED["supervisors"])
            if path == "/api/config":
                return self.respond(200, {"environment": SEED["environment"], "features": SEED["features"]})
            if path in ("/api/bookings", "/api/friends", "/api/incidents", "/api/sessions"):
                key = path.rsplit("/", 1)[-1]
                return self.respond(200, STATE[key])
            return self.respond(404, {"error": "not_found"})

    def do_POST(self):
        path = urlparse(self.path).path
        body = self.read_body()
        if not isinstance(body, dict):
            return self.respond(400, {"error": "invalid_json_object"})
        with LOCK:
            if path == "/api/bookings":
                run_id = str(body.get("run_id", "")).strip()
                user_id = str(body.get("user_id", "")).strip()
                if not run_id or not user_id:
                    return self.respond(400, {"error": "run_id_and_user_id_required"})
                if any(b["run_id"] == run_id and b["user_id"] == user_id for b in STATE["bookings"]):
                    return self.respond(409, {"error": "booking_exists"})
                item = {"id": uuid.uuid4().hex, "run_id": run_id, "user_id": user_id, "status": "pending_local_demo", "created_at": now()}
                STATE["bookings"].append(item)
            elif path == "/api/friends":
                name = str(body.get("name", "")).strip()
                if not name or len(name) > 80:
                    return self.respond(400, {"error": "valid_name_required"})
                item = {"id": uuid.uuid4().hex, "name": name, "status": "pending_consent_demo", "created_at": now()}
                STATE["friends"].append(item)
            elif path == "/api/incidents":
                kind = str(body.get("kind", "")).strip()
                description = str(body.get("description", "")).strip()
                if not kind:
                    return self.respond(400, {"error": "kind_required"})
                item = {"id": uuid.uuid4().hex, "kind": kind[:80], "description": description[:1000], "status": "open_demo", "created_at": now()}
                STATE["incidents"].append(item)
            elif path == "/api/sessions":
                run_id = str(body.get("run_id", "")).strip()
                if not run_id:
                    return self.respond(400, {"error": "run_id_required"})
                item = {"id": uuid.uuid4().hex, "run_id": run_id, "status": "planned_demo", "created_at": now()}
                STATE["sessions"].append(item)
            else:
                return self.respond(404, {"error": "not_found"})
            save_state()
            return self.respond(201, item)

    def do_DELETE(self):
        path = urlparse(self.path).path
        parts = path.strip("/").split("/")
        if len(parts) != 3 or parts[0] != "api" or parts[1] not in ("bookings", "friends", "incidents", "sessions"):
            return self.respond(404, {"error": "not_found"})
        collection, item_id = parts[1], parts[2]
        with LOCK:
            before = len(STATE[collection])
            STATE[collection][:] = [item for item in STATE[collection] if item.get("id") != item_id]
            if len(STATE[collection]) == before:
                return self.respond(404, {"error": "item_not_found"})
            save_state()
            return self.respond(200, {"ok": True, "deleted_id": item_id})

    def log_message(self, fmt, *args):
        print("[mock-api]", fmt % args)

if __name__ == "__main__":
    port = 8765
    if "--test-port" in sys.argv:
        try:
            port = int(sys.argv[sys.argv.index("--test-port") + 1])
        except (ValueError, IndexError):
            raise SystemExit("Uso: server.py [--test-port PORT]")
    server = HTTPServer(("127.0.0.1", port), Handler)
    print(f"MET Blind Fit mock API: http://127.0.0.1:{port}")
    print("Local only, no authentication. Ctrl+C to stop.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nMock API stopped.")
        server.server_close()

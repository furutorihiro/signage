import json
import sys
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlsplit

ROOT = Path(__file__).resolve().parent
MEDIA_EXTENSIONS = {
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".avif", ".bmp",
    ".mp4", ".m4v", ".mov", ".webm", ".ogv", ".ogg",
}


class SignageRequestHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def do_GET(self):
        request = urlsplit(self.path)
        if request.path == "/__media-root-check":
            requested_root = parse_qs(request.query).get("root", [None])[0]
            if not requested_root or Path(requested_root).resolve() != ROOT:
                self.send_error(409, "This server belongs to a different signage folder")
                return
            payload = str(ROOT).encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
            return
        if request.path == "/__media-list":
            requested_root = parse_qs(request.query).get("root", [None])[0]
            if requested_root and Path(requested_root).resolve() != ROOT:
                self.send_error(409, "This server belongs to a different signage folder")
                return
            files = sorted(
                (
                    entry.name
                    for entry in ROOT.iterdir()
                    if entry.is_file() and entry.suffix.lower() in MEDIA_EXTENSIONS
                ),
                key=str.casefold,
            )
            payload = json.dumps({"files": files}, ensure_ascii=False).encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Cache-Control", "no-store")
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
            return
        super().do_GET()

    def copyfile(self, source, outputfile):
        try:
            super().copyfile(source, outputfile)
        except (BrokenPipeError, ConnectionResetError):
            pass


port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
server = ThreadingHTTPServer(("127.0.0.1", port), SignageRequestHandler)
print(f"Serving signage from {ROOT} at http://127.0.0.1:{port}/", flush=True)
try:
    server.serve_forever()
except KeyboardInterrupt:
    pass
finally:
    server.server_close()

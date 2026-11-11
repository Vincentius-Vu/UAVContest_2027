"""
Lightweight CABP UDP-14555 -> WebSocket (RFC 6455) Bridge for Web_Arena_Simulation.
Uses Python standard library only (no pip dependencies) and imports
CABP_Starter_Kit/cabp_lite.py directly as the canonical decoder.

Usage:
    python Web_Arena_Simulation/bridge/cabp_ws_bridge.py
"""

from __future__ import annotations

import base64
import hashlib
import io
import json
import socket
import struct
import sys
import threading
from pathlib import Path

if hasattr(sys.stdout, "buffer") and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "CABP_Starter_Kit"))
import cabp_lite  # type: ignore

WS_HOST = "127.0.0.1"
WS_PORT = 8765
WS_GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

clients: set[socket.socket] = set()
clients_lock = threading.Lock()


def ws_encode_text(text: str) -> bytes:
    payload = text.encode("utf-8")
    n = len(payload)
    if n < 126:
        header = struct.pack("!BB", 0x81, n)
    elif n < 65536:
        header = struct.pack("!BBH", 0x81, 126, n)
    else:
        header = struct.pack("!BBQ", 0x81, 127, n)
    return header + payload


def broadcast_json(obj: dict) -> None:
    frame = ws_encode_text(json.dumps(obj, ensure_ascii=False))
    with clients_lock:
        dead = []
        for conn in clients:
            try:
                conn.sendall(frame)
            except OSError:
                dead.append(conn)
        for conn in dead:
            clients.discard(conn)
            try:
                conn.close()
            except OSError:
                pass


def handle_ws_client(conn: socket.socket) -> None:
    try:
        req = conn.recv(4096).decode("utf-8", errors="ignore")
        key = None
        for line in req.splitlines():
            if line.lower().startswith("sec-websocket-key:"):
                key = line.split(":", 1)[1].strip()
                break
        if not key:
            conn.close()
            return

        accept = base64.b64encode(hashlib.sha1((key + WS_GUID).encode("ascii")).digest()).decode("ascii")
        handshake = (
            "HTTP/1.1 101 Switching Protocols\r\n"
            "Upgrade: websocket\r\n"
            "Connection: Upgrade\r\n"
            f"Sec-WebSocket-Accept: {accept}\r\n\r\n"
        )
        conn.sendall(handshake.encode("ascii"))
        with clients_lock:
            clients.add(conn)

        while True:
            data = conn.recv(1024)
            if not data:
                break
    except OSError:
        pass
    finally:
        with clients_lock:
            clients.discard(conn)
        try:
            conn.close()
        except OSError:
            pass


def udp_listener_loop() -> None:
    receiver = cabp_lite.CABPReceiver(port=cabp_lite.CABP_PORT)
    print(f"[CABP Bridge] Listening UDP Broadcast on port {cabp_lite.CABP_PORT} (magic=0xCB)...")
    while True:
        msg, addr = receiver.receive()
        if msg:
            out = dict(msg)
            if msg["msg_type"] == "PERIODIC_BEACON":
                out["state_name"] = msg["state"].name
                out["intent_name"] = msg["intent"].name
                out["state"] = int(msg["state"])
                out["intent"] = int(msg["intent"])
            elif msg["msg_type"] == "MISSION_EVENT":
                out["event_name"] = msg["event_type"].name
                out["event_type"] = int(msg["event_type"])
            out["src_ip"] = addr[0] if addr else ""
            broadcast_json(out)


def main() -> None:
    threading.Thread(target=udp_listener_loop, daemon=True).start()
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind((WS_HOST, WS_PORT))
    srv.listen(8)
    print(f"[CABP Bridge] WebSocket Server ready at ws://{WS_HOST}:{WS_PORT}")
    while True:
        conn, _ = srv.accept()
        threading.Thread(target=handle_ws_client, args=(conn,), daemon=True).start()


if __name__ == "__main__":
    main()

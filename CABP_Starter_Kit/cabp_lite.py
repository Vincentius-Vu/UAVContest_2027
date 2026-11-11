"""
CPAS Agent Beacon Protocol (CABP) - Lite Reference Implementation
Dành cho Cuộc thi UAV Contest - Track Coordinated Ops
CPAS Lab - Trường Đại học Tôn Đức Thắng (TDTU)

Đặc tả:
- Periodic Beacon (5Hz): Phát broadcast trạng thái và ý định (intent)
- Discrete Event Message: mission_event khi UAV-A đặt kiện hàng
"""

import socket
import struct
import time
import json
from enum import IntEnum

# CABP Constants
CABP_PORT = 14555
CABP_MAGIC = 0xCB  # Magic byte để lọc gói tin ngoài luồng

class AgentState(IntEnum):
    IDLE = 0
    EXECUTING = 1
    RETURNING = 2
    LANDING = 3
    EMERGENCY = 4

class AgentIntent(IntEnum):
    HOVER = 0
    GO_TO_POINT = 1
    PICKUP = 2
    DELIVER = 3
    RETURN_HOME = 4
    LAND = 5

class EventType(IntEnum):
    PACKAGE_PLACED = 1
    PACKAGE_PICKED = 2
    MISSION_ABORT = 3

class CABPMessage:
    @staticmethod
    def pack_periodic_beacon(agent_id: int, seq_num: int, state: AgentState, intent: AgentIntent, 
                             x: float, y: float, z: float, battery_critical: bool) -> bytes:
        """
        Đóng gói bản tin định kỳ dạng Binary cực nhẹ (29 bytes)
        Format:
        - magic: uint8 (1 byte, 0xCB)
        - msg_type: uint8 (1 byte, 0x01 = Periodic)
        - agent_id: uint16 (2 bytes)
        - seq_num: uint32 (4 bytes)
        - timestamp: uint64 (8 bytes, ms)
        - state: uint8 (1 byte)
        - intent: uint8 (1 byte)
        - x: float32 (4 bytes)
        - y: float32 (4 bytes)
        - z: float32 (4 bytes)
        - battery_critical: uint8 (1 byte, 0 or 1)
        """
        ts_ms = int(time.time() * 1000)
        return struct.pack(
            ">BBHIQBBfffB",
            CABP_MAGIC, 0x01, agent_id, seq_num, ts_ms, 
            int(state), int(intent), float(x), float(y), float(z), 
            1 if battery_critical else 0
        )

    @staticmethod
    def unpack_periodic_beacon(data: bytes):
        if len(data) != 31: # 1+1+2+4+8+1+1+4+4+4+1 = 31 bytes
            return None
        unpacked = struct.unpack(">BBHIQBBfffB", data)
        if unpacked[0] != CABP_MAGIC or unpacked[1] != 0x01:
            return None
        return {
            "msg_type": "PERIODIC_BEACON",
            "agent_id": unpacked[2],
            "seq_num": unpacked[3],
            "timestamp": unpacked[4],
            "state": AgentState(unpacked[5]),
            "intent": AgentIntent(unpacked[6]),
            "position": (unpacked[7], unpacked[8], unpacked[9]),
            "battery_critical": bool(unpacked[10])
        }

    @staticmethod
    def pack_mission_event(agent_id: int, event_type: EventType, location_id: int) -> bytes:
        """
        Đóng gói bản tin sự kiện mission_event (16 bytes)
        Format:
        - magic: uint8 (0xCB)
        - msg_type: uint8 (0x02 = Event)
        - agent_id: uint16
        - event_type: uint8
        - location_id: uint8 (1: D1, 2: D2, 3: D3, 4: D4, 5: D5)
        - timestamp: uint64 (ms)
        - padding: 2 bytes
        """
        ts_ms = int(time.time() * 1000)
        return struct.pack(
            ">BBHBBQH",
            CABP_MAGIC, 0x02, agent_id, int(event_type), int(location_id), ts_ms, 0
        )

    @staticmethod
    def unpack_mission_event(data: bytes):
        if len(data) != 16:
            return None
        unpacked = struct.unpack(">BBHBBQH", data)
        if unpacked[0] != CABP_MAGIC or unpacked[1] != 0x02:
            return None
        return {
            "msg_type": "MISSION_EVENT",
            "agent_id": unpacked[2],
            "event_type": EventType(unpacked[3]),
            "location_id": unpacked[4], # 1: D1, 2: D2, 3: D3, 4: D4, 5: D5
            "timestamp": unpacked[5]
        }

class CABPBroadcaster:
    def __init__(self, port: int = CABP_PORT):
        self.port = port
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

    def send(self, packet: bytes, broadcast_ip: str = "255.255.255.255"):
        self.sock.sendto(packet, (broadcast_ip, self.port))

    def close(self):
        self.sock.close()

class CABPReceiver:
    def __init__(self, port: int = CABP_PORT):
        self.port = port
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.sock.bind(("", self.port))
        self.sock.settimeout(0.1)

    def receive(self):
        try:
            data, addr = self.sock.recvfrom(1024)
            if len(data) == 31:
                return CABPMessage.unpack_periodic_beacon(data), addr
            elif len(data) == 16:
                return CABPMessage.unpack_mission_event(data), addr
            return None, addr
        except socket.timeout:
            return None, None

    def close(self):
        self.sock.close()

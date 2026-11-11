"""
Mock UAV-A: Người điều khiển bay đặt hàng và phát mission_event qua CABP
Chạy độc lập để kiểm thử luồng truyền thông với UAV-B.
"""

import sys
import io
import time

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

from cabp_lite import CABPBroadcaster, CABPMessage, AgentState, AgentIntent, EventType

def main():
    agent_id = 101  # UAV-A ID
    broadcaster = CABPBroadcaster()
    print("=== [UAV-A SENDER] Khởi động chế độ mô phỏng đặt hàng ===")
    print("UAV-A đang cất cánh và thực hiện Phase 1 (Manual/Semi-auto)...")
    
    seq = 0
    # Mô phỏng phát periodic beacon trong 3 giây
    for i in range(15):
        seq += 1
        pkt = CABPMessage.pack_periodic_beacon(
            agent_id=agent_id,
            seq_num=seq,
            state=AgentState.EXECUTING,
            intent=AgentIntent.DELIVER,
            x=14.5, y=6.4, z=3.2,
            battery_critical=False
        )
        broadcaster.send(pkt)
        time.sleep(0.2)  # 5 Hz
    
    # Giả định UAV-A đặt thành công kiện hàng tại điểm D3 (location_id = 3)
    target_d = 3
    print(f"\n[SỰ KIỆN] UAV-A đã đặt kiện hàng thành công tại vị trí D{target_d}!")
    print("UAV-A bắt đầu phát lặp 3 lần bản tin mission_event qua CABP...")
    
    event_pkt = CABPMessage.pack_mission_event(
        agent_id=agent_id,
        event_type=EventType.PACKAGE_PLACED,
        location_id=target_d
    )
    
    for attempt in range(1, 4):
        broadcaster.send(event_pkt)
        print(f" -> Đã gửi mission_event lần {attempt}/3 (Vị trí: D{target_d})")
        time.sleep(0.08)
        
    print("\nUAV-A hoàn thành Giai đoạn 1 và bay về Depot.")
    broadcaster.close()

if __name__ == "__main__":
    main()

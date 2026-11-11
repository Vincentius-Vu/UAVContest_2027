"""
Mock UAV-B: Tự hành thực hiện Giai đoạn 2 (Lấy hàng)
Tích hợp State Machine:
- Lắng nghe CABP mission_event trong cửa sổ Timeout 3.0 giây
- Nếu nhận được bản tin hợp lệ -> Kích hoạt [ĐƯỜNG BONUS]: Bay thẳng tới điểm D đã báo
- Nếu hết 3.0 giây không nhận được -> Tự động Fallback sang [ĐƯỜNG CƠ BẢN]: Quét tuần tự các điểm ứng viên qua QR Code
"""

import sys
import io
import time

# Ensure UTF-8 output on Windows console
if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

from cabp_lite import CABPReceiver, EventType

TIMEOUT_SECONDS = 3.0
CANDIDATE_POINTS = [1, 3, 5]  # Tập 3 điểm bốc thăm ví dụ: D1, D3, D5

def execute_bonus_route(target_d: int):
    print(f"\n=======================================================")
    print(f"[*] KÍCH HOẠT [ĐƯỜNG BONUS] (Nhận thành công CABP!)")
    print(f"[*] Điểm đích trực tiếp: D{target_d}")
    print(f"[*] Bỏ qua hành trình quét tuần tự.")
    print(f"[*] UAV-B cất cánh tự động -> Tiếp cận D{target_d} -> Gắp kiện hàng -> Về Depot.")
    print(f"[*] KẾT QUẢ DỰ KIẾN: +60 ĐIỂM THƯỞNG COORDINATED OPS")
    print(f"=======================================================")

def execute_baseline_route():
    print(f"\n=======================================================")
    print(f"[!] HẾT TIMEOUT ({TIMEOUT_SECONDS}s) - TỰ ĐỘNG CHUYỂN SANG [ĐƯỜNG CƠ BẢN]")
    print(f"[!] Cơ chế Fallback an toàn kích hoạt: Không cần người can thiệp.")
    print(f"[!] Bắt đầu hành trình quét tuần tự tập ứng viên: {['D' + str(p) for p in CANDIDATE_POINTS]}")
    for pt in CANDIDATE_POINTS:
        print(f"    -> Đang bay tới kiểm tra D{pt}... Đọc QR Code... Kiểm tra hiện diện vật lý...")
        time.sleep(0.5)
    print(f"[*] Phát hiện kiện hàng tại điểm có mã QR khớp! Thực hiện gắp kiện hàng -> Về Depot.")
    print(f"[*] KẾT QUẢ DỰ KIẾN: +40 ĐIỂM THƯỞNG COORDINATED OPS")
    print(f"=======================================================")

def main():
    print("=== [UAV-B RELAY RECEIVER] Sẵn sàng tại Depot ===")
    print(f"Tập điểm ứng viên trận đấu: {['D' + str(p) for p in CANDIDATE_POINTS]}")
    print(f"Đang chờ tín hiệu Giai đoạn 1 kết thúc... Bắt đầu đếm ngược timeout {TIMEOUT_SECONDS}s cho CABP...")
    
    receiver = CABPReceiver()
    start_time = time.time()
    event_received = False
    target_point = None
    
    while time.time() - start_time < TIMEOUT_SECONDS:
        msg, addr = receiver.receive()
        if msg and msg.get("msg_type") == "MISSION_EVENT":
            if msg.get("event_type") == EventType.PACKAGE_PLACED:
                target_point = msg.get("location_id")
                event_received = True
                print(f"\n[CABP THÀNH CÔNG] Nhận bản tin từ Agent #{msg['agent_id']}: Vị trí D{target_point}")
                break
        time.sleep(0.05)
        
    receiver.close()
    
    if event_received and target_point is not None:
        execute_bonus_route(target_point)
    else:
        execute_baseline_route()

if __name__ == "__main__":
    main()

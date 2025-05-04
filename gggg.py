import requests, time

username = input('Nhập Username TikTok (Không nhập @): ').strip().replace('@', '')

while True:
    try:
        headers = {
            'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
            'accept': '*/*'
        }

        # Lấy token và session
        access = requests.get('https://tikfollowers.com/free-tiktok-followers', headers=headers)
        session = access.cookies.get('ci_session', '')
        token = access.text.split("csrf_token = '")[1].split("'")[0]

        headers['cookie'] = f'ci_session={session}'

        # Gửi yêu cầu follow
        data = f'{{"type":"follow","q":"@{username}","google_token":"t","token":"{token}"}}'
        search = requests.post('https://tikfollowers.com/api/free', headers=headers, data=data).json()

        if search.get('success'):
            data_follow = search['data']
            data = f'{{"google_token":"t","token":"{token}","data":"{data_follow}","type":"follow"}}'
            send = requests.post('https://tikfollowers.com/api/free/send', headers=headers, data=data).json()

            if send.get('type') == 'success':
                print(">>> Gửi follow thành công!")
            elif send.get('type') == 'info':
                message = send.get('message', '')
                if 'You need to wait' in message:
                    try:
                        mins = int(message.split('You need to wait for a new transaction. : ')[1].split(' ')[0])
                        print(f">>> Đang chờ {mins} phút cooldown...")
                        for i in range(mins * 60, 0, -1):
                            print(f'Chờ {i} giây...', end='\r')
                            time.sleep(1)
                        continue
                    except:
                        print(">>> Lỗi phân tích thời gian chờ.")
                else:
                    print(">>> Thông báo từ server:", message)
            else:
                print(">>> Lỗi không xác định khi gửi.")
        else:
            print(">>> Không lấy được token hợp lệ hoặc server từ chối.")

    except Exception as e:
        print(">>> Lỗi hệ thống:", e)
        time.sleep(10)


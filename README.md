# English Buddy 📱💻🌐
> **Đồ án môn Lập trình Thiết bị Di động (Cross-Platform Mobile & Web English Learning App)**  
> Ứng dụng hỗ trợ học tiếng Anh toàn diện **đa nền tảng (Android, Web & Desktop)** phát triển bằng **Flutter & Dart**: tích hợp **Luyện 4 kỹ năng (Nghe, Nói, Đọc, Viết)**, **Kho từ vựng 3.000+ mục từ CEFR A1–C1**, **Phòng luyện thi IELTS • TOEIC • CEFR có bấm giờ**, **Từ điển Offline & Online có bộ nhớ đệm SQLite (`dictionary_cache`)** và **Ôn tập ngắt quãng Spaced Repetition (SRS)**.

---

## 📌 1. Tổng quan các luồng chức năng cốt lõi

### 1.1. Điều hướng Đa nền tảng: Sidebar 13 mục riêng biệt & Mobile Drawer (`AppSidebar`, `MainNavigationScreen`)
- **Desktop & Web (`>= 820px`)**: Sidebar cố định bên trái, hỗ trợ mở rộng (`264px`) và thu gọn (`80px`), hiệu ứng hover/focus/pressed tinh tế, hiển thị trực tiếp **13 mục chức năng thực tế** (tuyệt đối không hiển thị các mục rỗng chưa có luồng hoạt động như Community, Podcast hay Truyện):
  1. **Trang chủ** (`HomeScreen`)
  2. **Chủ đề** (`TopicListScreen`)
  3. **Luyện nghe** (`SingleSkillScreen` – Listening)
  4. **Luyện đọc** (`SingleSkillScreen` – Reading)
  5. **Luyện viết** (`SingleSkillScreen` – Writing)
  6. **Luyện nói** (`SingleSkillScreen` – Speaking)
  7. **Shadowing** (`ShadowingHubScreen` & `ShadowingPracticeScreen`)
  8. **Từ vựng / Từ điển** (`DictionaryScreen`)
  9. **Luyện thi** (`ExamHubScreen`)
  10. **Trò chơi** (`GamesHubScreen`)
  11. **Ôn tập** (`ReviewScreen`)
  12. **Thống kê** (`StatsScreen`)
  13. **Cài đặt** (`SettingsScreen`)
- **Điện thoại & Màn hình hẹp (`< 820px`)**: Sử dụng thanh điều hướng dưới gọn nhẹ (`NavigationBar`) kết hợp `Drawer` chứa đầy đủ 13 mục và khu vực quản lý Tài khoản.

### 1.2. Luồng Luyện Tập Shadowing Chuyên Biệt (`ShadowingHubScreen`, `ShadowingPracticeScreen`)
- Danh sách bài học Shadowing phân loại theo **Chủ đề** và **Trình độ CEFR (`A1`–`C1`)**, mỗi bài gồm các câu hội thoại/đoạn nói có:
  - Văn bản tiếng Anh chuẩn, **sơ đồ trọng âm – nối âm – ngữ điệu** (`IN HOA` trọng âm, `_` nối âm, `|` ngắt nhịp, `↗`/`↘` ngữ điệu), nghĩa tiếng Việt, mẹo phát âm (`coachingTip`) và toàn văn Transcript.
- **Quy trình thực hành 4 bước chuẩn sư phạm**:
  - **Bước 1 – Nghe tốc độ chuẩn (`1.0x`)**: Nắm nhịp điệu tự nhiên và ngữ điệu toàn câu.
  - **Bước 2 – Nghe chậm (`0.75x`) & Phân tích**: Tách rõ từng cụm nối âm và trọng âm.
  - **Bước 3 – Nhại lại đồng thời (Shadowing)**: Bấm giờ thực hành nói đuổi theo giọng mẫu với bộ đếm lượt (`practiceCount`) hoặc kiểm tra micro thiết bị.
  - **Bước 4 – Bảng kiểm tự đánh giá (Self-Evaluation Checklist)**: Người học tự kiểm tra 4 tiêu chí phát âm/trọng âm/nối âm/ngữ điệu trước khi lưu tiến độ vào SQLite (`skill_scores` với `skill_type = 'shadowing'`).
- **Minh bạch kỹ thuật**: Ứng dụng tuyệt đối **không giả lập chấm điểm phát âm bằng AI** và **không tự ghi điểm giả** khi người học chưa thực hiện bước tự đánh giá.

### 1.3. Luyện tập 4 kỹ năng chuyên sâu & Trò chơi từ vựng (`SingleSkillScreen`, `GamesHubScreen`)
- **Bộ lọc trình độ CEFR (`A1` – `C1`) & Gợi ý bài học tiếp theo**: Tự động đề xuất bài luyện tập tiếp theo dựa trên lịch sử điểm số thực tế trong SQLite (`skill_scores`).
- 🎧 **Nghe hiểu (Listening)**:
  - Phát âm thanh hội thoại / bài nói bằng Text-to-Speech với 2 chế độ: **Tốc độ chuẩn (`1.0x`)** và **Nghe chậm (`0.75x`)**, hỗ trợ nghe lại nhiều lần.
  - **Khóa Transcript & Bản dịch trước khi nộp bài**: Lời thoại tiếng Anh và bản dịch tiếng Việt được giữ ẩn trong lúc làm câu hỏi trắc nghiệm / điền từ để rèn phản xạ nghe thực chất, và tự động mở khóa ngay sau khi người học nộp bài.
- 🗣️ **Luyện nói & Phát âm (Speaking)**:
  - Nghe câu mẫu chuẩn (`1.0x`) và chậm (`0.75x`), hướng dẫn trọng âm câu (Sentence Stress) và nối âm (Linking sounds).
  - Tích hợp **Đồng hồ bấm giờ tự luyện nói (Shadowing Timer)** và **Bảng kiểm tự đánh giá 4 tiêu chí (Speaking Self-Evaluation Rubric)**: âm cuối, trọng âm, nối âm/độ trôi chảy và ngữ điệu.
  - **Minh bạch kỹ thuật**: Ứng dụng lưu điểm tự đánh giá theo Rubric vào SQLite, tuyệt đối không giả lập điểm chấm phát âm AI tự động khi chưa tích hợp dịch vụ nhận dạng giọng nói chuyên sâu.
- 📖 **Đọc hiểu (Reading)**:
  - Bài đọc phân cấp từ `A1` đến `C1`, kết hợp cả **câu hỏi trắc nghiệm (Multiple Choice)** và **câu hỏi điền từ ngắn (Short-answer / Fill-in-the-blank)** kèm giải thích chi tiết từng câu.
  - **Danh sách Từ vựng trọng tâm trong bài (`keyWords`)**: Cho phép nghe phát âm từng từ và bấm **"Lưu từ"** để thêm trực tiếp vào kho từ vựng cần ôn tập (SRS) và danh sách Yêu thích.
- ✍️ **Luyện viết (Writing)**:
  - **Chế độ 1 – Cấu trúc & Sắp xếp câu (Sentence Scramble)**: Ghép các mảnh từ rời rạc thành câu hoàn chỉnh đúng ngữ pháp.
  - **Chế độ 2 – Viết đoạn văn / Bài luận theo Rubric (Guided Writing)**: Đếm số từ theo thời gian thực, tự động kiểm tra tỷ lệ sử dụng **từ khóa mục tiêu (`targetKeywords`)**, kiểm tra dấu câu kết thúc, bảng kiểm tự rà soát **Writing Rubric 4 tiêu chí** (Task Achievement, Coherence & Cohesion, Lexical Resource, Grammatical Accuracy).
  - Lưu toàn bộ bài viết của người học (`user_submission`) vào SQLite, cho phép xem lại lịch sử các bản nháp đã lưu và mở khóa **Bài viết mẫu tham khảo (Model Answer)** sau khi lưu. Không tạo điểm chấm AI giả.
- 🔤 **Từ vựng (Vocabulary)**:
  - **Flashcard 3D**, **Quiz phản xạ 3 chế độ**, **Trò chơi ghép cặp từ (Matching Pairs)**, **Từ mới lưu từ bài học**, **Danh sách yêu thích** và **Ôn tập lặp lại ngắt quãng SRS**.

### 1.2. Phòng Luyện Thi IELTS • TOEIC • CEFR (`ExamHubScreen`, `ExamAttemptScreen`, `ExamResultScreen`)
- Tổ chức theo định dạng kỳ thi (**IELTS Academic**, **TOEIC Workplace**, **CEFR Competency**), kỹ năng (*Reading*, *Listening*, *Mini Mock Test*), trình độ và thời lượng làm bài.
- **Giao diện làm đề bấm giờ thực chiến**:
  - Đồng hồ đếm ngược (`MM:SS`) tự động nộp bài khi hết giờ.
  - Thanh tiến độ làm bài và **Bảng điều hướng câu hỏi (Question Palette)** cho phép chuyển nhanh giữa các câu và **Đánh dấu câu hỏi cần xem lại (`🚩`)**.
  - Hỗ trợ cả câu hỏi trắc nghiệm (`mcq`) và điền từ/số vào chỗ trống (`fill` - Note/Summary Completion).
  - Hộp thoại xác nhận trước khi nộp bài (cảnh báo số câu chưa trả lời hoặc đang gắn cờ `🚩`).
- **Màn hình kết quả & Giải thích minh bạch**:
  - Hiển thị số câu đúng (`X/Y`), tỷ lệ phần trăm, thời gian hoàn thành, giải thích chi tiết từng câu và danh sách từ vựng học thuật/công sở trong đề để lưu vào kho ôn tập.
  - **Đánh giá năng lực trung thực**: Nhận xét mức độ nắm vững dạng bài dựa trên tỷ lệ đúng thực tế, kèm lưu ý rõ ràng rằng kết quả dùng để đánh giá kỹ năng luyện tập chứ không quy đổi giả tạo sang điểm Band IELTS hay điểm TOEIC chính thức của hội đồng khảo thí.
  - Lưu toàn bộ lịch sử làm đề vào bảng SQLite `exam_attempts`.

### 1.3. Từ điển Anh–Việt & Anh–Anh trực tuyến có Bộ nhớ đệm SQLite (`DictionaryScreen`)
- **Từ điển nội bộ (Offline 100%)**: Tra cứu tức thì hơn **3.000+ từ vựng, cụm động từ, collocation và thành ngữ** chuẩn CEFR `A1`–`C1`.
- **Tra cứu trực tuyến mở rộng & Caching Đa nguồn (`DictionaryApiService`)**:
  - Tách biệt rõ kiến trúc `DictionaryProvider` – `VocabularyRepository` – `DictionaryApiService`.
  - Hỗ trợ đa nguồn với cơ chế dự phòng tự động: **Free Dictionary API** và **Wikimedia Wiktionary REST API** (chuẩn **CC BY-SA 3.0**), tương thích hoàn toàn chuẩn **CORS trên Flutter Web** (không còn lỗi `ClientException: Failed to fetch`).
  - Hỗ trợ tra cứu Unicode, từ có dấu tiếng Việt, xử lý mã hóa URL an toàn (`Uri.encodeComponent`), và hỗ trợ proxy tùy biến qua `--dart-define=DICTIONARY_PROXY_URL=...`.
  - **Bộ nhớ đệm SQLite (`dictionary_cache`)**: Mọi từ đã tra trực tuyến đều được lưu cục bộ (từ loại, IPA, định nghĩa tiếng Anh, câu ví dụ, nguồn và giấy phép) để tái sử dụng ngay cả khi mất mạng.
  - Cho phép bấm **"Lưu vào từ vựng"** để thêm từ vừa tra trực tuyến vào danh sách học tập & SRS cục bộ.

### 1.4. Đấu trường Mini Games Từ vựng 4 trò chơi (`GamesHubScreen`)
- **1. Gõ Từ Siêu Tốc (Speed Typer - `WordTyperScreen`)**:
  - Chọn 3 mức độ trước khi xuất trận: **Dễ** (rơi chậm, từ ngắn A1–A2), **Bình thường** (cân bằng, A1–B2), **Khó / Pro** (tốc độ cao, A1–C1). Khóa mức độ trong trận và hiển thị huy hiệu trên HUD.
  - **Phi thuyền chiến đấu luôn cố định chính giữa theo chiều ngang ở đáy màn hình**, không bị dịch chuyển lệch góc khi đổi kích thước cửa sổ hay trên điện thoại.
  - Khi gõ đúng từ, phi thuyền bắn luồng tia sáng laze năng lượng mang chữ tới mục tiêu, phát nổ thành các mảnh hạt rực rỡ và điểm thưởng độ cao / combo.
- **2. Đấu trường từ vựng (Vocabulary Arena - `VocabularyArenaScreen`)**:
  - Thanh tiến trình 15 câu trực quan (✓/✗/câu hiện tại), hỗ trợ phím số `1`, `2`, `3`, `4` có keycap rõ nét, đồng hồ đếm ngược đổi màu động (>6s xanh, 3-6s cam, ≤3s đỏ) và thẻ giải thích chi tiết kèm phát âm TTS ngay sau khi chọn đáp án.
- **3. Mưa từ vựng (Word Rain - `WordRainScreen`)**:
  - Menu tùy chọn 3 mức tốc độ (Chậm / Bình thường / Nhanh), khung mục tiêu nổi bật với cấp độ và nghĩa tiếng Việt, hiệu ứng gợn sóng nước (Water Splash) khi chạm đúng giọt mưa hoặc khi giọt mục tiêu chìm xuống hồ nước.
- **4. Ong chính tả (Spelling Bee - `SpellingBeeScreen`)**:
  - Thanh 10 vòng thi, các ô chữ cái động `[ _ ] [ _ ]` điền theo thời gian thực khi gõ, hiệu ứng sóng âm khi phát âm TTS, 3 quyền trợ giúp (chữ cái đầu, xem nghĩa, câu ví dụ) và bảng phân tích lỗi sai chi tiết.

### 1.4. Đăng nhập, Tạo tài khoản & Chống Bot xác thực phía Server (`AuthScreen`, `AuthService`, `AntiBotService`)
- **Luồng xác thực (Web và Android)**:
  - Hỗ trợ **Đăng nhập với Google / Gmail**, **Email + Mật khẩu**, **Tên tài khoản + Mật khẩu khi có backend ánh xạ username**, **Tạo tài khoản**, **Đăng xuất**, trạng thái loading và thông báo lỗi tiếng Việt.
  - **Bảo mật nghiêm ngặt**:
    - Tuyệt đối **không tạo đăng nhập giả** lưu mật khẩu/tài khoản trong SQLite hoặc `SharedPreferences`.
    - Tuyệt đối **không lưu mật khẩu dạng văn bản thuần (plaintext password)** ở bất kỳ đâu trong ứng dụng, database cục bộ, log hay mã nguồn.
    - Tuyệt đối **không hardcode secret, private key, client secret** trong repository.
- **Chống Bot (Server-Verified Anti-Bot Architecture)**:
  - Trên Web, widget Cloudflare Turnstile gửi token đến endpoint máy chủ (`CAPTCHA_VERIFY_URL`), nơi secret được giữ phía server và gọi dịch vụ Siteverify.
  - Lưu ý triển khai: vì Firebase Auth REST vẫn có thể được gọi trực tiếp ngoài ứng dụng, xác minh Turnstile ở giao diện không tự chặn mọi yêu cầu đăng ký trực tiếp. Trước khi phát hành công khai, bật enforcement reCAPTCHA/anti-abuse của Firebase Authentication hoặc chuyển việc tạo tài khoản sang backend có kiểm soát.
  - Tuyệt đối **không dùng phép tính cộng trừ đơn giản hay checkbox "Tôi không phải robot" tự kiểm tra ở client** rồi coi đó là bảo mật chống bot thật.
  - Khi chưa cấu hình backend/provider (`CAPTCHA_SITE_KEY`, `CAPTCHA_VERIFY_URL`), ứng dụng hiển thị rõ cảnh báo trạng thái chưa kích hoạt Anti-Bot phía server và **không tạo trạng thái "đã vượt qua kiểm tra" giả**.
- **An toàn dữ liệu học tập cục bộ (Zero Local Data Loss)**:
  - Dữ liệu học tập trong SQLite vẫn tách biệt với phiên xác thực; đồng bộ dữ liệu đám mây chưa được triển khai.
  - Khi đăng nhập hoặc đăng xuất, **100% tiến độ học cục bộ được giữ nguyên**, không bao giờ bị xóa hay ghi đè.

---

## 🔐 2. Cấu hình Dịch vụ Xác thực (Firebase / Google OAuth) & Anti-Bot cho Chủ Dự Án

Ứng dụng đọc cấu hình qua biến môi trường biên dịch `--dart-define` (không lưu khóa bí mật trong mã nguồn). Khi chưa truyền các biến này, giao diện Đăng nhập / Tạo tài khoản sẽ hiển thị bảng chẩn đoán cấu hình chi tiết và giữ nguyên chế độ học Offline đầy đủ chức năng.

### 2.1. Danh sách biến môi trường (`--dart-define`)
| Tên biến | Vai trò | Ví dụ / Ghi chú |
| :--- | :--- | :--- |
| `FIREBASE_API_KEY` | Web API Key của dự án Firebase Authentication | Lấy trong *Firebase Console -> Project Settings -> General* |
| `GOOGLE_OAUTH_CLIENT_ID` | OAuth 2.0 Web Client ID dùng cho Google Sign-In web/Android | Lấy trong *Google Cloud Console -> APIs & Services -> Credentials* |
| `AUTH_BACKEND_URL` | *(Tùy chọn)* URL backend phân giải username thành email | Ví dụ: `https://api.yourdomain.com`; nếu chưa cấu hình, đăng nhập bằng email vẫn dùng được |
| `CAPTCHA_PROVIDER` | Nhà cung cấp Anti-Bot | Hiện hỗ trợ Cloudflare Turnstile trên Web |
| `CAPTCHA_SITE_KEY` | Public Site Key của Turnstile (hiển thị ở client) | Chỉ dùng Site Key công khai, **không** dùng Secret Key |
| `CAPTCHA_VERIFY_URL` | Endpoint Backend nhận `token` từ client và gọi `siteverify` | Ví dụ: `https://api.yourdomain.com/auth/verify-captcha` |
| `BOOTSTRAP_ADMIN_EMAIL` | *(Tùy chọn)* Email tài khoản được cấp quyền `admin` đầu tiên khi đăng nhập | Không hardcode email hay mật khẩu admin trong mã nguồn |
| `BOOTSTRAP_ADMIN_UID` | *(Tùy chọn)* UID Firebase được cấp quyền `admin` đầu tiên khi đăng nhập | Thay thế hoặc kết hợp với Firebase Custom Claims / `ADMIN_EMAILS` trên server |

### 2.2. Các bước thiết lập dành cho Chủ Dự Án (Project Owner Checklist)
1. **Tạo Firebase Project & Bật Authentication**:
   - Truy cập [Firebase Console](https://console.firebase.google.com/), tạo project mới và vào mục **Authentication -> Sign-in method**.
   - Bật **Email/Password** và **Google** provider.
2. **Khai báo ứng dụng theo nền tảng & SHA-1 / SHA-256**:
   - **Android**: Đăng ký package name `com.englishbuddy.app.english_buddy`, lấy chứng chỉ `SHA-1` và `SHA-256` bằng lệnh `cd android && ./gradlew signingReport`, thêm vào Google Cloud/Firebase Console. Đăng nhập Google dùng Web Client ID làm `serverClientId`.
   - **Web**: Trong *Google Cloud Console -> Credentials*, tạo **OAuth 2.0 Web Client ID** và thêm các Authorized JavaScript origins của môi trường phát triển/production (ví dụ `http://localhost:7357` và domain ứng dụng). Windows desktop native chưa hỗ trợ Google Sign-In trong bản hiện tại.
3. **Thiết lập Server Verification cho Anti-Bot (Cloudflare Turnstile)**:
   - Tạo widget tại Cloudflare Turnstile để nhận **Site Key** (đưa vào `--dart-define=CAPTCHA_SITE_KEY=...`) và **Secret Key** (chỉ lưu trong biến môi trường của Backend/Cloud Function).
   - Có sẵn mẫu Worker tại `backend/turnstile-worker.js`. Deploy Worker, đặt `TURNSTILE_SECRET`, `ALLOWED_ORIGINS` và (khuyến nghị) `ALLOWED_HOSTNAMES` làm secret/variable, rồi truyền URL Worker làm `CAPTCHA_VERIFY_URL`. Không đưa Turnstile secret vào ứng dụng Flutter.
   - Widget Turnstile và nút Google chính thức được tích hợp trên Web; Android cần CAPTCHA trong WebView trước khi bật đăng ký có anti-bot. Windows native chưa hỗ trợ OAuth/CAPTCHA trong cấu hình này. Đăng nhập email/password bằng email có thể hoạt động trên Android khi cấu hình Firebase.

---

## ⚖️ 3. Nguồn dữ liệu, Bản quyền & Tính Minh bạch (Copyright & Attribution)

1. **Nội dung từ vựng (3.000+ mục), bài tập 4 kỹ năng & bộ đề luyện thi**:
   - Được **biên soạn gốc (Original Educational Content)** mô phỏng theo khung năng lực ngoại ngữ **CEFR (`A1`–`C1`)** và cấu trúc kỹ năng học thuật/công sở phổ biến.
   - **Không sao chép trái phép** đề thi, đoạn băng ghi âm hay sách có bản quyền của Cambridge, ETS (TOEIC), British Council hay các nền tảng thương mại.
   - Mỗi bài tập và bộ đề đều lưu trữ đầy đủ metadata bản quyền (`ContentAttribution`: `author`, `source`, `license`, `updatedAt`) và hiển thị công khai trên giao diện.
2. **Nguồn từ điển & Tra cứu hai chiều Việt–Anh / Anh–Việt**:
   - **Tra cứu hai chiều thông minh**: Tự động nhận diện ngôn ngữ truy vấn (có dấu, không dấu hoặc cụm từ). Nhập tiếng Việt (ví dụ: "căn hộ") ➜ hiển thị từ tiếng Anh tương đương ("apartment", "flat"), từ loại, nghĩa đối chiếu, phiên âm IPA và ví dụ. Nhập tiếng Anh (ví dụ: "apartment") ➜ hiển thị bản dịch tiếng Việt ("căn hộ"), từ loại, định nghĩa tiếng Anh Wiktionary và ví dụ.
   - **Nguồn dịch thuật & Từ điển**: Kết hợp dịch nghĩa đa chiều từ **Google Translate API** (hỗ trợ CORS chuẩn Web, không cần secret) và dữ liệu định nghĩa học thuật từ **Wikimedia Wiktionary REST API** cùng **Free Dictionary API** theo giấy phép **Creative Commons Attribution-ShareAlike 3.0 (CC BY-SA 3.0)**.
   - **Bộ nhớ đệm SQLite (`dictionary_cache`)**: Mọi kết quả tra cứu hai chiều được tự động lưu vào bộ nhớ đệm cục bộ, cho phép xem lại tức thì offline mà không làm mất dữ liệu người dùng hay giới hạn số từ tra cứu.
   - **Lưu vào kho từ vựng & Ôn tập (SRS)**: Người dùng có thể nhấn nút "Lưu vào từ vựng & Ôn tập" trên thẻ kết quả trực tuyến để đưa từ mới vào lộ trình Spaced Repetition (SRS) mà không ghi đè dữ liệu tiến độ hiện có.
3. **Báo cáo minh bạch các tính năng cần quyền thiết bị / dịch vụ ngoài**:
   - **Hoạt động đầy đủ ngay lập tức (Offline & Đa nền tảng)**: Toàn bộ 3.000+ từ vựng, Flashcard 3D, Quiz, Game ghép từ, bài tập Nghe/Nói/Đọc/Viết, Phòng luyện thi IELTS/TOEIC/CEFR, lưu bài viết, chấm điểm theo quy tắc & Rubric, thống kê và giao diện Sáng/Tối.
   - **Cần kết nối Internet**: Tra cứu từ mới lần đầu trên Free Dictionary API (các lần tra lại cùng từ đó sẽ đọc từ bộ nhớ đệm SQLite `dictionary_cache` không cần mạng).
   - **Cần Engine TTS của Hệ điều hành/Trình duyệt**: Phát âm giọng đọc tiếng Anh (`flutter_tts` sử dụng Web Speech API trên Chrome và Google TTS trên Android/Windows).
   - **Không giả lập AI**: Tính năng Luyện Nói và Luyện Viết sử dụng bộ đếm thời gian, kiểm tra quy tắc thực tế (số từ, từ khóa mục tiêu, dấu câu) và Bảng kiểm tự đánh giá (Self-Evaluation Rubric) kèm bài mẫu tham khảo; không tạo điểm chấm AI giả.

---

## 🗄️ 4. Thiết kế Cơ sở Dữ liệu SQLite (Version 7 – Zero Data Loss Migration)

Cơ sở dữ liệu cục bộ được nâng cấp lên **Version 7** với cơ chế an toàn tự động bổ sung dữ liệu seed 3.000 từ vựng mà **giữ nguyên 100% tiến độ học tập, SRS, từ yêu thích và lịch sử làm bài cũ**:
1. **`topics`**: 8 danh mục chủ đề học tập (`id`, `name`, `icon_name`, `color_hex`, `description`).
2. **`words`** (3.000+ mục từ CEFR `A1`–`C1` + từ người dùng lưu thêm): `id`, `topic_id`, `term`, `ipa`, `part_of_speech`, `meaning`, `english_definition`, `example_en`, `example_vi`, `pronunciation_guide`, `level`, `item_type`, `synonyms`, `antonyms`, `is_favorite`, `status`, `review_count`, `last_reviewed_at`, `next_review_at`, `interval_days`.
3. **`quiz_history`**: Lịch sử làm bài Quiz từ vựng.
4. **`search_history`**: Lịch sử từ khóa tra cứu từ điển.
5. **`skill_scores`**: Lưu kết quả luyện tập 4 kỹ năng (`id`, `skill_type`, `exercise_id`, `title`, `score`, `user_submission`, `details_json`, `completed_at`).
6. **`exam_attempts`**: Lưu lịch sử làm đề luyện thi IELTS/TOEIC/CEFR (`id`, `exam_id`, `exam_title`, `exam_category`, `skill_section`, `total_questions`, `correct_answers`, `score_percentage`, `duration_seconds`, `answers_json`, `completed_at`).
7. **`dictionary_cache`**: Bộ nhớ đệm lưu kết quả tra cứu từ điển trực tuyến kèm giấy phép (`word`, `payload_json`, `source_name`, `source_url`, `license`, `cached_at`).

---

## 💻 5. Hướng dẫn chạy & Kiểm thử dự án

### Chạy ứng dụng (Chế độ Offline / Mặc định):
```bash
# 1. Cài đặt dependencies
flutter pub get

# 2. Chạy trên trình duyệt Web (Google Chrome)
flutter run -d chrome

# 3. Chạy trên thiết bị/máy ảo Android
flutter run -d android

# 4. Chạy trên Windows Desktop
flutter run -d windows
```

### Chạy ứng dụng kèm cấu hình Firebase Auth, Google OAuth & Anti-Bot Server:
```bash
flutter run -d chrome \
  --dart-define=FIREBASE_API_KEY=your_firebase_web_api_key \
  --dart-define=GOOGLE_OAUTH_CLIENT_ID=your_google_oauth_client_id.apps.googleusercontent.com \
  --dart-define=CAPTCHA_PROVIDER=cloudflare_turnstile \
  --dart-define=CAPTCHA_SITE_KEY=your_public_turnstile_site_key \
  --dart-define=CAPTCHA_VERIFY_URL=https://your-backend.example.com/api/verify-captcha
```

### Kiểm tra chất lượng mã nguồn & Chạy bộ kiểm thử tự động:
```bash
flutter analyze
flutter test
```

from pathlib import Path
import json, csv, zipfile
from docx import Document
from docx.shared import Pt, Cm, RGBColor

OUT = Path(__file__).parent
segments = []
def add(start, end, title, text, pause=0.8, note=''):
    segments.append(dict(start=start,end=end,title=title,text=text,pause=pause,note=note))

add(0,14,'Chào thầy – đăng ký – đăng nhập',
'''Nhóm chúng em chào thầy. Chúng em xin giới thiệu ứng dụng học tiếng Anh English Buddy. Người dùng đăng ký bằng tên, email, mật khẩu và xác minh chống bot. Đăng ký thành công, ứng dụng trở về trang đăng nhập. Form cũng có lựa chọn Google. Ở đây, nhóm dùng email và mật khẩu để vào hệ thống.''',0.3,
'Đọc ngay từ đầu video. Màn hình chuyển từ đăng ký sang đăng nhập khoảng 00:08, vào Trang chủ khoảng 00:14. Đây là đoạn đọc nhanh nhất; không thêm một lời mở đầu dài trước đoạn này.')
add(14,22,'Trang chủ sau đăng nhập',
'''Đăng nhập thành công, trang chủ hiển thị lời chào theo tên tài khoản, tiến độ học, chuỗi ngày học và các lối tắt. Thanh bên trái giúp chuyển nhanh giữa những chức năng chính.''',0.4)
add(22,34,'Đổi ngôn ngữ trực tiếp',
'''Trong cài đặt, người dùng có thể thay đổi ngôn ngữ giao diện. Nhóm lần lượt chọn tiếng Anh, tiếng Trung và tiếng Nhật. Các nhãn trên trang và thanh điều hướng thay đổi theo lựa chọn, sau đó chúng em chuyển về tiếng Việt.''',0.8)
add(34,43,'Danh sách mười ba ngôn ngữ',
'''Hộp chọn mở rộng cung cấp mười ba ngôn ngữ, kèm tên bản địa, ô tìm kiếm và dấu đánh dấu lựa chọn hiện tại. Người dùng cuộn danh sách để tìm ngôn ngữ phù hợp.''',0.8)
add(43,51,'Giao diện – mục tiêu – âm thanh',
'''Bên dưới là chế độ sáng, tối hoặc theo hệ thống; mục tiêu học hằng ngày; công tắc phát âm và thông tin bản quyền. Từ đây, người dùng cũng mở được hồ sơ cá nhân.''',0.5)
add(51,67,'Hồ sơ – avatar – tiến độ tuần',
'''Trang hồ sơ hiển thị tên, email, vai trò, cấp độ và chuỗi ngày học. Ảnh đại diện có thể chọn từ thiết bị, đường dẫn ảnh hoặc mẫu có sẵn. Bên dưới là tiến độ bảy ngày, số ngày hoạt động, số từ đã học hoặc ôn và bài hoàn thành. Tuần này chưa có hoạt động nên biểu đồ đang trống.''',0.8,
'Ảnh đại diện mới xuất hiện khoảng 01:06. Không nói người dùng đã hoàn thành mục tiêu tuần; các chỉ số tuần trong cảnh này đang bằng không.')
add(67,80,'Chỉnh sửa thông tin cá nhân',
'''Ở phần thông tin, nhóm thay đổi tên hiển thị, nhập giới thiệu bản thân và chọn mục tiêu mười từ mỗi ngày. Form còn có mục tiêu học tập, trường tên đăng nhập và email. Cấp độ hiện tại được hiển thị riêng, không cho sửa trực tiếp tại đây.''',0.8,
'Video sửa tên hiển thị và bio, không thực hiện đổi username. Không đọc rằng username đã được đổi thành công.')
add(80,89,'Lưu hồ sơ',
'''Nhấn Lưu thay đổi, ứng dụng thông báo cập nhật thành công. Tên và ảnh đại diện mới xuất hiện trong khu vực tài khoản. Người học có thể quay lại chỉnh sửa hồ sơ khi cần.''',0.8)
add(89,99,'Các thành phần trang chủ',
'''Trở lại trang chủ, lời chào đã đổi tên. Các thẻ thống kê tóm tắt tiến độ. Từ vựng hôm nay có phát âm, nghĩa, ví dụ, yêu thích và đổi từ. Bên dưới là chủ đề cùng các lối tắt.''',0.7)
add(99,110,'Thiết lập Quiz',
'''Nhóm mở Thử thách Quiz. Người dùng có thể kiểm tra tổng hợp hoặc chọn một chủ đề, đồng thời chọn năm hay mười câu hỏi. Ở đây, chúng em chọn Sức khỏe và Thể thao, với bài kiểm tra nhanh gồm năm câu.''',0.8)
add(110,120,'Trả lời và kiểm tra đáp án Quiz',
'''Bài kiểm tra có thanh tiến độ và các phương án trả lời. Người học chọn đáp án rồi bấm Kiểm tra. Câu đúng được tô xanh, đi kèm câu hoàn chỉnh và nghĩa tiếng Việt để đối chiếu ngay.''',1.0)
add(120,130,'Các dạng câu hỏi và phản hồi sai',
'''Các câu tiếp theo kết hợp chọn từ theo nghĩa và điền từ vào ngữ cảnh. Khi chọn sai, ứng dụng đánh dấu phương án sai bằng màu đỏ, đồng thời chỉ ra đáp án đúng để người học nhận biết lỗi.''',0.8)
add(130,142,'Kết quả Quiz',
'''Kết thúc lượt làm, nhóm trả lời đúng ba trên năm câu, đạt sáu mươi phần trăm. Trang kết quả liệt kê từng câu, đáp án đã chọn và phần giải thích. Từ trả lời sai được đưa vào diện cần ôn. Người học có thể làm lại hoặc về trang chủ.''',0.8)
add(142,152,'Danh sách chủ đề',
'''Kho từ vựng được chia thành tám chủ đề, từ giao tiếp, du lịch đến công nghệ, sức khỏe và môi trường. Mỗi thẻ có số lượng từ cùng tiến độ ghi nhớ. Nhóm chọn chủ đề Công sở và Sự nghiệp.''',0.7)
add(152,167,'Học bằng Flashcard',
'''Chế độ học thẻ hiển thị từ tiếng Anh, từ loại, phiên âm và nút nghe phát âm. Chạm vào thẻ để lật sang nghĩa tiếng Việt cùng câu ví dụ. Sau mỗi từ, người học chọn Cần ôn tập hoặc Đã nhớ. Thanh phía trên cho biết vị trí hiện tại trong bộ thẻ.''',1.4,
'Dành khoảng nghỉ cuối cho thao tác chuyển thẻ. Trong video lần lượt thấy Office, Boss và Email.')
add(167,173,'Danh sách từ và bộ lọc',
'''Quay lại danh sách, trạng thái ghi nhớ đã cập nhật. Trang còn có tìm kiếm, bộ lọc, yêu thích, thêm từ và lối vào Quiz.''',0.4,
'Chỉ giới thiệu các điều khiển hiện trên trang; không mô tả một thao tác thêm từ đã hoàn tất vì video không mở form thêm từ.')
add(173,182,'Luyện nghe – trình phát',
'''Tiếp theo là luyện nghe. Bài giới thiệu bản thân có nút phát, phát lại và điều chỉnh tốc độ. Người học nghe nội dung trước khi trả lời các câu hỏi bên dưới.''',1.5,
'Có thao tác phát âm thanh. Nếu giữ tiếng ứng dụng, giảm nhạc nền và dành khoảng nghỉ cuối đoạn cho âm thanh mẫu.')
add(182,196,'Luyện nghe – trắc nghiệm và điền từ',
'''Bài này gồm hai câu trắc nghiệm và một câu điền từ. Nhóm chọn thành phố, môn thể thao, rồi nhập từ còn thiếu trong câu. Phần từ vựng trọng tâm cung cấp nghĩa, ví dụ, nút phát âm và chức năng lưu từ. Hoàn tất câu trả lời, chúng em nhấn Nộp bài và Chấm điểm.''',0.8)
add(196,211,'Luyện nghe – kết quả và transcript',
'''Kết quả của lượt luyện nghe là ba trên ba câu đúng. Từng đáp án có giải thích dựa trên nội dung bài nghe. Sau khi nộp, người học mở lời thoại và bản dịch để đối chiếu. Các từ trọng tâm vẫn có thể nghe lại hoặc lưu, và nút Làm lại bài này hỗ trợ luyện thêm.''',1.2)
add(211,224,'Luyện đọc – chọn bài và đọc văn bản',
'''Phần luyện đọc có bộ lọc trình độ, gợi ý bài tiếp theo và lịch sử luyện tập. Nhóm mở bài Một buổi sáng cuối tuần. Văn bản tiếng Anh nằm phía trên, có nút nghe đọc và bản dịch đối chiếu; phía dưới là câu hỏi kiểm tra mức độ hiểu bài.''',0.8)
add(224,235,'Luyện đọc – trả lời câu hỏi',
'''Người học trả lời câu hỏi về giờ thức dậy, rồi điền từ chỉ ban công vào câu còn thiếu. Các từ trọng tâm được giải nghĩa ngay bên dưới. Nhóm hoàn thiện câu trả lời và nộp bài để xem kết quả.''',0.9)
add(235,247,'Luyện đọc – xem kết quả và bản dịch',
'''Ứng dụng thông báo hai trên hai câu đúng, tương ứng một trăm phần trăm. Mỗi câu có phần giải thích giúp người học xác định thông tin trong đoạn văn. Nhóm mở bản dịch tiếng Việt để đối chiếu, sau đó trở lại danh sách bài đọc.''',1.0)
add(247,260,'Luyện viết – hai hình thức',
'''Luyện viết được tổ chức thành hai phần: sắp xếp câu và viết đoạn văn theo tiêu chí. Nhóm mở bài Viết email công sở và Đàm phán. Ở phần đầu, ứng dụng đưa nghĩa tiếng Việt, gợi ý cấu trúc và các từ rời để người học ghép thành câu tiếng Anh.''',0.8)
add(260,274,'Sắp xếp câu đầu tiên',
'''Khi chọn từng từ, chúng sẽ xuất hiện trong khung trả lời theo đúng thứ tự thao tác. Sau đó, người học bấm Kiểm tra câu. Ở lần thử này, thứ tự chưa đúng nên hệ thống báo lỗi và đưa ra câu chuẩn để người học so sánh, nhận biết vị trí cần sửa.''',1.0)
add(274,291,'Sắp xếp câu thứ hai',
'''Câu tiếp theo yêu cầu diễn đạt lời nhắc nộp báo cáo trước thời hạn. Người học tiếp tục chọn các mảnh từ theo thứ tự. Dạng bài này giúp luyện cấu trúc câu, cách dùng động từ và cụm từ trong tình huống công sở. Các từ đã chọn được đưa ra khỏi danh sách còn lại, giúp theo dõi quá trình ghép câu.''',1.3)
add(291,301,'Sắp xếp câu thứ ba',
'''Với câu đề nghị đổi lịch họp, nhóm tiếp tục thử cách sắp xếp. Sau khi kiểm tra, ứng dụng hiển thị đáp án đúng. Người học có thể đối chiếu cấu trúc đề nghị trước khi chuyển sang phần viết đoạn văn.''',0.8)
add(301,317,'Viết đoạn văn – đề bài và yêu cầu',
'''Phần viết đoạn văn yêu cầu soạn một email cập nhật tiến độ dự án và đề xuất lịch họp. Đề bài đưa khoảng độ dài cùng các từ khóa mục tiêu. Bên dưới là khung nhập nội dung và bộ đếm từ. Khi chưa nhập, hệ thống hiển thị rõ số từ bằng không và những yêu cầu chưa đáp ứng.''',1.2)
add(317,333,'Viết đoạn văn – bốn tiêu chí tự đánh giá',
'''Bảng kiểm bên dưới gồm bốn tiêu chí: đáp ứng yêu cầu đề bài, bố cục và liên kết ý, sử dụng từ vựng, cùng ngữ pháp và dấu câu. Người học tự đánh dấu những tiêu chí mình đã thực hiện. Đây là bước tự rà soát bài viết, không phải kết quả chấm ngữ pháp tự động của trí tuệ nhân tạo.''',1.2)
add(333,349,'Viết đoạn văn – hướng dẫn trước khi nhập',
'''Trong lúc chuẩn bị nội dung, người học có thể kiểm tra lại chủ đề và nhóm từ gợi ý. Một bài viết phù hợp cần đủ độ dài, bám sát tình huống và trình bày mạch lạc. Bộ đếm từ cùng các chỉ báo bên dưới hỗ trợ theo dõi yêu cầu cơ bản; chất lượng diễn đạt vẫn cần được đọc lại và chỉnh sửa.''',1.5,
'Màn hình gần như đứng yên và khung viết còn trống. Đây là lời giải thích ngay trên cảnh chờ, không nói nội dung đã được nhập ở thời điểm này.')
add(349,359,'Nhập đoạn văn minh họa',
'''Nhóm nhập một đoạn văn để minh họa thao tác. Bộ đếm từ cập nhật ngay; hệ thống báo đã đủ độ dài, nhưng chưa có các từ khóa mục tiêu. Khi làm bài thực tế, nội dung cần bám đúng chủ đề email.''',0.8,
'Đoạn văn trong video nói về sinh hoạt hằng ngày, không phải email công sở. Không khẳng định bài này đạt yêu cầu nội dung hoặc đạt điểm cao.')
add(359,376,'Lưu bài viết – bài mẫu – lịch sử',
'''Sau khi lưu, ứng dụng mở bài mẫu tham khảo và hiển thị bản viết vừa lưu trong lịch sử. Người học có thể đọc hoặc nghe bài mẫu, so sánh cách triển khai ý và sử dụng từ khóa. Bản nháp được giữ lại để xem lại. Khi trở về danh sách, lượt luyện viết mới cũng xuất hiện trong phần lịch sử kỹ năng.''',1.4)
add(376,389,'Luyện nói – nghe mẫu và tự luyện',
'''Ở phần luyện nói, nhóm chọn bài Phát âm và Ngữ điệu giao tiếp. Mỗi câu có nội dung tiếng Anh, nghĩa tiếng Việt và hướng dẫn trọng âm, nối âm. Người học nghe ở tốc độ chuẩn hoặc chậm, đồng thời có thể bật đồng hồ để tự luyện nói theo mẫu.''',1.0)
add(389,400,'Luyện nói – rubric và chuyển câu',
'''Bảng tự đánh giá gồm âm cuối, trọng âm, nối âm và ngữ điệu. Nhóm chuyển qua các câu mẫu để quan sát hướng dẫn tương ứng. Điểm trên bảng phản ánh tiêu chí tự chọn; đây không phải điểm nhận dạng giọng nói tự động.''',0.8,
'Cuối bài có nút Lưu nhưng cảnh quay rời bài; không nói đã lưu thành công lượt nói này.')
add(400,411,'Shadowing – lọc bài và phân tích câu',
'''Phòng Shadowing cho phép lọc theo trình độ và chủ đề. Nhóm mở bài Chào hỏi và Bắt chuyện tự nhiên. Mỗi câu có bản đồ trọng âm, nối âm, nhịp ngắt, nghĩa tiếng Việt và mẹo phát âm để người học quan sát trước khi luyện.''',0.8)
add(411,423,'Shadowing – nghe chậm và nói đuổi',
'''Quy trình gồm nghe mẫu, nghe chậm, nói đuổi theo và tự đánh giá. Khi bắt đầu nói đuổi, đồng hồ ghi nhận thời gian thực hành. Giao diện cũng có chức năng kiểm tra micro thiết bị. Người học dừng lượt luyện khi hoàn tất rồi chuyển sang bảng kiểm.''',1.0)
add(423,435,'Shadowing – transcript và tự đánh giá',
'''Bảng kiểm gồm nhịp điệu, trọng âm, nối âm và ngữ điệu. Nhóm mở toàn bộ lời thoại, rồi chuyển câu để xem hướng dẫn riêng. Trong lượt minh họa này, các ô tự đánh giá chưa được chọn, nên chúng em không xem đây là lượt luyện đã hoàn tất.''',0.8)
add(435,449,'Từ điển – các bộ lọc',
'''Từ điển hỗ trợ tra cứu Việt sang Anh và Anh sang Việt. Người dùng có thể kết hợp bộ lọc cấp độ, chủ đề và từ loại, đồng thời xem lại từ khóa đã tra. Mỗi kết quả có phiên âm, nghĩa, định nghĩa tiếng Anh, ví dụ, nút nghe và biểu tượng yêu thích.''',1.0)
add(449,464,'Từ điển – tra trực tuyến và lưu từ',
'''Nhóm nhập cụm từ cái cây. Khi kho nội bộ chưa có kết quả phù hợp, phần tra trực tuyến cung cấp từ tiếng Anh tương ứng là tree, cùng định nghĩa và ví dụ. Người học có thể nghe phát âm và xem thông tin nguồn. Nhấn Lưu sẽ đưa từ này vào kho từ vựng và danh sách ôn tập.''',0.9)
add(464,478,'Kho luyện thi',
'''Phòng luyện thi tập hợp các đề IELTS, TOEIC và bài theo khung trình độ châu Âu. Người dùng lọc theo định dạng, kỹ năng và xem số câu, thời lượng từng đề. Danh sách có bài đọc, nghe, viết và đề tổng hợp; bên dưới còn lưu lịch sử những lần làm trước.''',1.0)
add(478,484,'Xem lại bài thi cũ',
'''Mở lịch sử để xem kết quả, đáp án, giải thích và từ vựng cần lưu. Điểm quy đổi chỉ mang tính tham khảo luyện tập.''',0.4)
add(484,498,'Luyện thi nghe – chọn chế độ',
'''Mỗi đề có chế độ thi tính giờ và luyện tập tự do. Nhóm chọn luyện tập cho bài nghe. Trình phát chia thành nhiều phần, có tốc độ chuẩn và chậm. Dãy số phía trên giúp chuyển câu; yêu cầu số từ được ghi rõ cạnh nội dung câu hỏi.''',1.0)
add(498,514,'Luyện thi nghe – gợi ý và điều hướng',
'''Trong chế độ luyện tập, người học có thể mở gợi ý và lời giải ngay tại câu đang làm. Nhóm xem đáp án mẫu, chuyển sang câu tiếp theo và đổi phần nghe. Các nút Câu trước, Câu tiếp theo cùng bảng số giúp di chuyển thuận tiện mà không phải làm tuần tự từ đầu.''',1.1)
add(514,526,'Chuyển sang thi đọc tính giờ',
'''Tiếp theo, nhóm quay lại kho đề và chọn bài đọc về không gian xanh đô thị. Lần này chúng em dùng chế độ thi tính giờ. Người học phải tự trả lời trong thời gian quy định, rồi nộp bài để xem kết quả và phần giải thích.''',0.9)
add(526,537,'Làm bài thi đọc và xác nhận nộp',
'''Bài đọc nằm bên trái, câu hỏi bên phải. Phía trên có đồng hồ đếm ngược và bảng số câu; mỗi câu có tùy chọn đánh dấu. Nhóm thử trả lời, chuyển câu và nhấn nộp. Hộp xác nhận giúp tránh nộp nhầm.''',0.7)
add(537,546,'Kết quả thi đọc',
'''Lượt thử này không có câu đúng. Trang kết quả vẫn chỉ rõ đáp án đã chọn, đáp án chuẩn và giải thích từng câu. Phần từ vựng phía dưới giúp người học bổ sung kiến thức sau bài thi.''',0.6)
add(546,555,'Trung tâm trò chơi – Chiến cơ vũ trụ',
'''Trung tâm trò chơi có bộ lọc chủ đề, cấp độ và lịch sử lượt chơi. Nhóm bắt đầu với Chiến cơ vũ trụ, chọn mức trung bình và chế độ gõ từ tiếng Anh.''',0.7)
add(555,570,'Chiến cơ – gõ từ và bắn mục tiêu',
'''Các thiên thạch mang từ tiếng Anh và nghĩa tiếng Việt rơi xuống màn hình. Khi người chơi gõ đúng, mục tiêu được khóa và phi thuyền bắn đạn để phá hủy. Điểm số tăng theo thao tác chính xác. Trò chơi kết hợp ghi nhớ cách viết với phản xạ bàn phím trong một tình huống trực quan.''',1.4)
add(570,585,'Chiến cơ – theo dõi trạng thái',
'''Thanh thông tin cho biết điểm, cấp độ, số mạng và trạng thái phòng thủ, kèm nút tạm dừng. Bảng phía dưới theo dõi từ mục tiêu, tốc độ gõ, độ chính xác và radar. Nếu để mục tiêu lọt qua phòng tuyến, khả năng phòng thủ suy giảm. Người chơi cần xử lý kịp thời các từ đang tiến gần đáy.''',1.4)
add(585,599,'Chiến cơ – kết thúc và ôn từ',
'''Khi không còn khả năng chống đỡ, lượt chơi kết thúc. Bảng tổng kết hiển thị độ khó, điểm, cấp độ, tốc độ gõ, độ chính xác và chuỗi đúng. Danh sách từ cần ôn có nút nghe phát âm. Người chơi có thể chơi lại hoặc thoát về trung tâm để chọn trò khác.''',1.2)
add(599,613,'Đấu trường từ vựng – thiết lập',
'''Tiếp theo là Đấu trường từ vựng. Nhóm chọn mức dễ trong ba mức độ khó. Mỗi câu có thời gian giới hạn và bốn phương án, chọn bằng chuột hoặc phím số. Câu hỏi gồm chọn nghĩa, chọn từ và đọc định nghĩa. Thanh trên theo dõi tiến độ, điểm và số mạng.''',1.0)
add(613,628,'Đấu trường – phản hồi và combo',
'''Nếu trả lời sai, phương án đã chọn chuyển đỏ, đáp án đúng được tô xanh và có giải thích kèm phát âm. Khi trả lời đúng liên tiếp, chuỗi kết hợp tăng và tạo điểm thưởng. Người chơi vừa cần chính xác, vừa phải chú ý đồng hồ, vì mỗi câu chỉ có một khoảng thời gian ngắn.''',1.2)
add(628,639,'Đấu trường – tiếp tục lượt đấu',
'''Các câu hỏi thay đổi dạng để kiểm tra cả nghĩa tiếng Việt lẫn định nghĩa tiếng Anh. Dãy chấm màu ghi lại câu đúng, sai và vị trí hiện tại. Nhóm tiếp tục trả lời cho đến khi lượt đấu kết thúc.''',1.0)
add(639,647,'Đấu trường – bảng tổng kết',
'''Bảng tổng kết hiển thị điểm, số câu đúng, độ chính xác, chuỗi cao nhất và thời gian. Các từ cần ôn được liệt kê riêng, kèm nút nghe lại trước khi chơi tiếp.''',0.7)
add(647,657,'Mưa từ vựng – bắt đầu',
'''Với Mưa từ vựng, nhóm chọn mức dễ. Nghĩa tiếng Việt xuất hiện ở phía trên; các giọt nước mang từ tiếng Anh rơi xuống. Nhiệm vụ là chọn đúng giọt tương ứng trước khi nó chạm đáy.''',0.8)
add(657,668,'Mưa từ vựng – điểm và lượt chơi',
'''Chọn đúng giúp tăng điểm và chuyển sang mục tiêu mới. Nhóm lần lượt tìm từ theo nghĩa đang hiển thị, trong khi các giọt khác tiếp tục rơi. Thanh trạng thái ghi nhận số lần bắt trúng, chuỗi đúng và số mạng để người chơi theo dõi.''',0.8)
add(668,674,'Mưa từ vựng – kết quả',
'''Kết thúc lượt chơi, bảng kết quả thống kê thành tích và những từ bỏ lỡ, cho phép nghe lại hoặc bắt đầu lượt mới.''',0.4)
add(674,683,'Ôn tập và yêu thích',
'''Mục Ôn tập tập hợp các từ cần củng cố, bên cạnh tab Yêu thích. Người dùng có thể nghe từng từ hoặc chọn Học thẻ ngay. Những từ từng trả lời sai cũng xuất hiện để luyện lại.''',0.7)
add(683,694,'Ôn lại bằng Flashcard',
'''Trong lượt ôn, chạm vào thẻ để xem nghĩa và ví dụ, rồi chọn Đã nhớ hoặc Cần ôn tập. Nhóm đánh dấu lại mức độ ghi nhớ của từng từ. Khi quay về danh sách, số từ cần ôn đã thay đổi theo kết quả vừa thao tác.''',0.8)
add(694,707,'Thống kê và lịch sử',
'''Trang Thống kê tổng hợp tỷ lệ hoàn thành, tổng số từ, số đã nhớ, cần ôn và yêu thích. Bên dưới là tiến độ từng chủ đề cùng lịch sử Quiz. Các số liệu giúp người học nhận biết phần còn yếu. Trang cũng có chức năng khôi phục dữ liệu ban đầu.''',0.9,
'Nút khôi phục chỉ xuất hiện trong video, không được bấm. Không nói dữ liệu đã được khôi phục hoặc xóa.')
add(707,719,'Trợ lý AI – xem hội thoại',
'''Cuối cùng là trợ lý AI. Lịch sử hội thoại được giữ lại để người học xem tiếp. Trên màn hình có ví dụ sửa câu, giải đáp khả năng hỗ trợ và hướng dẫn viết tiếng Anh. Người dùng trao đổi bằng ngôn ngữ tự nhiên, ngay trong khung trò chuyện.''',0.9,
'Ví dụ sửa ngữ pháp đầu màn hình là lịch sử có sẵn; không khẳng định vừa gửi trong cảnh này. Không đọc lại lời giải ngữ pháp sai của AI trong lịch sử.')
add(719,730,'Trợ lý AI – yêu cầu diễn đạt dài hơn',
'''Nhóm tiếp tục chủ đề món ăn yêu thích và yêu cầu viết câu dài hơn. Trợ lý hướng dẫn bổ sung chi tiết, kèm đoạn tiếng Anh minh họa. Câu hỏi nối tiếp giúp phát triển ý từ nội dung đã trao đổi.''',0.9)
add(730,742,'Trợ lý AI – đọc và đối chiếu gợi ý',
'''Người học đọc lại phản hồi, đối chiếu cách diễn đạt và tiếp tục làm rõ yêu cầu. Ô nhập phía dưới giúp gửi câu hỏi mới. Phía trên có thông tin trợ lý và nút xóa hội thoại khi cần bắt đầu cuộc trao đổi khác.''',1.0,
'Các nút thông tin và xóa chỉ xuất hiện, không được thao tác. Không mô tả đã xóa lịch sử.')
add(742,756,'Trợ lý AI – bổ sung ngữ cảnh',
'''Nhóm bổ sung rằng thịt bò nướng là món yêu thích sau một ngày làm việc. Trợ lý tiếp tục phản hồi theo ngữ cảnh này, đưa thêm gợi ý diễn đạt và câu tiếng Anh. Qua trao đổi nhiều lượt, người học có thể phát triển câu đơn thành nội dung cụ thể hơn, rồi tự chọn cách viết phù hợp.''',1.0)
add(756,764,'Đăng xuất',
'''Cuối video, nhóm mở menu tài khoản và xác nhận đăng xuất. Ứng dụng quay về màn hình đăng nhập, đồng thời thông báo dữ liệu học trên thiết bị vẫn được giữ lại.''',0.5)
add(764,768.733,'Lời kết',
'''Phần giới thiệu của nhóm chúng em đến đây kết thúc. Chúng em cảm ơn thầy đã theo dõi.''',0.3)

def tc(t,ms=False):
    if ms:
        return f'{int(t)//60:02d}:{int(t)%60:02d}.{round((t%1)*1000):03d}'
    return f'{int(t)//60:02d}:{int(t)%60:02d}'

instructions = '''Video nguồn: Screen Recording 2026-11-02 211524.mp4.
Thời lượng đo từ tệp: 12 phút 48,733 giây; 1920 × 1080, 30 hình/giây.
Kịch bản bám theo khung hình và thao tác quan sát trong video. Không thêm phần quản trị, giao diện điện thoại hoặc đăng nhập Google thành một màn demo vì video không thực hiện các luồng đó.

CÁCH GHÉP GIỌNG ADAM
1. Tạo giọng theo từng đoạn đánh số. Chỉ dán phần “Lời đọc”; không đưa tiêu đề, mốc thời gian hay ghi chú dựng vào công cụ đọc.
2. Dùng giọng thuyết trình rõ ràng, lịch sự, tự nhiên. Giữ cùng giọng và cấu hình xuyên suốt. Các dấu phẩy, dấu chấm đã được đặt để chia nhịp câu.
3. Đặt mỗi clip giọng tại mốc Bắt đầu. Cột “Nghỉ cuối” là khoảng lặng chủ động dự kiến trước cảnh tiếp theo; có thể chèn khoảng lặng trong trình dựng. Không đọc thành tiếng các chỉ dẫn nghỉ.
4. Thời lượng lời đọc mục tiêu = thời lượng đoạn trừ khoảng nghỉ cuối. Sau khi Adam xuất âm thanh, đo độ dài thực tế và điều chỉnh tốc độ/nhịp đọc nhẹ cho từng đoạn. Hệ số tốc độ dựng = thời lượng âm thanh thực tế / thời lượng lời đọc mục tiêu. Nếu cần chỉnh quá nhiều, xuất lại đoạn đó với nhịp đọc phù hợp thay vì kéo giãn cực đoan.
5. Mốc cảnh đã đối chiếu theo video; thời lượng giọng là mục tiêu dựng, chưa được xác nhận bằng bản âm thanh Adam. Không thể bảo đảm một lần dán toàn bộ văn bản sẽ tự khớp chính xác 12:48,733.
6. Không chèn thêm intro trước video: phần chào thầy đã bắt đầu tại 00:00. Đoạn đầu có nhiều thao tác nhanh nên cần đọc gọn, rõ. Kết thúc lời cảm ơn trước 12:48,733.
7. Nếu giữ âm thanh ứng dụng, hạ nhỏ dưới lời thuyết minh. Ở các đoạn nghe mẫu, có thể dùng khoảng nghỉ ghi trong kịch bản để tiếng mẫu nổi lên; không để hai giọng cùng lớn.
8. Giữ cách phát âm nhất quán cho English Buddy, Quiz, Flashcard, Shadowing, IELTS và TOEIC. Nếu công cụ đọc sai, chỉnh phát âm theo tính năng mà công cụ của bạn hỗ trợ; không giả định mọi công cụ Adam đều hiểu thẻ SSML.

ĐỘ CHÍNH XÁC NỘI DUNG
- Đăng ký chuyển về đăng nhập; sau đó mới đăng nhập vào Trang chủ.
- Video thay tên hiển thị và ảnh đại diện; không trình diễn đổi username thành công.
- Tiến độ tuần trong cảnh hồ sơ chưa có hoạt động; không tạo lời mô tả thành tích giả.
- Luyện nói và Shadowing dùng tự đánh giá; không mô tả là AI chấm phát âm tự động.
- Đoạn văn nhập minh họa khác chủ đề email: kịch bản nêu rõ, không khẳng định đúng yêu cầu đề.
- Bài thi đọc mới có 0/4 câu đúng; không nói đó là lượt làm đạt kết quả cao. Điểm band hiển thị chỉ là tham khảo của ứng dụng.
- Lịch sử chat có lời giải ngữ pháp chưa chuẩn; kịch bản không lặp lại hoặc xác nhận lời giải đó là đúng.
- Các chức năng chỉ thấy nút mà chưa được thao tác được giới thiệu là lựa chọn có trên giao diện, không phải kết quả đã thực hiện.
'''

assert segments[0]['start']==0
for a,b in zip(segments,segments[1:]): assert a['end']==b['start'],(a,b)
assert segments[-1]['end']==768.733
for i,s in enumerate(segments,1):
    s['id']=i
    s['duration']=round(s['end']-s['start'],3)
    s['voice_target']=round(s['duration']-s['pause'],3)
    s['space_units']=len(s['text'].split())
    s['units_per_sec']=round(s['space_units']/s['voice_target'],2)

(OUT/'timeline.json').write_text(json.dumps(segments,ensure_ascii=False,indent=2),encoding='utf-8')
md=['# Kịch bản thuyết minh English Buddy — 12:48,733','',instructions]
clean=[]
chunks=OUT/'adam_tung_doan'
chunks.mkdir(exist_ok=True)
for s in segments:
    title=f"{s['id']:02d}. {tc(s['start'])}–{tc(s['end'],s['end']%1!=0)} | {s['title']}"
    timing=f"Khung đoạn: {s['duration']:g} giây. Lời đọc mục tiêu: {s['voice_target']:g} giây. Nghỉ cuối: {s['pause']:g} giây."
    md.extend(['',f'## {title}','',timing,'','**Lời đọc:**','',s['text']])
    if s['note']: md.extend(['','**Ghi chú dựng, không đọc:** '+s['note']])
    clean.append(s['text'])
    filename=f"{s['id']:02d}_{tc(s['start']).replace(':','-')}_{tc(s['end']).replace(':','-')}.txt"
    (chunks/filename).write_text(s['text']+'\n',encoding='utf-8-sig')
(OUT/'Kich_ban_English_Buddy_co_moc_thoi_gian.md').write_text('\n'.join(md)+'\n',encoding='utf-8')
(OUT/'Loi_doc_Adam_khong_chu_thich.txt').write_text('\n\n'.join(clean)+'\n',encoding='utf-8-sig')
(OUT/'Huong_dan_ghep_giong.txt').write_text(instructions,encoding='utf-8-sig')
with (OUT/'Bang_can_thoi_gian.csv').open('w',encoding='utf-8-sig',newline='') as f:
    w=csv.writer(f); w.writerow(['Đoạn','Bắt đầu','Kết thúc','Nội dung','Khung đoạn (giây)','Lời đọc mục tiêu (giây)','Nghỉ cuối (giây)','Ghi chú dựng'])
    for s in segments:w.writerow([s['id'],tc(s['start']),tc(s['end'],s['end']%1!=0),s['title'],s['duration'],s['voice_target'],s['pause'],s['note']])

doc=Document()
sec=doc.sections[0]; sec.top_margin=sec.bottom_margin=Cm(1.8); sec.left_margin=sec.right_margin=Cm(2)
style=doc.styles['Normal']; style.font.name='Calibri'; style.font.size=Pt(11); style.paragraph_format.space_after=Pt(7)
doc.add_heading('Kịch bản thuyết minh English Buddy',0)
doc.add_paragraph('Video dài 12 phút 48,733 giây • Lời đọc dành cho giọng Adam')
doc.add_heading('Hướng dẫn sử dụng',1)
for p in instructions.strip().split('\n'):
    if p.strip():doc.add_paragraph(p)
doc.add_page_break()
doc.add_heading('Bản đồ nội dung video',1)
table=doc.add_table(rows=1,cols=3);table.style='Light Shading Accent 1'
for cell,t in zip(table.rows[0].cells,['Mốc bắt đầu','Mốc kết thúc','Nội dung']):cell.text=t
for s in segments:
    cells=table.add_row().cells
    for c,t in zip(cells,[tc(s['start']),tc(s['end'],s['end']%1!=0),s['title']]):c.text=t
doc.add_page_break()
doc.add_heading('Lời đọc theo từng cảnh',1)
for s in segments:
    doc.add_heading(f"{s['id']:02d}. {tc(s['start'])}–{tc(s['end'],s['end']%1!=0)} | {s['title']}",2)
    p=doc.add_paragraph(f"Lời đọc mục tiêu: {s['voice_target']:g} giây • Nghỉ cuối: {s['pause']:g} giây")
    for r in p.runs:r.italic=True;r.font.size=Pt(9);r.font.color.rgb=RGBColor.from_string('536477')
    doc.add_paragraph(s['text'])
    if s['note']:
        p=doc.add_paragraph('Ghi chú dựng — không đọc: '+s['note'])
        for r in p.runs:r.italic=True;r.font.size=Pt(9)
doc.save(OUT/'Kich_ban_English_Buddy_12p48.docx')
with zipfile.ZipFile(OUT/'Bo_kich_ban_Adam_English_Buddy.zip','w',zipfile.ZIP_DEFLATED) as z:
    for f in [OUT/'Kich_ban_English_Buddy_12p48.docx',OUT/'Kich_ban_English_Buddy_co_moc_thoi_gian.md',OUT/'Loi_doc_Adam_khong_chu_thich.txt',OUT/'Huong_dan_ghep_giong.txt',OUT/'Bang_can_thoi_gian.csv']:
        z.write(f,f.name)
    for f in sorted(chunks.glob('*.txt')):z.write(f,'adam_tung_doan/'+f.name)
print(json.dumps({'segments':len(segments),'duration':segments[-1]['end'],'spoken_space_units':sum(s['space_units'] for s in segments),'total_end_pauses':sum(s['pause'] for s in segments),'pace_range':[min(s['units_per_sec'] for s in segments),max(s['units_per_sec'] for s in segments)],'fast_segments':[{'id':s['id'],'pace':s['units_per_sec']} for s in segments if s['units_per_sec']>4.8]},ensure_ascii=False))

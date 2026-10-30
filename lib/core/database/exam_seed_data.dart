import '../../data/models/exam_model.dart';
import '../../data/models/skill_exercise_model.dart';

class ExamSeedData {
  ExamSeedData._();

  static const List<ExamModel> exams = [
    ExamModel(
      id: 'exam_ielts_read_1',
      title: 'IELTS Academic Reading: Urban Green Spaces & Microclimates',
      category: 'IELTS',
      skillSection: 'Reading',
      level: 'B2-C1',
      durationMinutes: 15,
      description:
          'Luyện kỹ năng đọc học thuật theo định dạng IELTS Reading: tìm thông tin chi tiết, nhận diện từ đồng nghĩa (Paraphrasing) và điền từ vào chỗ trống (Summary Completion).',
      hasAudioScript: false,
      passageOrScript:
          'Paragraph A\n'
          'Rapid urbanization over the past century has transformed natural landscapes into dense networks of concrete and asphalt. '
          'This phenomenon creates what climatologists refer to as the "Urban Heat Island" (UHI) effect, wherein metropolitan regions '
          'experience significantly warmer temperatures than their surrounding rural areas. Impervious surfaces absorb solar radiation '
          'throughout the day and release it slowly at night, escalating energy consumption for air conditioning.\n\n'
          'Paragraph B\n'
          'To mitigate these thermal pressures, urban planners are increasingly integrating vertical forests, rooftop gardens, and green corridors '
          'into municipal architecture. Vegetation regulates microclimates primarily through evapotranspiration and shade provision. '
          'Empirical studies conducted across several European capitals demonstrate that tree-lined avenues can reduce surface temperatures '
          'by up to four degrees Celsius during peak summer months.\n\n'
          'Paragraph C\n'
          'Beyond thermal regulation, accessible urban greenery yields measurable psychological benefits. Residents living within walking distance '
          'of botanical parks report lower cortisol levels and stronger community cohesion. Nevertheless, municipal authorities face financial constraints '
          'and high maintenance costs when retrofitting historical city centers with sustainable infrastructure.',
      transcriptVi:
          'Đoạn A: Quá trình đô thị hóa nhanh chóng trong thế kỷ qua đã biến đổi cảnh quan tự nhiên thành mạng lưới bê tông và nhựa đường dày đặc. Hiện tượng này tạo ra hiệu ứng "Đảo nhiệt đô thị" (UHI), nơi các khu vực đô thị ấm hơn đáng kể so với vùng nông thôn xung quanh...\n\n'
          'Đoạn B: Để giảm thiểu áp lực nhiệt này, các nhà quy hoạch đô thị ngày càng tích hợp rừng thẳng đứng, vườn trên mái và hành lang xanh vào kiến trúc thành phố. Thực vật điều hòa vi khí hậu chủ yếu qua quá trình bốc thoát hơi nước và tạo bóng râm...\n\n'
          'Đoạn C: Ngoài việc điều hòa nhiệt độ, không gian xanh đô thị dễ tiếp cận còn mang lại lợi ích tâm lý đo lường được. Tuy nhiên, chính quyền đô thị phải đối mặt với hạn chế tài chính và chi phí bảo trì cao khi cải tạo các trung tâm thành phố lịch sử.',
      keyWords: [
        LessonKeyWord(
          term: 'mitigate',
          ipa: '/ˈmɪt.ɪ.ɡeɪt/',
          partOfSpeech: 'v',
          meaning: 'giảm thiểu, làm dịu bớt',
          example: 'To mitigate these thermal pressures, planners integrate rooftop gardens.',
        ),
        LessonKeyWord(
          term: 'impervious',
          ipa: '/ɪmˈpɜː.vi.əs/',
          partOfSpeech: 'adj',
          meaning: 'không thấm nước',
          example: 'Impervious surfaces absorb solar radiation.',
        ),
        LessonKeyWord(
          term: 'cohesion',
          ipa: '/kəʊˈhiː.ʒən/',
          partOfSpeech: 'n',
          meaning: 'sự gắn kết',
          example: 'Residents report stronger community cohesion.',
        ),
      ],
      questions: [
        ExamQuestion(
          id: 'ir1_q1',
          sectionTitle: 'Multiple Choice (Đọc hiểu chi tiết)',
          questionText: 'Nguyên nhân chính gây ra hiệu ứng "Đảo nhiệt đô thị" (Urban Heat Island) được nêu ở Đoạn A là gì?',
          options: [
            'Do mật độ cây xanh trong thành phố quá dày đặc',
            'Do các bề mặt bê tông và nhựa đường hấp thụ bức xạ mặt trời rồi tỏa nhiệt chậm vào ban đêm',
            'Do người dân vùng nông thôn di cư ra ngoại ô',
            'Do lượng mưa tại các thủ đô châu Âu giảm mạnh'
          ],
          correctOptionIndex: 1,
          explanation: 'Đoạn A nêu rõ: "Impervious surfaces absorb solar radiation throughout the day and release it slowly at night".',
          targetSkill: 'Reading Detail',
        ),
        ExamQuestion(
          id: 'ir1_q2',
          sectionTitle: 'Multiple Choice (Suy luận & Paraphrase)',
          questionText: 'Theo Đoạn B, các đại lộ có hàng cây xanh ở các thủ đô châu Âu đã chứng minh được hiệu quả nào?',
          options: [
            'Làm giảm hoàn toàn chi phí điện năng về mức bằng 0',
            'Giúp giảm nhiệt độ bề mặt tới 4 độ C vào những tháng cao điểm mùa hè',
            'Thay thế hoàn toàn hệ thống giao thông công cộng',
            'Tăng diện tích bê tông hóa của thành phố'
          ],
          correctOptionIndex: 1,
          explanation: 'Đoạn B: "tree-lined avenues can reduce surface temperatures by up to four degrees Celsius during peak summer months."',
          targetSkill: 'Reading Paraphrase',
        ),
        ExamQuestion(
          id: 'ir1_q3',
          sectionTitle: 'Summary Completion (Điền 1 từ trong bài)',
          questionText: 'Điền 1 danh từ từ Đoạn C: Residents near parks experience lower cortisol levels and stronger community _______. (sự gắn kết cộng đồng)',
          options: ['cohesion'],
          correctOptionIndex: 0,
          questionType: 'fill',
          acceptedAnswers: ['cohesion'],
          explanation: 'Trong Đoạn C: "...report lower cortisol levels and stronger community cohesion."',
          targetSkill: 'Summary Completion',
        ),
        ExamQuestion(
          id: 'ir1_q4',
          sectionTitle: 'Multiple Choice (Xác định rào cản thực tế)',
          questionText: 'Khó khăn nào mà chính quyền thành phố gặp phải khi cải tạo trung tâm lịch sử ở Đoạn C?',
          options: [
            'Người dân phản đối việc trồng thêm cây xanh',
            'Hạn chế về ngân sách tài chính và chi phí bảo trì cao',
            'Thiếu các nhà nghiên cứu khí hậu học',
            'Cây xanh làm tăng mức độ hormone căng thẳng'
          ],
          correctOptionIndex: 1,
          explanation: 'Đoạn C: "municipal authorities face financial constraints and high maintenance costs when retrofitting historical city centers".',
          targetSkill: 'Reading Detail',
        ),
      ],
    ),
    ExamModel(
      id: 'exam_ielts_lis_1',
      title: 'IELTS Listening Section 2: University Library Orientation',
      category: 'IELTS',
      skillSection: 'Listening',
      level: 'B1-B2',
      durationMinutes: 10,
      description:
          'Luyện nghe hướng dẫn học thuật tại trường đại học (IELTS Listening Part 2). Bao gồm câu hỏi trắc nghiệm và điền từ ngắn (Note Completion). Bản transcript được khóa cho tới khi nộp bài.',
      hasAudioScript: true,
      passageOrScript:
          'Welcome to the Central University Library orientation tour. My name is Dr. Clara Evans, Head Librarian. '
          'Our building is divided into three main zones. The Ground Floor houses the Digital Media Commons and a collaborative café where group discussions are encouraged. '
          'On the Second Floor, you will find the Science and Engineering periodicals, along with twelve soundproof study pods that can be reserved online up to forty-eight hours in advance. '
          'Finally, the Third Floor is designated strictly as a Silent Research Zone. Undergraduate students may borrow up to eight printed volumes for a standard loan period of fourteen days. '
          'Please remember that overdue rare reference books incur a fine of two dollars per day.',
      transcriptVi:
          'Chào mừng các bạn đến với buổi tham quan định hướng Thư viện Trung tâm Trường Đại học. Tôi là Tiến sĩ Clara Evans, Trưởng thư viện. '
          'Tòa nhà của chúng tôi được chia thành ba khu vực chính. Tầng trệt có Khu Truyền thông Kỹ thuật số và quán cà phê cộng tác nơi khuyến khích thảo luận nhóm. '
          'Ở Tầng hai, bạn sẽ tìm thấy các ấn phẩm định kỳ Khoa học và Kỹ thuật, cùng với 12 phòng học cách âm có thể đặt trực tuyến trước tối đa 48 giờ. '
          'Cuối cùng, Tầng ba được quy định nghiêm ngặt là Khu Nghiên cứu Yên tĩnh. Sinh viên đại học có thể mượn tối đa 8 cuốn sách in trong thời hạn tiêu chuẩn là 14 ngày.',
      keyWords: [
        LessonKeyWord(
          term: 'periodical',
          ipa: '/ˌpɪə.riˈɒd.ɪ.kəl/',
          partOfSpeech: 'n',
          meaning: 'ấn phẩm định kỳ, tạp chí chuyên ngành',
          example: 'You will find the Science and Engineering periodicals on the second floor.',
        ),
        LessonKeyWord(
          term: 'soundproof',
          ipa: '/ˈsaʊnd.pruːf/',
          partOfSpeech: 'adj',
          meaning: 'cách âm',
          example: 'Twelve soundproof study pods can be reserved online.',
        ),
      ],
      questions: [
        ExamQuestion(
          id: 'il1_q1',
          sectionTitle: 'Listening Multiple Choice',
          questionText: 'Khu vực nào cho phép sinh viên thoải mái thảo luận nhóm?',
          options: [
            'Tầng trệt (Ground Floor)',
            'Tầng hai (Second Floor)',
            'Tầng ba (Third Floor)',
            'Tầng hầm lưu trữ'
          ],
          correctOptionIndex: 0,
          explanation: 'Trong bài nghe: "The Ground Floor houses the Digital Media Commons and a collaborative café where group discussions are encouraged."',
          targetSkill: 'Listening Detail',
        ),
        ExamQuestion(
          id: 'il1_q2',
          sectionTitle: 'Listening Multiple Choice',
          questionText: 'Các phòng học cách âm (soundproof study pods) ở tầng hai có thể đặt trước tối đa bao lâu?',
          options: ['12 giờ', '24 giờ', '48 giờ', '7 ngày'],
          correctOptionIndex: 2,
          explanation: 'Trong bài nghe: "can be reserved online up to forty-eight hours in advance."',
          targetSkill: 'Listening Numbers',
        ),
        ExamQuestion(
          id: 'il1_q3',
          sectionTitle: 'Note Completion (Điền số hoặc chữ)',
          questionText: 'Sinh viên đại học được mượn sách in trong thời hạn tiêu chuẩn là bao nhiêu ngày? (Nhập số hoặc chữ tiếng Anh)',
          options: ['14', 'fourteen'],
          correctOptionIndex: 0,
          questionType: 'fill',
          acceptedAnswers: ['14', 'fourteen', '14 days', 'fourteen days'],
          explanation: 'Trong bài nghe: "for a standard loan period of fourteen days."',
          targetSkill: 'Note Completion',
        ),
      ],
    ),
    ExamModel(
      id: 'exam_toeic_read_1',
      title: 'TOEIC Reading Part 5 & 7: Workplace Email & Contract Notice',
      category: 'TOEIC',
      skillSection: 'Reading',
      level: 'B1-B2',
      durationMinutes: 12,
      description:
          'Luyện đề định dạng TOEIC Reading (Incomplete Sentences & Reading Comprehension): hoàn thành câu ngữ pháp công sở và đọc hiểu thông báo nội bộ doanh nghiệp.',
      hasAudioScript: false,
      passageOrScript:
          'MEMORANDUM\n'
          'To: All Product Development Staff\n'
          'From: Julian Vance, Director of Operations\n'
          'Date: October 18\n'
          'Subject: Quarterly Security Audit & Server Maintenance\n\n'
          'Please be advised that our IT Infrastructure Department will conduct a scheduled server upgrade this Saturday, October 22, from 10:00 PM to 4:00 AM. '
          'During this six-hour window, access to the internal cloud repository will be temporarily suspended. '
          'All project managers are requested to ensure that their team members synchronize local codebases before Friday at 5:00 PM. '
          'Should you encounter any authentication issues on Monday morning, please submit a support ticket through the Helpdesk Portal rather than emailing technicians directly.',
      transcriptVi:
          'THÔNG BÁO NỘI BỘ\n'
          'Kính gửi: Toàn thể nhân viên Phát triển Sản phẩm\n'
          'Từ: Julian Vance, Giám đốc Vận hành\n'
          'Chủ đề: Kiểm toán bảo mật hằng quý & Bảo trì máy chủ\n\n'
          'Xin lưu ý rằng Phòng Hạ tầng CNTT sẽ tiến hành nâng cấp máy chủ định kỳ vào thứ Bảy tuần này, ngày 22/10, từ 22:00 đến 04:00 sáng. '
          'Trong khoảng thời gian 6 tiếng này, quyền truy cập vào kho lưu trữ đám mây nội bộ sẽ tạm thời bị ngưng. '
          'Tất cả quản lý dự án được yêu cầu đảm bảo các thành viên đồng bộ hóa mã nguồn cục bộ trước 17:00 thứ Sáu. '
          'Nếu bạn gặp sự cố xác thực vào sáng thứ Hai, vui lòng gửi yêu cầu qua Cổng thông tin Helpdesk thay vì gửi email trực tiếp cho kỹ thuật viên.',
      keyWords: [
        LessonKeyWord(
          term: 'suspend',
          ipa: '/səˈspend/',
          partOfSpeech: 'v',
          meaning: 'tạm ngưng, đình chỉ',
          example: 'Access to the cloud repository will be temporarily suspended.',
        ),
        LessonKeyWord(
          term: 'authentication',
          ipa: '/ɔːˌθen.tɪˈkeɪ.ʃən/',
          partOfSpeech: 'n',
          meaning: 'sự xác thực (tài khoản/bảo mật)',
          example: 'Should you encounter any authentication issues on Monday morning...',
        ),
      ],
      questions: [
        ExamQuestion(
          id: 'tr1_q1',
          sectionTitle: 'TOEIC Part 5: Incomplete Sentences',
          questionText: 'All employees must _______ with the updated safety regulations before entering the laboratory.',
          options: ['comply', 'complies', 'compliance', 'compliant'],
          correctOptionIndex: 0,
          explanation: 'Sau động từ khuyết thiếu "must" cần một động từ nguyên mẫu: "comply with" (tuân thủ).',
          targetSkill: 'Grammar & Collocation',
        ),
        ExamQuestion(
          id: 'tr1_q2',
          sectionTitle: 'TOEIC Part 5: Vocabulary in Context',
          questionText: 'The marketing proposal was _______ approved by the board of directors after a thorough review.',
          options: ['unanimously', 'reluctantly', 'scarcely', 'accidentally'],
          correctOptionIndex: 0,
          explanation: '"unanimously approved" nghĩa là được thông qua với sự nhất trí hoàn toàn sau khi xem xét kỹ lưỡng.',
          targetSkill: 'Business Vocabulary',
        ),
        ExamQuestion(
          id: 'tr1_q3',
          sectionTitle: 'TOEIC Part 7: Reading Comprehension',
          questionText: 'Theo thông báo (Memorandum), các thành viên dự án cần hoàn tất việc đồng bộ hóa mã nguồn trước thời điểm nào?',
          options: [
            '10:00 tối thứ Bảy',
            '5:00 chiều thứ Sáu',
            '4:00 sáng Chủ nhật',
            '9:00 sáng thứ Hai'
          ],
          correctOptionIndex: 1,
          explanation: 'Thông báo ghi rõ: "synchronize local codebases before Friday at 5:00 PM."',
          targetSkill: 'Reading Detail',
        ),
        ExamQuestion(
          id: 'tr1_q4',
          sectionTitle: 'TOEIC Part 7: Reading Comprehension',
          questionText: 'Nhân viên nên làm gì nếu gặp lỗi đăng nhập/xác thực vào sáng thứ Hai?',
          options: [
            'Gửi email trực tiếp cho kỹ thuật viên',
            'Gọi điện cho Giám đốc Vận hành Julian Vance',
            'Gửi phiếu hỗ trợ qua cổng Helpdesk Portal',
            'Tự khởi động lại máy chủ nội bộ'
          ],
          correctOptionIndex: 2,
          explanation: 'Trong bài: "submit a support ticket through the Helpdesk Portal rather than emailing technicians directly."',
          targetSkill: 'Reading Detail',
        ),
      ],
    ),
    ExamModel(
      id: 'exam_toeic_lis_1',
      title: 'TOEIC Listening Part 3 & 4: Business Announcement & Travel Update',
      category: 'TOEIC',
      skillSection: 'Listening',
      level: 'A2-B1',
      durationMinutes: 8,
      description:
          'Luyện nghe thông báo tại sân bay và tin nhắn thoại công sở theo định dạng TOEIC Listening. Transcript khóa cho tới khi nộp bài.',
      hasAudioScript: true,
      passageOrScript:
          'Attention passengers booked on Pacific Express Flight 408 to Singapore. '
          'Due to routine mechanical inspection, boarding has been relocated from Gate B12 to Gate C05 on the lower concourse. '
          'Departure is now scheduled for 3:45 PM, which is thirty minutes later than originally printed on your boarding pass. '
          'Complimentary refreshment vouchers can be collected at the customer service counter next to Gate C05 upon presentation of your ticket.',
      transcriptVi:
          'Xin lưu ý các hành khách đặt vé trên chuyến bay Pacific Express 408 đi Singapore. '
          'Do kiểm tra kỹ thuật định kỳ, cổng lên máy bay đã được chuyển từ Cổng B12 sang Cổng C05 ở sảnh tầng dưới. '
          'Giờ khởi hành hiện được ấn định vào lúc 3:45 chiều, muộn hơn 30 phút so với giờ in ban đầu trên thẻ lên máy bay của quý khách. '
          'Phiếu đồ uống miễn phí có thể được nhận tại quầy dịch vụ khách hàng cạnh Cổng C05 khi xuất trình vé.',
      keyWords: [
        LessonKeyWord(
          term: 'complimentary',
          ipa: '/ˌkɒm.plɪˈmen.tər.i/',
          partOfSpeech: 'adj',
          meaning: 'miễn phí (ưu đãi tặng kèm)',
          example: 'Complimentary refreshment vouchers can be collected at the counter.',
        ),
        LessonKeyWord(
          term: 'inspection',
          ipa: '/ɪnˈspek.ʃən/',
          partOfSpeech: 'n',
          meaning: 'sự kiểm tra, thanh tra kỹ thuật',
          example: 'Due to routine mechanical inspection, boarding has been relocated.',
        ),
      ],
      questions: [
        ExamQuestion(
          id: 'tl1_q1',
          sectionTitle: 'TOEIC Listening Part 4',
          questionText: 'Cổng lên máy bay mới của chuyến bay 408 là cổng nào?',
          options: ['Gate A08', 'Gate B12', 'Gate C05', 'Gate D15'],
          correctOptionIndex: 2,
          explanation: 'Thông báo nêu rõ: "boarding has been relocated from Gate B12 to Gate C05".',
          targetSkill: 'Listening Specific Info',
        ),
        ExamQuestion(
          id: 'tl1_q2',
          sectionTitle: 'TOEIC Listening Part 4',
          questionText: 'Tại sao chuyến bay bị khởi hành muộn 30 phút?',
          options: [
            'Do thời tiết xấu tại Singapore',
            'Do kiểm tra kỹ thuật định kỳ (routine mechanical inspection)',
            'Do thiếu phi hành đoàn',
            'Do tắc nghẽn đường băng'
          ],
          correctOptionIndex: 1,
          explanation: 'Thông báo: "Due to routine mechanical inspection..."',
          targetSkill: 'Listening Cause & Effect',
        ),
        ExamQuestion(
          id: 'tl1_q3',
          sectionTitle: 'TOEIC Listening Part 4',
          questionText: 'Hành khách được tặng ưu đãi gì tại quầy dịch vụ khách hàng?',
          options: [
            'Vé nâng hạng thương gia',
            'Phiếu đồ uống/ăn nhẹ miễn phí (Complimentary refreshment vouchers)',
            'Một đêm nghỉ khách sạn',
            'Vali du lịch mới'
          ],
          correctOptionIndex: 1,
          explanation: 'Thông báo: "Complimentary refreshment vouchers can be collected at the customer service counter".',
          targetSkill: 'Listening Detail',
        ),
      ],
    ),
    ExamModel(
      id: 'exam_cefr_mock_b1',
      title: 'CEFR B1–B2 Integrated Competency Mini-Test (Đề tổng hợp)',
      category: 'CEFR',
      skillSection: 'Mini Mock Test',
      level: 'B1-B2',
      durationMinutes: 15,
      description:
          'Bài kiểm tra năng lực tổng hợp chuẩn khung tham chiếu châu Âu CEFR (Ngữ pháp, Từ vựng ngữ cảnh, Đọc hiểu và Cấu trúc viết học thuật).',
      hasAudioScript: false,
      passageOrScript:
          'lifelong learning has become a cornerstone of career adaptability in the twenty-first century. '
          'In the past, a university degree often sufficed for a forty-year career path. Today, technological innovation cycles '
          'are shortening so rapidly that technical skills can become obsolete within five years. Consequently, professionals who cultivate '
          'curiosity and self-directed study habits are far better equipped to navigate industry transitions.',
      transcriptVi:
          'Học tập suốt đời đã trở thành nền tảng của khả năng thích ứng nghề nghiệp trong thế kỷ 21. '
          'Trước đây, một tấm bằng đại học thường đã đủ cho chặng đường sự nghiệp 40 năm. Ngày nay, chu kỳ đổi mới công nghệ '
          'đang rút ngắn nhanh đến mức các kỹ năng kỹ thuật có thể trở nên lỗi thời chỉ trong vòng 5 năm. Do đó, những chuyên gia rèn luyện '
          'sự ham học hỏi và thói quen tự học có định hướng sẽ được trang bị tốt hơn nhiều để vượt qua những chuyển dịch của ngành.',
      keyWords: [
        LessonKeyWord(
          term: 'cornerstone',
          ipa: '/ˈkɔː.nə.stəʊn/',
          partOfSpeech: 'n',
          meaning: 'nền tảng cốt lõi, viên đá tảng',
          example: 'Lifelong learning has become a cornerstone of career adaptability.',
        ),
        LessonKeyWord(
          term: 'obsolete',
          ipa: '/ˌɒb.səlˈiːt/',
          partOfSpeech: 'adj',
          meaning: 'lỗi thời, không còn dùng nữa',
          example: 'Technical skills can become obsolete within five years.',
        ),
      ],
      questions: [
        ExamQuestion(
          id: 'cefr1_q1',
          sectionTitle: 'Grammar & Structure (B1)',
          questionText: 'Had I known about the traffic jam earlier, I _______ an alternative route to the station.',
          options: [
            'will take',
            'would take',
            'would have taken',
            'took'
          ],
          correctOptionIndex: 2,
          explanation: 'Đảo ngữ câu điều kiện loại 3 (Had + S + V3/ed, S + would have + V3/ed) diễn tả giả định trái ngược quá khứ.',
          targetSkill: 'Grammar (Conditionals)',
        ),
        ExamQuestion(
          id: 'cefr1_q2',
          sectionTitle: 'Vocabulary in Context (B2)',
          questionText: 'Trong đoạn văn, từ "obsolete" gần nghĩa nhất với từ nào sau đây?',
          options: ['Outdated (Lỗi thời)', 'Essential (Thiết yếu)', 'Profitable (Sinh lời)', 'Innovative (Đổi mới)'],
          correctOptionIndex: 0,
          explanation: '"Obsolete" (/ˌɒb.səlˈiːt/) nghĩa là lỗi thời, đồng nghĩa với "outdated".',
          targetSkill: 'Lexical Resource',
        ),
        ExamQuestion(
          id: 'cefr1_q3',
          sectionTitle: 'Reading Comprehension',
          questionText: 'Theo đoạn văn, điều gì giúp các chuyên gia thích ứng tốt hơn với sự chuyển dịch của ngành?',
          options: [
            'Chỉ dựa vào một tấm bằng đại học trong suốt 40 năm',
            'Rèn luyện sự ham học hỏi và thói quen tự học có định hướng',
            'Tránh sử dụng các công nghệ mới',
            'Thay đổi công việc mỗi tháng một lần'
          ],
          correctOptionIndex: 1,
          explanation: 'Đoạn văn nêu: "professionals who cultivate curiosity and self-directed study habits are far better equipped to navigate industry transitions."',
          targetSkill: 'Reading Inference',
        ),
        ExamQuestion(
          id: 'cefr1_q4',
          sectionTitle: 'Word Completion (Điền từ chính xác)',
          questionText: 'Điền danh từ trong bài mang nghĩa "nền tảng cốt lõi": "Lifelong learning has become a _______ of career adaptability."',
          options: ['cornerstone'],
          correctOptionIndex: 0,
          questionType: 'fill',
          acceptedAnswers: ['cornerstone'],
          explanation: 'Từ cần điền là "cornerstone" (nền tảng cốt lõi).',
          targetSkill: 'Vocabulary Recall',
        ),
        ExamQuestion(
          id: 'cefr1_q5',
          sectionTitle: 'Academic Writing Cohesion (B2)',
          questionText: 'Chọn từ nối học thuật phù hợp nhất: "Renewable energy reduces carbon emissions; _______, it creates sustainable jobs in engineering."',
          options: ['furthermore', 'nevertheless', 'conversely', 'despite'],
          correctOptionIndex: 0,
          explanation: '"Furthermore" (Hơn thế nữa) dùng để bổ sung thêm một luận điểm cùng chiều sau dấu chấm phẩy.',
          targetSkill: 'Writing Cohesion',
        ),
      ],
    ),

    // ==========================================
    // IELTS LISTENING FULL PRACTICE (4 SECTIONS)
    // ==========================================
    ExamModel(
      id: 'exam_ielts_listen_full',
      title: 'IELTS Listening Practice Test: Campus Life to Marine Ecology',
      category: 'IELTS',
      skillSection: 'Listening',
      level: 'B2-C1',
      durationMinutes: 30,
      description:
          'Bài luyện thi IELTS Listening hoàn chỉnh gồm 4 Section tăng dần độ khó: Hội thoại ghi danh (Section 1), Độc thoại hướng dẫn (Section 2), Thảo luận học thuật (Section 3) và Bài giảng khoa học (Section 4). Transcript bị khóa trong chế độ thi tính giờ.',
      hasAudioScript: true,
      ieltsModule: 'Academic',
      passageOrScript:
          '[SECTION 1: Sports Club Membership Dialogue]\n'
          'Clerk: Good morning, welcome to Metro Health & Sports Club. How can I help you today?\n'
          'Applicant: Hello! I would like to inquire about joining your fitness club.\n'
          'Clerk: Certainly! May I have your full name, please?\n'
          'Applicant: It is Martin Gallagher. That is G-A-L-L-A-G-H-E-R.\n'
          'Clerk: Thank you, Martin. And what type of membership tier are you looking for?\n'
          'Applicant: I work standard hours, so the Gold tier would be ideal for me since it grants evening access to the indoor pool and tennis courts.\n'
          'Clerk: Great choice. Gold membership is sixty-five pounds monthly. And your preferred start date?\n'
          'Applicant: The fifth of November, please.\n'
          'Clerk: Perfect. Lastly, your contact telephone number?\n'
          'Applicant: It is 07946 382109.\n\n'
          '[SECTION 2: Riverside Nature Sanctuary Guide]\n'
          'Guide: Good afternoon everyone and welcome to the Riverside Nature Sanctuary. '
          'Before we begin our guided trail walking tour, let me give you a quick orientation of our visitor center. '
          'As you enter through the main glass revolving doors, directly in front of you is the information desk. '
          'To your immediate left is the botanical gift shop, where all profits support wildlife rehabilitation. '
          'If you follow the corridor to your right, past the café, you will discover the interactive bird observation deck overlooking the wetland marshes. '
          'Please take note that the bird observation deck closes at 5:30 PM for nocturnal creature safety, while the café remains open until 7:00 PM.\n\n'
          '[SECTION 3: Academic Tutorial on Renewable Microgrids]\n'
          'Tutor: Welcome Sarah and Liam. Today we are reviewing your research proposal on decentralized microgrids in rural communities. Sarah, what is your primary takeaway?\n'
          'Sarah: Well, Professor, I found that while solar panels have plummeted in price, the main bottleneck remains battery storage efficiency during prolonged winter periods.\n'
          'Liam: I agree with Sarah on storage, but from my field interviews, community engagement and clear local governance are even more decisive than battery chemistry. Without local buy-in, maintenance stops after eighteen months.\n'
          'Tutor: Excellent observation, Liam. Technical viability is pointless without institutional sustainability.\n\n'
          '[SECTION 4: Academic Lecture on Coral Bleaching and Ocean Acidification]\n'
          'Lecturer: Good morning students. In today’s marine ecology lecture, we examine the accelerated degradation of tropical coral reefs. '
          'Corals live in an obligate symbiotic relationship with microscopic algae known as zooxanthellae. '
          'These photosynthetic micro-organisms provide up to ninety percent of the coral polyp’s metabolic energy requirements. '
          'When ocean temperatures elevate by even one to two degrees above seasonal averages, corals experience severe thermal stress and expel their algal symbionts, a phenomenon known as bleaching. '
          'Furthermore, as oceanic bodies absorb thirty percent of anthropogenic carbon dioxide emissions, ocean pH declines significantly. '
          'This acidification reduces the availability of carbonate ions, drastically impeding calcium carbonate skeleton calcification.',
      transcriptVi:
          '[Phần 1: Ghi danh câu lạc bộ thể thao]\n'
          'Nhân viên: Xin chào! Martin Gallagher đăng ký gói Gold (65 bảng/tháng), bắt đầu ngày 5 tháng 11, số điện thoại 07946 382109.\n\n'
          '[Phần 2: Khu bảo tồn thiên nhiên Riverside]\n'
          'Hướng dẫn viên: Quầy thông tin ở chính diện; cửa hàng quà lưu niệm ở bên trái; đài quan sát chim ở hành lang bên phải qua quán cà phê, đóng cửa lúc 5:30 chiều.\n\n'
          '[Phần 3: Hướng dẫn học thuật về lưới điện microgrid]\n'
          'Giảng viên cùng Sarah và Liam thảo luận: Sarah nhấn mạnh nút thắt lưu trữ pin; Liam cho rằng sự gắn kết cộng đồng và quản trị địa phương còn quan trọng hơn.\n\n'
          '[Phần 4: Bài giảng axít hóa đại dương & tẩy trắng san hô]\n'
          'Giảng viên: San hô cộng sinh với tảo zooxanthellae cung cấp 90% năng lượng. Tăng 1-2 độ C khiến san hô trục xuất tảo (bleaching). Đại dương hấp thụ 30% CO2 làm giảm pH và cản trở sự vôi hóa vỏ canxi cacbonat.',
      keyWords: [
        LessonKeyWord(
          term: 'symbiotic',
          ipa: '/ˌsɪm.baɪˈɒt.ɪk/',
          partOfSpeech: 'adj',
          meaning: 'cộng sinh (tương hỗ cùng sống)',
          example: 'Corals live in an obligate symbiotic relationship with microscopic algae.',
        ),
        LessonKeyWord(
          term: 'bottleneck',
          ipa: '/ˈbɒt.əl.nek/',
          partOfSpeech: 'n',
          meaning: 'điểm nghẽn, trở ngại chính',
          example: 'The main bottleneck remains battery storage efficiency.',
        ),
        LessonKeyWord(
          term: 'anthropogenic',
          ipa: '/ˌæn.θrə.pəˈdʒen.ɪk/',
          partOfSpeech: 'adj',
          meaning: 'do con người gây ra',
          example: 'Oceanic bodies absorb thirty percent of anthropogenic carbon dioxide emissions.',
        ),
      ],
      questions: [
        ExamQuestion(
          id: 'il_full_q1',
          sectionTitle: 'Section 1: Form Completion (NO MORE THAN TWO WORDS)',
          questionText: 'Applicant surname (họ người đăng ký):',
          options: ['Gallagher'],
          correctOptionIndex: 0,
          questionType: 'fill',
          wordLimit: 1,
          acceptedAnswers: ['Gallagher'],
          explanation: 'Họ của người đăng ký là Gallagher (được đánh vần G-A-L-L-A-G-H-E-R).',
          evidenceQuote: 'Martin Gallagher. That is G-A-L-L-A-G-H-E-R.',
          targetSkill: 'Listening Spelling & Form',
        ),
        ExamQuestion(
          id: 'il_full_q2',
          sectionTitle: 'Section 1: Form Completion (ONE WORD ONLY)',
          questionText: 'Selected membership tier (hạng thành viên):',
          options: ['Gold'],
          correctOptionIndex: 0,
          questionType: 'fill',
          wordLimit: 1,
          acceptedAnswers: ['Gold', 'Gold tier'],
          explanation: 'Martin chọn hạng thành viên Gold để vào bể bơi trong nhà và sân tennis vào buổi tối.',
          evidenceQuote: 'the Gold tier would be ideal for me',
          targetSkill: 'Listening Form Completion',
        ),
        ExamQuestion(
          id: 'il_full_q3',
          sectionTitle: 'Section 1: Form Completion (A DATE)',
          questionText: 'Membership start date (ngày bắt đầu):',
          options: ['5 November'],
          correctOptionIndex: 0,
          questionType: 'fill',
          wordLimit: 2,
          acceptedAnswers: ['5 November', '5th November', 'November 5', 'November 5th', '05/11'],
          explanation: 'Ngày bắt đầu là 5th November.',
          evidenceQuote: 'The fifth of November, please.',
          targetSkill: 'Listening Dates',
        ),
        ExamQuestion(
          id: 'il_full_q4',
          sectionTitle: 'Section 2: Multiple Choice',
          questionText: 'Địa điểm nào nằm ngay bên tay trái khi khách bước qua cửa xoay chính?',
          options: [
            'Quầy thông tin (Information desk)',
            'Cửa hàng quà lưu niệm thực vật (Botanical gift shop)',
            'Đài quan sát chim (Bird observation deck)',
            'Quán cà phê đầm lầy'
          ],
          correctOptionIndex: 1,
          explanation: 'Hướng dẫn viên: "To your immediate left is the botanical gift shop".',
          evidenceQuote: 'To your immediate left is the botanical gift shop',
          targetSkill: 'Listening Map Orientation',
        ),
        ExamQuestion(
          id: 'il_full_q5',
          sectionTitle: 'Section 2: Short Answer / Time',
          questionText: 'Đài quan sát chim đóng cửa vào lúc mấy giờ?',
          options: ['5:00 PM', '5:30 PM', '6:00 PM', '7:00 PM'],
          correctOptionIndex: 1,
          explanation: 'Đài quan sát chim đóng cửa lúc 5:30 PM, trong khi quán cà phê mở đến 7:00 PM.',
          evidenceQuote: 'the bird observation deck closes at 5:30 PM',
          targetSkill: 'Listening Numbers & Time',
        ),
        ExamQuestion(
          id: 'il_full_q6',
          sectionTitle: 'Section 3: Matching Opinions',
          questionText: 'Theo Liam, yếu tố nào thậm chí còn quyết định hơn cả công nghệ pin trong dự án microgrid?',
          options: [
            'Sự gắn kết của cộng đồng và quản trị địa phương (Community engagement & governance)',
            'Giá thành của các tấm pin năng lượng mặt trời',
            'Sự tài trợ của chính phủ liên bang',
            'Sự phát triển của xe điện'
          ],
          correctOptionIndex: 0,
          explanation: 'Liam nêu: "community engagement and clear local governance are even more decisive than battery chemistry."',
          evidenceQuote: 'community engagement and clear local governance are even more decisive',
          targetSkill: 'Listening Opinion Matching',
        ),
        ExamQuestion(
          id: 'il_full_q7',
          sectionTitle: 'Section 4: Academic Note Completion (NO MORE THAN TWO WORDS)',
          questionText: 'Algae known as zooxanthellae provide up to 90% of the coral polyp’s _______ requirements.',
          options: ['metabolic energy'],
          correctOptionIndex: 0,
          questionType: 'fill',
          wordLimit: 2,
          acceptedAnswers: ['metabolic energy', 'energy'],
          explanation: 'Trong bài giảng: "provide up to ninety percent of the coral polyp’s metabolic energy requirements."',
          evidenceQuote: 'provide up to ninety percent of the coral polyp’s metabolic energy requirements',
          targetSkill: 'Listening Academic Lecture',
        ),
        ExamQuestion(
          id: 'il_full_q8',
          sectionTitle: 'Section 4: Academic Summary (ONE WORD ONLY)',
          questionText: 'Ocean acidification significantly reduces carbonate ions, impeding calcium carbonate _______.',
          options: ['calcification'],
          correctOptionIndex: 0,
          questionType: 'fill',
          wordLimit: 1,
          acceptedAnswers: ['calcification'],
          explanation: 'Trong bài: "drastically impeding calcium carbonate skeleton calcification."',
          evidenceQuote: 'impeding calcium carbonate skeleton calcification',
          targetSkill: 'Listening Scientific Vocabulary',
        ),
      ],
    ),

    // ==========================================
    // IELTS ACADEMIC READING (850 WORDS)
    // ==========================================
    ExamModel(
      id: 'exam_ielts_read_academic',
      title: 'IELTS Academic Reading: Neuroplasticity & Cognitive Reserve in Bilinguals',
      category: 'IELTS',
      skillSection: 'Reading',
      level: 'B2-C1',
      durationMinutes: 20,
      ieltsModule: 'Academic',
      description:
          'Bài đọc học thuật chuẩn IELTS Academic (850 từ). Luyện kỹ năng Matching Headings, True / False / Not Given (TFNG) và Summary Completion với căn cứ trích dẫn đoạn văn cụ thể.',
      hasAudioScript: false,
      passageOrScript:
          'Paragraph A\n'
          'For much of the twentieth century, pedagogical orthodoxy warned that raising children in a bilingual environment '
          'would inevitably trigger developmental delays and intellectual confusion. Monolingualism was championed as the cognitive '
          'gold standard, with critics asserting that the juvenile brain lacked the neuro-architectural bandwidth to assimilate '
          'two linguistic systems simultaneously without suffering severe academic handicaps. However, over the past three decades, '
          'pioneering investigations in neuroimaging and behavioral psychology have systematically demolished this misconception, '
          'unveiling a neurological landscape wherein managing multiple tongues confers profound cognitive resilience.\n\n'
          'Paragraph B\n'
          'The core mechanism driving bilingual advantages lies in the constant executive control demanded by language competition. '
          'Even when a multilingual individual communicates exclusively in one language, both linguistic repertoires remain '
          'subconsciously active within the cerebral cortex. To avoid speech contamination—such as inserting a French syntax pattern '
          'into an English utterance—the brain’s prefrontal cortex must continuously recruit the dorsolateral prefrontal cortex '
          'and anterior cingulate cortex to suppress the irrelevant lexicon while selecting the target idiom. This lifelong cognitive '
          'gymnastics substantially fortifies the brain’s executive functioning apparatus, encompassing task switching, selective attention, '
          'and conflict resolution.\n\n'
          'Paragraph C\n'
          'The clinical implications of this executive fortification are particularly striking in geriatric medicine. '
          'Epidemiological surveys led by Dr. Ellen Bialystok across diverse clinical cohorts demonstrate that bilingual Alzheimer’s '
          'patients manifest noticeable behavioral symptoms of cognitive decline approximately four to five years later than their '
          'monolingual counterparts with comparable degrees of physical brain pathology. Although bilingualism does not prevent '
          'the underlying biological etiology of neurodegenerative diseases, it builds what neuroscientists classify as "cognitive reserve"—a '
          'robust compensatory neural network that allows the brain to bypass damaged tissue and maintain functional daily autonomy for longer.\n\n'
          'Paragraph D\n'
          'Beyond executive control and delayed dementia onset, polyglot individuals routinely outperform monolinguals in metalinguistic '
          'awareness—the deliberate capacity to reflect upon the nature and structural mechanics of language itself. Because bilingual '
          'children learn early that arbitrary acoustic labels represent abstract concepts, they exhibit superior perceptual flexibility. '
          'For example, when presented with semantic paradoxes, such as accepting an instruction that "a cow is called a dog and therefore barks," '
          'bilingual youths rapidly disentangle communicative arbitrariness from empirical reality.\n\n'
          'Paragraph E\n'
          'Nevertheless, researchers emphasize that the bilingual dividend is neither uniform nor unconditional. The magnitude of cognitive '
          'gains correlates intimately with the frequency of contextual language switching and the speaker’s relative proficiency in both codes. '
          'Occasional or passive bilingualism yields far less structural neuroplasticity than immersive, daily conversational balancing. '
          'Modern cognitive science thus reframes multilingualism not as a decorative personal accomplishment, but as an enduring protective shield '
          'for the human intellect across the lifespan.',
      transcriptVi:
          'Đoạn A: Suốt thế kỷ 20, quan niệm sư phạm cho rằng song ngữ gây chậm phát triển trí tuệ. Ba thập kỷ gần đây, khoa học thần kinh đã chứng minh điều ngược lại.\n'
          'Đoạn B: Cơ chế cốt lõi là kiểm soát điều hành (executive control): cả 2 ngôn ngữ luôn kích hoạt ngầm, buộc vỏ não trước phải liên tục ức chế từ ngữ không liên quan, tăng cường khả năng chuyển đổi nhiệm vụ và tập trung.\n'
          'Đoạn C: Ứng dụng lâm sàng: Bệnh nhân Alzheimer song ngữ khởi phát triệu chứng muộn hơn 4-5 năm nhờ "dự trữ nhận thức" (cognitive reserve).\n'
          'Đoạn D: Năng lực nhận thức ngôn ngữ siêu hình (metalinguistic awareness): trẻ song ngữ nhận thức rõ tính quy ước trừu tượng của ngôn ngữ.\n'
          'Đoạn E: Lợi ích không đồng đều mà phụ thuộc vào tần suất chuyển đổi ngôn ngữ và mức độ thành thạo thực tế.',
      keyWords: [
        LessonKeyWord(
          term: 'orthodoxy',
          ipa: '/ˈɔː.θə.dɒk.si/',
          partOfSpeech: 'n',
          meaning: 'quan niệm chính thống, lề lối truyền thống',
          example: 'Pedagogical orthodoxy warned that raising children bilingual would trigger delays.',
        ),
        LessonKeyWord(
          term: 'cognitive reserve',
          ipa: '/ˈkɒɡ.nə.tɪv rɪˈzɜːv/',
          partOfSpeech: 'n',
          meaning: 'dự trữ nhận thức (khả năng bù đắp của não bộ)',
          example: 'Bilingualism builds what neuroscientists classify as cognitive reserve.',
        ),
        LessonKeyWord(
          term: 'metalinguistic',
          ipa: '/ˌmet.ə.lɪŋˈɡwɪs.tɪk/',
          partOfSpeech: 'adj',
          meaning: 'thuộc siêu ngôn ngữ học (nhận thức về bản chất ngôn ngữ)',
          example: 'Polyglot individuals routinely outperform monolinguals in metalinguistic awareness.',
        ),
      ],
      questions: [
        ExamQuestion(
          id: 'ar_q1',
          sectionTitle: 'Matching Headings',
          paragraphRef: 'Paragraph B',
          questionText: 'Tiêu đề nào sau đây tóm tắt chính xác nhất nội dung của Paragraph B?',
          options: [
            'The physiological mechanics behind executive control in bilingual brains',
            'Historical prejudices against multilingual education in the 20th century',
            'Clinical treatments for severe neurodegenerative diseases',
            'The limitations of passive language learning'
          ],
          correctOptionIndex: 0,
          explanation: 'Paragraph B giải thích chi tiết cơ chế sinh lý học thần kinh (dorsolateral prefrontal cortex & anterior cingulate cortex) trong việc kiểm soát điều hành khi hai ngôn ngữ cùng hoạt động ngầm.',
          evidenceQuote: 'The core mechanism driving bilingual advantages lies in the constant executive control demanded by language competition.',
          targetSkill: 'Matching Headings',
        ),
        ExamQuestion(
          id: 'ar_q2',
          sectionTitle: 'True / False / Not Given (TFNG)',
          paragraphRef: 'Paragraph A',
          questionText: 'Trong suốt thế kỷ 20, các nhà giáo dục học thường khuyến khích việc nuôi dạy trẻ song ngữ vì nó giúp tăng tốc độ phát triển trí tuệ.',
          options: ['TRUE', 'FALSE', 'NOT GIVEN'],
          correctOptionIndex: 1, // FALSE
          questionType: 'tfng',
          explanation: 'Đoạn A khẳng định quan điểm chính thống thế kỷ 20 cảnh báo rằng nuôi dạy trẻ song ngữ sẽ gây chậm phát triển ("trigger developmental delays and intellectual confusion"). Vì vậy câu này trái ngược hoàn toàn (FALSE).',
          evidenceQuote: 'pedagogical orthodoxy warned that raising children in a bilingual environment would inevitably trigger developmental delays',
          targetSkill: 'Reading TFNG',
        ),
        ExamQuestion(
          id: 'ar_q3',
          sectionTitle: 'True / False / Not Given (TFNG)',
          paragraphRef: 'Paragraph C',
          questionText: 'Việc thông thạo song ngữ giúp ngăn chặn hoàn toàn nguyên nhân sinh học gây ra bệnh thoái hóa thần kinh ở người già.',
          options: ['TRUE', 'FALSE', 'NOT GIVEN'],
          correctOptionIndex: 1, // FALSE
          questionType: 'tfng',
          explanation: 'Đoạn C nêu rõ: "bilingualism does not prevent the underlying biological etiology of neurodegenerative diseases, it builds cognitive reserve". Vì vậy câu nói khẳng định ngăn chặn hoàn toàn là FALSE.',
          evidenceQuote: 'Although bilingualism does not prevent the underlying biological etiology of neurodegenerative diseases...',
          targetSkill: 'Reading TFNG',
        ),
        ExamQuestion(
          id: 'ar_q4',
          sectionTitle: 'True / False / Not Given (TFNG)',
          paragraphRef: 'Paragraph C',
          questionText: 'Các bệnh nhân song ngữ tham gia nghiên cứu của Tiến sĩ Bialystok đều có thói quen đọc sách văn học mỗi ngày.',
          options: ['TRUE', 'FALSE', 'NOT GIVEN'],
          correctOptionIndex: 2, // NOT GIVEN
          questionType: 'tfng',
          explanation: 'Đoạn C nói về các đoàn hệ bệnh nhân của Tiến sĩ Bialystok nhưng không hề đề cập đến thói quen đọc sách văn học mỗi ngày của họ (NOT GIVEN).',
          evidenceQuote: 'Epidemiological surveys led by Dr. Ellen Bialystok across diverse clinical cohorts...',
          targetSkill: 'Reading TFNG',
        ),
        ExamQuestion(
          id: 'ar_q5',
          sectionTitle: 'Summary Completion (NO MORE THAN TWO WORDS)',
          paragraphRef: 'Paragraph C',
          questionText: 'Bilingualism creates a neural buffer known as _______ which enables individuals to withstand brain tissue deterioration.',
          options: ['cognitive reserve'],
          correctOptionIndex: 0,
          questionType: 'fill',
          wordLimit: 2,
          acceptedAnswers: ['cognitive reserve'],
          explanation: 'Đoạn C: "it builds what neuroscientists classify as cognitive reserve".',
          evidenceQuote: 'it builds what neuroscientists classify as "cognitive reserve"',
          targetSkill: 'Summary Completion',
        ),
        ExamQuestion(
          id: 'ar_q6',
          sectionTitle: 'Multiple Choice (Inference)',
          paragraphRef: 'Paragraph E',
          questionText: 'Theo tác giả ở Paragraph E, điều kiện nào cần thiết để người học thu được lợi ích dẻo dai thần kinh (neuroplasticity) tối đa?',
          options: [
            'Chỉ cần học thuộc ngữ pháp mà không cần giao tiếp',
            'Phải có sự chuyển đổi ngôn ngữ thường xuyên và thực hành giao tiếp song ngữ sâu rộng hàng ngày',
            'Chỉ nói tiếng mẹ đẻ cho đến khi tròn 18 tuổi',
            'Tránh hoàn toàn các bài tập thử thách trí nhớ'
          ],
          correctOptionIndex: 1,
          explanation: 'Đoạn E khẳng định lợi ích phụ thuộc vào tần suất chuyển đổi theo ngữ cảnh và thực hành giao tiếp cân bằng hàng ngày (immersive, daily conversational balancing).',
          evidenceQuote: 'The magnitude of cognitive gains correlates intimately with the frequency of contextual language switching...',
          targetSkill: 'Reading Inference',
        ),
      ],
    ),

    // ==========================================
    // IELTS GENERAL TRAINING READING (750 WORDS)
    // ==========================================
    ExamModel(
      id: 'exam_ielts_read_general',
      title: 'IELTS General Reading: Workplace Ergonomics & Remote Working Policies',
      category: 'IELTS',
      skillSection: 'Reading',
      level: 'B1-B2',
      durationMinutes: 15,
      ieltsModule: 'General Training',
      description:
          'Bài đọc IELTS General Training về quy định sức khỏe lao động và chính sách làm việc từ xa. Luyện dạng Yes / No / Not Given (YNNG), ghép thông tin và câu hỏi trả lời ngắn.',
      hasAudioScript: false,
      passageOrScript:
          'SECTION 1: Ergonomic Guidelines for Display Screen Equipment (DSE)\n'
          'Modern office employees spend an estimated average of 7.5 hours per day stationed before digital displays. '
          'Prolonged static postures and repetitive keystrokes are recognized contributors to musculoskeletal disorders (MSD), '
          'including cervical strain, carpal tunnel syndrome, and lumbar tension. Under corporate health and safety regulations, '
          'all department heads must ensure that personnel complete an ergonomic self-assessment workstation checklist within '
          'fourteen working days of commencement or workspace relocation.\n\n'
          'Key ergonomic adjustments include:\n'
          '• Monitor Position: The top of the monitor casing should align horizontally with eye level, positioned roughly arm’s length away (50–70 cm).\n'
          '• Chair Lumbar Support: The backrest must firmly support the inward curve of the lower spine. Feet should rest flat on the floor; otherwise, an adjustable footrest must be supplied upon request at no cost to the employee.\n'
          '• Rest Breaks: Staff are advised to observe the 20-20-20 rule—every 20 minutes, gaze at an object 20 feet away for at least 20 seconds.\n\n'
          'SECTION 2: Hybrid Employment Stipend and Asset Care Policy\n'
          'Eligible employees transitioning to a hybrid schedule (minimum two days remote per week) may claim a one-off tax-free '
          'home-office stipend of up to £350. This reimbursement applies exclusively toward approved hardware items: certified ergonomic task chairs, '
          'external keyboards, and height-adjustable desk converters. Peripheral computer hardware provided directly by the company '
          '(such as secure corporate laptops and docking hubs) remains company property and must be surrendered upon contract termination. '
          'Damage resulting from negligence or unauthorized third-party repairs will be deducted from final salary settlements.',
      transcriptVi:
          'Mục 1: Hướng dẫn công thái học màn hình (DSE): Nhân viên hoàn thành tự kiểm tra trong 14 ngày làm việc. Màn hình ngang tầm mắt cách 50-70cm; ghế tựa hỗ trợ thắt lưng; kê chân miễn phí theo yêu cầu; quy tắc nghỉ 20-20-20.\n'
          'Mục 2: Trợ cấp làm việc kết hợp hybrid: Trợ cấp 1 lần tối đa £350 cho ghế công thái học, bàn nâng, bàn phím rời. Thiết bị cấp phát là tài sản công ty.',
      keyWords: [
        LessonKeyWord(
          term: 'musculoskeletal',
          ipa: '/ˌmʌs.kjə.ləʊˈskel.ɪ.təl/',
          partOfSpeech: 'adj',
          meaning: 'thuộc hệ cơ xương khớp',
          example: 'Prolonged static postures contribute to musculoskeletal disorders.',
        ),
        LessonKeyWord(
          term: 'stipend',
          ipa: '/ˈstaɪ.pend/',
          partOfSpeech: 'n',
          meaning: 'khoản trợ cấp phụ cấp',
          example: 'Eligible employees may claim a one-off home-office stipend.',
        ),
      ],
      questions: [
        ExamQuestion(
          id: 'gr_q1',
          sectionTitle: 'Yes / No / Not Given (YNNG)',
          paragraphRef: 'Section 1',
          questionText: 'Nhân viên mới bắt buộc phải hoàn thành bảng tự kiểm tra công thái học bàn làm việc trong vòng 14 ngày làm việc.',
          options: ['YES', 'NO', 'NOT GIVEN'],
          correctOptionIndex: 0, // YES
          questionType: 'ynng',
          explanation: 'Mục 1 nêu: "must ensure that personnel complete an ergonomic self-assessment workstation checklist within fourteen working days". Khớp hoàn toàn với ý của tác giả (YES).',
          evidenceQuote: 'personnel complete an ergonomic self-assessment workstation checklist within fourteen working days',
          targetSkill: 'Reading YNNG',
        ),
        ExamQuestion(
          id: 'gr_q2',
          sectionTitle: 'Yes / No / Not Given (YNNG)',
          paragraphRef: 'Section 1',
          questionText: 'Công ty sẽ tính phí dịch vụ nếu nhân viên yêu cầu cung cấp bàn kê chân (footrest).',
          options: ['YES', 'NO', 'NOT GIVEN'],
          correctOptionIndex: 1, // NO
          questionType: 'ynng',
          explanation: 'Mục 1 nêu rõ: "an adjustable footrest must be supplied upon request at no cost to the employee" (không tốn chi phí). Do đó câu khẳng định tính phí là trái ngược (NO).',
          evidenceQuote: 'supplied upon request at no cost to the employee',
          targetSkill: 'Reading YNNG',
        ),
        ExamQuestion(
          id: 'gr_q3',
          sectionTitle: 'Short Answer (NO MORE THAN THREE WORDS AND/OR A NUMBER)',
          paragraphRef: 'Section 2',
          questionText: 'Số tiền tối đa của khoản trợ cấp văn phòng tại nhà một lần là bao nhiêu?',
          options: ['£350', '350 pounds', '350'],
          correctOptionIndex: 0,
          questionType: 'fill',
          wordLimit: 3,
          acceptedAnswers: ['£350', '350 pounds', '350', 'up to £350'],
          explanation: 'Trong Mục 2: "home-office stipend of up to £350".',
          evidenceQuote: 'one-off tax-free home-office stipend of up to £350',
          targetSkill: 'Reading Short Answer',
        ),
        ExamQuestion(
          id: 'gr_q4',
          sectionTitle: 'Multiple Choice',
          paragraphRef: 'Section 2',
          questionText: 'Điều gì sẽ xảy ra với các thiết bị máy tính do công ty cấp phát (như laptop doanh nghiệp) khi nhân viên thôi việc?',
          options: [
            'Nhân viên được quyền giữ lại để sử dụng cá nhân',
            'Nhân viên phải bàn giao trả lại công ty (must be surrendered)',
            'Công ty sẽ tự động bán thanh lý cho nhân viên với giá rẻ',
            'Được chuyển giao cho đồng nghiệp trong cùng bộ phận'
          ],
          correctOptionIndex: 1,
          explanation: 'Mục 2 nêu: "remains company property and must be surrendered upon contract termination."',
          evidenceQuote: 'remains company property and must be surrendered upon contract termination',
          targetSkill: 'Reading Information Matching',
        ),
      ],
    ),

    // ==========================================
    // IELTS ACADEMIC WRITING TASK 1 (BAR CHART)
    // ==========================================
    ExamModel(
      id: 'exam_ielts_write_task1_acad',
      title: 'IELTS Academic Writing Task 1: Renewable Electricity Generation in Europe',
      category: 'IELTS',
      skillSection: 'Writing',
      level: 'B2-C1',
      durationMinutes: 20,
      ieltsModule: 'Academic',
      writingTaskType: 'Task 1 Academic',
      chartType: 'bar',
      chartData: {
        'title': 'Percentage of Electricity from Renewable Sources (2015 vs 2025)',
        'categories': ['Germany', 'Spain', 'UK', 'Norway'],
        'series': [
          {'name': '2015', 'values': [32, 38, 25, 95]},
          {'name': '2025 (Projected)', 'values': [58, 62, 54, 98]},
        ],
      },
      description:
          'Đề thi viết IELTS Academic Task 1 kèm biểu đồ trực quan. Yêu cầu tóm tắt các đặc điểm chính, so sánh dữ liệu qua 2 mốc thời gian (2015 và 2025). Tối thiểu 150 từ, thời gian làm bài khuyến nghị 20 phút.',
      passageOrScript:
          'WRITING TASK 1 PROMPT:\n'
          'The bar chart illustrates the proportion of electricity generated from renewable sources in four European nations (Germany, Spain, the UK, and Norway) in 2015, alongside projections for 2025.\n\n'
          'Summarise the information by selecting and reporting the main features, and make comparisons where relevant.\n'
          'Write at least 150 words.',
      transcriptVi:
          'Đề bài Task 1 Academic: Biểu đồ cột thể hiện tỷ trọng điện sản xuất từ nguồn tái tạo tại 4 quốc gia châu Âu (Đức, Tây Ban Nha, Anh, Na Uy) năm 2015 và dự báo 2025. Hãy tóm tắt các đặc điểm nổi bật, viết ít nhất 150 từ trong 20 phút.',
      sampleResponseBand8:
          'The bar chart compares the share of electricity produced from renewable energy sources across four European countries in 2015, with projected figures for the year 2025.\n\n'
          'Overall, it is clear that all four countries are expected to experience an upward trajectory in green electricity generation over the decade. Notably, Norway maintained a dominant position throughout the period, whereas the United Kingdom was projected to witness the most substantial relative growth.\n\n'
          'Looking first at Norway, renewable electricity already constituted an overwhelming 95% of its total output in 2015. This figure is forecasted to rise marginally to 98% by 2025, solidifying its clean energy leadership. In contrast, the remaining three nations began from considerably lower baselines.\n\n'
          'Among the other countries, Spain generated 38% of its power renewably in 2015, followed by Germany at 32% and the UK at a modest 25%. However, all three are projected to achieve marked expansions by 2025. Spain is predicted to climb by 24 percentage points to 62%, thereby surpassing Germany, which is expected to reach 58%. The most dramatic surge is anticipated in the UK, where the renewable proportion is projected to more than double, reaching 54% and closely converging with the German share.',
      examinerNotes:
          '• Task Achievement (Band 8.5): Thí sinh nêu bật được tổng quan (Overview) xuất sắc với 2 xu hướng chính (tất cả đều tăng, Na Uy dẫn đầu, Anh tăng mạnh nhất). Mọi số liệu quan trọng đều được chọn lọc và so sánh logic.\n'
          '• Coherence & Cohesion (Band 8.5): Bố cục 4 đoạn chuẩn mực (Introduction, Overview, Details 1 - Norway, Details 2 - 3 nước còn lại). Các liên từ mạch lạc: "Overall", "Looking first at", "In contrast", "Among the other countries".\n'
          '• Lexical Resource (Band 8.5): Vốn từ phong phú miêu tả xu hướng: "upward trajectory", "dominant position", "marginal rise", "marked expansions", "dramatic surge", "converging with".\n'
          '• Grammatical Range (Band 8.5): Kết hợp linh hoạt thì quá khứ đơn ("constituted") và cấu trúc dự báo tương lai ("is projected to", "is forecasted to rise").',
      keyWords: [
        LessonKeyWord(
          term: 'trajectory',
          ipa: '/trəˈdʒek.tər.i/',
          partOfSpeech: 'n',
          meaning: 'quỹ đạo, chiều hướng phát triển',
          example: 'All four countries are expected to experience an upward trajectory.',
        ),
        LessonKeyWord(
          term: 'converge',
          ipa: '/kənˈvɜːdʒ/',
          partOfSpeech: 'v',
          meaning: 'hội tụ, tiến gần tới cùng một mức',
          example: 'Reaching 54% and closely converging with the German share.',
        ),
      ],
      questions: [],
    ),

    // ==========================================
    // IELTS GENERAL WRITING TASK 1 (FORMAL LETTER)
    // ==========================================
    ExamModel(
      id: 'exam_ielts_write_task1_gt',
      title: 'IELTS General Writing Task 1: Formal Letter to Conference Venue',
      category: 'IELTS',
      skillSection: 'Writing',
      level: 'B1-B2',
      durationMinutes: 20,
      ieltsModule: 'General Training',
      writingTaskType: 'Task 1 General',
      chartType: 'none',
      description:
          'Đề thi viết IELTS General Training Task 1 (Formal Letter). Viết thư trang trọng gửi ban quản lý khách sạn/trung tâm hội nghị về sự cố thiết bị và yêu cầu bồi hoàn dịch vụ. Tối thiểu 150 từ.',
      passageOrScript:
          'WRITING TASK 1 (GENERAL TRAINING) PROMPT:\n'
          'You recently organized a business conference at a hotel, but several problems occurred with the facilities and audio-visual equipment.\n\n'
          'Write a letter to the hotel manager. In your letter:\n'
          '• Provide details of your booking and the event\n'
          '• Explain what problems occurred during the conference\n'
          '• State what actions you expect the hotel management to take\n\n'
          'Write at least 150 words. You do NOT need to write any addresses. Begin your letter with: Dear Sir or Madam,',
      transcriptVi:
          'Đề bài Task 1 General Training: Viết thư khiếu nại trang trọng gửi Giám đốc khách sạn về sự cố phòng hội nghị (thông tin đặt phòng, sự cố thiết bị và yêu cầu bồi hoàn). Viết tối thiểu 150 từ.',
      sampleResponseBand8:
          'Dear Sir or Madam,\n\n'
          'I am writing to express my profound dissatisfaction with the conference facilities provided during our annual corporate seminar, held at your hotel on October 24th under booking reference CF-8924.\n\n'
          'We reserved the Grand Ballroom from 9:00 AM to 5:00 PM for eighty international delegates, having specifically pre-ordered high-definition projectors, dual wireless microphone sets, and simultaneous audio streaming capabilities.\n\n'
          'Regrettably, upon arrival, the ceiling-mounted projector failed to synchronize with our presentation laptops due to outdated display adapter cables. Furthermore, the audio system suffered persistent high-frequency feedback, forcing our keynote speaker to deliver her address without amplification for over forty minutes while your on-duty technician attempted troubleshooting. To compound matters, the air conditioning system malfunctioned midway through the afternoon session, leaving the auditorium uncomfortably warm.\n\n'
          'Given that these technical disruptions severely compromised the professional reputation of our organization, I request a formal written apology along with a 35% reimbursement of our total venue rental fee. I trust you will treat this matter with the urgency it warrants, and I look forward to your prompt response.\n\n'
          'Yours faithfully,\n'
          'Marcus Vance\n'
          'Head of Corporate Communications',
      examinerNotes:
          '• Task Achievement (Band 8.5): Giải quyết trọn vẹn cả 3 yêu cầu đề bài: nêu rõ mã đặt chỗ & thời gian, liệt kê chi tiết sự cố máy chiếu / micro / điều hòa, và yêu cầu bồi hoàn 35% chi phí kèm thư xin lỗi.\n'
          '• Tone & Register (Band 9.0): Giọng văn trang trọng, lịch thiệp, chuẩn mực công sở Anh ("Dear Sir or Madam" kết thúc bằng "Yours faithfully").\n'
          '• Cohesion & Coherence (Band 8.5): Liên kết mượt mà với "Regrettably", "Furthermore", "To compound matters", "Given that".\n'
          '• Lexical Resource (Band 8.5): "profound dissatisfaction", "international delegates", "persistent high-frequency feedback", "compromised professional reputation", "prompt response".',
      keyWords: [],
      questions: [],
    ),

    // ==========================================
    // IELTS WRITING TASK 2 (ESSAY - DISCUSSION & OPINION)
    // ==========================================
    ExamModel(
      id: 'exam_ielts_write_task2',
      title: 'IELTS Writing Task 2: Artificial Intelligence in Modern Classrooms',
      category: 'IELTS',
      skillSection: 'Writing',
      level: 'B2-C1',
      durationMinutes: 40,
      writingTaskType: 'Task 2',
      chartType: 'none',
      description:
          'Đề thi viết IELTS Writing Task 2 (Dạng bài thảo luận 2 quan điểm và nêu ý kiến riêng: Discuss both views and give your opinion). Tối thiểu 250 từ, thời gian làm bài khuyến nghị 40 phút.',
      passageOrScript:
          'WRITING TASK 2 PROMPT:\n'
          'Some people believe that artificial intelligence applications and adaptive learning software will eventually replace human teachers in classrooms. Others argue that educators remain fundamentally irreplaceable.\n\n'
          'Discuss both views and give your own opinion.\n'
          'Give reasons for your answer and include any relevant examples from your own knowledge or experience.\n'
          'Write at least 250 words.',
      transcriptVi:
          'Đề bài Task 2: Một số người tin rằng công cụ AI sẽ thay thế giáo viên trong lớp học, trong khi người khác cho rằng giáo viên con người không thể thay thế. Thảo luận cả 2 quan điểm và đưa ra ý kiến của bạn. Tối thiểu 250 từ.',
      sampleResponseBand8:
          'In recent years, the rapid proliferation of artificial intelligence tools and automated tutoring algorithms has ignited a passionate debate regarding the future of the teaching profession. While some observers contend that intelligent instructional software will ultimately render human teachers obsolete, I firmly believe that educators possess interpersonal and pedagogical dimensions that machine algorithms cannot replicate.\n\n'
          'On the one hand, advocates of automated education point out the undeniable efficiencies and bespoke personalization offered by modern educational technology. AI-powered platforms can instantly diagnose an individual pupil’s conceptual weaknesses, adapt question difficulty in real time, and deliver customized problem sets far faster than an instructor overseeing thirty students. Furthermore, intelligent learning tools can grade homework objectively around the clock, eliminating geographical and socio-economic barriers for underprivileged pupils who lack access to top-tier academic institutions.\n\n'
          'On the other hand, reducing pedagogy to algorithmic data transmission fundamentally misinterprets the essence of holistic education. Teaching is inherently an empathetic enterprise. Human mentors inspire curiosity, instill ethical principles, and provide critical emotional encouragement when students encounter psychological obstacles. A sensitive teacher notices subtle behavioral cues such as demotivation or anxiety—nuances that automated software inevitably overlooks. Moreover, teachers foster critical thinking and collaborative teamwork through nuanced classroom dialogues, modeling citizenship and values that cannot be coded into algorithmic parameters.\n\n'
          'In conclusion, although artificial intelligence undoubtedly serves as an extraordinary pedagogical aid that streamlines factual dissemination and diagnostic assessment, it remains merely a tool. The holistic, moral, and emotional guidance provided by dedicated educators guarantees that human teachers will remain irreplaceable in modern schooling.',
      examinerNotes:
          '• Task Response (Band 8.5): Bàn luận thấu đáo cả hai mặt của vấn đề và duy trì lập trường nhất quán (Clear position throughout). Các luận điểm về cá nhân hóa dữ liệu của AI và giá trị cảm xúc/đạo đức của giáo viên con người được phát triển sâu sắc.\n'
          '• Coherence & Cohesion (Band 8.5): Phân đoạn chặt chẽ (Mở bài, Thân bài 1 - Ủng hộ AI, Thân bài 2 - Giá trị giáo viên, Kết luận). Từ nối học thuật được dùng tự nhiên: "On the one hand", "On the other hand", "Furthermore", "In conclusion".\n'
          '• Lexical Resource (Band 9.0): Từ vựng học thuật đỉnh cao: "proliferation", "render obsolete", "bespoke personalization", "empathetic enterprise", "holistic education", "algorithmic data transmission", "streamlines factual dissemination".\n'
          '• Grammatical Range (Band 8.5): Đa dạng mệnh đề quan hệ, câu phức điều kiện, đảo ngữ và danh từ hóa (nominalization).',
      keyWords: [],
      questions: [],
    ),
  ];
}

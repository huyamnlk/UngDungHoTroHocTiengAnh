import '../../data/models/skill_exercise_model.dart';

class SkillsSeedData {
  SkillsSeedData._();

  static final List<SkillExerciseModel> listeningExercises = [
    const SkillExerciseModel(
      id: 'lis_0_a1',
      type: SkillType.listening,
      title: 'Làm quen và giới thiệu bản thân (First Day at Class)',
      level: 'A1',
      topic: 'Giao tiếp hằng ngày',
      content:
          'Good morning everyone! My name is Minh, and I am twenty years old. '
          'I come from Da Nang, a coastal city in central Vietnam. '
          'In my free time, I enjoy listening to English podcasts and playing badminton with my neighbors.',
      contentVi:
          'Chào buổi sáng mọi người! Tên tôi là Minh, năm nay tôi 20 tuổi. '
          'Tôi đến từ Đà Nẵng, một thành phố biển ở miền Trung Việt Nam. '
          'Vào thời gian rảnh, tôi thích nghe podcast tiếng Anh và chơi cầu lông với hàng xóm.',
      keyWords: [
        LessonKeyWord(
          term: 'coastal',
          ipa: '/ˈkəʊ.stəl/',
          partOfSpeech: 'adj',
          meaning: 'thuộc vùng ven biển',
          example: 'Da Nang is a coastal city.',
        ),
        LessonKeyWord(
          term: 'neighbor',
          ipa: '/ˈneɪ.bər/',
          partOfSpeech: 'n',
          meaning: 'hàng xóm',
          example: 'I play badminton with my neighbors.',
        ),
      ],
      questions: [
        SkillQuestion(
          questionText: 'Minh đến từ thành phố nào?',
          options: ['Hà Nội', 'Đà Nẵng', 'Huế', 'Nha Trang'],
          correctOptionIndex: 1,
          explanation: 'Trong bài nghe: "I come from Da Nang, a coastal city in central Vietnam."',
        ),
        SkillQuestion(
          questionText: 'Minh thích chơi môn thể thao nào vào thời gian rảnh?',
          options: ['Bóng đá', 'Bơi lội', 'Cầu lông', 'Chạy bộ'],
          correctOptionIndex: 2,
          explanation: 'Trong bài nghe: "playing badminton with my neighbors".',
        ),
        SkillQuestion(
          questionText: 'Điền từ tiếng Anh còn thiếu: "a _______ city in central Vietnam" (thành phố ven biển)',
          options: ['coastal'],
          correctOptionIndex: 0,
          questionType: 'fill',
          acceptedAnswers: ['coastal'],
          explanation: 'Từ cần điền là "coastal" (/ˈkəʊ.stəl/ - ven biển).',
        ),
      ],
    ),
    const SkillExerciseModel(
      id: 'lis_1',
      type: SkillType.listening,
      title: 'Đặt bàn tại nhà hàng (Dining Out)',
      level: 'A2',
      topic: 'Ăn uống & Đời sống',
      content:
          'Hello, I would like to book a table for four people tonight at 7 PM. '
          'We prefer a quiet table near the window if possible. Also, one of our guests is vegetarian, '
          'so we would appreciate it if you could recommend some plant-based dishes.',
      contentVi:
          'Xin chào, tôi muốn đặt một bàn cho bốn người vào tối nay lúc 7 giờ. '
          'Chúng tôi ưu tiên một bàn yên tĩnh gần cửa sổ nếu có thể. Ngoài ra, một trong những vị khách của chúng tôi ăn chay, '
          'vì vậy chúng tôi sẽ rất cảm kích nếu bạn có thể giới thiệu một số món ăn thực vật.',
      keyWords: [
        LessonKeyWord(
          term: 'vegetarian',
          ipa: '/ˌvedʒ.ɪˈteə.ri.ən/',
          partOfSpeech: 'n/adj',
          meaning: 'người ăn chay / thuộc đồ chay',
          example: 'One of our guests is vegetarian.',
        ),
        LessonKeyWord(
          term: 'recommend',
          ipa: '/ˌrek.əˈmend/',
          partOfSpeech: 'v',
          meaning: 'giới thiệu, đề xuất',
          example: 'Could you recommend some plant-based dishes?',
        ),
      ],
      questions: [
        SkillQuestion(
          questionText: 'Người nói muốn đặt bàn cho bao nhiêu người?',
          options: ['2 người', '3 người', '4 người', '5 người'],
          correctOptionIndex: 2,
          explanation: 'Trong bài nghe: "book a table for four people".',
        ),
        SkillQuestion(
          questionText: 'Bàn được yêu cầu ở vị trí nào?',
          options: ['Gần cửa ra vào', 'Gần cửa sổ', 'Tầng hai', 'Ngoài ban công'],
          correctOptionIndex: 1,
          explanation: 'Người nói nói: "near the window if possible".',
        ),
        SkillQuestion(
          questionText: 'Khách yêu cầu món ăn gì cho một vị khách?',
          options: ['Món cay', 'Món ăn chay', 'Món tráng miệng', 'Hải sản'],
          correctOptionIndex: 1,
          explanation: 'Bài nghe đề cập: "one of our guests is vegetarian".',
        ),
      ],
    ),
    const SkillExerciseModel(
      id: 'lis_2',
      type: SkillType.listening,
      title: 'Phỏng vấn dự án công nghệ (Tech Interview)',
      level: 'B1',
      topic: 'Công nghệ & Kỹ thuật số',
      content:
          'In this mobile project, we adopted Flutter for cross-platform development. '
          'Our main goal was to deliver a smooth user experience while maintaining a single codebase. '
          'For offline data persistence, SQLite was chosen because it provides reliable and secure local transactions.',
      contentVi:
          'Trong dự án di động này, chúng tôi đã áp dụng Flutter để phát triển đa nền tảng. '
          'Mục tiêu chính của chúng tôi là mang lại trải nghiệm người dùng mượt mà trong khi vẫn duy trì một cơ sở mã duy nhất. '
          'Đối với việc lưu trữ dữ liệu ngoại tuyến, SQLite đã được chọn vì nó cung cấp các giao dịch cục bộ đáng tin cậy và an toàn.',
      keyWords: [
        LessonKeyWord(
          term: 'persistence',
          ipa: '/pəˈsɪs.təns/',
          partOfSpeech: 'n',
          meaning: 'sự lưu trữ bền vững (dữ liệu)',
          example: 'For offline data persistence, SQLite was chosen.',
        ),
        LessonKeyWord(
          term: 'reliable',
          ipa: '/rɪˈlaɪ.ə.bəl/',
          partOfSpeech: 'adj',
          meaning: 'đáng tin cậy',
          example: 'It provides reliable and secure local transactions.',
        ),
      ],
      questions: [
        SkillQuestion(
          questionText: 'Công nghệ nào được dùng để phát triển đa nền tảng?',
          options: ['React Native', 'Flutter', 'Swift', 'Kotlin Native'],
          correctOptionIndex: 1,
          explanation: 'Người nói nêu rõ: "we adopted Flutter for cross-platform development".',
        ),
        SkillQuestion(
          questionText: 'Tại sao nhóm phát triển lại chọn SQLite?',
          options: [
            'Vì nó miễn phí hoàn toàn',
            'Vì lưu trữ ngoại tuyến đáng tin cậy và an toàn',
            'Vì giao diện đẹp',
            'Vì không cần lập trình'
          ],
          correctOptionIndex: 1,
          explanation: 'Trong bài: "it provides reliable and secure local transactions".',
        ),
        SkillQuestion(
          questionText: 'Điền từ tiếng Anh còn thiếu: "maintaining a single _______" (một cơ sở mã nguồn duy nhất)',
          options: ['codebase'],
          correctOptionIndex: 0,
          questionType: 'fill',
          acceptedAnswers: ['codebase', 'code base'],
          explanation: 'Thuật ngữ kỹ thuật trong bài là "codebase" (cơ sở mã nguồn).',
        ),
      ],
    ),
    const SkillExerciseModel(
      id: 'lis_3',
      type: SkillType.listening,
      title: 'Bảo vệ môi trường xanh (Green Living)',
      level: 'B2',
      topic: 'Môi trường & Tự nhiên',
      content:
          'Global warming has accelerated renewable energy transitions worldwide. '
          'Solar and wind energy now account for a substantial percentage of total electrical output. '
          'Individuals can also contribute by minimizing single-use plastics and embracing public transportation.',
      contentVi:
          'Sự nóng lên toàn cầu đã thúc đẩy nhanh quá trình chuyển đổi năng lượng tái tạo trên toàn thế giới. '
          'Năng lượng mặt trời và gió hiện chiếm tỷ lệ đáng kể trong tổng sản lượng điện. '
          'Các cá nhân cũng có thể đóng góp bằng cách giảm thiểu nhựa dùng một lần và sử dụng phương tiện giao thông công cộng.',
      keyWords: [
        LessonKeyWord(
          term: 'renewable',
          ipa: '/rɪˈnjuː.ə.bəl/',
          partOfSpeech: 'adj',
          meaning: 'có thể tái tạo',
          example: 'Global warming has accelerated renewable energy transitions.',
        ),
        LessonKeyWord(
          term: 'substantial',
          ipa: '/səbˈstæn.ʃəl/',
          partOfSpeech: 'adj',
          meaning: 'đáng kể, lớn lao',
          example: 'Solar and wind energy account for a substantial percentage.',
        ),
      ],
      questions: [
        SkillQuestion(
          questionText: 'Hai nguồn năng lượng tái tạo nào được nhắc đến?',
          options: ['Năng lượng than và khí đốt', 'Năng lượng mặt trời và gió', 'Năng lượng hạt nhân', 'Thủy điện'],
          correctOptionIndex: 1,
          explanation: 'Bài nghe đề cập: "Solar and wind energy".',
        ),
        SkillQuestion(
          questionText: 'Người dân có thể đóng góp bằng hành động nào?',
          options: [
            'Mua thêm xe hơi cá nhân',
            'Giảm nhựa dùng một lần & đi phương tiện công cộng',
            'Xây thêm nhà máy',
            'Hạn chế trồng cây'
          ],
          correctOptionIndex: 1,
          explanation: 'Trong bài: "minimizing single-use plastics and embracing public transportation".',
        ),
      ],
    ),
    const SkillExerciseModel(
      id: 'lis_4_c1',
      type: SkillType.listening,
      title: 'Chiến lược làm việc kết hợp (Hybrid Work Architecture)',
      level: 'C1',
      topic: 'Công sở & Sự nghiệp',
      content:
          'Modern organizations are increasingly adopting asynchronous communication protocols to accommodate distributed teams. '
          'Rather than measuring productivity by physical presence in an office, executive leadership now evaluates tangible deliverables '
          'and cross-functional collaboration. Nevertheless, deliberate mentorship programs remain indispensable to prevent professional isolation.',
      contentVi:
          'Các tổ chức hiện đại ngày càng áp dụng các giao thức giao tiếp không đồng bộ để phù hợp với các nhóm làm việc phân tán. '
          'Thay vì đo lường năng suất bằng sự hiện diện vật lý tại văn phòng, ban lãnh đạo hiện đánh giá dựa trên kết quả đầu ra cụ thể '
          'và sự phối hợp liên phòng ban. Tuy nhiên, các chương trình cố vấn có chủ đích vẫn không thể thiếu nhằm ngăn chặn sự cô lập nghề nghiệp.',
      keyWords: [
        LessonKeyWord(
          term: 'asynchronous',
          ipa: '/eɪˈsɪŋ.krə.nəs/',
          partOfSpeech: 'adj',
          meaning: 'không đồng bộ',
          example: 'Organizations adopt asynchronous communication protocols.',
        ),
        LessonKeyWord(
          term: 'indispensable',
          ipa: '/ˌɪn.dɪˈspen.sə.bəl/',
          partOfSpeech: 'adj',
          meaning: 'không thể thiếu, thiết yếu',
          example: 'Deliberate mentorship programs remain indispensable.',
        ),
      ],
      questions: [
        SkillQuestion(
          questionText: 'Ban lãnh đạo hiện nay đánh giá năng suất dựa trên tiêu chí nào?',
          options: [
            'Số giờ ngồi tại văn phòng',
            'Kết quả đầu ra cụ thể và sự phối hợp liên phòng ban',
            'Số lượng email gửi mỗi ngày',
            'Thâm niên làm việc'
          ],
          correctOptionIndex: 1,
          explanation: 'Trong bài: "evaluates tangible deliverables and cross-functional collaboration".',
        ),
        SkillQuestion(
          questionText: 'Điền tính từ C1 mang nghĩa "không thể thiếu": "mentorship programs remain _______"',
          options: ['indispensable'],
          correctOptionIndex: 0,
          questionType: 'fill',
          acceptedAnswers: ['indispensable'],
          explanation: '"indispensable" (/ˌɪn.dɪˈspen.sə.bəl/) nghĩa là tối quan trọng, không thể thiếu.',
        ),
      ],
    ),
  ];

  static final List<SkillExerciseModel> readingExercises = [
    const SkillExerciseModel(
      id: 'read_0_a1',
      type: SkillType.reading,
      title: 'Một buổi sáng cuối tuần (A Relaxing Sunday Morning)',
      level: 'A1',
      topic: 'Giao tiếp hằng ngày',
      content:
          'Every Sunday morning, Lan wakes up at half past six and walks to the local market with her mother. '
          'They buy fresh vegetables, tropical fruits, and warm bread for breakfast. '
          'After breakfast, Lan waters the small garden on the balcony and reads her favorite storybook.',
      contentVi:
          'Mỗi sáng Chủ nhật, Lan thức dậy lúc 6 giờ rưỡi và đi bộ ra chợ địa phương cùng mẹ. '
          'Họ mua rau tươi, trái cây nhiệt đới và bánh mì nóng cho bữa sáng. '
          'Sau bữa sáng, Lan tưới khu vườn nhỏ ngoài ban công và đọc cuốn truyện yêu thích của mình.',
      keyWords: [
        LessonKeyWord(
          term: 'local',
          ipa: '/ˈləʊ.kəl/',
          partOfSpeech: 'adj',
          meaning: 'địa phương, tại chỗ',
          example: 'She walks to the local market.',
        ),
        LessonKeyWord(
          term: 'balcony',
          ipa: '/ˈbæl.kə.ni/',
          partOfSpeech: 'n',
          meaning: 'ban công',
          example: 'Lan waters the small garden on the balcony.',
        ),
      ],
      questions: [
        SkillQuestion(
          questionText: 'Lan thức dậy lúc mấy giờ vào sáng Chủ nhật?',
          options: ['6:00', '6:30', '7:00', '7:30'],
          correctOptionIndex: 1,
          explanation: 'Trong bài đọc: "wakes up at half past six" (6 giờ 30 phút).',
        ),
        SkillQuestion(
          questionText: 'Điền từ tiếng Anh còn thiếu: "waters the small garden on the _______" (ban công)',
          options: ['balcony'],
          correctOptionIndex: 0,
          questionType: 'fill',
          acceptedAnswers: ['balcony'],
          explanation: 'Từ trong bài là "balcony" (/ˈbæl.kə.ni/ - ban công).',
        ),
      ],
    ),
    const SkillExerciseModel(
      id: 'read_1',
      type: SkillType.reading,
      title: 'Lợi ích của việc học ngôn ngữ mỗi ngày (Daily Language Learning)',
      level: 'A2',
      topic: 'Trường học & Học thuật',
      content:
          'Learning a foreign language requires consistent dedication rather than occasional cramming. '
          'Spending just fifteen minutes every morning reviewing vocabulary through flashcards significantly strengthens '
          'long-term retention. Moreover, practicing short dialogues helps learners build natural reflexes and speak '
          'with genuine confidence.',
      contentVi:
          'Học một ngoại ngữ đòi hỏi sự kiên trì liên tục hơn là nhồi nhét thỉnh thoảng. '
          'Chỉ cần dành ra mười lăm phút mỗi buổi sáng để ôn từ vựng qua flashcard sẽ tăng cường đáng kể khả năng ghi nhớ dài hạn. '
          'Hơn nữa, luyện tập các đoạn hội thoại ngắn giúp người học xây dựng phản xạ tự nhiên và nói chuyện với sự tự tin thực sự.',
      keyWords: [
        LessonKeyWord(
          term: 'consistent',
          ipa: '/kənˈsɪs.tənt/',
          partOfSpeech: 'adj',
          meaning: 'kiên trì, đều đặn, nhất quán',
          example: 'Learning requires consistent dedication.',
        ),
        LessonKeyWord(
          term: 'retention',
          ipa: '/rɪˈten.ʃən/',
          partOfSpeech: 'n',
          meaning: 'khả năng ghi nhớ, lưu giữ',
          example: 'Flashcards strengthen long-term retention.',
        ),
        LessonKeyWord(
          term: 'cramming',
          ipa: '/ˈkræm.ɪŋ/',
          partOfSpeech: 'n',
          meaning: 'học nhồi nhét',
          example: 'Consistent dedication rather than occasional cramming.',
        ),
      ],
      questions: [
        SkillQuestion(
          questionText: 'Theo đoạn văn, học ngôn ngữ cần điều gì quan trọng nhất?',
          options: [
            'Nhồi nhét trước kỳ thi',
            'Sự kiên trì đều đặn mỗi ngày',
            'Chỉ học ngữ pháp phức tạp',
            'Học một mình không giao tiếp'
          ],
          correctOptionIndex: 1,
          explanation: 'Đoạn văn nói: "Learning a foreign language requires consistent dedication rather than occasional cramming."',
        ),
        SkillQuestion(
          questionText: 'Mỗi ngày nên dành bao nhiêu thời gian ôn từ vựng?',
          options: ['15 phút', '2 tiếng', '45 phút', 'Cả ngày'],
          correctOptionIndex: 0,
          explanation: 'Trong bài nêu rõ: "Spending just fifteen minutes every morning".',
        ),
        SkillQuestion(
          questionText: 'Điền danh từ trong bài có nghĩa "khả năng ghi nhớ": "long-term _______"',
          options: ['retention'],
          correctOptionIndex: 0,
          questionType: 'fill',
          acceptedAnswers: ['retention'],
          explanation: 'Cụm từ trong bài là "long-term retention" (khả năng ghi nhớ dài hạn).',
        ),
      ],
    ),
    const SkillExerciseModel(
      id: 'read_2',
      type: SkillType.reading,
      title: 'Trí tuệ nhân tạo và tương lai việc làm (AI and the Future of Work)',
      level: 'B1',
      topic: 'Công nghệ & Kỹ thuật số',
      content:
          'Artificial intelligence is rapidly reshaping the modern workplace. While automated algorithms efficiently '
          'handle repetitive calculations and data processing, human creativity, empathy, and critical thinking remain '
          'irreplaceable. Forward-thinking professionals are now learning how to collaborate with AI tools to enhance their '
          'daily productivity.',
      contentVi:
          'Trí tuệ nhân tạo đang nhanh chóng định hình lại nơi làm việc hiện đại. Trong khi các thuật toán tự động xử lý hiệu quả '
          'các phép tính lặp đi lặp lại và xử lý dữ liệu, thì sự sáng tạo, sự đồng cảm và tư duy phản biện của con người vẫn không thể '
          'thay thế được. Những chuyên gia có tầm nhìn xa hiện đang học cách cộng tác với các công cụ AI để nâng cao năng suất hằng ngày.',
      keyWords: [
        LessonKeyWord(
          term: 'algorithm',
          ipa: '/ˈæl.ɡə.rɪ.ðəm/',
          partOfSpeech: 'n',
          meaning: 'thuật toán',
          example: 'Automated algorithms handle repetitive calculations.',
        ),
        LessonKeyWord(
          term: 'irreplaceable',
          ipa: '/ˌɪr.ɪˈpleɪ.sə.bəl/',
          partOfSpeech: 'adj',
          meaning: 'không thể thay thế',
          example: 'Human creativity and empathy remain irreplaceable.',
        ),
        LessonKeyWord(
          term: 'collaborate',
          ipa: '/kəˈlæb.ə.reɪt/',
          partOfSpeech: 'v',
          meaning: 'cộng tác, phối hợp',
          example: 'Professionals learn how to collaborate with AI tools.',
        ),
      ],
      questions: [
        SkillQuestion(
          questionText: 'Yếu tố nào của con người được xem là không thể thay thế?',
          options: [
            'Khả năng tính toán nhanh',
            'Sự sáng tạo, đồng cảm và tư duy phản biện',
            'Sao chép dữ liệu',
            'Làm việc không cần nghỉ ngơi'
          ],
          correctOptionIndex: 1,
          explanation: 'Đoạn văn: "human creativity, empathy, and critical thinking remain irreplaceable."',
        ),
        SkillQuestion(
          questionText: 'Các chuyên gia có tầm nhìn đang làm gì với AI?',
          options: [
            'Tránh xa hoàn toàn',
            'Học cách cộng tác với AI để tăng năng suất',
            'Xóa bỏ mọi công cụ AI',
            'Chỉ sử dụng để chơi game'
          ],
          correctOptionIndex: 1,
          explanation: 'Đoạn văn: "learning how to collaborate with AI tools to enhance their daily productivity."',
        ),
      ],
    ),
    const SkillExerciseModel(
      id: 'read_3_b2',
      type: SkillType.reading,
      title: 'Du lịch bền vững và bảo tồn di sản (Sustainable Tourism)',
      level: 'B2',
      topic: 'Du lịch & Khám phá',
      content:
          'Mass tourism often places immense strain on fragile ecosystems and historic monuments. '
          'In response, sustainable tourism initiatives encourage travelers to respect local customs, patronize community-owned businesses, '
          'and reduce ecological footprints. By prioritizing quality experiences over visitor volume, destinations can preserve their cultural '
          'authenticity for future generations.',
      contentVi:
          'Du lịch đại trà thường đặt áp lực khổng lồ lên các hệ sinh thái mỏng manh và các di tích lịch sử. '
          'Để ứng phó, các sáng kiến du lịch bền vững khuyến khích du khách tôn trọng phong tục địa phương, ủng hộ doanh nghiệp cộng đồng '
          'và giảm dấu chân sinh thái. Bằng cách ưu tiên chất lượng trải nghiệm hơn số lượng khách, các điểm đến có thể bảo tồn bản sắc văn hóa '
          'cho các thế hệ tương lai.',
      keyWords: [
        LessonKeyWord(
          term: 'fragile',
          ipa: '/ˈfrædʒ.aɪl/',
          partOfSpeech: 'adj',
          meaning: 'mỏng manh, dễ tổn thương',
          example: 'Mass tourism places strain on fragile ecosystems.',
        ),
        LessonKeyWord(
          term: 'authenticity',
          ipa: '/ˌɔː.θenˈtɪs.ə.ti/',
          partOfSpeech: 'n',
          meaning: 'tính nguyên bản, bản sắc đích thực',
          example: 'Destinations can preserve their cultural authenticity.',
        ),
      ],
      questions: [
        SkillQuestion(
          questionText: 'Du lịch đại trà (Mass tourism) gây ra tác động gì?',
          options: [
            'Giúp hệ sinh thái tự phục hồi',
            'Gây áp lực lớn lên hệ sinh thái mỏng manh và di tích lịch sử',
            'Giảm lượng rác thải nhựa',
            'Xóa bỏ hoàn toàn chi phí bảo trì'
          ],
          correctOptionIndex: 1,
          explanation: 'Trong bài: "Mass tourism often places immense strain on fragile ecosystems and historic monuments."',
        ),
        SkillQuestion(
          questionText: 'Điền danh từ trong bài có nghĩa "bản sắc / tính nguyên bản": "preserve their cultural _______"',
          options: ['authenticity'],
          correctOptionIndex: 0,
          questionType: 'fill',
          acceptedAnswers: ['authenticity'],
          explanation: 'Từ trong bài là "authenticity" (tính xác thực, bản sắc văn hóa).',
        ),
      ],
    ),
    const SkillExerciseModel(
      id: 'read_4_c1',
      type: SkillType.reading,
      title: 'Kinh tế học hành vi trong quyết định tiêu dùng (Behavioral Economics)',
      level: 'C1',
      topic: 'Trường học & Học thuật',
      content:
          'Classical economic theory posits that consumers consistently make rational choices to maximize utility. '
          'However, empirical research in behavioral economics reveals that cognitive biases—such as loss aversion and anchoring—profoundly '
          'influence financial decisions. Understanding these psychological mechanisms enables policymakers to design subtle nudges that '
          'foster healthier long-term saving habits.',
      contentVi:
          'Lý thuyết kinh tế học cổ điển cho rằng người tiêu dùng luôn đưa ra các lựa chọn duy lý nhằm tối đa hóa lợi ích. '
          'Tuy nhiên, nghiên cứu thực nghiệm trong kinh tế học hành vi chỉ ra rằng các thiên kiến nhận thức — chẳng hạn như tâm lý sợ mất mát và hiệu ứng mỏ neo — '
          'ảnh hưởng sâu sắc đến quyết định tài chính. Hiểu rõ các cơ chế tâm lý này giúp các nhà hoạch định chính sách thiết kế những cú hích tinh tế '
          'nhằm thúc đẩy thói quen tiết kiệm dài hạn lành mạnh hơn.',
      keyWords: [
        LessonKeyWord(
          term: 'empirical',
          ipa: '/ɪmˈpɪr.ɪ.kəl/',
          partOfSpeech: 'adj',
          meaning: 'thực nghiệm (dựa trên quan sát, thí nghiệm)',
          example: 'Empirical research reveals that cognitive biases influence decisions.',
        ),
        LessonKeyWord(
          term: 'cognitive bias',
          ipa: '/ˈkɒɡ.nə.tɪv ˈbaɪ.əs/',
          partOfSpeech: 'n',
          meaning: 'thiên kiến nhận thức',
          example: 'Cognitive biases such as loss aversion influence decisions.',
        ),
      ],
      questions: [
        SkillQuestion(
          questionText: 'Nghiên cứu thực nghiệm trong kinh tế học hành vi bác bỏ giả định nào của kinh tế học cổ điển?',
          options: [
            'Người tiêu dùng luôn hành động hoàn toàn duy lý (rational)',
            'Tiền tệ có giá trị trao đổi',
            'Ngân hàng hỗ trợ gửi tiết kiệm',
            'Chính sách công có ảnh hưởng đến xã hội'
          ],
          correctOptionIndex: 0,
          explanation: 'Kinh tế học hành vi chứng minh các thiên kiến nhận thức (cognitive biases) chi phối quyết định thay vì con người luôn duy lý tuyệt đối.',
        ),
        SkillQuestion(
          questionText: 'Điền tính từ học thuật C1 mang nghĩa "thực nghiệm": "_______ research in behavioral economics"',
          options: ['empirical'],
          correctOptionIndex: 0,
          questionType: 'fill',
          acceptedAnswers: ['empirical'],
          explanation: '"Empirical" (/ɪmˈpɪr.ɪ.kəl/) nghĩa là dựa trên bằng chứng thực nghiệm.',
        ),
      ],
    ),
  ];

  static final List<SkillExerciseModel> writingExercises = [
    const SkillExerciseModel(
      id: 'wri_1',
      type: SkillType.writing,
      title: 'Luyện cấu trúc & Viết đoạn văn giao tiếp (Daily Communication)',
      level: 'A2',
      topic: 'Giao tiếp hằng ngày',
      content: 'Sắp xếp câu giao tiếp chuẩn ngữ pháp và luyện viết đoạn văn ngắn giới thiệu thói quen học tiếng Anh của bạn.',
      contentVi: 'Bài tập rèn luyện tư duy đặt câu và viết đoạn văn ngắn (40–60 từ) theo tiêu chí rõ ràng.',
      writingSentences: [
        WritingSentence(
          englishSentence: 'I really appreciate your kind support.',
          vietnameseMeaning: 'Tôi thực sự cảm kích sự hỗ trợ ân cần của bạn.',
          scrambledWords: ['appreciate', 'I', 'kind', 'support.', 'your', 'really'],
          hint: 'Bắt đầu bằng chủ ngữ "I"',
        ),
        WritingSentence(
          englishSentence: 'Do not hesitate to contact us.',
          vietnameseMeaning: 'Đừng ngần ngại liên hệ với chúng tôi.',
          scrambledWords: ['to', 'Do', 'not', 'contact', 'hesitate', 'us.'],
          hint: 'Bắt đầu bằng "Do not"',
        ),
        WritingSentence(
          englishSentence: 'She is very enthusiastic about learning English.',
          vietnameseMeaning: 'Cô ấy rất hào hứng với việc học tiếng Anh.',
          scrambledWords: ['about', 'She', 'is', 'very', 'English.', 'learning', 'enthusiastic'],
          hint: 'Cụm từ: enthusiastic about something',
        ),
      ],
      writingPromptTask: WritingPromptTask(
        promptTitle: 'Viết đoạn văn ngắn về thói quen học tiếng Anh mỗi ngày của bạn',
        promptDescription:
            'Hãy viết một đoạn văn khoảng 40–70 từ chia sẻ lý do bạn học tiếng Anh và cách bạn luyện tập hằng ngày (ví dụ: học từ vựng qua flashcard, nghe hội thoại, đọc bài ngắn).',
        minWords: 40,
        targetKeywords: ['vocabulary', 'practice', 'confidence', 'daily'],
        sampleAnswer:
            'Learning English is an important part of my daily routine. Every morning, I spend fifteen minutes reviewing new vocabulary with flashcards. In the evening, I practice listening to short conversations and repeating sentences aloud. Consistent practice helps me build genuine confidence when communicating with international friends.',
      ),
    ),
    const SkillExerciseModel(
      id: 'wri_2',
      type: SkillType.writing,
      title: 'Viết email công sở & Đàm phán (Business Email & Sentences)',
      level: 'B1',
      topic: 'Công sở & Sự nghiệp',
      content: 'Rèn luyện khả năng diễn đạt chuyên nghiệp và viết email phản hồi dự án trong môi trường làm việc.',
      contentVi: 'Luyện sắp xếp câu trang trọng và tự viết một email công việc hoàn chỉnh theo Rubric.',
      writingSentences: [
        WritingSentence(
          englishSentence: 'We managed to negotiate a better deal.',
          vietnameseMeaning: 'Chúng tôi đã thương lượng thành công một thỏa thuận tốt hơn.',
          scrambledWords: ['negotiate', 'We', 'deal.', 'a', 'managed', 'better', 'to'],
          hint: 'Cấu trúc: manage to do something',
        ),
        WritingSentence(
          englishSentence: 'Please submit the report before the deadline.',
          vietnameseMeaning: 'Vui lòng nộp báo cáo trước thời hạn chót.',
          scrambledWords: ['submit', 'Please', 'before', 'the', 'report', 'the', 'deadline.'],
          hint: 'Bắt đầu bằng lời mời lịch sự "Please"',
        ),
        WritingSentence(
          englishSentence: 'Could we reschedule our meeting to Wednesday morning?',
          vietnameseMeaning: 'Chúng ta có thể dời lịch họp sang sáng thứ Tư được không?',
          scrambledWords: ['reschedule', 'Could', 'we', 'our', 'meeting', 'to', 'Wednesday', 'morning?'],
          hint: 'Câu hỏi lịch sự bắt đầu bằng "Could we"',
        ),
      ],
      writingPromptTask: WritingPromptTask(
        promptTitle: 'Viết email cập nhật tiến độ dự án và đề xuất lịch họp',
        promptDescription:
            'Viết một email ngắn (50–90 từ) gửi đồng nghiệp để thông báo tiến độ báo cáo hiện tại, nêu 1 điểm cần thảo luận thêm và đề xuất lịch họp trước thời hạn (deadline).',
        minWords: 50,
        targetKeywords: ['schedule', 'report', 'deadline', 'collaborate'],
        sampleAnswer:
            'Dear Team, I am writing to update you on our quarterly project report. We have completed the data analysis section ahead of schedule. However, I would like to collaborate with the design team to finalize the presentation slides before the Friday deadline. Could we arrange a brief meeting tomorrow morning at 10 AM? Best regards.',
      ),
    ),
    const SkillExerciseModel(
      id: 'wri_3_b2',
      type: SkillType.writing,
      title: 'Nghị luận học thuật: Công nghệ & Giáo dục (Academic Paragraph)',
      level: 'B2',
      topic: 'Trường học & Học thuật',
      content: 'Rèn luyện cấu trúc câu phức học thuật và viết đoạn văn nghị luận (Essay Body Paragraph) chuẩn B2–C1.',
      contentVi: 'Phát triển lập luận chặt chẽ với từ nối học thuật (Furthermore, Consequently, Nevertheless).',
      writingSentences: [
        WritingSentence(
          englishSentence: 'Sustainable development requires global cooperation and strict policies.',
          vietnameseMeaning: 'Phát triển bền vững đòi hỏi sự hợp tác toàn cầu và các chính sách nghiêm ngặt.',
          scrambledWords: ['Sustainable', 'development', 'requires', 'global', 'cooperation', 'and', 'strict', 'policies.'],
          hint: 'Chủ ngữ là cụm danh từ "Sustainable development"',
        ),
        WritingSentence(
          englishSentence: 'Interactive applications enable students to learn at their own pace.',
          vietnameseMeaning: 'Các ứng dụng tương tác giúp học sinh học tập theo tốc độ của riêng mình.',
          scrambledWords: ['Interactive', 'applications', 'enable', 'students', 'to', 'learn', 'at', 'their', 'own', 'pace.'],
          hint: 'Cấu trúc: enable somebody to do something',
        ),
      ],
      writingPromptTask: WritingPromptTask(
        promptTitle: 'Viết đoạn văn nghị luận: Lợi ích của công nghệ trong việc tự học ngoại ngữ',
        promptDescription:
            'Hãy viết một đoạn văn học thuật (70–120 từ) phân tích cách các ứng dụng học tập kỹ thuật số hỗ trợ người học cá nhân hóa lộ trình, đồng thời nêu vai trò của sự kỷ luật bản thân.',
        minWords: 70,
        targetKeywords: ['technology', 'personalized', 'sustainable', 'dedication'],
        sampleAnswer:
            'Modern educational technology has fundamentally transformed how individuals acquire a second language. Digital platforms provide personalized learning pathways and spaced repetition systems that adapt to each learner’s pace. Furthermore, instant access to authentic audio and interactive dictionaries fosters independent study. Nevertheless, technology alone cannot guarantee fluency; sustainable progress ultimately depends on consistent daily dedication and active practice.',
      ),
    ),
  ];

  static final List<SkillExerciseModel> speakingExercises = [
    const SkillExerciseModel(
      id: 'spk_1',
      type: SkillType.speaking,
      title: 'Luyện phát âm & Ngữ điệu giao tiếp (Pronunciation & Intonation)',
      level: 'A2',
      topic: 'Giao tiếp hằng ngày',
      content:
          'Lắng nghe câu phát âm mẫu (tốc độ thường hoặc chậm), chú ý trọng âm và nối âm, sau đó thực hành nói to và tự đánh giá theo bảng kiểm (Rubric).',
      contentVi: 'Phương pháp Shadowing giúp cải thiện ngữ điệu, độ trôi chảy và sự tự tin khi giao tiếp.',
      writingSentences: [
        WritingSentence(
          englishSentence: 'Could you please repeat that more slowly?',
          vietnameseMeaning: 'Bạn có thể vui lòng lặp lại chậm hơn một chút được không?',
          scrambledWords: [],
          hint: 'Trọng âm câu rơi vào: REPEAT và SLOWLY. Nối âm "Could you" thành /kʊdʒuː/.',
        ),
        WritingSentence(
          englishSentence: 'It is a pleasure to meet you today.',
          vietnameseMeaning: 'Rất hân hạnh được gặp bạn ngày hôm nay.',
          scrambledWords: [],
          hint: 'Từ "pleasure" phát âm là /ˈpleʒ.ər/, ngữ điệu đi xuống nhẹ ở cuối câu trần thuật.',
        ),
        WritingSentence(
          englishSentence: 'I am looking forward to working with you.',
          vietnameseMeaning: 'Tôi rất mong đợi được làm việc cùng bạn.',
          scrambledWords: [],
          hint: 'Cụm "looking forward to" đọc liền mạch, chú ý âm cuối /d/ nhẹ.',
        ),
      ],
    ),
    const SkillExerciseModel(
      id: 'spk_2_b1',
      type: SkillType.speaking,
      title: 'Thuyết trình & Thảo luận công việc (Workplace Presentation)',
      level: 'B1',
      topic: 'Công sở & Sự nghiệp',
      content:
          'Luyện nói các câu mở đầu thuyết trình, nêu quan điểm và chuyển ý mạch lạc trong cuộc họp bằng tiếng Anh.',
      contentVi: 'Tập trung vào cách ngắt nghỉ (chunking) và nhấn trọng âm vào các từ khóa mang thông tin chính.',
      writingSentences: [
        WritingSentence(
          englishSentence: 'Let me walk you through the main milestones of our project.',
          vietnameseMeaning: 'Hãy để tôi điểm qua các cột mốc chính trong dự án của chúng ta.',
          scrambledWords: [],
          hint: 'Nối âm "walk you" (/wɔːkjuː/), nhấn rõ cụm "MAIN MILESTONES".',
        ),
        WritingSentence(
          englishSentence: 'From my perspective, prioritizing user experience is essential.',
          vietnameseMeaning: 'Theo góc nhìn của tôi, việc ưu tiên trải nghiệm người dùng là điều thiết yếu.',
          scrambledWords: [],
          hint: 'Ngắt nhịp nhẹ sau "From my perspective,", nhấn trọng âm từ "esSENtial" (/ɪˈsen.ʃəl/).',
        ),
        WritingSentence(
          englishSentence: 'That is a valid point, and we will take it into consideration.',
          vietnameseMeaning: 'Đó là một ý kiến xác đáng, và chúng tôi sẽ cân nhắc kỹ điều này.',
          scrambledWords: [],
          hint: 'Nối âm "take it into" (/teɪkɪt ˈɪntə/), phát âm rõ danh từ "consideRAtion".',
        ),
      ],
    ),
    const SkillExerciseModel(
      id: 'spk_3_b2',
      type: SkillType.speaking,
      title: 'Phản biện học thuật IELTS Speaking Part 3 (Academic Discussion)',
      level: 'B2',
      topic: 'Trường học & Học thuật',
      content:
          'Luyện trả lời câu hỏi thảo luận sâu với cấu trúc mở rộng ý (Point – Explanation – Example) và ngữ điệu tự nhiên.',
      contentVi: 'Giúp bạn tránh trả lời cụt lủn và làm chủ tốc độ nói ổn định trong phòng thi vấn đáp.',
      writingSentences: [
        WritingSentence(
          englishSentence: 'There is compelling evidence that bilingual education enhances cognitive flexibility.',
          vietnameseMeaning: 'Có bằng chứng thuyết phục cho thấy giáo dục song ngữ giúp tăng cường sự linh hoạt nhận thức.',
          scrambledWords: [],
          hint: 'Nhấn trọng âm chính xác: comPELLing (/kəmˈpel.ɪŋ/), COGniTive (/ˈkɒɡ.nə.tɪv/).',
        ),
        WritingSentence(
          englishSentence: 'While digital tools offer convenience, face-to-face interaction remains vital.',
          vietnameseMeaning: 'Mặc dù công cụ số mang lại sự tiện lợi, tương tác trực tiếp vẫn giữ vai trò sống còn.',
          scrambledWords: [],
          hint: 'Lên giọng nhẹ ở cuối mệnh đề "convenience," để báo hiệu sự tương phản ở vế sau.',
        ),
      ],
    ),
  ];
}

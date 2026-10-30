import '../../data/models/shadowing_model.dart';

class ShadowingSeedData {
  ShadowingSeedData._();

  static const List<ShadowingLessonModel> lessons = [
    ShadowingLessonModel(
      id: 'shad_a1_daily',
      title: 'Chào hỏi & Bắt chuyện tự nhiên (Small Talk Basics)',
      topic: 'Giao tiếp hằng ngày',
      level: 'A1',
      description:
          'Làm quen với nhịp điệu câu ngắn, cách nối âm cơ bản và ngữ điệu thân thiện khi gặp gỡ bạn mới.',
      segments: [
        ShadowingSegment(
          id: 'shad_a1_s1',
          englishText: 'Good morning! It is a lovely day, isn’t it?',
          phoneticStress: 'Good MORning! ↘ | It’s a LOVEly DAY, ↘ | ISn’t_it? ↗',
          vietnameseMeaning: 'Chào buổi sáng! Hôm nay là một ngày tuyệt đẹp, phải không?',
          coachingTip:
              'Nối âm cuối /t/ của "isn’t" sang "it" (/ˈɪz.ənt_ɪt/). Lên giọng nhẹ ở câu hỏi đuôi "isn’t it? ↗" để mời người nghe hưởng ứng.',
          targetDurationSeconds: 5,
        ),
        ShadowingSegment(
          id: 'shad_a1_s2',
          englishText: 'I usually grab a cup of coffee before heading to class.',
          phoneticStress: 'I Usually GRAB_a cup_of COFfee ↗ | before HEADing to CLASS. ↘',
          vietnameseMeaning: 'Tôi thường mua một tách cà phê trước khi đến lớp.',
          coachingTip:
              'Giảm âm "of" thành /əv/ ("cup_of" đọc liền như "cuppa"). Hạ giọng dứt khoát ở từ cuối "CLASS ↘".',
          targetDurationSeconds: 6,
        ),
        ShadowingSegment(
          id: 'shad_a1_s3',
          englishText: 'Let me know if you need any help with your schedule.',
          phoneticStress: 'LET me KNOW ↗ | if you NEED any HELP ↗ | with your SCHEdule. ↘',
          vietnameseMeaning: 'Hãy cho tôi biết nếu bạn cần bất kỳ sự giúp đỡ nào với lịch trình nhé.',
          coachingTip:
              'Từ "schedule" có thể đọc là /ˈʃed.juːl/ (Anh-Anh) hoặc /ˈskedʒ.uːl/ (Anh-Mỹ). Nhấn rõ động từ "NEED" và danh từ "HELP".',
          targetDurationSeconds: 6,
        ),
      ],
    ),
    ShadowingLessonModel(
      id: 'shad_a2_travel',
      title: 'Hỏi đường & Làm thủ tục tại sân bay (Airport & Transit)',
      topic: 'Du lịch & Khám phá',
      level: 'A2',
      description:
          'Rèn ngữ điệu lịch sự khi đặt câu hỏi nơi công cộng và nhấn rõ số hiệu, thời gian tại sân bay.',
      segments: [
        ShadowingSegment(
          id: 'shad_a2_s1',
          englishText: 'Excuse me, could you tell me where the boarding gate is?',
          phoneticStress: 'ExCUSE me, ↗ | could_you TELL me ↗ | where the BOARding GATE is? ↘',
          vietnameseMeaning: 'Xin lỗi, bạn có thể chỉ giúp tôi cổng lên máy bay ở đâu không?',
          coachingTip:
              'Nối âm "could you" thành /kʊdʒuː/. Đây là câu hỏi gián tiếp bắt đầu bằng "Could you tell me where..." nên cuối câu hạ giọng nhẹ ↘.',
          targetDurationSeconds: 6,
        ),
        ShadowingSegment(
          id: 'shad_a2_s2',
          englishText: 'I would like an aisle seat near the front of the cabin.',
          phoneticStress: 'I’d LIKE_an AISLE seat ↗ | near the FRONT_of the CAbin. ↘',
          vietnameseMeaning: 'Tôi muốn một ghế cạnh lối đi ở gần phía đầu khoang máy bay.',
          coachingTip:
              'Chú ý từ "aisle" phát âm là /aɪl/ (âm "s" câm hoàn toàn). Nối âm "like an aisle" thành /laɪk_ən_aɪl/.',
          targetDurationSeconds: 6,
        ),
        ShadowingSegment(
          id: 'shad_a2_s3',
          englishText: 'How long does it take to reach downtown by express train?',
          phoneticStress: 'HOW LONG does_it TAKE ↗ | to reach DOWNtown by exPRESS TRAIN? ↘',
          vietnameseMeaning: 'Đi tàu tốc hành vào trung tâm thành phố mất bao lâu?',
          coachingTip:
              'Nối âm "does it" (/dʌz_ɪt/). Nhấn trọng âm vào cụm từ để hỏi "HOW LONG" và danh từ ghép "exPRESS TRAIN".',
          targetDurationSeconds: 6,
        ),
      ],
    ),
    ShadowingLessonModel(
      id: 'shad_b1_workplace',
      title: 'Báo cáo tiến độ & Đóng góp ý kiến trong cuộc họp (Stand-up Meeting)',
      topic: 'Công sở & Sự nghiệp',
      level: 'B1',
      description:
          'Luyện cách ngắt cụm tư duy (Thought Groups / Chunking) để trình bày công việc rõ ràng, tự tin.',
      segments: [
        ShadowingSegment(
          id: 'shad_b1_s1',
          englishText: 'We have resolved the database migration issue ahead of schedule.',
          phoneticStress: 'We’ve reSOLVED the DAtabase miGRAtion issue ↗ | aHEAD_of SCHEdule. ↘',
          vietnameseMeaning: 'Chúng tôi đã xử lý xong sự cố nâng cấp cơ sở dữ liệu sớm hơn tiến độ.',
          coachingTip:
              'Ngắt nhịp nhẹ sau từ "issue". Nối âm "ahead of" (/əˈhed_əv/) và bật rõ âm cuối /d/ trong "reSOLVED".',
          targetDurationSeconds: 7,
        ),
        ShadowingSegment(
          id: 'shad_b1_s2',
          englishText: 'Our next priority is optimizing the user interface for mobile devices.',
          phoneticStress: 'Our NEXT priOrity ↗ | is OPtimizing the User INterface ↗ | for MObile deVIces. ↘',
          vietnameseMeaning: 'Ưu tiên tiếp theo của chúng ta là tối ưu hóa giao diện người dùng cho thiết bị di động.',
          coachingTip:
              'Từ "priority" nhấn âm tiết thứ hai (/praɪˈɒr.ə.ti/). Chia câu thành 3 cụm hơi ngắn để không bị hụt hơi.',
          targetDurationSeconds: 7,
        ),
        ShadowingSegment(
          id: 'shad_b1_s3',
          englishText: 'I completely agree with your proposal, and I am happy to support it.',
          phoneticStress: 'I comPLETEly aGREE with your proPOsal, ↗ | and I’m HAPpy to supPORT_it. ↘',
          vietnameseMeaning: 'Tôi hoàn toàn đồng ý với đề xuất của bạn và rất sẵn lòng hỗ trợ.',
          coachingTip:
              'Từ "proposal" phát âm là /prəˈpəʊ.zəl/ (âm đầu là schwa /ə/, không đọc là /prəʊ/). Nối âm cuối "support it" (/səˈpɔːt_ɪt/).',
          targetDurationSeconds: 7,
        ),
      ],
    ),
    ShadowingLessonModel(
      id: 'shad_b2_academic',
      title: 'Thuyết trình học thuật & Phân tích xu hướng (Academic Presentation)',
      topic: 'Trường học & Học thuật',
      level: 'B2',
      description:
          'Làm chủ ngữ điệu tương phản (Contrastive Stress) khi nêu hai luồng quan điểm trong bài nói học thuật.',
      segments: [
        ShadowingSegment(
          id: 'shad_b2_s1',
          englishText: 'On the one hand, automation boosts efficiency; on the other hand, it requires workforce retraining.',
          phoneticStress: 'On the ONE hand, ↗ autoMAtion boosts efFIciency; ↘ | on the OTHer hand, ↗ it reQUIRES WORKforce reTRAIning. ↘',
          vietnameseMeaning: 'Một mặt, tự động hóa thúc đẩy hiệu suất; mặt khác, nó đòi hỏi việc đào tạo lại lực lượng lao động.',
          coachingTip:
              'Nhấn mạnh sự đối lập giữa "ONE hand" và "OTHer hand". Lên giọng nhẹ sau mệnh đề phụ để giữ sự chú ý của người nghe.',
          targetDurationSeconds: 9,
        ),
        ShadowingSegment(
          id: 'shad_b2_s2',
          englishText: 'Consistent spaced repetition is proven to strengthen long-term memory retention.',
          phoneticStress: 'ConSIStent SPACED repeTItion ↗ | is PROven to STRENGthen ↗ | LONG-term MEmory reTENtion. ↘',
          vietnameseMeaning: 'Việc lặp lại ngắt quãng đều đặn đã được chứng minh giúp củng cố khả năng ghi nhớ dài hạn.',
          coachingTip:
              'Chú ý cụm phụ âm trong "STRENGthen" (/ˈstreŋ.θən/). Đọc rõ nhịp 3 cụm danh từ ở cuối câu.',
          targetDurationSeconds: 8,
        ),
      ],
    ),
    ShadowingLessonModel(
      id: 'shad_c1_leadership',
      title: 'Diễn thuyết chiến lược & Tư duy phản biện (Executive Keynote)',
      topic: 'Công nghệ & Kỹ thuật số',
      level: 'C1',
      description:
          'Luyện kỹ thuật ngắt nghỉ có chủ đích (Strategic Pausing) và nhấn từ đa âm tiết trình độ C1.',
      segments: [
        ShadowingSegment(
          id: 'shad_c1_s1',
          englishText: 'Sustainable innovation demands not only technological breakthroughs, but also ethical governance.',
          phoneticStress: 'SusTAInable innoVAtion deMANDS ↗ | NOT ONly technoLOgical BREAKthroughs, ↗ | but_ALso ETHical GOvernance. ↘',
          vietnameseMeaning: 'Đổi mới bền vững đòi hỏi không chỉ những đột phá công nghệ mà còn cả sự quản trị có đạo đức.',
          coachingTip:
              'Nghỉ 0.3 giây sau "BREAKthroughs," trước khi hạ giọng trầm và chắc ở cụm "ETHical GOvernance ↘" để tạo sức nặng cho thông điệp.',
          targetDurationSeconds: 9,
        ),
        ShadowingSegment(
          id: 'shad_c1_s2',
          englishText: 'By cultivating cross-cultural empathy, global teams can transform diversity into a decisive advantage.',
          phoneticStress: 'By CULtivating CROSS-cultural EMpathy, ↗ | GLObal teams can transFORM diVERsity ↗ | into_a deCIsive adVANtage. ↘',
          vietnameseMeaning: 'Bằng cách nuôi dưỡng sự thấu cảm đa văn hóa, các đội ngũ toàn cầu có thể biến sự đa dạng thành lợi thế quyết định.',
          coachingTip:
              'Chú ý động từ "transFORM" nhấn âm 2 (/trænsˈfɔːm/), danh từ "diVERsity" (/daɪˈvɜː.sə.ti/) và tính từ "deCIsive" (/dɪˈsaɪ.sɪv/).',
          targetDurationSeconds: 9,
        ),
      ],
    ),
  ];
}

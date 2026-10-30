import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../data/models/online_dictionary_result.dart';
import '../database/database_helper.dart';

enum DictionarySearchStatus {
  success,
  notFound,
  networkError,
}

class DictionarySearchResult {
  final OnlineDictionaryResult? result;
  final DictionarySearchStatus status;
  final String? errorMessage;
  final bool isFromCache;

  const DictionarySearchResult({
    this.result,
    required this.status,
    this.errorMessage,
    this.isFromCache = false,
  });

  bool get isSuccess =>
      status == DictionarySearchStatus.success && result != null;
  bool get isNotFound => status == DictionarySearchStatus.notFound;
  bool get isNetworkError => status == DictionarySearchStatus.networkError;
}

class DictionaryApiService {
  static final DictionaryApiService _instance =
      DictionaryApiService._internal();
  factory DictionaryApiService() => _instance;
  DictionaryApiService._internal();

  /// Regex nhận diện ký tự tiếng Việt có dấu
  static final RegExp _vietnameseDiacriticsRegex = RegExp(
    r'[àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴĐ]',
  );

  /// Tập hợp từ tiếng Việt không dấu thông dụng để nhận diện khi người dùng gõ không dấu
  static const Set<String> _unaccentedVietnameseTokens = {
    'can',
    'ho',
    'nha',
    'hoc',
    'truong',
    'ban',
    'ngay',
    'lam',
    'viec',
    'yeu',
    'thich',
    'nguoi',
    'xe',
    'may',
    'mua',
    'toi',
    'anh',
    'chi',
    'em',
    'con',
    'me',
    'cha',
    'ba',
    'ong',
    'chu',
    'bac',
    'co',
    'sach',
    'but',
    'tien',
    'an',
    'uong',
    've',
    'dau',
    'sao',
    'the',
    'gi',
    'nao',
    'nay',
    'do',
    'kia',
    'khong',
    'duoc',
    'di',
    'den',
  };

  /// Kiểm tra xem truy vấn là tiếng Việt (trả về true) hay tiếng Anh (trả về false)
  static bool isVietnameseQuery(String text) {
    final clean = text.trim().toLowerCase();
    if (clean.isEmpty) return false;

    // 1. Kiểm tra ký tự có dấu tiếng Việt
    if (_vietnameseDiacriticsRegex.hasMatch(clean)) {
      return true;
    }

    // 2. Tách từ kiểm tra các từ đơn/cụm từ tiếng Việt không dấu thông dụng
    final tokens = clean.split(RegExp(r'[\s\-_,.]+'));
    int viMatchCount = 0;
    for (final token in tokens) {
      if (_unaccentedVietnameseTokens.contains(token)) {
        viMatchCount++;
      }
    }
    // Nếu có ít nhất 1 token thuần Việt hoặc tỉ lệ token Việt cao
    if (tokens.length >= 2 && viMatchCount >= 1) {
      return true;
    }
    if (tokens.length == 1 &&
        viMatchCount == 1 &&
        (clean == 'nha' ||
            clean == 'hoc' ||
            clean == 'nguoi' ||
            clean == 'thich' ||
            clean == 'yeu' ||
            clean == 'uong' ||
            clean == 'khong')) {
      return true;
    }

    return false;
  }

  /// Wiktionary REST API chính thức hỗ trợ CORS Access-Control-Allow-Origin: * chuẩn Web
  static const String _wiktionaryBaseUrl =
      'https://en.wiktionary.org/api/rest_v1/page/definition';

  /// Free Dictionary API (dữ liệu Wiktionary CC BY-SA 3.0)
  static const String _freeDictBaseUrl =
      'https://api.dictionaryapi.dev/api/v2/entries/en';

  /// Tra cứu trực tuyến hai chiều Việt–Anh và Anh–Việt với bộ nhớ đệm SQLite
  Future<DictionarySearchResult> searchOnlineDetailed(
    String word, {
    DatabaseHelper? dbHelper,
  }) async {
    final cleanWord = word.trim();
    if (cleanWord.isEmpty) {
      return const DictionarySearchResult(
        status: DictionarySearchStatus.notFound,
        errorMessage: 'Vui lòng nhập từ hoặc cụm từ cần tra cứu.',
      );
    }

    final db = dbHelper ?? DatabaseHelper.instance;
    final cacheKey = cleanWord.toLowerCase();

    // 1. Kiểm tra bộ nhớ đệm SQLite trước để đạt tốc độ cao nhất và chạy offline
    try {
      final cachedRow = await db.getCachedDictionaryResult(cacheKey);
      if (cachedRow != null) {
        final payloadJson = cachedRow['payload_json'] as String? ?? '';
        if (payloadJson.isNotEmpty) {
          final decoded = jsonDecode(payloadJson) as Map<String, dynamic>;
          final cachedResult = OnlineDictionaryResult.fromCacheMap(
            decoded,
            isFromCache: true,
          );
          return DictionarySearchResult(
            result: cachedResult,
            status: DictionarySearchStatus.success,
            isFromCache: true,
          );
        }
      }
    } catch (e) {
      debugPrint('Dictionary cache read warning: $e');
    }

    final isVi = isVietnameseQuery(cleanWord);
    final sl = isVi ? 'vi' : 'en';
    final tl = isVi ? 'en' : 'vi';

    bool sawNetworkIssue = false;

    // 2. Nguồn 1: Google Translate GTX API (Hỗ trợ CORS trên Web, không cần API Key, chuẩn xác hai chiều)
    try {
      final gtxUri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sl&tl=$tl&dt=t&dt=bd&dt=rm&dt=at&q=${Uri.encodeComponent(cleanWord)}',
      );

      final response = await http.get(
        gtxUri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          final translatedBuf = StringBuffer();
          if (decoded[0] is List) {
            for (final seg in decoded[0]) {
              if (seg is List && seg.isNotEmpty && seg[0] != null) {
                translatedBuf.write(seg[0].toString());
              }
            }
          }

          final translatedText = translatedBuf.toString().trim();
          if (translatedText.isNotEmpty) {
            // Xác định từ tiếng Anh mục tiêu để tra cứu thêm định nghĩa tiếng Anh & IPA
            final englishWord =
                isVi ? translatedText.toLowerCase() : cleanWord.toLowerCase();

            // Lấy định nghĩa tiếng Anh và phiên âm nếu có thể
            final extraData = await _fetchEnglishDetails(englishWord);

            final result = OnlineDictionaryResult.fromTranslationJson(
              query: cleanWord,
              translatedText: translatedText,
              sourceLang: sl,
              targetLang: tl,
              gtxData: decoded,
              phonetic: extraData.phonetic,
              extraDefinitions: extraData.definitions,
              isFromCache: false,
            );

            await _saveToCacheSafe(db, cacheKey, result);
            return DictionarySearchResult(
              result: result,
              status: DictionarySearchStatus.success,
            );
          }
        }
      } else {
        sawNetworkIssue = true;
      }
    } on TimeoutException {
      sawNetworkIssue = true;
      debugPrint('Google GTX API timeout for: $cleanWord');
    } on SocketException {
      sawNetworkIssue = true;
      debugPrint('Google GTX API socket error for: $cleanWord');
    } catch (e) {
      sawNetworkIssue = true;
      debugPrint('Google GTX API error ($cleanWord): $e');
    }

    // 3. Nguồn 2 dự phòng: MyMemory Translation API (Hỗ trợ CORS chuẩn Web, dịch câu và từ hai chiều)
    try {
      final myMemoryUri = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(cleanWord)}&langpair=$sl|$tl',
      );
      final mmResponse = await http.get(
        myMemoryUri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 6));

      if (mmResponse.statusCode == 200) {
        final mmData = jsonDecode(mmResponse.body) as Map<String, dynamic>;
        final responseData = mmData['responseData'] as Map<String, dynamic>?;
        final translatedText =
            (responseData?['translatedText'] as String? ?? '').trim();

        if (translatedText.isNotEmpty &&
            !translatedText.toLowerCase().contains('mymemory') &&
            translatedText.toLowerCase() != cleanWord.toLowerCase()) {
          final englishWord =
              isVi ? translatedText.toLowerCase() : cleanWord.toLowerCase();
          final extraData = await _fetchEnglishDetails(englishWord);

          final result = OnlineDictionaryResult(
            word: isVi ? translatedText : cleanWord,
            originalQuery: cleanWord,
            phonetic: extraData.phonetic,
            definitions: [
              OnlineDefinition(
                partOfSpeech: isVi ? 'English Equivalent' : 'Vietnamese Meaning',
                definition: isVi ? translatedText : cleanWord,
              ),
              ...extraData.definitions,
            ],
            sourceName: 'MyMemory Translation / Wiktionary',
            sourceUrl:
                'https://mymemory.translated.net/en/$sl/$tl/${Uri.encodeComponent(cleanWord)}',
            license: 'Public Educational Data',
            isFromCache: false,
            vietnameseTranslation: isVi ? cleanWord : translatedText,
            queryDirection: isVi ? 'vi_en' : 'en_vi',
            alternativeTranslations: [translatedText],
          );

          await _saveToCacheSafe(db, cacheKey, result);
          return DictionarySearchResult(
            result: result,
            status: DictionarySearchStatus.success,
          );
        }
      }
    } catch (mmErr) {
      debugPrint('MyMemory fallback error: $mmErr');
    }

    // 4. Nguồn 3 dự phòng: Wikimedia Wiktionary REST API trực tiếp (khi tra cứu từ tiếng Anh)
    if (!isVi) {
      try {
        final wiktionaryUri =
            Uri.parse('$_wiktionaryBaseUrl/${Uri.encodeComponent(cleanWord)}');
        final response = await http.get(
          wiktionaryUri,
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'EnglishBuddyApp/1.0 (edu; support@englishbuddy.app)',
          },
        ).timeout(const Duration(seconds: 6));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final result = OnlineDictionaryResult.fromWiktionaryJson(
            cleanWord,
            data,
            isFromCache: false,
          );

          if (result.definitions.isNotEmpty) {
            await _saveToCacheSafe(db, cacheKey, result);
            return DictionarySearchResult(
              result: result,
              status: DictionarySearchStatus.success,
            );
          }
        } else if (response.statusCode == 404) {
          return DictionarySearchResult(
            status: DictionarySearchStatus.notFound,
            errorMessage:
                'Không tìm thấy từ "$cleanWord" trên các hệ thống từ điển trực tuyến.',
          );
        } else {
          sawNetworkIssue = true;
        }
      } catch (e) {
        sawNetworkIssue = true;
        debugPrint('Wiktionary REST API error ($cleanWord): $e');
      }
    }

    // 5. Nếu gặp sự cố mạng hoặc lỗi kết nối
    if (sawNetworkIssue) {
      return const DictionarySearchResult(
        status: DictionarySearchStatus.networkError,
        errorMessage:
            'Lỗi kết nối từ điển trực tuyến (mất mạng hoặc dịch vụ bận). Vui lòng kiểm tra lại đường truyền và bấm "Thử lại".',
      );
    }

    return DictionarySearchResult(
      status: DictionarySearchStatus.notFound,
      errorMessage:
          'Không tìm thấy kết quả tra cứu cho "$cleanWord". Vui lòng kiểm tra lại chính tả hoặc thử cụm từ khác.',
    );
  }

  /// Lấy chi tiết định nghĩa tiếng Anh & phiên âm IPA từ Wiktionary / Free Dictionary API
  Future<({String? phonetic, List<OnlineDefinition> definitions})>
      _fetchEnglishDetails(String englishWord) async {
    final clean = englishWord.trim().toLowerCase();
    String? phonetic;
    final List<OnlineDefinition> defs = [];

    // Thử Wiktionary REST API trước vì có CORS Access-Control-Allow-Origin: * chuẩn Web
    try {
      final uri = Uri.parse('$_wiktionaryBaseUrl/${Uri.encodeComponent(clean)}');
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'EnglishBuddyApp/1.0 (edu; support@englishbuddy.app)',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final wiktionaryResult = OnlineDictionaryResult.fromWiktionaryJson(
          clean,
          data,
          isFromCache: false,
        );
        defs.addAll(wiktionaryResult.definitions);
      }
    } catch (_) {}

    // Thử Free Dictionary API để lấy thêm phiên âm IPA nếu chưa có
    try {
      final freeUri =
          Uri.parse('$_freeDictBaseUrl/${Uri.encodeComponent(clean)}');
      final response = await http.get(
        freeUri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          final first = decoded.first as Map<String, dynamic>;
          final parsed = OnlineDictionaryResult.fromJson(first);
          if (parsed.phonetic != null && parsed.phonetic!.isNotEmpty) {
            phonetic = parsed.phonetic;
          }
          if (defs.isEmpty) {
            defs.addAll(parsed.definitions);
          }
        }
      }
    } catch (_) {}

    return (phonetic: phonetic, definitions: defs);
  }

  /// Tra cứu trực tuyến đơn giản (giữ tương thích ngược với code hiện hữu)
  Future<OnlineDictionaryResult?> searchOnline(
    String word, {
    DatabaseHelper? dbHelper,
  }) async {
    final response = await searchOnlineDetailed(word, dbHelper: dbHelper);
    return response.result;
  }

  Future<void> _saveToCacheSafe(
    DatabaseHelper db,
    String cacheKey,
    OnlineDictionaryResult result,
  ) async {
    try {
      await db.saveDictionaryCache(
        word: cacheKey,
        payloadJson: jsonEncode(result.toCacheMap()),
        sourceName: result.sourceName,
        sourceUrl: result.sourceUrl,
        license: result.license,
      );
    } catch (cacheErr) {
      debugPrint('Dictionary cache write warning: $cacheErr');
    }
  }
}

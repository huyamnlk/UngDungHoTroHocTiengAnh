// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

class PickedAvatarResult {
  final String? dataUri;
  final String? fileName;
  final int? byteSize;
  final String? errorMessage;
  final bool isCancelled;

  const PickedAvatarResult({
    this.dataUri,
    this.fileName,
    this.byteSize,
    this.errorMessage,
    this.isCancelled = false,
  });

  bool get isSuccess =>
      !isCancelled &&
      errorMessage == null &&
      dataUri != null &&
      dataUri!.isNotEmpty;
}

Future<PickedAvatarResult> pickAvatarImageFromDevice() async {
  final completer = Completer<PickedAvatarResult>();
  final input = html.FileUploadInputElement()
    ..accept = 'image/png,image/jpeg,image/webp,image/gif';

  input.onChange.listen((_) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      if (!completer.isCompleted) {
        completer.complete(const PickedAvatarResult(isCancelled: true));
      }
      return;
    }

    final file = files.first;
    const maxBytes = 2 * 1024 * 1024; // 2MB
    if (file.size > maxBytes) {
      if (!completer.isCompleted) {
        completer.complete(
          const PickedAvatarResult(
            errorMessage:
                'Kích thước ảnh vượt quá giới hạn 2MB. Vui lòng chọn ảnh nhẹ hơn.',
          ),
        );
      }
      return;
    }

    final reader = html.FileReader();
    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result is String && result.startsWith('data:image/')) {
        if (!completer.isCompleted) {
          completer.complete(
            PickedAvatarResult(
              dataUri: result,
              fileName: file.name,
              byteSize: file.size,
            ),
          );
        }
      } else {
        if (!completer.isCompleted) {
          completer.complete(
            const PickedAvatarResult(
              errorMessage:
                  'Tệp đã chọn không phải là định dạng hình ảnh hợp lệ (PNG, JPG, WEBP, GIF).',
            ),
          );
        }
      }
    });
    reader.onError.listen((_) {
      if (!completer.isCompleted) {
        completer.complete(
          const PickedAvatarResult(
            errorMessage: 'Không thể đọc tệp hình ảnh đã chọn.',
          ),
        );
      }
    });
    reader.readAsDataUrl(file);
  });

  input.click();
  return completer.future;
}

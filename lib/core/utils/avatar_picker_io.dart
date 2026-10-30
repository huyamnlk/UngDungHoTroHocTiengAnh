import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

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

/// Mở hộp thoại chọn file ảnh trên Windows/Desktop và chuyển thành Data URI để xem trước & lưu trữ
Future<PickedAvatarResult> pickAvatarImageFromDevice({
  String? directFilePath,
}) async {
  try {
    String? selectedPath = directFilePath?.trim();

    if ((selectedPath == null || selectedPath.isEmpty) && Platform.isWindows) {
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        r'''
Add-Type -AssemblyName System.Windows.Forms;
$dialog = New-Object System.Windows.Forms.OpenFileDialog;
$dialog.Title = 'Chon anh dai dien (PNG, JPG, WEBP, GIF)';
$dialog.Filter = 'Image Files (*.png;*.jpg;*.jpeg;*.webp;*.gif)|*.png;*.jpg;*.jpeg;*.webp;*.gif';
if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
  Write-Output $dialog.FileName;
}
''',
      ]);
      selectedPath = (result.stdout as String?)?.trim();
      if (selectedPath == null || selectedPath.isEmpty) {
        return const PickedAvatarResult(isCancelled: true);
      }
    }

    if (selectedPath == null || selectedPath.isEmpty) {
      return const PickedAvatarResult(
        errorMessage:
            'Vui lòng nhập đường dẫn tệp ảnh trên thiết bị hoặc chọn từ bộ Avatar tích hợp.',
      );
    }

    final file = File(selectedPath);
    if (!await file.exists()) {
      return const PickedAvatarResult(
        errorMessage: 'Không tìm thấy tệp hình ảnh tại đường dẫn đã chọn.',
      );
    }

    final bytes = await file.readAsBytes();
    const maxBytes = 2 * 1024 * 1024; // 2MB
    if (bytes.isEmpty) {
      return const PickedAvatarResult(
        errorMessage: 'Tệp hình ảnh rỗng hoặc bị lỗi.',
      );
    }
    if (bytes.length > maxBytes) {
      return const PickedAvatarResult(
        errorMessage:
            'Kích thước ảnh vượt quá giới hạn 2MB. Vui lòng chọn ảnh nhẹ hơn.',
      );
    }

    final ext = p.extension(selectedPath).toLowerCase();
    String mimeType = 'image/png';
    if (ext == '.jpg' || ext == '.jpeg') {
      mimeType = 'image/jpeg';
    } else if (ext == '.webp') {
      mimeType = 'image/webp';
    } else if (ext == '.gif') {
      mimeType = 'image/gif';
    } else if (ext != '.png') {
      return const PickedAvatarResult(
        errorMessage:
            'Chỉ hỗ trợ các định dạng ảnh: .png, .jpg, .jpeg, .webp, .gif.',
      );
    }

    final base64Str = base64Encode(bytes);
    return PickedAvatarResult(
      dataUri: 'data:$mimeType;base64,$base64Str',
      fileName: p.basename(selectedPath),
      byteSize: bytes.length,
    );
  } catch (e) {
    return PickedAvatarResult(
      errorMessage: 'Không thể mở hoặc đọc tệp ảnh: $e',
    );
  }
}

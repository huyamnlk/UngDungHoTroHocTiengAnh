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
  return const PickedAvatarResult(
    errorMessage:
        'Trình chọn tệp trực tiếp không khả dụng trên môi trường này. Bạn có thể chọn Avatar mẫu hoặc nhập đường dẫn ảnh.',
  );
}

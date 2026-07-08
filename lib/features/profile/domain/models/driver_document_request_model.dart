class DriverDocumentRequestModel {
  final String id;
  final String additionalFieldTitle;
  final String status;
  final String? adminNote;
  final String? lockAfter;
  final bool lockImmediately;
  final List<String> submittedFiles;

  DriverDocumentRequestModel({
    required this.id,
    required this.additionalFieldTitle,
    required this.status,
    this.adminNote,
    this.lockAfter,
    required this.lockImmediately,
    required this.submittedFiles,
  });

  factory DriverDocumentRequestModel.fromJson(Map<String, dynamic> json) {
    return DriverDocumentRequestModel(
      id: json['id']?.toString() ?? '',
      additionalFieldTitle: json['additional_field_title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      adminNote: json['admin_note']?.toString(),
      lockAfter: json['lock_after']?.toString(),
      lockImmediately: json['lock_immediately']?.toString() == '1' ||
          json['lock_immediately']?.toString() == 'true',
      submittedFiles: (json['submitted_files'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
    );
  }
}

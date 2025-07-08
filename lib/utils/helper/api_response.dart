class ApiResponse<T> {
  final int statusCode;
  final String message;
  final T? data;

  ApiResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      statusCode: json['statusCode'],
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}

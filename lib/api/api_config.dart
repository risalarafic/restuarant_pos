class ApiConfig {
  ApiConfig._();

  static const baseUrl = 'http://15.235.64.38/restaurant/backend';
  static const mediaBaseUrl = 'http://15.235.64.38/restaurant';
  static const loginUrl = '$baseUrl/login.php';
  static const dashboardUrl = '$baseUrl/dashboard.php';
  static const saveOrderUrl = '$baseUrl/saveorder.php';

  /// Builds
  /// `http://15.235.64.38/restaurant/uploads/410/products/picture….jpeg`
  /// from the API `picture` field (`uploads/410/products/picture….jpeg`).
  static String productImageUrl(String? picture) {
    final path = picture?.trim() ?? '';
    if (path.isEmpty || path == 'null') return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final relative = path.startsWith('/') ? path.substring(1) : path;
    return '$mediaBaseUrl/$relative';
  }
}

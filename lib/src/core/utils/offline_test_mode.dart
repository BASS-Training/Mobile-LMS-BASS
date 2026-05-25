import 'local_storage.dart';

class OfflineTestMode {
  static const String offlineToken = 'DUMMY_OFFLINE_TOKEN_892374982374';
  static const String offlineEmail = 'tester@bass.com';
  static const String offlineEmailAlias = 'testing@bass.com';

  static bool isActive() {
    final token = LocalStorage.getAuthToken();
    final userEmail = LocalStorage.getAuthUser()?['email']
        ?.toString()
        .trim()
        .toLowerCase();

    return token == offlineToken || _isOfflineEmail(userEmail);
  }

  static String describeContext() {
    final token = LocalStorage.getAuthToken();
    final userEmail = LocalStorage.getAuthUser()?['email']
        ?.toString()
        .trim()
        .toLowerCase();

    return 'token=$token email=$userEmail active=${isActive()}';
  }

  static bool _isOfflineEmail(String? email) {
    if (email == null) {
      return false;
    }

    return email == offlineEmail || email == offlineEmailAlias;
  }
}

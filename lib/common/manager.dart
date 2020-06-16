class AppManager {
  static final AppManager _instance = AppManager._internal();

  bool isVibrationing;

  factory AppManager() {
    return _instance;
  }

  AppManager._internal() {
    isVibrationing = false;
  }
}

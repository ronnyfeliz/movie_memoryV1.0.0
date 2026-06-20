import 'package:flutter/foundation.dart';

enum PlayState { loading, loaded, error, timeout, switchingServer }

class PlayerController extends ChangeNotifier {
  PlayState _state = PlayState.loading;
  double _loadingProgress = 0.0;
  String? _errorMessage;
  int _retryCount = 0;
  String _currentServer = '';
  bool _isDisposed = false;

  PlayState get state => _state;
  double get loadingProgress => _loadingProgress;
  String? get errorMessage => _errorMessage;
  int get retryCount => _retryCount;
  String get currentServer => _currentServer;
  bool get isLoading => _state == PlayState.loading || _state == PlayState.switchingServer;
  bool get hasError => _state == PlayState.error || _state == PlayState.timeout;
  String stateLabel({String? langCode}) {
    final isEs = langCode == null || langCode.startsWith('es');
    switch (_state) {
      case PlayState.loading:
        return isEs ? 'Cargando video...' : 'Loading video...';
      case PlayState.loaded:
        return isEs ? 'Video cargado' : 'Video loaded';
      case PlayState.error:
        final err = _errorMessage ?? (isEs ? 'desconocido' : 'unknown');
        return '${isEs ? 'Error' : 'Error'}: $err';
      case PlayState.timeout:
        return isEs ? 'Tiempo de espera agotado' : 'Connection timed out';
      case PlayState.switchingServer:
        return isEs ? 'Cambiando fuente...' : 'Switching server...';
    }
  }

  void onLoadStart({String? server}) {
    if (_isDisposed) return;
    _state = PlayState.loading;
    _loadingProgress = 0.0;
    _errorMessage = null;
    if (server != null && server.isNotEmpty) _currentServer = server;
    notifyListeners();
  }

  void onProgress(double value) {
    if (_isDisposed) return;
    _loadingProgress = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void onLoadComplete() {
    if (_isDisposed) return;
    _state = PlayState.loaded;
    _loadingProgress = 1.0;
    _errorMessage = null;
    _retryCount = 0;
    notifyListeners();
  }

  void onError([String? message]) {
    if (_isDisposed) return;
    _state = PlayState.error;
    _errorMessage = message ?? 'No se pudo cargar el video';
    notifyListeners();
  }

  void onTimeout() {
    if (_isDisposed) return;
    _state = PlayState.timeout;
    _errorMessage = 'El video tardó demasiado en cargar';
    notifyListeners();
  }

  void onSwitchingServer(String server) {
    if (_isDisposed) return;
    _state = PlayState.switchingServer;
    _currentServer = server;
    _loadingProgress = 0.0;
    _errorMessage = null;
    notifyListeners();
  }

  void resetForRetry() {
    if (_isDisposed) return;
    _retryCount++;
    _state = PlayState.loading;
    _loadingProgress = 0.0;
    _errorMessage = null;
    notifyListeners();
  }

  void resetRetryCount() {
    _retryCount = 0;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

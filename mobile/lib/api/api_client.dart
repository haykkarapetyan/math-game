import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://localhost:3000/api';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Try refresh
          final refreshed = await _tryRefresh();
          if (refreshed) {
            // Retry original request
            final opts = error.requestOptions;
            final prefs = await SharedPreferences.getInstance();
            opts.headers['Authorization'] =
                'Bearer ${prefs.getString('access_token')}';
            final response = await _dio.fetch(opts);
            return handler.resolve(response);
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<bool> _tryRefresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null) return false;

      final response = await Dio(BaseOptions(baseUrl: baseUrl)).post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      await prefs.setString('access_token', response.data['access_token']);
      await prefs.setString('refresh_token', response.data['refresh_token']);
      return true;
    } catch (_) {
      return false;
    }
  }

  // --- Auth ---

  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final response = await _dio.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
    });
    await _saveTokens(response.data);
    return response.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await _saveTokens(response.data);
    return response.data;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get('/auth/me');
    return response.data;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // --- Profile ---

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/profile');
    return response.data;
  }

  Future<void> updateProfile({String? username, String? language, String? avatar}) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (language != null) data['language'] = language;
    if (avatar != null) data['avatar'] = avatar;
    await _dio.patch('/profile', data: data);
  }

  // --- Game ---

  Future<List<dynamic>> getTiers({String lang = 'en'}) async {
    final response = await _dio.get('/tiers', queryParameters: {'lang': lang});
    return response.data;
  }

  Future<List<dynamic>> getLevels(int tierId) async {
    final response = await _dio.get('/tiers/$tierId/levels');
    return response.data;
  }

  Future<Map<String, dynamic>> getPuzzle(int levelId) async {
    final response = await _dio.get('/levels/$levelId/puzzles');
    return response.data;
  }

  Future<Map<String, dynamic>> submitPuzzle(
      int puzzleId, List<Map<String, dynamic>> cells, int timeTakenMs, int wrongMoves) async {
    final response = await _dio.post('/puzzles/$puzzleId/submit', data: {
      'cells': cells,
      'time_taken_ms': timeTakenMs,
      'wrong_moves': wrongMoves,
    });
    return response.data;
  }

  Future<List<dynamic>> getProgress() async {
    final response = await _dio.get('/progress');
    return response.data;
  }

  // --- Energy ---

  Future<Map<String, dynamic>> getEnergy() async {
    final response = await _dio.get('/energy');
    return response.data;
  }

  Future<void> refillEnergy() async {
    await _dio.post('/energy/refill');
  }

  // --- Helpers ---

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', data['access_token']);
    await prefs.setString('refresh_token', data['refresh_token']);
  }

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null;
  }
}

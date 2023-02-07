import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class BaseClient {
  BaseClient._() {
    _setupAuthHeaderInterceptor();
  }

  static final BaseClient _instance = BaseClient._();
  static BaseClient get instance => _instance;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.openai.com/v1/',
    contentType: Headers.jsonContentType,
    connectTimeout: 20000,
    sendTimeout: 20000,
    receiveTimeout: 20000,
  ));

  void _setupAuthHeaderInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler r) async {
          _dio.lock();

          options.headers['Accept'] = "application/json";
          options.headers['Content-Type'] = "application/json";

          ///Put your api key from open-AI here
          options.headers['Authorization'] =
              "Bearer ";
          _dio.unlock();
          r.next(options);
        },
        onError: (e, handler) {
          handler.next(e);
          // handler.reject(e);
        },
      ),
    );
    _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90));
  }

  /// return response body or throws [NetworkExceptions]
  Future<dynamic> post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final res = await _dio.post(uri, data: data);
      return res.data;
    } on DioError catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}

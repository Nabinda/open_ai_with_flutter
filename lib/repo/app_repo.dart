import '../constants/api_constants.dart';
import '../core/base_client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final appRepo = Provider((ref) => AppRepo());

class AppRepo {
  final _client = BaseClient.instance;

  Future searchImage(Map<String, dynamic> data) async {
    return await _client.post(ApiConstants.image, data: data);
  }
}

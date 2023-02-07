import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_search/enum/image_size.dart';
import 'package:image_search/repo/app_repo.dart';

final imageBloc = ChangeNotifierProvider((ref) => ImageBloc(ref));

class ImageBloc extends ChangeNotifier {
  ImageBloc(this.ref);

  final Ref ref;
  AsyncValue<List> retrivedData = const AsyncLoading();

  Future<void> getImage({
    required String prompt,
    required ImageSize imageSize,
    int imageCount = 4,
  }) async {
    try {
      retrivedData = const AsyncLoading();
      customNotifyListeners();
      final imageFilterSize = ImageSizeFilter().filter(imageSize);

      final result = await ref.read(appRepo).searchImage(
          {'prompt': prompt, 'n': imageCount, 'size': imageFilterSize});

      retrivedData = AsyncValue.data(result['data'] as List);
    } catch (e) {
      retrivedData = AsyncValue.error(e.toString(), StackTrace.current);
    }
    customNotifyListeners();
  }

  // to indicate whether the state provider is disposed or not
  bool _isDisposed = false;

  // use the notifyListeners as below
  customNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _isDisposed = true;
  }
}

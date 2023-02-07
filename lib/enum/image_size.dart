enum ImageSize {
  size_256X256,
  size_512x512,
  size_1024x1024,
}

class ImageSizeFilter {
  String filter(ImageSize size) {
    switch (size) {
      case ImageSize.size_256X256:
        return '256x256';
      case ImageSize.size_512x512:
        return '512x512';
      case ImageSize.size_1024x1024:
        return '1024x1024';
      default:
        return '1024x1024';
    }
  }
}

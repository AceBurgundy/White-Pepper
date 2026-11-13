class PlatenPaperDimensions {
  const PlatenPaperDimensions({
    required this.name,
    required this.widthMm,
    required this.heightMm,
  });

  final String name;
  final double widthMm;
  final double heightMm;

  double get widthInches => widthMm / 25.4;
  double get heightInches => heightMm / 25.4;

  int pixelWidth(int dpi) => (widthInches * dpi).round();
  int pixelHeight(int dpi) => (heightInches * dpi).round();
}

class PlatenGeometryHelper {
  // Physical HP Flatbed Platen Limits (Letter width, A4 length)
  static const double platenWidthMm = 215.9; // 8.50"
  static const double platenHeightMm = 297.0; // 11.693"

  static const Map<String, PlatenPaperDimensions> presetDimensions = {
    'full': PlatenPaperDimensions(name: 'Full Platen', widthMm: 215.9, heightMm: 297.0),
    'a4': PlatenPaperDimensions(name: 'A4', widthMm: 210.0, heightMm: 297.0),
    'letter': PlatenPaperDimensions(name: 'Letter', widthMm: 215.9, heightMm: 279.4),
    'legal': PlatenPaperDimensions(name: 'Legal (Stitch)', widthMm: 215.9, heightMm: 355.6),
    'a5': PlatenPaperDimensions(name: 'A5', widthMm: 148.0, heightMm: 210.0),
    'a6': PlatenPaperDimensions(name: 'A6', widthMm: 105.0, heightMm: 148.0),
    'b5': PlatenPaperDimensions(name: 'B5', widthMm: 176.0, heightMm: 250.0),
    'executive': PlatenPaperDimensions(name: 'Executive', widthMm: 184.15, heightMm: 266.7),
    'statement': PlatenPaperDimensions(name: 'Statement', widthMm: 139.7, heightMm: 215.9),
    'photo-4x6': PlatenPaperDimensions(name: 'Photo 4x6"', widthMm: 101.6, heightMm: 152.4),
    'photo-5x7': PlatenPaperDimensions(name: 'Photo 5x7"', widthMm: 127.0, heightMm: 177.8),
    'index-3x5': PlatenPaperDimensions(name: 'Index 3x5"', widthMm: 76.2, heightMm: 127.0),
    'id-card': PlatenPaperDimensions(name: 'ID-1 Card', widthMm: 85.6, heightMm: 53.98),
    'receipt-half': PlatenPaperDimensions(name: 'Receipt Half', widthMm: 215.9, heightMm: 148.5),
  };

  static PlatenPaperDimensions resolveDimensions(
    String paperPreset, {
    double customWidth = 210.0,
    double customHeight = 297.0,
    String units = 'mm',
  }) {
    if (paperPreset == 'custom') {
      final double widthMillimeters = units == 'in' ? customWidth * 25.4 : customWidth;
      final double heightMillimeters = units == 'in' ? customHeight * 25.4 : customHeight;
      return PlatenPaperDimensions(
        name: 'Custom',
        widthMm: widthMillimeters,
        heightMm: heightMillimeters,
      );
    }
    return presetDimensions[paperPreset.toLowerCase()] ??
        presetDimensions['a4']!;
  }
}

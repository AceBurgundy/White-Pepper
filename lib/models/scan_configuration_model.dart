enum WorkflowType {
  flatbed(
    identifier: 'flatbed-document',
    title: 'Flatbed Document',
    subtitle: 'Standard document & photo scanning',
    cliSummary: 'scan_cli.py flatbed --paper-size a4 --dpi 300',
    iconName: 'description',
    emojiIcon: '📄',
    useEmoji: false,
  ),
  photoScan(
    identifier: 'photo-scan',
    title: 'Photo Scan',
    subtitle: 'High-resolution color photo scan',
    cliSummary: 'scan_cli.py flatbed --preset photo-4x6 --dpi 600',
    iconName: 'image',
    emojiIcon: '🖼️',
    useEmoji: false,
  ),
  bookletBatch(
    identifier: 'booklet-batch',
    title: 'Booklet Batch',
    subtitle: 'Continuous dual-page book scanning',
    cliSummary: 'scan_cli.py booklet --interval 10 --dpi 300',
    iconName: 'auto_stories',
    emojiIcon: '📖',
    useEmoji: false,
  ),
  cardDuplex(
    identifier: 'id-card-duplex',
    title: 'ID Card Duplex',
    subtitle: 'Front & back ID card alignment',
    cliSummary: 'scan_cli.py card --dpi 600 --safety-inset-mm 0.5',
    iconName: 'badge',
    emojiIcon: '🪪',
    useEmoji: false,
  ),
  batchCardDeskew(
    identifier: 'batch-card-deskew',
    title: 'Batch Card Deskewer',
    subtitle: 'Auto-straighten & crop card images',
    cliSummary: 'process_cli.py cards --dpi 600',
    iconName: 'view_carousel',
    emojiIcon: '🔍',
    useEmoji: false,
  ),
  compilePdf(
    identifier: 'compile-pdf',
    title: 'Compile PDF',
    subtitle: 'Combine scanned pages into PDF',
    cliSummary: 'process_cli.py compile-pdf --fit-mode contain',
    iconName: 'picture_as_pdf',
    emojiIcon: '📑',
    useEmoji: false,
  ),
  receiptArchive(
    identifier: 'receipt-archive',
    title: 'Receipt Archive',
    subtitle: 'Quick receipt & invoice capture',
    cliSummary: 'scan_cli.py flatbed --preset boy-gatas-receipts',
    iconName: 'receipt_long',
    emojiIcon: '🧾',
    useEmoji: false,
  ),
  legalStitch(
    identifier: 'legal-two-pass',
    title: 'Legal 2-Pass Stitch',
    subtitle: 'Two-pass full legal paper merge',
    cliSummary: 'scan_cli.py legal-stitch --resolution 300 --ipc-mode',
    iconName: 'vertical_split',
    emojiIcon: '📐',
    useEmoji: false,
  );

  const WorkflowType({
    required this.identifier,
    required this.title,
    required this.subtitle,
    required this.cliSummary,
    required this.iconName,
    required this.emojiIcon,
    required this.useEmoji,
  });

  final String identifier;
  final String title;
  final String subtitle;
  final String cliSummary;
  final String iconName;
  final String emojiIcon;
  final bool useEmoji;
}

class ScanConfigurationModel {
  ScanConfigurationModel({
    this.workflowType = WorkflowType.flatbed,
    this.paperSize = 'a4',
    this.dpi = 300,
    this.colorMode = 'color',
    this.format = 'pdf',
    this.outputDirectory = r'D:\Pictures\Scanned',
    this.fileNamePrefix = '',
    this.rotation = 0,
    this.brightness = 0,
    this.contrast = 0,
    this.autoCrop = false,
    this.units = 'mm',
    this.customWidth = 210.0,
    this.customHeight = 297.0,
    this.offsetX = 0.0,
    this.offsetY = 0.0,
    this.fitMode = 'contain',
    this.marginMm = 0.0,
    this.safetyInsetMm = 0.5,
    this.cornerRadiusMm = 3.18,
    this.cardBackground = 'transparent',
    this.cardDuplexTwoSided = true,
    this.intervalSeconds = 10,
    this.maxScans = 0,
    this.noDeskew = false,
    this.ipcMode = true,
  });

  WorkflowType workflowType;
  String paperSize;
  int dpi;
  String colorMode;
  String format;
  String outputDirectory;
  String fileNamePrefix;
  int rotation;
  int brightness;
  int contrast;
  bool autoCrop;
  String units;
  double customWidth;
  double customHeight;
  double offsetX;
  double offsetY;
  String fitMode;
  double marginMm;
  double safetyInsetMm;
  double cornerRadiusMm;
  String cardBackground;
  bool cardDuplexTwoSided;
  int intervalSeconds;
  int maxScans;
  bool noDeskew;
  bool ipcMode;

  ScanConfigurationModel copyWith({
    WorkflowType? workflowType,
    String? paperSize,
    int? dpi,
    String? colorMode,
    String? format,
    String? outputDirectory,
    String? fileNamePrefix,
    int? rotation,
    int? brightness,
    int? contrast,
    bool? autoCrop,
    String? units,
    double? customWidth,
    double? customHeight,
    double? offsetX,
    double? offsetY,
    String? fitMode,
    double? marginMm,
    double? safetyInsetMm,
    double? cornerRadiusMm,
    String? cardBackground,
    bool? cardDuplexTwoSided,
    int? intervalSeconds,
    int? maxScans,
    bool? noDeskew,
    bool? ipcMode,
  }) {
    return ScanConfigurationModel(
      workflowType: workflowType ?? this.workflowType,
      paperSize: paperSize ?? this.paperSize,
      dpi: dpi ?? this.dpi,
      colorMode: colorMode ?? this.colorMode,
      format: format ?? this.format,
      outputDirectory: outputDirectory ?? this.outputDirectory,
      fileNamePrefix: fileNamePrefix ?? this.fileNamePrefix,
      rotation: rotation ?? this.rotation,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      autoCrop: autoCrop ?? this.autoCrop,
      units: units ?? this.units,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
      fitMode: fitMode ?? this.fitMode,
      marginMm: marginMm ?? this.marginMm,
      safetyInsetMm: safetyInsetMm ?? this.safetyInsetMm,
      cornerRadiusMm: cornerRadiusMm ?? this.cornerRadiusMm,
      cardBackground: cardBackground ?? this.cardBackground,
      cardDuplexTwoSided: cardDuplexTwoSided ?? this.cardDuplexTwoSided,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      maxScans: maxScans ?? this.maxScans,
      noDeskew: noDeskew ?? this.noDeskew,
      ipcMode: ipcMode ?? this.ipcMode,
    );
  }
}

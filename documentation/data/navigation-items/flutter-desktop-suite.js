/**
 * Navigation item specification: Flutter Desktop Suite UI Architecture.
 */
window.DOCUMENTATION_ITEMS = window.DOCUMENTATION_ITEMS || {};
window.DOCUMENTATION_ITEMS["data/navigation-items/flutter-desktop-suite.js"] = {
  "item_title": "Flutter Desktop Suite",
  "icon_name": "desktop_windows",
  "header_container": {
    "title": "Flutter Desktop Suite & Design System",
    "description": "Deep-dive into the spacious 1180x820 workstation container, dual-orb orbital loading screen, streamlined 5-workflow cards, natural-scale contoured Pea Pod parameter drawer, and split wavy layout.",
    "badge_list": [
      { "icon_name": "aspect_ratio", "badge_label": "1180x820 Workstation Frame" },
      { "icon_name": "view_compact", "badge_label": "5 Streamlined Workflows" },
      { "icon_name": "progress_activity", "badge_label": "Dual-Orb Loading Splash" },
      { "icon_name": "touch_app", "badge_label": "Contoured Pea Pod" },
      { "icon_name": "view_in_ar", "badge_label": "Platen Preview" }
    ],
    "banner_image": { "image_path": "assets/desktop_suite_banner.png", "shrink": false },
    "mockup_card": { "image_path": "assets/desktop_suite_banner.png", "shrink": false }
  },
  "tab_list": [
    {
      "tab_title": "Design System",
      "icon_name": "palette",
      "section_blocks": [
        {
          "heading_title": "Minimalist Workstation Aesthetics",
          "block_type": "paragraph",
          "paragraph_text": "The White Pepper desktop interface replicates the precision hardware aesthetic of the minimalist design system: deep onyx charcoal surfaces, intense accent yellow highlights, pill-shaped navigation capsules, relaxed spacious margins, and responsive workstation framing."
        },
        {
          "heading_title": "Design Tokens & Color Palette",
          "block_type": "table",
          "table_headers": ["Token Name", "Hex Value", "Usage Context"],
          "table_rows": [
            ["DesignTokens.onyx", "#212121", "Primary workstation border, dark deck background, button foreground"],
            ["DesignTokens.accentYellow", "#FFFF1E", "Primary action button, active pill highlights, live LED indicators"],
            ["DesignTokens.neutralLightSurface", "#F5F7FA", "Dashboard background, instruction pane light surface"],
            ["DesignTokens.darkSurfaceOne", "#2A2A2A", "Options screen preview column, console output background"],
            ["DesignTokens.darkSurfaceTwo", "#2D2D2D", "Contoured Pea Pod housing, drawer background, pill clusters"],
            ["DesignTokens.statusOnlineGreen", "#22C55E", "Scanner online badge, successful execution checkmarks"]
          ]
        }
      ]
    },
    {
      "tab_title": "Workstation Screens",
      "icon_name": "devices",
      "section_blocks": [
        {
          "heading_title": "Screen 0: Dual-Orb Loading Screen (LoadingScreen.dart)",
          "block_type": "paragraph",
          "paragraph_text": "Upon application launch, a pure dual-orb orbital animation displays primary and secondary counter-pulsing glowing orbs revolving at a 1.8s cadence. Once scanner discovery initializes, the orbs stop, converge to the center, and split in opposite horizontal directions while scaling down and fading out smoothly over 550ms, seamlessly revealing the main dashboard."
        },
        {
          "heading_title": "Screen 1: Dashboard (DashboardScreen.dart)",
          "block_type": "paragraph",
          "paragraph_text": "The dashboard presents a 310px left sidebar alongside a spacious grid of 5 streamlined workflow cards (Basic Scan with presets, 4-inch transparent Card Scan, multi-format Batch Scan, Custom Region, and hardware-detected Legal 2-Pass Stitch). Features relaxed desktop spacing, inverted white high-contrast printer card on night mode, animated printer line icon on View Printer, and zero-background-change icon animations across all buttons."
        },
        {
          "heading_title": "Screen 2: Options Control Deck (OptionsScreen.dart)",
          "block_type": "paragraph",
          "paragraph_text": "Opening any workflow transitions smoothly into the spacious Control Deck. The left column displays the widened Optical Platen canvas with real-time DPI checkered box density patterns, dashed crop margin guidelines with L-corner brackets, discrete color mode sheets (RGB Color with CMYK swatches, 8-bit Grayscale, and stark 1-bit B&W), and physically accurate relative proportions (A4 shorter than Full Platen, Letter much shorter than A4 with full platen width). The right column renders the natural-scale contoured PeaPodWidget with wrapping navigation arrows, animated line icons on hover, Start Scan pulse action, and the dynamic parameter drawer."
        },
        {
          "heading_title": "Screen 3: Step-by-Step Instructions (InstructionsScreen.dart)",
          "block_type": "paragraph",
          "paragraph_text": "The instructions screen utilizes an organic cubic-bezier vertical wave divider separating the light physical instruction pane from the dark onyx execution pane. The right pane features guided card flip countdowns, an 84x84 circular hold-to-confirm progress trigger button, and real-time streaming CLI console output."
        }
      ]
    },
    {
      "tab_title": "Interactive Controls & Vision Feedback",
      "icon_name": "auto_awesome",
      "section_blocks": [
        {
          "heading_title": "Pure Component-Level Icon Animations",
          "block_type": "paragraph",
          "paragraph_text": "White Pepper enforces an uncompromising interaction rule: button hover states are driven strictly by vector icon kinematics rather than background color changes, overlays, or shadow shifts. When a user hovers over an interactive component, the icon's constituent paths independently animate (e.g. the Start Scan play arrow shifts forward while an optical sweep beam passes across; the View Printer chassis emerges a printed document sheet with text lines; the PeaPod rotate icon spins with tangent-aligned wings)."
        },
        {
          "heading_title": "Optical Platen Real-Time Feedback Engine",
          "block_type": "table",
          "table_headers": ["Feature", "Implementation", "Visual Response"],
          "table_rows": [
            ["DPI Checkered Grid", "_PaperDpiCheckeredPainter", "Cell size inversely proportional to DPI (2400/dpi); transitions dynamically from coarse 24px boxes at 75 DPI to a silky 3px micro-mesh at 1200 DPI"],
            ["Crop Guidelines & Margins", "_PaperCropMarginsPainter", "Draws dashed boundary rectangle and 4 graphic design L-corner registration brackets reflecting autoCrop status and marginMm insets"],
            ["Color Mode Representation", "_buildColorModeStrip", "Renders RGB Color (with 4 vibrant CMYK swatches), 8-bit Grayscale (discrete 10%-90% monochrome ramp), and stark 1-bit B&W line art with black border"],
            ["Proportional Paper Scaling", "PlatenGeometryHelper", "Mathematically computes paper dimensions against physical glass bounds; A4 is narrower than Letter and shorter than Full Platen, while Letter has full platen width and is much shorter than A4"]
          ]
        },
        {
          "heading_title": "Curated 5-Workflow Matrix",
          "block_type": "table",
          "table_headers": ["Workflow", "Key Capabilities", "Target Output"],
          "table_rows": [
            ["Basic Scan", "One-touch document & photo capture with quick presets (High Quality 600 DPI, B&W Text, Quick 300 DPI)", "PDF, PNG, JPEG, TIFF"],
            ["Card Scan", "4-inch capture window, automated ID-1 deskew, 3.18mm rounded corner clipping, transparent background PNG, front/back guided dual-pass timer", "Dual PNGs (Front/Back)"],
            ["Batch Scan", "Continuous multi-sheet document acquisition with customizable interval timer and Stop Early trigger", "Multi-page PDF / TIFF"],
            ["Custom Region", "Custom platen coordinate clamping (width, height, X/Y offsets) with live inch/millimeter unit switching", "Custom cropped raster/PDF"],
            ["Legal 2-Pass Stitch", "Auto-detected for <14\" flatbed scanners; guided top/bottom scanning with feature matching and seam blending", "14.0\" Legal PDF"]
          ]
        }
      ]
    }
  ]
};

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
          "paragraph_text": "The dashboard presents a 310px left sidebar alongside a spacious grid of 5 streamlined workflow cards (Basic Scan with presets, 4-inch transparent Card Scan, multi-format Batch Scan, Custom Region, and hardware-detected Legal 2-Pass Stitch). Features relaxed desktop spacing, printer status, CMYK ink levels, and bottom navigation pill."
        },
        {
          "heading_title": "Screen 2: Options Control Deck (OptionsScreen.dart)",
          "block_type": "paragraph",
          "paragraph_text": "Opening any workflow transitions smoothly into the spacious Control Deck. The left column displays a 3D Printer Pill capsule with an emerging paper sheet preview that visually rotates and scales according to chosen dimensions. The right column renders the natural-scale contoured PeaPodWidget with wrapping navigation arrows, animated line icons on hover, and the dynamic parameter drawer."
        },
        {
          "heading_title": "Screen 3: Step-by-Step Instructions (InstructionsScreen.dart)",
          "block_type": "paragraph",
          "paragraph_text": "The instructions screen utilizes an organic cubic-bezier vertical wave divider separating the light physical instruction pane from the dark onyx execution pane. The right pane features guided card flip countdowns, an 84x84 circular hold-to-confirm progress trigger button, and real-time streaming CLI console output."
        }
      ]
    }
  ]
};

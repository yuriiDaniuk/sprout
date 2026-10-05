# Local design assets

Photos and SVGs were exported from Figma file tA5zaOIT7BGhdWOdU7VaTa on 2026-10-05. `figma-manifest.json` maps each local file to its source frame/variable; runtime code uses local asset paths.

Frame 2:4 provides the tree logo, reused by all auth screens. Frame 9:4 provides the separate 56px task photo, four 130px-tall plant card photographs, droplet/check icons, plus background and Home tabs. Frame 16:339 provides the 96px avatar, settings/back icons, separators and Profile tabs. SVG root sizes are preserved. Native iOS owns status bar/home indicator, as approved.

Manrope variable font: https://github.com/google/fonts/tree/main/ofl/manrope . Font license in `fonts/OFL.txt`; original font retained in `fonts/Manrope.ttf`. Text styles explicitly select its weight axis.

No image or font is loaded from the network by the app.

Profile uses `avatar-cropped.png`, the export of image layer 16:358, preserving its Figma fill crop. The uncropped original `avatar.png` is retained as source evidence. The plus SVG's circle is unchanged; Flutter adds its shadow because flutter_svg does not support the exported filter.

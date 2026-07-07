NIMA Icon Pack

1. Copy assets/icons/ into your Flutter project.
2. Copy lib/core/widgets/nima_svg_icon.dart into your project.
3. Add to pubspec.yaml:

dependencies:
  flutter_svg: ^2.2.1

flutter:
  assets:
    - assets/icons/

4. Remove font_awesome_flutter from pubspec.yaml.
5. Remove imports of package:font_awesome_flutter/font_awesome_flutter.dart.

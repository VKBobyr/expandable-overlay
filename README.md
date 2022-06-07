This package fascilitates easy creation of expandable overlays that expand out of the button (`ExpandableOverlayLauncher`) and can be swiped down to dismiss.

<img src="https://github.com/VKBobyr/expandable-overlay/blob/master/media/demo.gif?raw=true"
     alt="Animated gif of how the package works"
     style="width: 300px;" />

## Getting Started

Install package via command line (or just add it in `pubspec.yaml`):

```bash
flutter pub add expandable_overlay
```

## Usage

### 1. Import the package:

```dart
import 'package:expandable_overlay/expandable_overlay.dart';
```

### 2. Wrap an element with the `ExpandableOverlayLauncher` widget.

```dart
ExpandableOverlayLauncher(
  overlayParams: ExpandableOverlayParams(
    contentBuilder: (
      context,
      dismissOverlay, // function that can be used to dismiss the modal through code
    ) => Text("I'm inside the modal"), // widget containing the contents of the modal
  ),
  // widget that will be tapped to open the modal
  child: Text('click me'),
)
```

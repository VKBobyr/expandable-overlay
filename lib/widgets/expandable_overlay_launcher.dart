part of expandable_overlay;

// ignore: must_be_immutable
class ExpandableOverlayLauncher extends HookWidget {
  final Widget child;
  final ExpandableOverlayParams overlayParams;

  ExpandableOverlayLauncher({
    Key? key,
    required this.child,
    required this.overlayParams,
  }) : super(key: key);

  final childKey = GlobalKey();
  late ValueNotifier<bool> open;

  Size? childSize;
  Overlay? overlay;
  OverlayEntry? overlayEntry;

  @override
  Widget build(BuildContext context) {
    open = useState(false);

    return Container(
      key: childKey,
      child: GestureDetector(
        onTap: () {
          childSize = childKey.currentContext!.size;
          open.value = true;
          createOverlay(context);
        },
        child: child,
      ),
    );
  }

  void createOverlay(context) {
    if (overlayEntry != null) return;

    final overlay = Overlay.of(childKey.currentContext!);

    overlayEntry = OverlayEntry(
      builder: (context) {
        return buildOverlay(
          context,
          childHeight: childSize!.height,
        );
      },
    );

    overlay?.insert(overlayEntry!);
  }

  Widget buildOverlay(
    BuildContext context, {
    required double childHeight,
  }) {
    return _ExpandableOverlay(
      childRenderBox: childKey.currentContext!.findRenderObject() as RenderBox,
      dismissOverlay: closeOverlay,
      top: child,
      params: overlayParams,
    );
  }

  void closeOverlay() {
    open.value = false;
    overlayEntry?.remove();
    overlayEntry = null;
  }
}

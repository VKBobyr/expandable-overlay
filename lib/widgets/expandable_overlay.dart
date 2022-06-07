part of expandable_overlay;

class ExpandableOverlayParams {
  final Color backgroundColor;
  final Color overlayDimColor;
  final Color handleBackgroundColor;
  final Widget Function(
    BuildContext context,
    void Function() dismissOverlay,
  ) contentBuilder;
  final double closeCutoff;
  final Duration animationDuration;

  const ExpandableOverlayParams({
    required this.contentBuilder,
    this.animationDuration = const Duration(milliseconds: 300),
    // the background color of the modal
    this.backgroundColor = Colors.white,
    this.handleBackgroundColor = const Color(0xfff5f5f5),
    this.overlayDimColor = const Color.fromARGB(100, 0, 0, 0),
    this.closeCutoff = .8,
  }) : assert(closeCutoff <= 1 && closeCutoff >= 0);
}

// ignore: must_be_immutable
class _ExpandableOverlay extends HookWidget {
  static const double handleHeight = 30;
  static Color transparentColor = const Color.fromARGB(0, 0, 0, 0);
  static Color defaultDimmedColor = const Color.fromARGB(100, 0, 0, 0);
  static Color defaultBackgroundColor = Colors.white;

  final Widget top;
  final Function() dismissOverlay;
  final RenderBox childRenderBox;
  final ExpandableOverlayParams params;

  late BuildContext context;
  late ValueNotifier<Rect> currentRect;
  late ValueNotifier<double?> dragPosition;
  late ScrollController scrollController;
  double currentHandleHeight = 0;
  Color currentBackgroundColor = transparentColor;

  _ExpandableOverlay({
    Key? key,
    required this.params,
    required this.top,
    required this.dismissOverlay,
    required this.childRenderBox,
  }) : super(key: key);

  Rect? get dragRect {
    if (dragPosition.value == null) return null;
    return Rect.fromPoints(
      Offset(0, dragPosition.value!),
      expandedRect.bottomRight,
    );
  }

  Rect get childRect {
    final offset = childRenderBox.localToGlobal(Offset.zero);
    final size = childRenderBox.size;
    final out = Rect.fromPoints(
      offset,
      offset + Offset(size.width, size.height),
    );

    return out;
  }

  Rect get expandedRect {
    final media = MediaQuery.of(context);
    final screenSize = media.size;
    final safePadding = media.padding;
    return Rect.fromPoints(
      Offset.zero + Offset(0, safePadding.top),
      Offset(
        screenSize.width,
        screenSize.height,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    currentRect = useState(childRect);
    dragPosition = useState(null);
    scrollController = useScrollController();

    useEffect(() {
      Future.delayed(Duration.zero).then((value) {
        currentRect.value = expandedRect;
        currentHandleHeight = handleHeight;
        currentBackgroundColor = defaultDimmedColor;
      });
      return null;
    }, []);

    return Stack(
      children: [
        buildOverlayBackground(),
        buildOverlayContents(context),
      ],
    );
  }

  AnimatedPositioned buildOverlayContents(BuildContext context) {
    return AnimatedPositioned.fromRect(
      duration: dragRect == null ? params.animationDuration : Duration.zero,
      curve: Curves.easeInOut,
      rect: dragRect ?? currentRect.value,
      child: Container(
        color: Colors.white,
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              wrapWithGestureDetector(buildHandle()),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Material(
                    color: defaultBackgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        wrapWithGestureDetector(top),
                        params.contentBuilder(context, dismissOverlay),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector wrapWithGestureDetector(Widget child) {
    return GestureDetector(
      onTap: dismiss,
      onVerticalDragStart: onDragStart,
      onVerticalDragUpdate: onDragUpdate,
      onVerticalDragEnd: onDragEnd,
      child: child,
    );
  }

  void onDragEnd(drag) {
    final y = dragPosition.value;
    if (y == null) return;

    final screenHeight = MediaQuery.of(context).size.height;
    if ((y / (screenHeight - expandedRect.top)) > (1 - params.closeCutoff)) {
      dismiss();
    }

    dragPosition.value = null;
  }

  void onDragUpdate(drag) {
    final newY = dragPosition.value! + drag.delta.dy;
    dragPosition.value = newY;
  }

  void onDragStart(drag) {
    dragPosition.value = currentRect.value.top;
  }

  AnimatedContainer buildOverlayBackground() {
    return AnimatedContainer(
      duration: params.animationDuration,
      color: currentBackgroundColor,
    );
  }

  Widget buildHandle() {
    return AnimatedContainer(
      duration: params.animationDuration,
      height: currentHandleHeight,
      width: double.infinity,
      color: params.handleBackgroundColor,
      child: Center(
        child: AnimatedContainer(
          duration: params.animationDuration,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(20),
          ),
          width: 60,
          height: currentHandleHeight == 0 ? 0 : 7,
        ),
      ),
    );
  }

  Future<void> dismiss() async {
    currentRect.value = childRect;
    currentHandleHeight = 0;
    currentBackgroundColor = transparentColor;

    await Future.delayed(params.animationDuration);
    dismissOverlay();
  }
}

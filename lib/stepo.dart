import 'package:flutter/material.dart';

enum Direction { increment, decrement }

enum StepoOrientation { vertical, horizontal }

class Stepo extends StatefulWidget {
  final double? width, fontSize, iconSize;
  final Function(int)? onIncrementClicked, onDecrementClicked;
  final Color? textColor, iconColor, backgroundColor;
  final Duration? animationDuration;
  final int? initialCounter, upperBound, lowerBound;
  final StepoOrientation? orientation;
  final TextStyle? textStyle;
  Stepo({
    required Key key,
    this.initialCounter,
    this.onIncrementClicked,
    this.onDecrementClicked,
    this.orientation,
    this.width,
    this.backgroundColor,
    this.fontSize,
    this.iconSize,
    this.textColor,
    this.iconColor,
    this.upperBound,
    this.lowerBound,
    this.animationDuration,
    this.textStyle,
  }) : super(key: key);

  @override
  _StepoState createState() => _StepoState();
}

class _StepoState extends State<Stepo> with TickerProviderStateMixin {
  late int _counter, upperBound, lowerBound;
  late bool _isDecrementIconClicked = false;
  late bool _isIncrementIconClicked = false;
  late double rootWidth, rootHeight, fontSize, iconSize, cornerRadius;
  late double textOpacity = 1;
  late double textAnimationEndValue;
  late Duration textAnimationDuration;
  late Duration iconAnimationDuration;
  late Duration scaleDuration = Duration(milliseconds: 100);
  late Function onIncrementClicked, onDecrementClicked;
  late Color? textColor, backgroundColor;
  late Color iconColor;
  late StepoOrientation? orientation;
  late TextStyle? textStyle;

  late Animation<double> textIncrementAnimation,
      textDecrementAnimation,
      incrementIconAnimation,
      decrementIconAnimation,
      scaleAnimation;
  late AnimationController textIncrementAnimationController,
      textDecrementAnimationController,
      incrementIconAnimationController,
      decrementIconAnimationController,
      scaleAnimationController;

  @override
  void initState() {
    super.initState();

    initProperties();
    initBackgroundScaleAnimationController();
    initTextIncrementAnimationController();
    initTextDecrementAnimationController();
    initIncrementIconAnimationController();
    initDecrementIconAnimationController();
  }

  @override
  void dispose() {
    textIncrementAnimationController.dispose();
    textDecrementAnimationController.dispose();
    incrementIconAnimationController.dispose();
    decrementIconAnimationController.dispose();
    scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Transform.scale(
          scale: scaleAnimation.value,
          child: Container(
            height: rootHeight,
            width: rootWidth,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.all(
                Radius.circular(cornerRadius),
              ),
            ),
            child: Material(
              type: MaterialType.canvas,
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: <Widget>[
                  Align(
                    alignment: orientation == StepoOrientation.horizontal
                        ? AlignmentDirectional.centerStart
                        : AlignmentDirectional.bottomCenter,
                    child: Transform.translate(
                      offset: orientation == StepoOrientation.horizontal
                          ? Offset(decrementIconAnimation.value, 0)
                          : Offset(
                              0,
                              decrementIconAnimation.value,
                            ),
                      child: InkWell(
                        customBorder: CircleBorder(),
                        onTap: () async {
                          handleOnTap(Direction.decrement);
                        },
                        child: Icon(
                          orientation == StepoOrientation.horizontal
                              ? Icons.chevron_left
                              : Icons.keyboard_arrow_down,
                          color: _isDecrementIconClicked
                              ? iconColor.withOpacity(0.5)
                              : iconColor,
                          size: iconSize,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Transform.translate(
                      offset: orientation == StepoOrientation.horizontal
                          ? Offset(
                              _isIncrementIconClicked
                                  ? textIncrementAnimation.value
                                  : textDecrementAnimation.value,
                              0,
                            )
                          : Offset(
                              0,
                              _isIncrementIconClicked
                                  ? -textIncrementAnimation.value
                                  : textDecrementAnimation.value,
                            ),
                      child: Text(
                        _counter.toString(),
                        style: textStyle ??
                            TextStyle(
                              fontSize: fontSize,
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: orientation == StepoOrientation.horizontal
                        ? AlignmentDirectional.centerEnd
                        : AlignmentDirectional.topCenter,
                    child: Transform.translate(
                      offset: orientation == StepoOrientation.horizontal
                          ? Offset(incrementIconAnimation.value, 0)
                          : Offset(0, -incrementIconAnimation.value),
                      child: InkWell(
                        customBorder: CircleBorder(),
                        onTap: () async {
                          handleOnTap(Direction.increment);
                        },
                        child: Icon(
                          orientation == StepoOrientation.horizontal
                              ? Icons.chevron_right
                              : Icons.keyboard_arrow_up,
                          color: _isIncrementIconClicked
                              ? iconColor.withOpacity(0.5)
                              : iconColor,
                          size: iconSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void initProperties() {
    textStyle = widget.textStyle;
    orientation = widget.orientation ?? StepoOrientation.vertical;
    upperBound = widget.upperBound ?? 100;
    backgroundColor = widget.backgroundColor ?? Colors.white;
    textColor = widget.textColor ?? Colors.black54;
    iconColor = widget.iconColor ?? Colors.black54;
    textAnimationEndValue =
        widget.width == null ? 100.0 : (widget.width! * 1.5);
    _counter = widget.initialCounter ?? 1;
    lowerBound = widget.lowerBound ?? _counter;

    rootWidth = widget.width ??
        ((orientation == StepoOrientation.horizontal) ? 160 : 80);
    if (orientation == StepoOrientation.vertical) {
      rootHeight = rootWidth * 2;
    } else {
      rootHeight = rootWidth / 2;
    }
    cornerRadius = orientation == StepoOrientation.horizontal
        ? (rootWidth / 4)
        : (rootHeight / 4);
    textAnimationDuration =
        widget.animationDuration ?? Duration(milliseconds: 200);
    iconAnimationDuration = Duration(
      milliseconds: (textAnimationDuration.inMilliseconds / 2).floor(),
    );
    iconSize = orientation == StepoOrientation.horizontal
        ? rootWidth * 0.25
        : (rootHeight * 0.25);

    fontSize = orientation == StepoOrientation.horizontal
        ? (rootWidth / 5)
        : (rootHeight / 5);
    onIncrementClicked = widget.onIncrementClicked ?? (val) {};
    onDecrementClicked = widget.onDecrementClicked ?? (val) {};
  }

  void initBackgroundScaleAnimationController() {
    scaleAnimationController = getAnimationController(
      vsync: this,
      duration: scaleDuration,
    );
    scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.9).animate(scaleAnimationController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              scaleAnimationController.reverse();
            }
          })
          ..addListener(() {
            setState(() {});
          });
  }

  void initTextIncrementAnimationController() {
    textIncrementAnimationController = getAnimationController(
      vsync: this,
      duration: textAnimationDuration,
    );

    textIncrementAnimation = getAnimation(
      beginValue: 0.0,
      endValue: textAnimationEndValue,
      animationController: textIncrementAnimationController,
      direction: Direction.increment,
    );
  }

  void initTextDecrementAnimationController() {
    textDecrementAnimationController = getAnimationController(
      vsync: this,
      duration: textAnimationDuration,
    );

    textDecrementAnimation = getAnimation(
      beginValue: 0,
      endValue: textAnimationEndValue,
      animationController: textDecrementAnimationController,
      direction: Direction.decrement,
    );
  }

  void initIncrementIconAnimationController() {
    incrementIconAnimationController = getAnimationController(
      vsync: this,
      duration: iconAnimationDuration,
    );

    incrementIconAnimation = getAnimation(
      beginValue: 0.0,
      endValue: textAnimationEndValue / 2,
      animationController: incrementIconAnimationController,
      direction: Direction.increment,
    );
  }

  void initDecrementIconAnimationController() {
    decrementIconAnimationController = getAnimationController(
      vsync: this,
      duration: iconAnimationDuration,
    );

    decrementIconAnimation = getAnimation(
      beginValue: 0.0,
      endValue: textAnimationEndValue / 2,
      animationController: decrementIconAnimationController,
      direction: Direction.decrement,
    );
  }

  AnimationController getAnimationController({
    required TickerProvider vsync,
    required Duration duration,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: duration,
    );
  }

  Animation<double> getAnimation({
    required double beginValue,
    required double endValue,
    required AnimationController animationController,
    required Direction direction,
  }) {
    if (orientation == StepoOrientation.horizontal) {
      endValue = direction == Direction.increment ? endValue : -endValue;
    }

    return Tween<double>(begin: beginValue, end: endValue)
        .animate(animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  void handleOnTap(Direction direction) {
    if (direction == Direction.increment) {
      handleIncrementAnimation();
    } else {
      handleDecrementAnimation();
    }
  }

  void handleIncrementAnimation() async {
    _isIncrementIconClicked = true;
    scaleAnimationController.forward();
    incrementIconAnimationController.forward();
    await Future.delayed(iconAnimationDuration);
    textIncrementAnimationController.forward();
    await Future.delayed(textAnimationDuration);

    incrementCounter();

    textIncrementAnimationController.reverse();
    await Future.delayed(iconAnimationDuration);
    incrementIconAnimationController.reverse();

    await Future.delayed(iconAnimationDuration);

    this.setState(() {
      _isIncrementIconClicked = false;
    });
    onIncrementClicked(_counter);
  }

  void handleDecrementAnimation() async {
    _isDecrementIconClicked = true;
    scaleAnimationController.forward();
    decrementIconAnimationController.forward();
    await Future.delayed(iconAnimationDuration);
    textDecrementAnimationController.forward();
    await Future.delayed(textAnimationDuration);

    decrementCounter();

    textDecrementAnimationController.reverse();
    await Future.delayed(iconAnimationDuration);
    decrementIconAnimationController.reverse();

    await Future.delayed(iconAnimationDuration);

    this.setState(() {
      _isDecrementIconClicked = false;
    });
    onDecrementClicked(_counter);
  }

  void incrementCounter() {
    setState(() {
      if (_counter < upperBound) {
        _counter++;
      }
    });
  }

  void decrementCounter() {
    setState(() {
      if (_counter > lowerBound) {
        _counter--;
      }
    });
  }
}

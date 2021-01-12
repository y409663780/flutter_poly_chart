import 'package:flutter/material.dart';
import 'package:poly_line_demo/chart/wx_poly_chart_painter.dart';
import 'package:poly_line_demo/data/wx_line_entity.dart';

import '../utils/date_format_util.dart';

class TimeFormat {
  static const List<String> YEAR_MONTH_DAY = [yyyy, '-', mm, '-', dd];
  static const List<String> YEAR_MONTH_DAY_WITH_HOUR = [
    yyyy,
    '-',
    mm,
    '-',
    dd,
    ' ',
    HH,
    ':',
    nn
  ];
}

class WXPolyChartWidget extends StatefulWidget {
  final List<WXLineEntity> datas;

  /// 背景渐变色集合
  final List<Color> bgColor;

  /// 滑动动画时间
  final int flingTime;

  /// 滑动比例
  final double flingRatio;

  /// 滑动curve动画
  final Curve flingCurve;

  /// 是否在拖动
  final Function(bool) isOnDrag;

  ///当屏幕滚动到尽头会调用，true为拉到屏幕右侧尽头，false为拉到屏幕左侧尽头
  final Function(bool) onLoadMore;

  /// 时间集合
  final List<String> timeFormat;

  WXPolyChartWidget(
      {this.datas,
      this.bgColor,
      this.flingTime = 600,
      this.flingRatio = 0.5,
      this.flingCurve = Curves.decelerate,
      this.isOnDrag,
      this.timeFormat = TimeFormat.YEAR_MONTH_DAY_WITH_HOUR,
      this.onLoadMore})
      : assert(datas.isNotEmpty);

  @override
  _WXPolyChartWidgetState createState() => _WXPolyChartWidgetState();
}

class _WXPolyChartWidgetState extends State<WXPolyChartWidget> with TickerProviderStateMixin {
  /// 屏幕宽度
  double mWidth = 0;

  /// X轴触摸坐标
  double mSelectX = 0.0;

  /// X轴缩放比例
  double mScaleX = 1.0;

  /// X轴滚动距离
  double mScrollX = 0.0;

  /// 动画
  AnimationController _controller;
  Animation<double> _animationX;

  double _lastScale = 1.0;

  bool isScale = false;

  /// 是否长按
  bool isLongPress = false;

  bool isDrag = false;

  bool isInit = false;

  @override
  void initState() {
    super.initState();
    isInit = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mWidth = MediaQuery.of(context).size.width;
    mSelectX = mWidth - 100;
  }

  /// 停止动画
  void _stopAnimation({bool needNotify = true}) {
    if (_controller != null && _controller.isAnimating) {
      _controller.stop();
      _onDragChanged(false);
      if (needNotify) {
        notifyChanged();
      }
    }
  }

  /// 拖动监听
  void _onDragChanged(bool isOnDrag) {
    isInit = false;
    isDrag = isOnDrag;
    if (widget.isOnDrag != null) {
      widget.isOnDrag(isDrag);
    }
  }

  void _onFling(double x) {
    isInit = false;
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: widget.flingTime));
    _animationX = null;
    _animationX = Tween<double>(begin: mScrollX, end: x * widget.flingRatio + mScrollX)
        .animate(CurvedAnimation(parent: _controller, curve: widget.flingCurve));
    _animationX.addListener(() {
      mScrollX = _animationX.value;
      if (mScrollX <= 0) {
        ///到达最右侧
        mScrollX = 0;
        if (widget.onLoadMore != null) {
          widget.onLoadMore(true);
        }
        _stopAnimation();
      } else if (mScrollX >= WXChartPainter.maxScrollX) {
        /// 到达最左侧
        mScrollX = WXChartPainter.maxScrollX;
        if (widget.onLoadMore != null) {
          widget.onLoadMore(false);
        }
        _stopAnimation();
      }
      notifyChanged();
    });
    _animationX.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        _onDragChanged(false);
        notifyChanged();
      }
    });
    _controller.forward();
  }

  void notifyChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    if (widget.datas == null || widget.datas.isEmpty) {
      mScrollX = 0.0;
      mSelectX = 0.0;
      mScaleX = 1.0;
    }
    return GestureDetector(
        onHorizontalDragDown: (down) {
          isInit = false;
          if (isLongPress) {
            isLongPress = false;
            return;
          }
          _stopAnimation();
          _onDragChanged(true);
        },
        onHorizontalDragUpdate: (update) {
          if (isScale || isLongPress) return;
          mScrollX = (update.primaryDelta / mScaleX + mScrollX).clamp(0.0, WXChartPainter.maxScrollX);
          notifyChanged();
        },
        onHorizontalDragEnd: (end) {
          var velocity = end.velocity.pixelsPerSecond.dx;
          _onFling(velocity);
        },
        onHorizontalDragCancel: () {
          _onDragChanged(false);
        },
        onLongPressStart: (start) {
          isInit = false;
          isLongPress = true;
          if (mSelectX != start.globalPosition.dx) {
            mSelectX = start.globalPosition.dx;
            notifyChanged();
          }
        },
        onLongPressMoveUpdate: (update) {
          if (mSelectX != update.globalPosition.dx) {
            mSelectX = update.globalPosition.dx;
            notifyChanged();
          }
        },
        onLongPressEnd: (end) {
          isLongPress = false;
          notifyChanged();
        },
        onTap: () {
          isInit = false;
          isLongPress = false;
          notifyChanged();
        },
        onScaleStart: (_) {
          isInit = false;
          isScale = true;
        },
        onScaleUpdate: (details) {
          if (isDrag || isLongPress) return;
          mScaleX = (_lastScale * details.scale).clamp(0.5, 2.2);
          notifyChanged();
        },
        onScaleEnd: (_) {
          isScale = false;
          _lastScale = mScaleX;
        },
        child: Stack(
          children: <Widget>[
            CustomPaint(
              size: Size(double.infinity, double.infinity),
              painter: WXChartPainter(
                datas: widget.datas,
                scaleX: mScaleX,
                scrollX: mScrollX,
                isLongPress: isLongPress,
                selectX: mSelectX,
                isInit: isInit,
                isOnDrag: isDrag
              ),
            ),
          ],
        ));
  }
}

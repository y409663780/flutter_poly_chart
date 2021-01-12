import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poly_line_demo/data/wx_line_entity.dart';


abstract class BaseChartPainter extends CustomPainter {
  static double maxScrollX = 0.0;
  List<WXLineEntity> datas;
  double scaleX = 1.0, scrollX = 0.0, selectX = 0.0;

  bool isLongPress = false;

  /// 主区域
  Rect mMainRect;

  /// 展示区域宽高
  double mDisplayHeight, mDisplayWidth;

  /// 上下间距
  double mTopPadding = 100.0, mBottomPadding = 20.0, mChildPadding = 12.0;
  /// 起点，终点位置
  int mStartIndex = 0, mStopIndex = 0;
  double mMainMaxValue = double.minPositive, mMainMinValue = double.maxFinite;

  double mTranslateX = double.minPositive;
  int mMainMaxIndex = 0, mMainMinIndex = 0;

  double mMainHighMaxValue = double.minPositive, mMainLowMinValue = double.maxFinite;
  int mItemCount = 0;
  double mDataLength = 0.0;

  double mPointWidth = 11.0;

  BaseChartPainter({
    @required this.datas,
    @required this.scaleX,
    @required this.scrollX,
    @required this.isLongPress,
    @required this.selectX,
  }) {
    mItemCount = datas?.length ?? 0;
    mDataLength = mItemCount * mPointWidth;
  }

  void initRect(Size size) {
    double mainHeight = mDisplayHeight;
    mMainRect = Rect.fromLTRB(0, mTopPadding, mDisplayWidth, mTopPadding + mainHeight);
  }

  calculateValue() {
    if (datas == null || datas.isEmpty) return;
    maxScrollX = getMinTranslateX().abs();
    setTranslateXFromScrollX(scrollX);
    mStartIndex = indexOfTranslateX(xToTranslateX(0));
    mStopIndex = indexOfTranslateX(xToTranslateX(mDisplayWidth));
    for (int i = mStartIndex; i <= mStopIndex; i++) {
      var item = datas[i];
      getMainMaxMinValue(item, i);
    }
  }

  /// 获取主视图最大与最小值
  void getMainMaxMinValue(WXLineEntity item, int i) {
    mMainMaxValue = max(mMainMaxValue, item.amount);
    mMainMinValue = min(mMainMinValue, item.amount);
  }

  ///根据索引索取x坐标,translateX
  ///@param position 索引值
  double getX(int position) => position * mPointWidth + mPointWidth / 2;

  /// x坐标转换为 TranslateX
  double xToTranslateX(double x) => -mTranslateX + x / scaleX;

  /// translateX 转换为 屏幕X坐标
  double translateXtoX(double translateX) => (translateX + mTranslateX) * scaleX;

  /// 开始二分查找当前值的index
  int indexOfTranslateX(double translateX) {
    return _indexOfTranslateX(translateX, 0, mItemCount - 1);
  }

  int _indexOfTranslateX(double translateX, int start, int end) {
    if (end == start || end == -1) return start;
    if (end - start == 1) {
      double startValue = getX(start);
      double endValue = getX(end);
      return (translateX - startValue).abs() < (translateX - endValue).abs() ? start : end;
    }

    int mid = start + (end - start) ~/ 2;
    double midValue = getX(mid);
    if (translateX < midValue) {
      return _indexOfTranslateX(translateX, start, mid);
    } else if (translateX > midValue) {
      return _indexOfTranslateX(translateX, mid, end);
    } else {
      return mid;
    }
  }

  /// 获取平移最小值
  double getMinTranslateX() {
    var x = -mDataLength + mDisplayWidth / scaleX - mPointWidth / 2;
    return x >= 0 ? 0.0 : x;
  }

  /// scrollX 转换为 TranslateX
  void setTranslateXFromScrollX(double scrollX) {
    /// 移动后的X坐标
    mTranslateX = scrollX + getMinTranslateX();
  }

  @override
  void paint(Canvas canvas, Size size) {
    mDisplayHeight = size.height - mTopPadding - mBottomPadding;
    mDisplayWidth = size.width;
    initRect(size);
    calculateValue();
    initChartRenderer();

    canvas.save();
    canvas.scale(1, 1);
    drawBg(canvas, size);

    if (datas != null && datas.isNotEmpty) {
      drawChart(canvas, size);
      drawLineAmountText(canvas, size);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void initChartRenderer();

  ///画背景
  void drawBg(Canvas canvas, Size size);

  ///画图表
  void drawChart(Canvas canvas, Size size);

  ///当前金额
  void drawLineAmountText(Canvas canvas, Size size);
}

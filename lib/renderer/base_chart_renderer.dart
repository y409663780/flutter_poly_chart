import 'dart:ui';

import 'package:flutter/material.dart';

abstract class BaseChartRenderer<T> {
  ///返回数据中的最大与最小值
  double maxValue, minValue;

  /// Y轴缩放比例
  double scaleY;

  /// 顶部padding
  double topPadding;

  /// K线图区域
  Rect chartRect;

  BaseChartRenderer({
    @required this.chartRect,
    @required this.maxValue,
    @required this.minValue,
    @required this.topPadding,
  }) {
    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }
    scaleY = chartRect.height / (maxValue - minValue);
  }

  /// 获取Y轴坐标
  double getY(double y) => (maxValue - y) * scaleY + chartRect.top;

  String format(double n) {
    if (n == null || n.isNaN) {
      return "0.00";
    }
    return n.toStringAsFixed(2);
  }

  /// 画图表
  void drawChart(T lastPoint, T curPoint, double lastX, double curX, Size size,
      Canvas canvas);
}

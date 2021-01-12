import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:poly_line_demo/data/wx_line_entity.dart';

import 'base_chart_renderer.dart';

class MainRenderer extends BaseChartRenderer<WXLineEntity> {
  /// 绘制的内容区域
  Rect _contentRect;
  double _contentPadding = 5.0;

  ///折线图部分
  Shader mLineFillShader;
  Path mLinePath, mLineFillPath;
  Paint mLinePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..color = Colors.blue;

  Paint mLineFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  MainRenderer(
    Rect mainRect,
    double maxValue,
    double minValue,
    double topPadding,
  ) : super(
          chartRect: mainRect,
          maxValue: maxValue,
          minValue: minValue,
          topPadding: topPadding,
        ) {
    _contentRect = Rect.fromLTRB(
        chartRect.left, chartRect.top + _contentPadding, chartRect.right, chartRect.bottom - _contentPadding);
    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }
    scaleY = _contentRect.height / (maxValue - minValue);
  }

  @override
  void drawChart(WXLineEntity lastPoint, WXLineEntity curPoint, double lastX, double curX, Size size, Canvas canvas) {
    drawPolyLine(lastPoint.amount, curPoint.amount, canvas, lastX, curX);
  }

  ///画折线图
  void drawPolyLine(double lastPrice, double curPrice, Canvas canvas, double lastX, double curX) {
    mLinePath ??= Path();
    if (lastX == curX) {
      lastX = 0;
    }
    mLinePath.moveTo(lastX, getY(lastPrice));
    mLinePath.cubicTo((lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));

    /// 阴影
    mLineFillShader ??= LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: <Color>[Color(0x334C86CD), Colors.transparent],
      ).createShader(Rect.fromLTRB(chartRect.left, chartRect.top, chartRect.right, chartRect.bottom));
    mLineFillPaint..shader = mLineFillShader;

    mLineFillPaint.color = Colors.white;
    mLineFillPath ??= Path();

    mLineFillPath.moveTo(lastX, chartRect.height + chartRect.top);
    mLineFillPath.lineTo(lastX, getY(lastPrice));
    mLineFillPath.cubicTo(
        (lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
    mLineFillPath.lineTo(curX, chartRect.height + chartRect.top);
    mLineFillPath.close();

    canvas.drawPath(mLineFillPath, mLineFillPaint);
    mLineFillPath.reset();

    canvas.drawPath(mLinePath, mLinePaint);
    mLinePath.reset();
  }

  @override
  double getY(double y) => (maxValue - y) * scaleY + chartRect.top;
}

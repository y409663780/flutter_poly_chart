import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:poly_line_demo/data/wx_line_entity.dart';

import 'base_chart_painter.dart';
import '../renderer/base_chart_renderer.dart';
import '../renderer/main_renderer.dart';

const Color defaultTextColor = Color(0xff60738E);

class WXChartPainter extends BaseChartPainter {
  static get maxScrollX => BaseChartPainter.maxScrollX;

  BaseChartRenderer mMainRenderer;

  Color upColor, dnColor;

  List<Color> bgColor;

  int fixedLength;

  List<String> timeFormat;

  bool isInit;

  /// 是否在拖动
  bool isOnDrag;

  double open = 0.0;
  double close = 0.0;

  WXChartPainter(
      {@required datas,
      @required scaleX,
      @required scrollX,
      @required isLongPress,
      @required selectX,
      this.fixedLength,
      this.isInit,
      this.bgColor,
      this.isOnDrag})
      : assert(bgColor == null || bgColor.length >= 2),
        super(
          datas: datas,
          scaleX: scaleX,
          scrollX: scrollX,
          isLongPress: isLongPress,
          selectX: selectX,
        );

  @override
  void drawBg(Canvas canvas, Size size) {
    Paint mBgPaint = Paint();
    Gradient mBgGradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: bgColor ?? [Color(0xCCFFFFFF), Color(0xCCFFFFFF)]);
    if (mMainRect != null) {
      /// 绘制主区域
      Rect mainRect = Rect.fromLTRB(0, 0, mMainRect.width, mMainRect.height + mTopPadding);
      canvas.drawRect(mainRect, mBgPaint..shader = mBgGradient.createShader(mainRect));
    }
  }

  @override
  void drawChart(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(mTranslateX * scaleX, 0.0);
    canvas.scale(scaleX, 1.0);
    for (int i = mStartIndex; datas != null && i <= mStopIndex; i++) {
      WXLineEntity curPoint = datas[i];
      if (curPoint == null) continue;
      WXLineEntity lastPoint = i == 0 ? curPoint : datas[i - 1];
      double curX = getX(i);
      double lastX = i == 0 ? curX : getX(i - 1);
      /// 绘制图表
      mMainRenderer?.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
    }

    /// 支持长按显现线上圆点
    drawLineCircle(canvas, size);
    canvas.restore();
  }

  /// 画当前对应坐标的圆点
  void drawLineCircle(Canvas canvas, Size size) {
    int index = calculateSelectedX(selectX);
    WXLineEntity point = getItem(index);

    Paint paintY = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    double x = getX(index);
    double y = getMainY(point.amount);

    Paint paintX = Paint()
      ..color = Colors.blue
      ..strokeWidth = 0.5
      ..isAntiAlias = true;

    Paint paintZ = Paint()
      ..color = Colors.grey[200]
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawCircle(Offset(x, y), 12.0, paintY);
    canvas.drawCircle(Offset(x, y), 12.0, paintZ);
    canvas.drawCircle(Offset(x, y), 5.0, paintX);
  }

  @override
  void drawLineAmountText(Canvas canvas, Size size) {
    int index = calculateSelectedX(selectX);
    WXLineEntity data = getItem(index);

    /// 时间
    String date = data.time;
    /// 绘制当前金额
    String amount = data.amount.toStringAsFixed(2);
    List<String> amountSplit = amount.split(".");

    TextPainter tp1 = getTextPainter(amountSplit[0], color: Colors.black, fontSize: 30.0);

    double x1 = 20;
    double y1 = 40;
    tp1.paint(canvas, Offset(x1, y1));

    TextPainter tp2 = getTextPainter(".${amountSplit[1]}\$", color: Colors.black, fontSize: 20.0);
    double x2 = 20 + tp1.width;
    double y2 = 40;
    tp2.paint(canvas, Offset(x2, y2));

    /// 百分比坐标
    double percentX = mDisplayWidth - 100;
    double percentY = 50;

    /// 绘制时间
    TextPainter tpTime;

    /// 绘制百分比
    TextPainter percentTp;
    if (!isInit && !isLongPress) {
      if (isOnDrag) {
        percentTp = getTextPainter("", color: Colors.green, fontSize: 20.0);
        tpTime = getTextPainter(date, color: Colors.grey[600], fontSize: 16.0);
      } else {
        tpTime = getTextPainter("Total Value", color: Colors.grey[600], fontSize: 16.0);
        percentTp = getTextPainter("+ 4.21%", color: Colors.green, fontSize: 20.0);
      }
    } else {
      tpTime = getTextPainter(date, color: Colors.grey[600], fontSize: 16.0);
      percentTp = getTextPainter("", color: Colors.green, fontSize: 20.0);
    }
    percentTp.paint(canvas, Offset(percentX, percentY));
    tpTime.paint(canvas, Offset(x1, y1 - 25));
  }

  /// 文字风格
  TextStyle getTextStyle(Color color, {double fontSize = 20.0}) {
    return TextStyle(fontSize: fontSize, color: color, fontWeight: FontWeight.bold);
  }

  /// 获取TextPainter对象
  TextPainter getTextPainter(text, {Color color = defaultTextColor, double fontSize = 20.0}) {
    TextSpan span = TextSpan(text: "$text", style: getTextStyle(color, fontSize: fontSize));
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    return tp;
  }

  @override
  void initChartRenderer() {
    fixedLength = 2;
    mMainRenderer ??= MainRenderer(mMainRect, mMainMaxValue, mMainMinValue, mTopPadding);
  }

  /// 计算长按后x的值，转换为index
  int calculateSelectedX(double selectX) {
    int mSelectedIndex = indexOfTranslateX(xToTranslateX(selectX));
    if (mSelectedIndex < mStartIndex) {
      mSelectedIndex = mStartIndex;
    }
    if (mSelectedIndex > mStopIndex) {
      mSelectedIndex = mStopIndex;
    }
    return mSelectedIndex;
  }

  /// 获取指定位置的数据
  Object getItem(int position) {
    if (datas != null) {
      return datas[position];
    } else {
      return null;
    }
  }

  /// 主视图的数据Y坐标
  double getMainY(double y) => mMainRenderer?.getY(y) ?? 0.0;
}

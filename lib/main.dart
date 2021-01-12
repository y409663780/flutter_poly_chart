import 'package:flutter/material.dart';
import 'package:poly_line_demo/chart/wx_poly_chart.dart';

import 'data/wx_line_datas.dart';
import 'data/wx_line_entity.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<WXLineEntity> datas = List();

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            child: WXPolyChartWidget(
              datas: datas,
            ),
          )
        ],
      ),
    );
  }

  void getData() {
    List list = WXLineData.data;
    list.forEach((element) {
      datas.add(WXLineEntity.fromJson(element as List));
    });
  }
}

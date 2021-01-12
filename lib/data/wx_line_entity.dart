class WXLineEntity {
  String time;
  double amount;

  WXLineEntity.fromJson(List<dynamic> list) {
    time = list[0];
    amount = double.parse(list[1].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time;
    data['amount'] = this.amount;
    return data;
  }

  @override
  String toString() {
    return 'MarketModel{time: $time, close: $amount}';
  }
}

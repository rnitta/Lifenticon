import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Identicon Game of Life',
      theme: ThemeData.dark(),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Home> {
  static int gN = 49;
  Color _bC = Color.fromRGBO(240, 240, 240, 1.0);
  bool _isA = false;
  bool _sEN = false;
  String _seed;
  Color _cC;
  List<int> _digest;
  List<bool> _field = List.filled(gN, false);
  Timer _timer;
  int _age;
  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 667)..init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Identicon Automaton'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(70)),
              child: TextField(enabled: !_isA, onChanged: _cT, autocorrect: false, decoration: InputDecoration(hintText: 'Type something'))),
            Padding(
              padding: EdgeInsets.all(30),
              child: _identiconGrid()),
            RaisedButton(
              padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
              color: _isA ? Colors.grey : Colors.cyan,
              onPressed: () {
                if (_isA) { _endLife(); _cT(_seed); return; }
                setState(() { _isA = true; });
                _timer = Timer.periodic(Duration(milliseconds: 700), (timer) { _evlove(_field); });
              },
              child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Icon(_isA ? Icons.stop : Icons.play_arrow),
                Text(_isA ? "Stop" : "Play")
              ]))
          ],
        ),
      ),
    );
  }

  void _cT(String s) {
    setState(() {
      _age = 0; _seed = s; _digest = md5.convert(utf8.encode(s)).bytes;
      _cC = _color(_digest); _bC = Color((0x1ff << 24) - _cC.value); _field = _buildField(_digest);
    });
  }

  List<bool> _buildField(List<int> dig) {
    final f = List<bool>.filled(gN, false);
    final List<bool> pt = dig
        .fold<List<int>>([], (acc, cur) => acc..add(cur ~/ 16)..add(cur & 15))
        .map<bool>((i) => (i % 2) == 0)
        .toList();
    int i = 0;
    for (int c = 3; c >= 1; c--) {
      for (int r = 1; r < 6; r++) {
        f[r * 7 + c] = pt[i];
        f[r * 7 + 6 - c] = pt[i];
        i++;
      }
    }
    _age = 0;
    return f;
  }

  Future<void> _evlove(List<bool> f) {
    final nf = List<bool>.filled(gN, false);
    f.asMap().forEach((i, v) {
      final j = (int p) => (i - p >= 0 && i - p <= gN - 1 && f[i - p]);
      final c = [8, 7, 6, 1, -1, -6, -7, -8].map((p) => j(p)).where(((b) => b)).length;
      nf[i] = c < 2 ? false : c == 2 ? f[i] : c == 3 ? !f[i] : false;
    });
    setState(() { _age++; _field = nf; });
    if (_sEN) {
      _endLife();
      _sEN = false;
    } else {
      if (nf.every((v) => !v) || _age > 29) { _sEN = true; }
    }
  }

  double _map(int value, int vmin, int vmax, int dmin, int dmax) => ((value - vmin) * (dmax - dmin)) / ((vmax - vmin) + dmin);

  Color _color(List<int> dig) {
    final double hue = _map((((dig[12] & 0xf) << 8) | dig[13]), 0, 0xfff, 0, 360);
    final double sat = (65 - _map(dig[14], 0, 0xff, 0, 20)) / 100;
    final double lig = (75 - _map(dig[15], 0, 0xff, 0, 20)) / 100;
    return HSLColor.fromAHSL(1.0, hue, sat, lig).toColor();
  }

  void _endLife() {
    _timer.cancel();
    setState(() {
      _isA = false;
    });
    final b = _age > 29;
    final s = '${_age - 1}${b ? '+' : ''}';
    showDialog(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: Text(b ? "Congraturations!" : "End of Life..."),
        content: Text("You survived $s turns."),
        actions: <Widget>[FlatButton(child: const Text("R.I.P."), onPressed: () { Navigator.pop(c); _cT(_seed); })],
        ),
    ).then<void>((_) {});
  }

  Widget _identiconGrid() {
    return Center(
      child: Container(
        width: ScreenUtil().setWidth(210), height: ScreenUtil().setWidth(210),
        child: Container(
          padding: EdgeInsets.all(0),
          color: _bC,
          child: GridView.count(
            shrinkWrap: true,
            primary: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            children: List<Widget>.generate(gN, (i) => Container(color: _field[i] ? _cC : _bC))
          ))));
  }
}

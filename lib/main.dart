import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(MaterialApp(
    title: "it's Your Time",
    theme: ThemeData(
      canvasColor: Colors.blueGrey,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      accentColor: Colors.pinkAccent,
      brightness: Brightness.dark,
    ),
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  AnimationController controller;

  final TextEditingController minuteController = TextEditingController();
  final TextEditingController secondController = TextEditingController();

  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    updateTimmer(sec: 30);
  }

  void updateTimmer({int min = 0, int sec = 0}) {
    controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: min, seconds: sec),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: FractionalOffset.center,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedBuilder(
                            animation: controller,
                            builder: (BuildContext context, Widget child) {
                              return new CustomPaint(
                                painter: TimerPainter(
                                  animation: controller,
                                  backgroundColor: Colors.white,
                                  color: themeData.indicatorColor,
                                ),
                              );
                            }),
                      ),
                      Align(
                        alignment: FractionalOffset.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // SizedBox(
                            //   height: 120,
                            // ),
                            Text("Count Down",
                                style: themeData.textTheme.subtitle1),
                            AnimatedBuilder(
                                animation: controller,
                                builder: (BuildContext context, Widget child) {
                                  return Text(
                                    timerString,
                                    style: themeData.textTheme.headline1,
                                  );
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      print('${controller.value}');

                      setState(() {});
                      if (controller.isAnimating) {
                        controller.stop();
                        print("a");
                      } else {
                        controller.reverse(
                            from: controller.value == 0.0
                                ? 1.0
                                : controller.value);
                        print("b");
                      }
                    },
                    child: AnimatedBuilder(
                        animation: controller,
                        builder: (BuildContext context, Widget child) {
                          return Icon(controller.isAnimating
                              ? Icons.pause
                              : Icons.play_arrow);
                        }),
                  ),
                  FloatingActionButton(
                      onPressed: () {
                        if (controller.isAnimating) {
                          controller.reverse(from: 1);
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              minuteController.text = '';
                              secondController.text = '';
                              return Dialog(
                                child: Container(
                                  padding: EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        keyboardType:
                                            TextInputType.numberWithOptions(),
                                        maxLength: 2,
                                        controller: minuteController,
                                        decoration: InputDecoration(
                                          hintText: "Enter Minutes",
                                          labelText: "Minutes",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      TextField(
                                        controller: secondController,
                                        keyboardType:
                                            TextInputType.numberWithOptions(),
                                        maxLength: 2,
                                        decoration: InputDecoration(
                                          hintText: "Enter Seconds",
                                          labelText: "Seconds",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      RaisedButton(
                                        padding: EdgeInsets.all(0),
                                        color: Colors.black,
                                        onPressed: () {
                                          if (secondController.text
                                                  .compareTo("") ==
                                              0) {
                                            secondController.text = '0';
                                          }
                                          if (minuteController.text
                                                  .compareTo("") ==
                                              0) {
                                            minuteController.text = '0';
                                          }
                                          final int minutes =
                                              int.parse(minuteController.text);
                                          final int seconds =
                                              int.parse(secondController.text);
                                          if ((minutes >= 0 && minutes < 59) &&
                                              (seconds >= 0 && seconds < 60)) {
                                            updateTimmer(
                                                min: minutes, sec: seconds);
                                            controller.value = 1;
                                            setState(() {});

                                            Navigator.pop(context);
                                            //controller.reverse(from:1);

                                          } else {
                                            Navigator.pop(context);
                                            SnackBar mySnackBar = SnackBar(
                                              content: Text(
                                                  "invalid Input\nminutes allowed :0 to 59\nseconds allowed:0 to 59"),
                                              duration: Duration(seconds: 3),
                                            );
                                            _scaffoldKey.currentState
                                                .showSnackBar(
                                                    mySnackBar); //calling snacBar
                                          }
                                        },
                                        child: Text(
                                          "SUBMIT",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                      child: AnimatedBuilder(
                          animation: controller,
                          builder: (context, child) {
                            return Icon(controller.isAnimating
                                ? Icons.refresh
                                : Icons.reply);
                          })),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final Animation<double> animation;
  final backgroundColor, color;
  TimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
    paint.color = color; //using a different color
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}

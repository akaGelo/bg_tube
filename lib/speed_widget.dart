import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SpeedWidget extends StatefulWidget {
  double rate;

  SpeedWidget(this.rate, {Key? key}) : super(key: key);

  @override
  SpeedWidgetState createState() => SpeedWidgetState();
}

class SpeedWidgetState extends State<SpeedWidget> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // FocusScope.of(context).requestFocus(FocusNode());
        Navigator.of(context).pop(widget.rate);
        return false;
      },
      child: Container(
        height: 150,
        color: Colors.black12,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Скорость: " + widget.rate.toStringAsFixed(2)),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("-3"),
                    Text("0"),
                    Text("+3"),
                  ],
                ),
              ),
              Slider(
                min: -3,
                max: 4,
                value: widget.rate,
                onChanged: (value) {
                  setState(() {
                    widget.rate = value;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

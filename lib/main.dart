import 'package:flutter/material.dart';
import 'package:mlapp/screens/prediction_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heatstroke Cases Predictor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PredictionScreen(),
    );
  }
}


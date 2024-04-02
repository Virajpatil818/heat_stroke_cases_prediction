import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'widgets/my_button.dart';
import 'widgets/my_textfield.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heatstroke Predictor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PredictionScreen(),
    );
  }
}

class PredictionScreen extends StatefulWidget {
  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {

  final tempController = TextEditingController();
  final dewController = TextEditingController();
  final windController = TextEditingController();

  String temperature = '';
  String dewPoint = '';
  String windSpeed = '';
  String predictionResult = '';

  Future<void> _predictHeatstroke() async {
    try {
      setState(() {
        predictionResult = ''; // Reset predictionResult
      });

      const apiUrl = 'http://127.0.0.1:5000/predict'; // Replace with your Flask API URL

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'Dew_Point_dc': dewController.text,
          'Temperature_dc': tempController.text,
          'Wind_Speed_kph': windController.text,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final predictionDouble = double.tryParse(jsonResponse['prediction'].toString());
        if (predictionDouble != null) {
          final prediction = predictionDouble.toInt(); // Convert to integer
          setState(() {
            predictionResult = prediction.toString();
          });
        } else {
          setState(() {
            predictionResult = ''; // or any default value indicating an error
          });
        }
      } else {
        setState(() {
          predictionResult = ''; // or any default value indicating an error
        });
      }
    } catch (e) {
      setState(() {
        predictionResult = 'Error: $e';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heatstroke Predictor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MyTextField(
                controller: tempController,
                hintText: 'Temperature'
            ),
            const SizedBox(height: 20),
            MyTextField(
                controller: dewController,
                hintText: 'Dew Point'
            ),
            const SizedBox(height: 20),
            MyTextField(
                controller: windController,
                hintText: 'Wind Speed'
            ),
            const SizedBox(height: 20),
            MyButton(
              onTap: _predictHeatstroke,
              buttonText: 'Predict Heatstroke',
            ),
            const SizedBox(height: 20),
            Text(
              'Prediction Result: $predictionResult',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'This app predicts heatstroke cases based on selected date.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

import '../widgets/my_button.dart';
import '../widgets/my_textfield.dart';

class PredictionScreen extends StatefulWidget {
  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final tempController = TextEditingController();
  final dewController = TextEditingController();
  final windController = TextEditingController();

  String predictionResult = '';

  Future<void> _predictHeatstroke() async {
    try {
      setState(() {
        predictionResult = ''; // Reset predictionResult
      });

      const apiUrlCatBoost = 'http://127.0.0.1:5000/predict_catboost';
      const apiUrlXGBoost = 'http://127.0.0.1:5000/predict_xgboost';

      final responseCatBoost = await http.post(
        Uri.parse(apiUrlCatBoost),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'Dew_Point_dc': dewController.text,
          'Temperature_dc': tempController.text,
          'Wind_Speed_kph': windController.text,
        }),
      );

      final responseXGBoost = await http.post(
        Uri.parse(apiUrlXGBoost),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'Dew_Point_dc': dewController.text,
          'Temperature_dc': tempController.text,
          'Wind_Speed_kph': windController.text,
        }),
      );

      if (responseCatBoost.statusCode == 200 && responseXGBoost.statusCode == 200) {
        final jsonResponseCatBoost = jsonDecode(responseCatBoost.body);
        final jsonResponseXGBoost = jsonDecode(responseXGBoost.body);

        setState(() {
          predictionResult = 'CatBoost Prediction: ${jsonResponseCatBoost['prediction']}, '
              'XGBoost Prediction: ${jsonResponseXGBoost['prediction']}';
        });
      } else {
        setState(() {
          predictionResult = 'Error fetching prediction';
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/heatwaves.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Temperature (°C) : "),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: tempController,
                      hintText: 'Enter Temperature',
                    ),
                    const SizedBox(height: 10),
                    const Text("Dew Point (°C) : "),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: dewController,
                      hintText: 'Enter Dew Point',
                    ),
                    const SizedBox(height: 10),
                    const Text("Wind Speed (kph) : "),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: windController,
                      hintText: 'Enter Wind Speed',
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      onTap: _predictHeatstroke,
                      buttonText: 'Predict Heatstroke',
                    ),
                    const SizedBox(height: 20),
                    Text(
                      predictionResult,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '* This app predicts heatstroke cases based on given parameters.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16,color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

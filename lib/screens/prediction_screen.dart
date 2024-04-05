import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
          // Check if prediction result is more than 3
          if (prediction > 3) {
            _showAlert();
          }
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

  // Function to show alert
  void _showAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: const Text('The prediction result is more than 3. Inform local hospitals.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                      'Prediction Result : $predictionResult',
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

import 'package:flutter/material.dart';
import 'package:flutter_sample/boardwidget.dart'; // Make sure BoardWidget is imported
import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool isOtpSent = false;
  String serverMessage = '';
  String? authToken; // To store the token received after OTP verification
  String? email;
  final String apiBaseUrl = "http://10.0.2.2:3000"; 

  Future<void> sendOtp() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        serverMessage = 'Please enter your email.';
      });
      return;
    }

    final response = await http.post(
      Uri.parse('$apiBaseUrl/forgotPassword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 201) {
      setState(() {
        isOtpSent = true;
        serverMessage = 'OTP sent successfully. Check your email.';
      });
    } else {
      setState(() {
        serverMessage = responseBody['msg'] ?? 'Failed to send OTP.';
      });
    }
  }

  Future<void> verifyOtp() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      setState(() {
        serverMessage = 'Please enter the OTP.';
      });
      return;
    }

    final response = await http.post(
      Uri.parse('$apiBaseUrl/verifyOtp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        serverMessage = 'OTP verified. You are logged in.';
        authToken = responseBody['token']; // Store the received token
      });

      // Ensure token is not null before navigating to the next screen
      if (authToken != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>  const BoardWidget(
            ),
          ),
        );
      }
    } else {
      setState(() {
        serverMessage = responseBody['msg'] ?? 'Failed to verify OTP.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
              ),
            ),
            if (isOtpSent)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    hintText: 'Enter the OTP',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isOtpSent ? verifyOtp : sendOtp,
              child: Text(isOtpSent ? 'Verify OTP' : 'Send OTP'),
            ), 
            const SizedBox(height: 16.0),
            if (serverMessage.isNotEmpty)
              Text(
                serverMessage,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:routex/Guests/guest_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _isEmailLogin = true; // Track the selected login option

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final driverDoc = await FirebaseFirestore.instance
              .collection('drivers')
              .doc(user.uid)
              .get();
          final guestDoc = await FirebaseFirestore.instance
              .collection('guests')
              .doc(user.uid)
              .get();

          if (driverDoc.exists) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (guestDoc.exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GuestHomeScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account type not recognized.')),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'user-not-found') {
            _errorMessage = tr('error_user_not_found');
          } else if (e.code == 'wrong-password') {
            _errorMessage = tr('error_wrong_password');
          } else {
            _errorMessage = e.message;
          }
        });
      }
    }
  }

  void _sendOtp() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length != 10) {
      setState(() {
        _errorMessage = tr('error_invalid_phone');
      });
      return;
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+1${_phoneController.text}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.pushReplacementNamed(context, '/dashboard');
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _errorMessage = e.message;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {});
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(tr('enter_otp')),
              content: TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: tr('otp')),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final credential = PhoneAuthProvider.credential(
                      verificationId: verificationId,
                      smsCode: _otpController.text,
                    );
                    try {
                      await FirebaseAuth.instance
                          .signInWithCredential(credential);
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    } catch (e) {
                      setState(() {
                        _errorMessage = tr('error_invalid_otp');
                      });
                    }
                  },
                  child: Text(tr('verify')),
                ),
              ],
            );
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 219, 235, 246), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'RouteX', // App name, keep as is or add to translations
                          style: TextStyle(
                            fontSize: 48,
                            fontFamily: 'GreatVibes',
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 90),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEmailLogin = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor:
                              _isEmailLogin ? Colors.blue : Colors.grey,
                        ),
                        child: const Icon(Icons.email, color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEmailLogin = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor:
                              !_isEmailLogin ? Colors.blue : Colors.grey,
                        ),
                        child: const Icon(Icons.phone, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_isEmailLogin) ...[
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: tr('email'),
                              labelStyle:
                                  const TextStyle(fontFamily: 'Poppins'),
                              fillColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon:
                                  const Icon(Icons.email, color: Colors.blue),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return tr('error_email_required');
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return tr('error_email_invalid');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: tr('password'),
                              labelStyle:
                                  const TextStyle(fontFamily: 'Poppins'),
                              fillColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.blue),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return tr('error_password_required');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/forgot-password');
                              },
                              child: Text(
                                tr('forgot_password'),
                                style: const TextStyle(
                                  color: Colors.lightBlue,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            decoration: InputDecoration(
                              labelText: tr('phone_number'),
                              labelStyle:
                                  const TextStyle(fontFamily: 'Poppins'),
                              fillColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon:
                                  const Icon(Icons.phone, color: Colors.blue),
                              counterText: '',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return tr('error_phone_required');
                              }
                              if (value.length != 10 ||
                                  !RegExp(r'^\d{10}$').hasMatch(value)) {
                                return tr('error_phone_invalid');
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isEmailLogin ? _login : _sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              tr('login'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text(
                      tr('signup_prompt'),
                      style: const TextStyle(
                        color: Colors.lightBlue,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

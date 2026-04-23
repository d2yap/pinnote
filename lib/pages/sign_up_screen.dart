import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pinnote/widgets/image_banner.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  final List<String> profilePicturePaths = [
    'assets/profile/dragon.gif',
    'assets/profile/duck.gif',
    'assets/profile/human.gif',
    'assets/profile/hyena.gif',
    'assets/profile/robot.gif',
    'assets/profile/cat.gif',
  ];

  String? selectedProfilePath;

  Future<void> createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedProfilePath == null) {
      setState(() {
        error = 'Please tap on a profile picture to continue';
      });
      return;
    }
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await result.user!.updateDisplayName(_usernameController.text.trim());

      // Setting the user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(result.user!.uid)
          .set({
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'profilePicturePath': selectedProfilePath,
            'pinUsage': 0,
            'lastPinDate': FieldValue.serverTimestamp(),
          });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageBanner(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Create',
                      style: TextStyle(
                        fontFamily: 'Clash',
                        fontSize: deviceWidth * 0.14,
                        fontWeight: FontWeight(800),
                      ),
                    ),
                    // Profile
                    SizedBox(
                      height: deviceWidth * 0.2,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: profilePicturePaths.length,
                        itemBuilder: (context, index) {
                          final path = profilePicturePaths[index];
                          final isSelected = selectedProfilePath == path;

                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedProfilePath = path),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 4.0,
                                top: 5.0,
                                bottom: 5.0,
                              ),
                              child: Container(
                                width: deviceWidth * 0.17,
                                height: deviceWidth * 0.5,
                                margin: EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? Color(0xFF149C21)
                                        : Color(0xFFFFFFFF),
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 1,
                                      spreadRadius: 2,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(path, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: deviceHeight * 0.04),

                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Username is required.";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: deviceHeight * 0.016),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email is required.";
                        }
                        //https://medium.com/@saurabhsinghaswal/how-to-validate-email-in-a-textformfield-in-flutter-b32539041fe9
                        const pattern =
                            r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
                            r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
                            r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
                            r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
                            r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
                            r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
                            r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
                        final regex = RegExp(pattern);

                        return value!.isNotEmpty && !regex.hasMatch(value)
                            ? 'Enter a valid email address'
                            : null;
                      },
                    ),

                    SizedBox(height: deviceHeight * 0.016),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Password is required.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: deviceHeight * 0.016),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Password is required.";
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    if (error != null) ...[
                      SizedBox(height: deviceHeight * 0.016),
                      Text(error!, style: TextStyle(color: Colors.red)),
                    ],

                    SizedBox(height: deviceHeight * 0.03),

                    SizedBox(
                      width: double.infinity,
                      height: deviceHeight * 0.07,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF61F6BE),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: Color(0xFF149C21),
                              width: 2,
                            ),
                          ),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator()
                            : Text(
                                'CREATE',
                                style: TextStyle(
                                  fontFamily: 'Clash',
                                  fontSize: deviceWidth * 0.09,
                                  fontWeight: FontWeight(700),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: deviceHeight * 0.016),

                    // create account
                    SizedBox(
                      width: double.infinity,
                      height: deviceHeight * 0.054,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/sign-in'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.black, width: 2),
                          ),
                        ),
                        child: Text(
                          'HAVE AN ACCOUNT? SIGN IN',
                          style: TextStyle(
                            fontFamily: 'Clash',
                            fontSize: deviceWidth * 0.049,
                            fontWeight: FontWeight(500),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: deviceHeight * 0.016),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Go back',
                        style: TextStyle(
                          fontFamily: 'Clash',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

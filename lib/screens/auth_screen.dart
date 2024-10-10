import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../custom_widgets/custom.dart';
import '../firebase/auth.dart';
import '../providers/providers.dart';
import '../utils/utils.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _nameController = TextEditingController(),
      _emailController = TextEditingController(),
      _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false,
      _isPasswordVisible = false,
      _isEmailLoading = false,
      _isGoogleLoading = false;
  final Auth _auth = Auth();

  void _toggleSignUp() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isEmailLoading = true;
    });

    try {
      User? user;
      if (_isSignUp) {
        user = await _auth.signUpWithEmailAndPassword(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        user = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      if (mounted) {
        ref.read(authProvider.notifier).setUser(user);
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showSnackBar(context, e.toString());
      }
    } finally {
      setState(() {
        _isEmailLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BackgroundContainer(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 50),
                      Center(
                        child: Image.asset(
                          Strings.appIcon,
                          height: 200,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const CustomText(
                        text: "Sign in",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const CustomText(
                        text: "to access to your account",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (_isSignUp)
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black26,
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                            hintText: 'Name',
                            hintStyle: GoogleFonts.poppins(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          validator: Strings.nameValidator,
                        ),
                      if (_isSignUp) const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black26,
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.white,
                            size: 30,
                          ),
                          hintText: 'Email',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: Strings.emailValidator,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black26,
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 30,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          hintText: 'Password',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: Strings.passwordValidator,
                      ),
                      const SizedBox(height: 20),
                      _isEmailLoading
                          ? const Center(child: CustomProgressBar())
                          : CustomButton(
                              icon: Strings.mail,
                              label: _isSignUp ? 'Sign Up' : 'Sign In',
                              color: Colors.blueGrey.shade900,
                              onPressed: _authenticate,
                            ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: _toggleSignUp,
                          child: CustomText(
                            text: _isSignUp
                                ? "Already have an account? Sign In"
                                : "Don't have an account? Sign Up",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: CustomText(
                          text: "Or Sign In With",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _isGoogleLoading
                          ? const Center(child: CustomProgressBar())
                          : CustomButton(
                              icon: Strings.google,
                              label: 'Google',
                              color: Colors.green.shade900,
                              onPressed: () {
                                setState(() {
                                  _isGoogleLoading = true;
                                });
                                Auth()
                                    .signInWithGoogle()
                                    .then((userCredential) {
                                  ref
                                      .read(authProvider.notifier)
                                      .setUser(userCredential?.user);
                                  if (context.mounted) {
                                    Navigator.pushReplacementNamed(
                                        context, '/main');
                                  }
                                }).catchError((e) {
                                  if (context.mounted) {
                                    CustomSnackBar.showSnackBar(
                                        context, e.toString());
                                  }
                                }).whenComplete(() {
                                  setState(() {
                                    _isGoogleLoading = false;
                                  });
                                });
                              },
                            ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

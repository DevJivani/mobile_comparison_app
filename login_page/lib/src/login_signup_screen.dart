import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'chat_screen.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isSignUp = false;
  bool isLoading = false;

  final Color primaryBlue = const Color(0xFF2196F3);
  final Color secondaryBlue = const Color(0xFF1976D2);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  Future<User?> signInWithGoogle() async {
  setState(() => isLoading = true);

  try {
    // For web platforms
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      
      try {
        final UserCredential userCredential = 
            await _auth.signInWithPopup(googleProvider);
            
        if (userCredential.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MobileListScreen()),
          );
        }
        
        return userCredential.user;
      } catch (e) {
        showToast('Sign in failed: ${e.toString()}');
        return null;
      }
    } 
    // For mobile platforms
    else {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        showToast('Sign in cancelled');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MobileListScreen()),
        );
      }

      return userCredential.user;
    }
  } catch (e) {
    debugPrint('Google sign-in error: $e');
    showToast('Sign in failed. Please try again.');
    return null;
  } finally {
    setState(() => isLoading = false);
  }
}
  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  Future<void> signUpWithEmailPassword() async {
    setState(() => isLoading = true);

    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        throw 'Please fill in both email and password';
      }

      if (!isValidEmail(_emailController.text)) {
        throw 'Please enter a valid email address';
      }

      if (_passwordController.text.length < 6) {
        throw 'Password must be at least 6 characters';
      }

      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MobileListScreen()),
      );
    } catch (e) {
      showAlert(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> logInWithEmailPassword() async {
    setState(() => isLoading = true);

    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        throw 'Please fill in both email and password';
      }

      if (!isValidEmail(_emailController.text)) {
        throw 'Please enter a valid email address';
      }

      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MobileListScreen()),
      );
    } on FirebaseAuthException catch (e) {
      showToast(e.message ?? 'Authentication failed');
    } catch (e) {
      showAlert(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryBlue,
        title: const Text('TechCompare Pro'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 250,
                      width: 350,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder: (child, animation) => RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0).animate(animation),
                      child: child,
                    ),
                    child: isSignUp ? buildSignUpForm() : buildLoginForm(),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => setState(() => isSignUp = !isSignUp),
                    child: Text(
                      isSignUp ? 'Already have an account? Login' : 'Don\'t have an account? Sign Up',
                      style: TextStyle(color: primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: signInWithGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const Text(
                    'By signing up, you agree to our Terms and Conditions',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email, color: primaryBlue),
            labelText: 'Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock, color: primaryBlue),
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: logInWithEmailPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Login', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget buildSignUpForm() {
    return Column(
      key: const ValueKey('signup'),
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email, color: primaryBlue),
            labelText: 'Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock, color: primaryBlue),
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: signUpWithEmailPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
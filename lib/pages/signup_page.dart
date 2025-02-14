import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:minimal_tweets_app/components/my_text_field.dart';
import 'package:minimal_tweets_app/services/auth/auth_service.dart';
class SignupPage extends StatefulWidget {
  final VoidCallback onTap;

  const SignupPage({super.key, required this.onTap});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final AuthService auth = AuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> signUp() async {
    if (passwordController.text == confirmPasswordController.text) {
      showDialog(
          context: context,
          builder: (context) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            );
          },
          barrierDismissible: false);

      try {
        await auth.signUpWithEmailAndPassword(
            nameController.text, emailController.text, passwordController.text);

        Navigator.of(context).pop();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Account created successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        Navigator.of(context).pop();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Passwords Do Not Match'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 8.0, bottom: 16.0),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 16.0,
                children: [
                  const SizedBox(height: 20),

                  // Lottie Icon
                  Lottie.asset('assets/chat_animation.json'),

                  // Welcome Text
                  Text(
                    'Welcome to Twitter Clone',
                    style: GoogleFonts.dmSerifText(
                      fontSize: 20,
                    ),
                  ),

                  // Name
                  MyTextField(
                    controller: nameController,
                    icon: Icons.person,
                    hintText: 'Name',
                    obscureText: false,
                  ),

                  // Email
                  MyTextField(
                    controller: emailController,
                    icon: Icons.email,
                    hintText: 'Email',
                    obscureText: false,
                  ),

                  // Password
                  MyTextField(
                    controller: passwordController,
                    icon: Icons.key,
                    hintText: 'Password',
                    obscureText: true,
                  ),

                  // Confirm Password
                  MyTextField(
                    controller: confirmPasswordController,
                    icon: Icons.key,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),

                  // SignUp Button
                  GestureDetector(
                    onTap: signUp,
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 64.0),
                      color: Theme.of(context).colorScheme.tertiary,
                      elevation: 12.0,
                      shadowColor: Theme.of(context).colorScheme.secondary,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // OR
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 2,
                          indent: 10,
                          endIndent: 10,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text('OR'),
                      Expanded(
                        child: Divider(
                          thickness: 2,
                          indent: 10,
                          endIndent: 10,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  
                  // Google SignUp Text
                  Text(
                    'Sign Up using Google',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),

                  // SignIn Using Google
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(75)),
                    child: Image.asset(
                      'assets/google.png',
                      height: 50,
                      width: 50,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Not a Member Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already a member? ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

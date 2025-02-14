import 'package:flutter/material.dart';
import 'package:minimal_tweets_app/components/my_text_field.dart';
import 'package:minimal_tweets_app/services/auth/auth_service.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Re-set Your Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 24.0,
          children: [
            Text(
              'Enter your email to change your password',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 18,
              ),
            ),
            MyTextField(
              controller: emailController,
              icon: Icons.email,
              hintText: 'Email',
              obscureText: false,
            ),
            GestureDetector(
              onTap: () {
                // Send link to reset the password
                AuthService().forgotPassword(emailController.text);

                // Clear the text
                emailController.clear();

                // Show SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Check your email for a link to reset your password.',
                    ),
                    duration: Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(bottom: 50, left: 16, right: 16),
                  ),
                );

                // Unfocus the keyboard
                FocusScope.of(context).unfocus();

                // Navigate back to SignIn Page
                Navigator.of(context).pop();
              },
              child: Container(
                height: 50,
                width: 150,
                margin: EdgeInsets.all(16.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Send Email'),
                    Icon(Icons.send),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

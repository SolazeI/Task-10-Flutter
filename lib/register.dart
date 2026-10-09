import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_page.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final AuthService auth = AuthService();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ), // InputDecoration
              ), // TextField
              SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ), // InputDecoration
              ), // TextField
              SizedBox(height: 12),
              ElevatedButton(
                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Register"),
                onPressed: () async {
                  if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) return;
                  setState(() => loading = true);

                  final user = await auth.registerWithEmail(
                    emailCtrl.text, passwordCtrl.text);

                  if (!context.mounted) return;
                  setState(() => loading = false);

                  if (user != null) {
                    // Send verification email
                    if (!user.emailVerified) {
                      await user.sendEmailVerification();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Verification email sent. Please check your inbox."),
                        ), // Text // SnackBar
                      );
                    }
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Registration failed")),
                    );
                  }
                },
              ), // ElevatedButton
              SizedBox(height: 12),
              TextButton(
                child: Text("Already have an account? Login"),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
              ), // TextButton
            ],
          ), // Column
        ), // SingleChildScrollView
      ), // Center
    ); // Scaffold
  }
}
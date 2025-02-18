import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:narayomi/services/mangaupdates_service.dart';

class MangaUpdatesLoginForm extends StatefulWidget {
  final VoidCallback onSuccess;

  MangaUpdatesLoginForm({required this.onSuccess});

  @override
  _MangaUpdatesLoginFormState createState() => _MangaUpdatesLoginFormState();
}

class _MangaUpdatesLoginFormState extends State<MangaUpdatesLoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _authenticate() async {
    setState(() => _isLoading = true);

    final success = await MangaUpdatesService()
        .login(_usernameController.text, _passwordController.text);

    setState(() => _isLoading = false);

    if (success) {
      widget.onSuccess();
    } else {
      Fluttertoast.showToast(
          msg: "Login failed. Please try again.",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          textColor: Theme.of(context).colorScheme.onBackground);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: "Username")),
        TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: "Password"),
            obscureText: true),
        const SizedBox(height: 20),
        _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(onPressed: _authenticate, child: Text("Login")),
      ],
    );
  }
}

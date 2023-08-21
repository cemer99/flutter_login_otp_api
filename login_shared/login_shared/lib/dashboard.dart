import 'package:flutter/material.dart';
import 'package:login_shared/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  var _emailController = TextEditingController();
  var _otpController = TextEditingController();

  bool _isLoggedIn = false;

  DateTime? _tokenExpiration = DateTime.now();

  String _token = "";

  String _email = "";

  @override
  void initState() {
    super.initState();

    getCred();
  }

  void getCred() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    setState(() {
      _token = pref.getString("login")!;
      _email = pref.getString("email")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Column(
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 35),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    logoutAndRoute();
                  },
                  icon: const Icon(Icons
                      .login), // Icon widget'ının const olmadan tanımlandığına dikkat edin.
                  label: const Text("Logout"),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  enabled: false,
                  controller: _emailController,
                  decoration: InputDecoration(
                      labelText: _email,
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.email)),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _otpController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: "OTP",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.password)),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text("Your Token Expiration: ${_tokenExpiration}"),
                
                const SizedBox(
                  height: 50,
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    logoutAndRoute();
                  },
                  icon: const Icon(Icons
                      .login), 
                  label: const Text("Logout"),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  void logoutAndRoute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('login');
    await prefs.remove('tokenExpiration');
    await prefs.setBool('isLoggedIn', false);

    setState(() {
      _isLoggedIn = false;
      _token = '';
      _tokenExpiration = null;
    });

    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false);
  }
}

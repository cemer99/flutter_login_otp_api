import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:login_shared/dashboard.dart';
import 'package:login_shared/otp_screen.dart';
import 'package:login_shared/send_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

   bool _rememberMe = false;



  var emailController = TextEditingController();
  var passController = TextEditingController();

  bool _isLoggedIn = false;

  DateTime? _tokenExpiration = DateTime.now();

  String _token = "";

  @override
  void initState() {
  
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
   
    SharedPreferences pref = await SharedPreferences.getInstance();

    String? tokenExpirationString = pref.getString('tokenExpiration');

    String? val = pref.getString("login");

    bool? rememberMeFlag = pref.getBool('rememberMe');

      //! Check if "Remember Me" is selected and user has previously logged in
  if (rememberMeFlag == true && val != null) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashBoard()),
      (route) => false,
    );
  }else{
      setState(() {
      _rememberMe = false; // Hatırla beni değerini false olarak set et
      _isLoggedIn = pref.getBool('isLoggedIn') ?? false;
      _token = pref.getString('login') ?? '';
      _tokenExpiration = pref.getString('tokenExpiration') != null
          ? DateTime.parse(pref.getString('tokenExpiration')!)
          : DateTime.now();
    });


  }


    if (tokenExpirationString != null){
      _tokenExpiration = DateTime.parse(tokenExpirationString);
    }

    if(_tokenExpiration!.isBefore(DateTime.now())){

       //! Token expired, end session.
      logout();
    }else{
      
      //! TokenExpiration not defined yet, end session
      logout();
    }

    
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
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.email)),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.password)),
              ),
              const SizedBox(
                height: 20,
              ),
               Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    Text('Remember Me'),
                  ],
                ),
              OutlinedButton.icon(
                onPressed: () {
                  login();
                },
                icon: const Icon(Icons.login),
                label: const Text("Login"),
              )
            ],
          ),
        ),
      ),
      ),
    );
  }

  void login() async {
    if (passController.text.isNotEmpty && emailController.text.isNotEmpty) {
      var headers = {'Accept': 'application/json'};
      var request = http.MultipartRequest(
          'POST', Uri.parse('your_api_url'));
      request.fields.addAll(
          {'email': emailController.text, 'password': passController.text});

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String userToken = await response.stream.bytesToString();

        pageRoute(userToken);
        
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invalid Credentials")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Blank Value Found")));
    }
  }

  void pageRoute(String userToken) async {

    DateTime tokenExpiration = DateTime.now().add(const Duration(seconds: 30));
    //! STORE VALUE OR TOKEN INSIDE SHARED PREFERENCES
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("email", emailController.text.toString());
    await pref.setString("login", userToken);
    await pref.setBool('rememberMe', _rememberMe);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OtpSend()), (route) => false);

    await pref.setString('tokenExpiration', tokenExpiration.toIso8601String());
    await pref.setBool('isLoggedIn', true);

    setState(() {
      _isLoggedIn = true;
      _token = userToken;
      _tokenExpiration = tokenExpiration;
    });
  }

   void logout() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('login');
    await prefs.remove('tokenExpiration');
    await prefs.setBool('isLoggedIn', false);
    await prefs.setBool('rememberMe',false);

      setState(() {
       _rememberMe = false;
       _isLoggedIn = false;
       _token = '';
      _tokenExpiration = null;
    });


}
}
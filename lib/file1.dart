import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jignasa/home_screen.dart';
import 'package:jignasa/logindata.dart';
import 'package:path_provider/path_provider.dart';


class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LoginRequestData _loginData = LoginRequestData();


  bool _validate = false;
  bool _obscureText = true;
  var username, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.lightGreen[500],
          child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height / 2.5,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        // begin: Alignment.topCenter,
                        // end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFFFFFFFF),
                          ]
                      ),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(90)
                      )
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset('images/ic_launcher1.png'),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                  child: SingleChildScrollView(
                    child: new Form(
                      key: _formKey,
                      autovalidate: _validate,
                      child: _getFormUI(),
                    ),
                  )
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _getFormUI() {
    return new Column(
      children: <Widget>[
        SizedBox(height: 24.0),
        Center(
          child: Text('Login',
            style: TextStyle(fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white),),
        ),
        new SizedBox(height: 25.0),
        new TextFormField(
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Username',
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
          validator: _validateName,
          onSaved: (value) {
            _loginData.username = value;
          },
        ),
        new SizedBox(height: 8.0),
        new TextFormField(
            autofocus: false,
            obscureText: _obscureText,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Password',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(24.0)),
              suffixIcon: GestureDetector(
                child: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  semanticLabel:
                  _obscureText ? 'show password' : 'hide password',
                ),
              ),
            ),
            validator: _validatePassword,
            onSaved: (String value) {
              _loginData.password = value;
            }
        ),
        new SizedBox(height: 15.0),
        new Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            onPressed: () {
              _submit();
//              Navigator.of(context).pushReplacementNamed('/home');
            },
            padding: EdgeInsets.all(12),
            color: Colors.black54,
            child: Text('Log In', style: TextStyle(color: Colors.white)),
          ),
        ),
        new FlatButton(
          child: Text(
            'Forgot password?',
            style: TextStyle(color: Colors.black54),
          ),
          onPressed: () {},
        ),
        new FlatButton(
          onPressed: _sendToRegisterPage,
          child: Text('Not a member? Sign up now',
              style: TextStyle(color: Colors.black54)),
        ),
        Text(''),
        Text(''),
        Text(''),
      ],
    );
  }

  _sendToRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  String _validateName(String value) {
    if (value.isEmpty) {
      return "Username is Required";
    } else {
      username = value.toString();
    }
  }

  String _validatePassword(String value) {
    if (value.isEmpty) {
      return "Password is Required";
    } else {
      password = value.toString();
    }
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print("Username ${_loginData.username}");
      print("Password ${_loginData.password}");
      return SessionId();
    } else {
      setState(() {
        bool _validate = false;
      });
    }
  }


  final Dio _dio = Dio();
  PersistCookieJar persistentCookies;
  final String url = "https://www.xxxx.in/rest/user/login.json";

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    return directory.path;
  }

  Future<Directory> get _localCoookieDirectory async {
    final path = await _localPath;
    final Directory dir = new Directory('$path/cookies');
    await dir.create();
    print(dir);
    return dir;
  }

  Future<String> getCsrftoken() async{
    try {
      String csrfTokenValue;
      final Directory dir = await _localCoookieDirectory;
      final cookiePath = dir.path;
      persistentCookies = new PersistCookieJar(dir: '$cookiePath');
      persistentCookies.deleteAll(); //clearing any existing cookies for a fresh start
      _dio.interceptors.add(
          CookieManager(persistentCookies) //this sets up _dio to persist cookies throughout subsequent requests
      );
      _dio.options = new BaseOptions(
        baseUrl: url,
        contentType: ContentType.json,
        responseType: ResponseType.plain,
        // connectTimeout: 5000,
        // receiveTimeout: 100000,
        headers: {
          HttpHeaders.userAgentHeader: "dio",
          "Connection": "keep-alive",
        },
      ); //BaseOptions will be persisted throughout subsequent requests made with _dio
      _dio.interceptors.add(
          InterceptorsWrapper(
              onResponse:(Response response) {
                List<Cookie> cookies = persistentCookies.loadForRequest(Uri.parse(url));
                csrfTokenValue = cookies.firstWhere((c) => c.name == 'csrftoken', orElse: () => null)?.value;
                if (csrfTokenValue != null) {
                  _dio.options.headers['X-CSRF-TOKEN'] = csrfTokenValue; //setting the csrftoken from the response in the headers
                }
                print(response);
                return response;
              }
          )
      );
      await _dio.get("https://www.xxxx.in/rest/user/login.json");
      print(csrfTokenValue);
      return csrfTokenValue;
    } catch (error, stacktrace) {
      print(error);
//      print("Exception occured: $error stackTrace: $stacktrace");
      return null;
    }
  }

   SessionId() async {
     try {
       final csrf = await getCsrftoken();
       FormData formData = new FormData.from({
         "username": "${_loginData.username}",
         "password": "${_loginData.password}",
         "csrfmiddlewaretoken" : '$csrf'
       });
       Options optionData = new Options(
         contentType: ContentType.parse("application/json"),
       );
       Response response = await _dio.post("https://www.xxxx.in/rest/user/login.json", data: formData, options: optionData);
       print("StatusCode:${response.statusCode}");
      //  print(response.data);
       if (response.statusCode == 200){
         return Navigator.of(context).pushReplacement(MaterialPageRoute(
             builder: (context) => HomeScreen(),
         ));
       }
       else{
         throw Exception();
       }
     } on DioError catch(e) {
       if(e.response != null) {
         print( e.response.statusCode.toString() + " " + e.response.statusMessage);
         print(e.response.data);
         print(e.response.headers);
         print(e.response.request);
       } else{
         print(e.request);
         print(e.message);
       }
     }
     catch (error, stacktrace) {
       print("Exception occured: $error stackTrace: $stacktrace");
       return null;
     }
   }
}
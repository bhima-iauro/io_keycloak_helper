import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:io_keycloak_helper/io_keycloak_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

@override
  void initState() {
    super.initState();
   
   const authServerUrl = "https://auth.keycloakserver.io/"; // your authServerUrl
   const realm = "realmname";// your realm
   const clientId = "";// your clientId
   const redirectUrl = "com.example.example:/oauth2redirect";// please replace com.example.example with your package name

 

    IOKeycloakHelper.instance.configureKeycloak(authServerUrl: authServerUrl, realm: realm, clientId: clientId, redirectUrl: redirectUrl);
  }
  void login() async {
  
    try {
    String? accessToken = await IOKeycloakHelper.instance.authenticateWithKeycloak();
    debugPrint("Logged in access token $accessToken");
    } on PlatformException catch (e) {
      debugPrint("LOGIN Error==>$e");
    
    }
   
  }
  void checkLoginStatus() async {
    var result = await IOKeycloakHelper.instance.isAccessTokenExpired();
    debugPrint("is token expired $result");
  
  }
  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
            Column(children: [
        ElevatedButton(
        onPressed: checkLoginStatus,
        child: const Text("Check Login Status"),
      ),ElevatedButton(
        onPressed: login,
        child: const Text("Login"),
      )
      ])
          ],
        ),
      ),);
  }
}

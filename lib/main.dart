import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    String? _fcmToken;
    String? _appInstanceId;


   void _getToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      setState(() {
        _fcmToken = token;
      });
      print("FCM Token: $_fcmToken");
    } catch (e) {
      print("Error fetching FCM token: $e");
    }
  }

  Future<void> _getAppInstanceId() async {
    try {
      String? instanceId = await FirebaseInstallations.instance.getId();
      setState(() {
        _appInstanceId = instanceId;
      });
      print("App Instance ID: $_appInstanceId");
    } catch (e) {
      print("Error fetching App Instance ID: $e");
    }
  }

  late FirebaseMessaging messaging;

  String _notificationMessage = "No new notifications";

  @override
  void initState() {
    super.initState();
    _getAppInstanceId();
    _getToken();
    messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic("messaging");
    messaging.getToken().then((value) {
      print(value);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);
      print(event.data.values);

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: event.data['Type'] == "important" ? Text("Important Notification") : Text("Regular Notification"),
              content: Text(event.notification!.body!),
              backgroundColor: event.data['Type'] == "important" ? Colors.red : Colors.green ,
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
    
  }

   void _showNotification(RemoteMessage message) {
    setState(() {
      _notificationMessage = message.notification?.title ?? "No Title";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(child: Text(_notificationMessage)),
    );
  }
}

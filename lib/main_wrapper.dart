import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aws_sdk/aws_sdk.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import 'package:aws_s3_upload/aws_s3_upload.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'dart:io';

// import 'package:aws_sdk_dart_v2/aws_sdk_dart_v2.dart';

// void main() {
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = ImageUploadPage();
        break;
      case 3:
        page = LoginPage();
        break;
      case 4:
        page = InputWordGenerator();
        break;
      // case 5:
      //   page = LoginScreen();
      //   break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.camera_alt),
                    label: Text('Images'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_box_outlined),
                    label: Text('Account'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Submit Prompt'),
                  ),
                  // NavigationRailDestination(
                  //   icon: Icon(Icons.pool),
                  //   label: Text('Submit Prompt'),
                  //   pooopoo
                  // ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   String _email = "";
//   String _password = "";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.all(20),
//               child: TextFormField(
//                 validator: (input) {
//                   if (input?.isEmpty == true) {
//                     return 'Please enter an email';
//                   }
//                   return null;
//                 },
//                 onSaved: (input) => _email = input ?? "",
//                 decoration: InputDecoration(labelText: 'Email'),
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.all(20),
//               child: TextFormField(
//                 validator: (input) {
//                   if (input == null || input.length < 6) {
//                     return 'Your password needs to be at least 6 characters';
//                   }
//                   return null;
//                 },
//                 onSaved: (input) => _password = input ?? '',
//                 decoration: InputDecoration(labelText: 'Password'),
//                 obscureText: true,
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.all(20),
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState?.validate() == true) {
//                     _formKey.currentState?.save();
//                     print(_email);
//                     print(_password);
//                     // Perform authentication here
//                   }
//                 },
//                 child: Text('Login'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  List<File> _imageFiles = [];
  String _customName = '';

  void _pickImage(ImageSource source) async {
    var imagePicker = ImagePicker();
    var imageFile = await imagePicker.pickImage(source: source);
    if (imageFile != null) {
      var imageCropper = ImageCropper();
      var croppedImage = await imageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        maxWidth: 512,
        maxHeight: 512,
      );

      if (croppedImage != null) {
        setState(() {
          _imageFiles.add(File(croppedImage.path));
        });
      }
    }
  }

  void _submitImages() async {
    String endpoint =
        "https://adkfh17ke7.execute-api.us-east-1.amazonaws.com/v1/test-image-bucket-2-diffusion";

    for (int i = 0; i < _imageFiles.length; i++) {
      String filename = "$_customName${i + 1}.jpeg";
      String url = endpoint + '/' + filename;

      var request = http.Request('PUT', Uri.parse(url));
      request.headers['Content-Type'] = 'image';
      request.bodyBytes = _imageFiles[i].readAsBytesSync();
      request.send().then((response) {
        print(response.statusCode);
        if (response.statusCode == 200) {
          print("Image uploaded successfully");
        } else {
          print("Upload failed");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Upload"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: List.generate(
                _imageFiles.length,
                (index) {
                  return Image.file(_imageFiles[index]);
                },
              ),
            ),
          ),
          _imageFiles.length < 2
              ? Container(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Add images",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.image),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ),
                )
              : Container(),
          _imageFiles.length >= 2
              ? Container(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Enter custom name",
                    ),
                    onChanged: (value) {
                      setState(() {
                        _customName = value;
                      });
                    },
                  ),
                )
              : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_imageFiles.length >= 2) {
            _submitImages();
          } else {
            Scaffold.of(context).showBottomSheet(
              (context) => Container(
                child: Text("Please select at least 2 images"),
              ),
            );
          }
        },
        child: Icon(Icons.send),
      ),
    );
  }
}
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Image Upload"),
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: GridView.count(
//               crossAxisCount: 3,
//               children: List.generate(
//                 _imageFiles.length,
//                 (index) {
//                   return Image.file(_imageFiles[index]);
//                 },
//               ),
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: <Widget>[
//               IconButton(
//                 icon: Icon(Icons.image),
//                 onPressed: () => _pickImage(ImageSource.gallery),
//               ),
//               IconButton(
//                 icon: Icon(Icons.camera_alt),
//                 onPressed: () => _pickImage(ImageSource.camera),
//               ),
//             ],
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           if (_imageFiles.length >= 15) {
//             _submitImages();
//           } else {
//             Scaffold.of(context).showBottomSheet(
//               (context) => Container(
//                 child: Text("Please select at least 15 images"),
//               ),
//             );
//           }
//         },
//         child: Icon(Icons.send),
//       ),
//     );
//   }
// }

class InputWordGenerator extends StatefulWidget {
  @override
  _InputWordGeneratorState createState() => _InputWordGeneratorState();
}

class _InputWordGeneratorState extends State<InputWordGenerator> {
  final _textController = TextEditingController();
  String _generatedWord = '';
  void _generateWord() async {
    setState(() {
      _generatedWord = _textController.text;
    });
// have to replace the user id
    final response = await http.post(
        Uri.parse(
            'https://nktvnrvvoh.execute-api.us-east-1.amazonaws.com/default'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "bucketPath": "bucketPath",
          "user_id": 1,
          'prompt': _generatedWord,
          "numFiles": 1
        }));
    print(json.encode({
      "bucketPath": "bucketPath",
      "user_id": 1,
      'prompt': _generatedWord,
      "numFiles": 1
    }));
    if (response.statusCode == 200) {
      print('Successfully sent the prompt to the API!');
    } else {
      print('Failed to send the prompt to the API. Response: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Generated Word: $_generatedWord'),
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: 'Enter a prompt',
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          child: Text('Submit prompt'),
          onPressed: _generateWord,
        ),
      ],
    );
  }
}

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   Future<void> _handleSignIn() async {
//     try {
//       await _googleSignIn.signIn();
//     } catch (error) {
//       print(error);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Sign in with Google',
//               style: TextStyle(fontSize: 20),
//             ),
//             SizedBox(height: 20),
//             GoogleSignInButton(
//               onPressed: _handleSignIn,
//               darkMode: true, // default: false
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email'],
      clientId:
          '552669576534-qho7ia2gdo64nsulf4lr1pg34dvfl6pj.apps.googleusercontent.com');

  Future<String> _login(LoginData data) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Use the authentication tokens to log in to your own backend
      // ...

      // Replace this with your own logic to handle a successful login
      return 'Login successful';
    } else {
      return 'Login failed';
    }
  }

  Future<String> _register(SignupData data) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Use the authentication tokens to log in to your own backend
      // ...

      // Replace this with your own logic to handle a successful registration
      return 'Registration successful';
    } else {
      return 'Registration failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Login Page',
      onLogin: _login,
      onSignup: _register,
      // onSubmitAnimationCompleted: () {
      //   // Navigator.of(context).pushReplacement(MaterialPageRoute(
      //   //   builder: (context) => HomePage(),
      //   // ));
      // },
      onRecoverPassword: (String _) => Future.value(null),
      messages: LoginMessages(
        signupButton: 'Sign Up',
        loginButton: 'Sign In with Google',
        forgotPasswordButton: 'Forgot Password',
      ),
    );
  }
}

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   GoogleSignIn _googleSignIn = GoogleSignIn(
//       scopes: ['email'],
//       clientId:
//           '552669576534-qho7ia2gdo64nsulf4lr1pg34dvfl6pj.apps.googleusercontent.com');
//   GoogleSignInAccount? _currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
//       setState(() {
//         _currentUser = account;
//       });
//     });
//     _googleSignIn.signInSilently();
//   }

//   Future<void> _handleSignIn() async {
//     try {
//       await _googleSignIn.signIn();
//     } catch (error) {
//       print(error);
//     }
//   }

//   Future<void> _handleSignOut() async {
//     _googleSignIn.disconnect();
//   }

//   Widget _buildBody() {
//     if (_currentUser != null) {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           ListTile(
//             leading: GoogleUserCircleAvatar(
//               identity: _currentUser! as GoogleIdentity,
//             ),
//             title: Text(_currentUser?.displayName ?? ''),
//             subtitle: Text(_currentUser?.email ?? ''),
//           ),
//           ElevatedButton(
//             child: Text('Sign out'),
//             onPressed: _handleSignOut,
//           ),
//         ],
//       );
//     } else {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           ElevatedButton(
//             child: Text('Sign in with Google'),
//             onPressed: _handleSignIn,
//           ),
//         ],
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Sign In Example'),
//       ),
//       body: _buildBody(),
//     );
//   }
// }

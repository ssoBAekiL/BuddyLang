import 'package:buddylang/services/auth_service.dart';
import 'package:buddylang/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();

  LoginScreen({this.auth});
  final BaseAuth auth;
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  String _name, _email, _password;
  int _selectedIndex = 0;

  @override
  void initState() { 
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
  ]);
  }

  _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 18.0),
          _buildEmailTF(),
          const SizedBox(height: 15.0),
          _buildPasswordTF(),
          _buildForgotPasswordBtn(),
          //_buildRememberMeCheckbox(),
          _buildLoginBtn(),
          const SizedBox(height: 4.0),
          _buildSignInWithText(),
          const SizedBox(height: 6.0),
          _buildSocialBtnRow(),
        ],
      ),
    );
  }

  _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20.0),
          _buildNameTF(),
          const SizedBox(height: 15.0),
          _buildEmailTF(),
          const SizedBox(height: 15.0),
          _buildPasswordTF(),
          const SizedBox(height: 15.0),
          _buildSignBtn()
        ],
      ),
    );
  }

  _buildNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Username',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              hintText: 'Enter a Username',
              hintStyle: kHintTextStyle,
            ),
            validator: (input) =>
                input.trim().isEmpty ? 'Please, enter a Username' : null,
            onSaved: (input) => _name = input.trim(),
          ),
        ),
      ],
    );
  }

  _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Enter your Email',
              hintStyle: kHintTextStyle,
            ),
            validator: (input) =>
                !input.contains('@') ? 'Please enter a valid Email' : null,
            onSaved: (input) => _email = input,
          ),
        ),
      ],
    );
  }

  _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 55.0,
          child: TextFormField(
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Enter your Password',
              hintStyle: kHintTextStyle,
            ),
            validator: (input) => input.length < 6
                ? 'Password must contain least 6 characters'
                : null,
            onSaved: (input) => _password = input,
          ),
        ),
      ],
    );
  }

  _submit() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    //  final FirebaseAuth _auth = FirebaseAuth.instance;
    // FirebaseUser user = await _auth.currentUser();
    AsyncSnapshot snapshot;

    try {
      if (_selectedIndex == 0 && _loginFormKey.currentState.validate()) {
        _loginFormKey.currentState.save();
        await authService.login(_email, _password);
      } else if (_selectedIndex == 1 &&
          _signupFormKey.currentState.validate()) {
        _signupFormKey.currentState.save();
        await authService.signup(_name, _email, _password);
        await _showVerifyEmailSentDialog();

        if (snapshot.hasData)
          return snapshot.data.isEmailVerified ? LoginScreen() : signOut();
        else
          return LoginScreen();

        //authService.isEmailVerified();

        // return LoginScreen();

        //authService.sendEmailVerification();

      }
    } on PlatformException catch (err) {
      _showErrorDialog(err.message);
    }
  }

  _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  signOut() {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.signOut();
    return Container(width: 0.0, height: 0.0);
  }

  _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showResetPwd() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Reset your Password"),
          content: new Text(
              "Link to verify reset your password has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

/*
   void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
*/

/*
  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }
  */

  // bool _rememberMe = false;

  _buildForgotPasswordBtn() {
    final authService = Provider.of<AuthService>(context, listen: false);
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () {
          authService.resetPassword(_email);
        },
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          'Forgot Password?',
          style: kLabelStyle,
        ),
      ),
    );
  }

/*
  Widget _buildRememberMeCheckbox() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _rememberMe,
              checkColor: Colors.green,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value;
                });
              },
            ),
          ),
          Text(
            'Remember me',
            style: kLabelStyle,
          ),
        ],
      ),
    );
  }
*/

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: .0,
        onPressed: _submit,
        padding: EdgeInsets.all(11.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'LOG IN',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _buildSignBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: .0,
        onPressed: () {
          _submit();
        },
        padding: EdgeInsets.all(11.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'SIGN UP',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _buildSignInWithText() {
    return Column(
      children: <Widget>[
        Text(
          '- OR -',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              shadows: [
                Shadow(
                  blurRadius: 75.0,
                  color: Colors.black,
                  offset: Offset(5.0, 5.0),
                ),
              ]),
        ),
        SizedBox(height: 13.0),
        Text(
          'Sign in with',
          style: kLabelStyle,
        ),
      ],
    );
  }

  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.0,
        width: 56.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
            () => AuthService().googleSignUp(),
            AssetImage(
              'assets/logos/google.jpg',
            ),
          ),
          _buildSocialBtn(
            () => AuthService().signUpWithFacebook(),
            AssetImage(
              'assets/logos/facebook.jpg',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 50.0, //oppure 40.0
                    vertical: 50.0, //oppure 40.0
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //r  const SizedBox(height: 20.0),
                      SafeArea(
                        child: Text(
                          'Welcome!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            width: 130.0,
                            height: 45.0,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              color: _selectedIndex == 0
                                  ? Colors.white
                                  : Colors.blue[450],
                              child: Text(
                                'LOG IN',
                                style: TextStyle(
                                  letterSpacing: 1.5,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                  color: _selectedIndex == 0
                                      ? Colors.blue[600]
                                      : Colors.white,
                                ),
                              ),
                              onPressed: () =>
                                  setState(() => _selectedIndex = 0),
                            ),
                          ),
                          Container(
                            width: 130.0,
                            height: 45.0,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              color: _selectedIndex == 1
                                  ? Colors.white
                                  : Colors.blue[450],
                              child: Text(
                                'SIGN UP',
                                style: TextStyle(
                                  letterSpacing: 1.5,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                  color: _selectedIndex == 1
                                      ? Colors.blue
                                      : Colors.white,
                                ),
                              ),
                              onPressed: () =>
                                  setState(() => _selectedIndex = 1),
                            ),
                          ),
                        ],
                      ),
                      _selectedIndex == 0
                          ? _buildLoginForm()
                          : _buildSignupForm(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

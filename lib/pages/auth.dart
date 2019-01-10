import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  bool _obscureText = true;
  String _email, _password;
  bool _acceptTnC = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double targetWidth = deviceWidth > 550 ? 500 : deviceWidth * 0.9;

    return Scaffold(
        appBar: AppBar(title: Text('Easy List')),
        body: Form(
          key: formKey,
          child: Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/background.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5), BlendMode.dstATop)),
              ),
              child: Center(
                child: SingleChildScrollView(
                    child: Container(
                  width: targetWidth,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Email',
                        ),
                        validator: (value) =>
                            RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                        .hasMatch(value) ==
                                    false
                                ? 'Enter Valid Email'
                                : null,
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (value) => _email = value,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Password',
                        ),
                        validator: (value) =>
                            value.length < 3 ? 'Password too short.' : null,
                        onSaved: (value) => _password = value,
                        obscureText: _obscureText,
                      ),
                      SwitchListTile(
                        value: _acceptTnC,
                        onChanged: (bool value) {
                          setState(() {
                            _acceptTnC = value;
                          });
                        },
                        title: Text('Accept TnC'),
                      ),
                      RaisedButton(
                          child: Text(
                            'Login',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            if (!formKey.currentState.validate()) {
                              return;
                            }
                            if (_acceptTnC) {
                              formKey.currentState.save();
                              Navigator.pushReplacementNamed(context, '/home');
                            }
                          }),
                    ],
                  ),
                )),
              )),
        ));
  }
}

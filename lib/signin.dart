import 'package:blood/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  var Email, Password;
  var _formkey = GlobalKey<FormState>();
  var _mailClt = TextEditingController();
  var _passClt = TextEditingController();
  var cheak = true;

  signInToFirebase() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      setState(() {
        cheak = false;
      });

      try {
        FirebaseAuth firebaseAuth = FirebaseAuth.instance;
        User? user = (await firebaseAuth.signInWithEmailAndPassword(
                email: Email, password: Password))
            .user;
        if (user != null) {
          setState(() {
            cheak = true;
          });
          checkEmailVerified();
        } else {
          Fluttertoast.showToast(
              msg: "Login Failed",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Fluttertoast.showToast(
              msg: "User not found.Please check your gmail",
              backgroundColor: Colors.redAccent[100],
              textColor: Colors.white);
          setState(() {
            cheak = true;
          });
        } else if (e.code == 'wrong-password') {
          Fluttertoast.showToast(
              msg: "Incorrect Password",
              backgroundColor: Colors.redAccent[100],
              textColor: Colors.white);
          setState(() {
            cheak = true;
          });
        }
      } catch (e) {
        print(e);
      }
    } else {
      Fluttertoast.showToast(msg: "Please check your internet connection!");
      setState(() {
        cheak = true;
      });
    }
  }

  Future<void> checkEmailVerified() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User? user = firebaseAuth.currentUser;
    await user!.reload();
    if (user.emailVerified) {
      Fluttertoast.showToast(
          msg: "Login Sucesss",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString('mail', 'useremail@gmail.com');
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      Fluttertoast.showToast(
          msg: "Please verify your account",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In",
            style: GoogleFonts.lato(
                fontSize: 20,
                color: Colors.white,
                textStyle:
                    TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2))),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_ios)),
        ),
        backgroundColor: Colors.redAccent[100],
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: height * 0.5,
                  decoration: BoxDecoration(
                      color: Colors.redAccent[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextFormField(
                            controller: _mailClt,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(fontSize: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(16),
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return "Empty Feild";
                              }
                            },
                            onSaved: (value) {
                              setState(() {
                                Email = value!.trim();
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextFormField(
                            controller: _passClt,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(fontSize: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(16),
                              fillColor: Colors.white,
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return "Empty Feild";
                              } else if (value.length < 6) {
                                return "Password will be at least 6 charecture";
                              }
                            },
                            onSaved: (value) {
                              setState(() {
                                Password = value;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            width: 170,
                            height: 40,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  elevation:
                                      MaterialStateProperty.all<double>(0.0),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                        width: 1.5, color: Colors.transparent),
                                  )),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.red)),
                              child: cheak
                                  ? Text('Submit',
                                      style: GoogleFonts.lato(
                                          fontSize: 20, color: Colors.white))
                                  : Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                              onPressed: () async {
                                signInToFirebase();
                              },
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: height / 100 * 3),
                          child: InkWell(
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline),
                            ),
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             ResetPasswordPage()));
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

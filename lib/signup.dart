import 'package:blood/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUp extends StatefulWidget {
  const SignUp() : super();

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var Email, Password, ConformPassword;
  var _formkey = GlobalKey<FormState>();
  var _mailClt = TextEditingController();
  var _passClt = TextEditingController();
  var _conformPassClt = TextEditingController();
  var cheak = true;

  registerToFirebase() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      if (Password != ConformPassword) {
        Fluttertoast.showToast(
            msg: "Password not match",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        return;
      }

      try {
        FirebaseAuth firebaseAuth = FirebaseAuth.instance;
        final User? user = (await firebaseAuth.createUserWithEmailAndPassword(
                email: Email, password: Password))
            .user;
        if (user != null) {
          setState(() {
            cheak = true;
          });

          User? _user = firebaseAuth.currentUser;
          _user!.sendEmailVerification();
          Fluttertoast.showToast(
              msg: "Please check your email",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.deepOrangeAccent,
              textColor: Colors.white,
              fontSize: 16.0);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignIn()));
        } else {
          Fluttertoast.showToast(
              msg: "Something Wrong..",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          Fluttertoast.showToast(
              msg: "Your email already exits",
              backgroundColor: Colors.redAccent[100],
              textColor: Colors.white);
          setState(() {
            cheak = true;
          });
        } else if (e.code == "invalid-email") {
          Fluttertoast.showToast(
              msg: "Your email is not valid",
              backgroundColor: Colors.redAccent[100],
              textColor: Colors.white);
          setState(() {
            cheak = true;
          });
        }
      } catch (signUpError) {
        print(signUpError);
      }
    } else {
      Fluttertoast.showToast(msg: "Please check your internet connection!");
      setState(() {
        cheak = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Sign Up",
            style: GoogleFonts.lato(
                fontSize: 20,
                color: Colors.white,
                textStyle:
                    TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
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
                            padding: const EdgeInsets.all(10),
                            child: TextFormField(
                              controller: _conformPassClt,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
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
                                  ConformPassword = value;
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
                                          width: 1.5,
                                          color: Colors.transparent),
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
                                  registerToFirebase();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

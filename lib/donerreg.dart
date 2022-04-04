import 'package:blood/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';

class Donation extends StatefulWidget {
  @override
  _DonationState createState() => _DonationState();
}

class _DonationState extends State<Donation> with TickerProviderStateMixin {
  List<String> bloodgroupList = [
    "Select Blood",
    "AB+",
    "AB-",
    "O+",
    "O-",
    "A+",
    "A-",
    "B+",
    "B-"
  ];
  String selectedBloodGroup = 'Select Blood';
  var _formKey = GlobalKey<FormState>();
  var _nameClt = TextEditingController();
  var _phoneClt = TextEditingController();
  var _mailClt = TextEditingController();
  var _divisionClt = TextEditingController();
  var _districtClt = TextEditingController();
  var _upazilaClt = TextEditingController();
  late String fullName,
      phoneNumber,
      mail = "",
      division,
      district,
      thana_upazila;
  var loading = false;
  var Uid;

  checkValidation(var contex) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (selectedBloodGroup == "Select Blood") {
        Fluttertoast.showToast(msg: "Not Selected");
        return;
      } else {
        showAlertDialog(contex);
      }
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Check Again",
        style: GoogleFonts.lato(color: Colors.redAccent[100]),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        "Yes, I am sure",
        style: GoogleFonts.lato(color: Colors.green[300]),
      ),
      onPressed: () {
        Navigator.pop(context);
        sendDataToFirebase();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Conformation alert!",
          style: GoogleFonts.lato(color: Colors.redAccent[100])),
      content: Text(
        "Are you sure your information is correct? You can't change your information again. It's one time registration.",
        style: GoogleFonts.lato(color: Colors.grey),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future sendDataToFirebase() async {
    setState(() {
      loading = true;
    });

    List<String> splitList = thana_upazila.split(' ');
    List<String> indexList = [];
    for (int i = 0; i < splitList.length; i++) {
      for (int j = 0; j <= splitList[i].length + i; j++) {
        indexList.add(splitList[i].substring(0, j).toLowerCase());
      }
    }
    await FirebaseFirestore.instance.collection('All').add({
      'Name': fullName.capitalize,
      'BloodGroup': selectedBloodGroup,
      'PhoneNumber': phoneNumber,
      'Mail': mail,
      'Division': division.capitalize,
      'Disrtict': district.capitalize,
      'Thana_Upazila': thana_upazila.capitalize,
      'Index': indexList
    }).then((value) async {
      await FirebaseFirestore.instance
          .collection(selectedBloodGroup.toString())
          .add({
        'Name': fullName.capitalize,
        'BloodGroup': selectedBloodGroup,
        'PhoneNumber': phoneNumber,
        'Mail': mail,
        'Division': division.capitalize,
        'Disrtict': district.capitalize,
        'Thana_Upazila': thana_upazila.capitalize,
        'Index': indexList
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection("Collection")
            .doc(Uid)
            .set({"Donner": "Yes"}).then((value) {
          setState(() {
            loading = false;
          });
          Get.to(HomePage());
          Get.snackbar('Doner!', 'Now you are a donner.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent[100],
              colorText: Colors.white);
        });
      });
    });
  }

  @override
  void initState() {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User? user = firebaseAuth.currentUser;
    setState(() {
      this.Uid = user!.uid.toString();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.redAccent[100],
        elevation: 0.2,
        title: Text('Registration',
            style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.redAccent[100],
                  borderRadius: BorderRadius.circular(10)),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 40.0, left: 8.0, right: 8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameClt,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Full Name',
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
                            fullName = value!;
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 20),
                          alignment: Alignment.center,
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                value: selectedBloodGroup,
                                isExpanded: true,
                                items: bloodgroupList.map((e) {
                                  return DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ));
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedBloodGroup = value.toString();
                                    print(selectedBloodGroup);
                                  });
                                },
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _phoneClt,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
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
                            phoneNumber = value.toString();
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _mailClt,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Mail (Optional)',
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
                        onSaved: (value) {
                          setState(() {
                            mail = value.toString();
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _divisionClt,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Division',
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
                            division = value.toString();
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _districtClt,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'District',
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
                            district = value.toString();
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _upazilaClt,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Upazila/Thana',
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
                            thana_upazila = value.toString();
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 150,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              elevation: MaterialStateProperty.all<double>(0.0),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                    width: 1.5, color: Colors.transparent),
                              )),
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.red)),
                          child: loading
                              ? Container(
                                  height: 30,
                                  child: SpinKitWave(
                                    color: Colors.white,
                                    type: SpinKitWaveType.end,
                                  ),
                                )
                              : Text('Submit',
                                  style: GoogleFonts.lato(
                                      fontSize: 20, color: Colors.white)),
                          onPressed: () {
                            checkValidation(context);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

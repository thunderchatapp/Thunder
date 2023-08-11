import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:thunder_chat/controllers/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ChatProfileController chatProfileController;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    chatProfileController = Provider.of<ChatProfileController>(context);

    TextEditingController userNameController = TextEditingController(
      text: chatProfileController.myProfile.name,
    );

    TextEditingController descriptionController = TextEditingController(
      text: chatProfileController.myProfile.description,
    );

    Future<void> updateProfile() async {
      // Logic to update the user profile in your database
      // Replace this with your actual implementation using database update queries or API calls
      // For example:
      bool userNameExists = await chatProfileController
          .checkUserNameExits(userNameController.text);

      if (userNameExists) {
        Fluttertoast.showToast(
          msg: "Username already exists. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        // show a toast here
      } else {
        // show a toast here
        setState(() {
          isLoading = true; // Show the loading indicator
        });
        chatProfileController.myProfile.name = userNameController.text;
        chatProfileController.myProfile.description =
            descriptionController.text;

        // You may also need to save the updated profile to your database
        // For example: await saveUpdatedUserProfileToDatabase();

        await chatProfileController.updateProfile();

        setState(() {
          isLoading = false; // Show the loading indicator
        });
        Fluttertoast.showToast(
          msg: "Profile updated successfully.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                // SizedBox(
                //   width: 2,
                // ),
                // SizedBox(
                //   width: 12,
                // ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Profile',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.account_circle_sharp,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircleAvatar(
                  backgroundImage:
                      NetworkImage(chatProfileController.myProfile.photoURL),
                  maxRadius: 70,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container(
                  //     margin: EdgeInsets.only(
                  //         top: 0, bottom: 20, left: 30, right: 30),
                  //     child: Text(chatProfileController.myProfile.userId)),
                  Container(
                    margin: EdgeInsets.only(
                        top: 10, bottom: 10, left: 30, right: 30),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextField(
                      controller: userNameController,
                      decoration: InputDecoration(
                        hintText: "Username",
                        hintStyle: TextStyle(
                          fontSize: 18.0,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 8.0,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: 10, bottom: 10, left: 30, right: 30),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        hintText: "Description",
                        hintStyle: TextStyle(
                          fontSize: 18.0,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 8.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              width: double.infinity,
              margin: EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => updateProfile(),
                  child: isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            value: null,
                            strokeWidth:
                                3, // You can adjust the strokeWidth if needed
                          ),
                        ) // Show loading indicator if isLoading is true
                      : Text('Update Profile'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

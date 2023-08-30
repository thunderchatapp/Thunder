import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:thunder_chat/appconfig.dart';
import 'package:thunder_chat/controllers/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final config = AppConfig();
  late ChatProfileController chatProfileController;
  bool isLoading = false;
  bool isPhotoLoading = false;
  @override
  Widget build(BuildContext context) {
    chatProfileController = Provider.of<ChatProfileController>(context);

    TextEditingController userNameController = TextEditingController(
      text: chatProfileController.myProfile.name,
    );

    TextEditingController descriptionController = TextEditingController(
      text: chatProfileController.myProfile.description,
    );

    // Method to upload image to IPFS (you'll need to implement this)
    Future<String> uploadImageToIPFS(img.Image image) async {
      final web3StorageEndpoint = config.web3StorageEndpoint;
      final apiKey = config.Web3StorageApiKey;

      final imageBytes = img.encodePng(image); // Convert the image to bytes

      final response = await http.post(
        Uri.parse(web3StorageEndpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
        body: imageBytes,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final ipfsLink =
            jsonResponse['cid']; // Assuming the API response contains the URL
        return "https://$ipfsLink.ipfs.w3s.link/";
      } else {
        throw Exception('Failed to upload image to Web3.Storage');
      }
    }

    Future<void> _selectAndUploadImage() async {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          isPhotoLoading = true;
        });
        final File imageFile = File(pickedImage.path);
        final img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;

        // Resize the image
        final img.Image resizedImage = img.copyResize(image, height: 256);

        // Upload the resized image to IPFS
        final ipfsLink = await uploadImageToIPFS(resizedImage);

        // Update the user's profile picture using the IPFS link
        setState(() {
          chatProfileController.myProfile.photoURL = ipfsLink;
          isPhotoLoading = false;
        });
      }
    }

    Future<void> updateProfile() async {
      // Logic to update the user profile in your database
      // Replace this with your actual implementation using database update queries or API calls
      // For example:
      bool userNameExists = await chatProfileController
          .checkUserNameExits(userNameController.text);

      if (userNameExists &&
          userNameController.text != chatProfileController.myProfile.name) {
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
            GestureDetector(
              onTap: _selectAndUploadImage, // Call the function when tapped
              child: Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          chatProfileController.myProfile.photoURL.isEmpty
                              ? AssetImage('assets/default_profile.png')
                              : NetworkImage(
                                      chatProfileController.myProfile.photoURL)
                                  as ImageProvider,
                      maxRadius: 70,
                    ),
                    if (isPhotoLoading) // Display the loading indicator
                      Positioned.fill(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
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

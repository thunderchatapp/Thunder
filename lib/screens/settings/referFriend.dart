import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:thunder_chat/controllers/profile_controller.dart';

class ReferFriendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chatProfileController = Provider.of<ChatProfileController>(context);

    void _shareMessage() {
      String message =
          "I've joined the Thunder Chat! And guess what?\nYou can use my referral link to join too.\nLet's explore together!\nhttps://play.google.com/store/apps/details?id=com.thunder.chat&referral=${chatProfileController.myProfile.referrerCode}";
      Share.share(message);
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
                        'Refer friends',
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
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'Balance Reward',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    child: Center(
                      child: Text(
                        '0 USC',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 8), // Adjusted the height here
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Claim to address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16), // Adjusted the height here
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      // Implement the claim functionality here
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Claim'),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Referrer Code',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Center(
              child: Text(
                '${chatProfileController.myProfile.referrerCode}',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 0),
            Padding(
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  // Implement the share functionality here
                  _shareMessage();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16), // Adjusted width and padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Share'),
              ),
            ),
            SizedBox(height: 0),
            Center(
              child: Text('Get 3 USC when you invite a friend!'),
            ),
            SizedBox(height: 25),
            Text(
              'Invited Friends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add your logic to display the invited friends here
          ],
        ),
      ),
    );
  }
}

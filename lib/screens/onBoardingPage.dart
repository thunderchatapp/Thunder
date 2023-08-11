import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:thunder_chat/screens/onBoardingPage1.dart';
import 'package:thunder_chat/screens/onBoardingPage2.dart';
import 'package:thunder_chat/screens/onBoardingPage3.dart';
import 'package:thunder_chat/screens/onBoardingPage4.dart';
import 'package:thunder_chat/screens/signUpPage.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final controller = PageController();
  bool onLastPage = false;
  bool onFirstPage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 3);
              });
              setState(() {
                onFirstPage = (index == 0);
              });
            },
            children: [
              OnBoardingPage1(),
              OnBoardingPage2(),
              OnBoardingPage3(),
              OnBoardingPage4(),
            ],
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 30, 30),
            alignment: Alignment.topRight,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              GestureDetector(
                onTap: () => {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SignUpPage();
                  }))
                },
                child:
                    Text('skip >', style: TextStyle(height: 5, fontSize: 16)),
              ),
            ]),
          ),
          Container(
            alignment: Alignment(0, 0.75),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  onFirstPage
                      ? GestureDetector(
                          child: Text('         ',
                              style: TextStyle(height: 5, fontSize: 16)),
                        )
                      : GestureDetector(
                          onTap: () => {
                            controller.previousPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeIn)
                          },
                          child: Text('back',
                              style: TextStyle(height: 5, fontSize: 16)),
                        ),
                  SmoothPageIndicator(
                    controller: controller,
                    count: 4,
                    effect: JumpingDotEffect(
                        //activeDotColor: Colors.deepOrange,
                        //dotColor: Colors.deepOrange.shade100,
                        //dotHeight: 20,
                        //dotWidth: 20,
                        spacing: 16),
                  ),
                  onLastPage
                      ? GestureDetector(
                          onTap: () => {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return SignUpPage();
                            }))
                          },
                          child: Text('done',
                              style: TextStyle(height: 5, fontSize: 16)),
                        )
                      : GestureDetector(
                          onTap: () => {
                            controller.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeIn)
                          },
                          child: Text('next',
                              style: TextStyle(height: 5, fontSize: 16)),
                        ),
                ]),
          )
        ],
      ),
    );
  }
}

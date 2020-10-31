import 'nav_bar.dart';
import 'package:flutter/material.dart';

class AboutDev extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(
          'About the app',
          style: TextStyle(fontSize: 25),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('assets/images/icon.png'),
                  )),
                ),
                SizedBox(width: 20),
                Text('Elixir',
                    style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 5)),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 40, right: 40),
              child: Divider(height: 40, color: Colors.grey[800]),
            ),
            Card(
                elevation: 8,
                child: Container(
                  width: MediaQuery.of(context).size.width - 100,
                  child: Column(
                    children: [
                      Text(
                        'App info',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.2),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 40, right: 40),
                        child: Divider(height: 30, color: Colors.grey[800]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Our mobile application will be one stop location to discuss about different medical milestones, connect with different doctors worldwide with one on one encrypted chat and also video call them and also send them prescription via image upload from gallery or click picture from the app to forward images, AI chatbot that can have a conversation with you through both text and speech about different medical terms, locate nearby hospitals to get proper medical care, a feed/blog space to share their recovery stories and finally a translator to get the whole app in the language one is comfortable with and hence dissolve any communication barrier. This solution will shorten the gap between the people around the world in search for good healthcare and help pave their a path in the journey of recovery.',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2),
                        ),
                      ),
                    ],
                  ),
                )),
            SizedBox(height: 40),
            Center(
              child: Text('App Developers',
                  style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 5)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 40, right: 40),
              child: Divider(height: 40, color: Colors.grey[800]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/images/sohamsakaria.jpg'),
                      radius: 60,
                    ),
                    Text('Soham Sakaria',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ))
                  ],
                ),
                SizedBox(width: 40),
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/images/parthsrivastava.jpeg'),
                      radius: 60,
                    ),
                    Text('Parth Srivastava',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ))
                  ],
                ),
              ],
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/images/eeshandutta.jpg'),
                      radius: 60,
                    ),
                    Text('Eeshan Dutta',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ))
                  ],
                ),
                SizedBox(width: 60),
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/images/parthpandey.jpg'),
                      radius: 60,
                    ),
                    Text('Parth Pandey',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ))
                  ],
                ),
              ],
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

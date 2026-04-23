import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Transform.translate(
          offset: Offset(0, deviceHeight * -0.02),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: deviceHeight * 0.60,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/earth.png'),
                      scale: 0.5,
                      alignment: Alignment.bottomRight,
                    ),
                    color: Color(0xFF61F6BE),
                    border: Border.all(color: Color(0xFF149C21), width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: deviceHeight * 0.03,
                      left: deviceWidth * 0.05,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'PIN',
                              style: TextStyle(
                                fontFamily: 'Clash',
                                fontSize: deviceWidth * 0.15,
                                fontWeight: FontWeight(500),
                                height: 0.8,
                              ),
                            ),
                            Text(
                              'note',
                              style: TextStyle(
                                fontFamily: 'Clash',
                                fontSize: deviceWidth * 0.15,
                                fontWeight: FontWeight(800),
                                height: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'LEAVING A NOTE FOR THE WORLD.',
                          style: TextStyle(
                            fontFamily: 'Clash',
                            fontSize: deviceWidth * 0.04,
                            fontWeight: FontWeight(800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: deviceHeight * 0.016),
                SizedBox(
                  width: double.infinity,
                  height: deviceHeight * 0.18,
                  child: ElevatedButton(
                    onPressed: () {
                      // login
                      Navigator.pushNamed(context, '/sign-in');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF61F6BE),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.only(
                        top: deviceHeight * 0.09,
                        right: deviceHeight * 0.18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Color(0xFF149C21), width: 2),
                      ),
                    ),
                    child: Text(
                      'Log  in',
                      style: TextStyle(
                        fontFamily: 'Clash',
                        fontSize: deviceWidth * 0.13,
                        fontWeight: FontWeight(800),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: deviceHeight * 0.016),
                SizedBox(
                  width: double.infinity,
                  height: deviceHeight * 0.054,
                  child: ElevatedButton(
                    onPressed: () {
                      // create
                      Navigator.pushNamed(context, '/register');
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    child: Text(
                      '+ CREATE AN ACCOUNT',
                      style: TextStyle(
                        fontFamily: 'Clash',
                        fontSize: deviceWidth * 0.049,
                        fontWeight: FontWeight(500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

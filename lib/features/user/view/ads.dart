import 'package:flutter/material.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/network/remote/dio_helper.dart';
import '../../../core/styles/themes.dart';

class AdsUser extends StatelessWidget {
  const AdsUser({super.key, required this.tittle, required this.desc, required this.image, required this.time});




  final String tittle;
  final String desc;
  final String image;
  final String time;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: Image.network(
                        "$url/uploads/$image",
                        fit: BoxFit.cover,
                        height: 340,
                        width: double.infinity,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        navigateBack(context);
                      },
                      child: Container(
                        margin: EdgeInsets.all(16),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_back_ios_new,size: 28,),
                      ),
                    )

                  ],
                ),
                SizedBox(height: 12,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              textAlign: TextAlign.right,
                              tittle,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12,),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              desc,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16,),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              time,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
    );
  }
}

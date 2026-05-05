import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ navigation/navigation.dart';
import '../../../../core/styles/themes.dart';
import '../../cubit/cubit.dart';
import '../../cubit/states.dart';


class DetailsPerson extends StatelessWidget {
  const DetailsPerson({
    super.key,
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    required this.isVerified,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String location;
  final String isVerified;
  final String phone;
  final String role;
  final String createdAt;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AdminCubit(),
      child: BlocConsumer<AdminCubit, AdminStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit=AdminCubit.get(context);
          DateTime date = DateTime.parse(createdAt);
          String formattedDate = "${date.year}-${date.month}-${date.day}";
          return SafeArea(
            child: Scaffold(
              body: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: (){
                                navigateBack(context);
                              },
                              child: Icon(Icons.arrow_back_ios_new,)),
                          const Text(
                            textAlign: TextAlign.right,
                            'تفاصيل الطلاب',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30,vertical: 14),
                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 14),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: primaryColor,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          )
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Spacer(),
                              Column(
                                children: [
                                  Text(name,style: TextStyle(fontSize: 14,color: Colors.white),),
                                  SizedBox(height: 10,),
                                  Text(phone,style: TextStyle(fontSize: 14,color: Colors.white),),
                                  SizedBox(height: 10,),
                                  Text(location,style: TextStyle(fontSize: 14,color: Colors.white),),
                                  SizedBox(height: 10,),
                                  Text(isVerified,style: TextStyle(fontSize: 14,color: Colors.white),),
                                  SizedBox(height: 10,),
                                  Text(role,style: TextStyle(fontSize: 14,color: Colors.white),),
                                  SizedBox(height: 10,),
                                  Text(formattedDate,style: TextStyle(fontSize: 14,color: Colors.white),),
                                ],
                              ),
                              Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(':الاسم',style: TextStyle(fontSize: 16,color: Colors.white),),
                                  SizedBox(height: 10,),
                                  Text(':الهاتف',style: TextStyle(fontSize: 16,color: Colors.white),),
                                  SizedBox(height: 10,),
                                  Text(':الموقع',style: TextStyle(fontSize: 16,color: Colors.white),),
                                  SizedBox(height: 10,),
                                  Text(':تفعيل الحساب',style: TextStyle(fontSize: 16,color: Colors.white),),
                                  SizedBox(height: 10,),
                                  Text(':الصلاحياة',style: TextStyle(fontSize: 16,color: Colors.white),),
                                  SizedBox(height: 10,),
                                  Text(':تاريخ الانشاء',style: TextStyle(fontSize: 16,color: Colors.white),),
                                ],
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
        },
      ),
    );
  }
}

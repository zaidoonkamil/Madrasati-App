import 'package:madrasati_app/features/admin/view/details/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ navigation/navigation.dart';
import '../../../../core/styles/themes.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../cubit/chat/chat_admin.dart';

class AllUserChatAdmin extends StatelessWidget {
  const AllUserChatAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminUsersCubit(),
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: appPageColor(context),
          body: Column(
            children: [
              const CustomAppBarBack(
                title: 'المحادثات',
                subtitle: 'استعرض رسائل المستخدمين والإدارة',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<AdminUsersCubit, AdminUsersState>(
                  builder: (context, state) {
                    if (state is AdminUsersInitial ||
                        state is AdminUsersLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AdminUsersLoaded) {
                      final users = state.users;
                      if (users.isEmpty) {
                        return const Center(
                          child: Text('لا يوجد مستخدمين حتى الآن'),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final u = users[index];
                          final user = u['user'];
                          final lastMsg = u['lastMessage'];
                          return GestureDetector(
                            onTap: () {
                              navigateTo(
                                context,
                                ChatAdmin(userId: users[index]['user']['id']),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 2,
                              color: appSurface(context),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: appBorder(context)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          user['name'],
                                          style: TextStyle(
                                            color: appTextPrimary(context),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          lastMsg != null
                                              ? lastMsg['message']
                                              : 'لا توجد رسائل بعد',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: appTextMuted(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 8),
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.blueAccent,
                                      child: Text(
                                        user['name'][0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is AdminUsersError) {
                      return Center(child: Text(state.message));
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

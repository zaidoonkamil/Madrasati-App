import 'package:madrasati_app/core/styles/themes.dart';
import 'package:madrasati_app/core/widgets/constant.dart';
import 'package:madrasati_app/features/admin/cubit/chat/chat_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ navigation/navigation.dart';
import '../../../../core/widgets/background.dart';
import '../../../../core/widgets/circular_progress.dart';


class ChatAdmin extends StatefulWidget {
  final int userId;
  const ChatAdmin({super.key, required this.userId});

  @override
  State<ChatAdmin> createState() => _ChatAdminState();
}

class _ChatAdminState extends State<ChatAdmin> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminChatCubit(
        adminId: int.parse(id),
        userId: widget.userId,
      ),
      child: BlocListener<AdminChatCubit, AdminChatState>(
        listener: (context, state) {
          if (state is AdminChatLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          }
          if (state is AdminChatError) {

          }
        },
        child: SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                Background(),
                Column(
                  children: [
                    Container(
                      color: primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(width: 28),
                            const Text(
                              'دردش مع المستخدم',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                navigateBack(context);
                              },
                              child: const Icon(
                                Icons.keyboard_arrow_right_outlined,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: BlocBuilder<AdminChatCubit, AdminChatState>(
                          builder: (context, state) {
                            if (state is AdminChatConnecting ||state is AdminChatLoading) {
                              return const Center(child: CircularProgress());
                            } else if (state is AdminChatLoaded) {
                              var messages = state.messages;
                              return ListView.builder(
                                controller: _scrollController,
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final msg = messages[index];
                                  final isUserMessage = msg['senderId'] != widget.userId;
                                  final messageText = msg['message'] ?? '';
                                  return Align(
                                    alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        isUserMessage ==false? Row(
                                          children: [
                                            const SizedBox(width: 8),
                                            Image.asset(
                                              'assets/images/Mask group.png',
                                              width: 40,
                                              height: 40,
                                            ),
                                          ],
                                        ):Container(),
                                        Container(
                                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          padding: const EdgeInsets.all(12),
                                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                                          decoration: BoxDecoration(
                                            color: isUserMessage ? primaryColor : Colors.grey[300],
                                            borderRadius: isUserMessage ?const BorderRadius.only(
                                              topLeft: Radius.circular(14),
                                              topRight: Radius.circular(14),
                                              bottomLeft: Radius.circular(14),
                                            ):BorderRadius.only(
                                              topLeft: Radius.circular(14),
                                              topRight: Radius.circular(14),
                                              bottomRight: Radius.circular(14),
                                            ),
                                          ),
                                          child: Text(
                                            messageText,
                                            style: TextStyle(
                                              color: isUserMessage ? Colors.white : Colors.black87,
                                            ),
                                            textAlign: TextAlign.right,
                                            softWrap: true,
                                          ),
                                        ),
                                        isUserMessage? Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.blueAccent,
                                              child: Text(
                                                'اد'.toUpperCase(),
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ):Container(),

                                      ],
                                    ),
                                  );
                                },
                              );

                            } else if (state is AdminChatError) {
                              return Center(child: Text(state.message));
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    _MessageInput(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _MessageInput extends StatefulWidget {
  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  final TextEditingController _controller = TextEditingController();

  void _send(BuildContext context) {
    final text = _controller.text;
    if (text.trim().isEmpty) return;

    context.read<AdminChatCubit>().sendMessage(text);
    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AdminChatCubit>().messages.isNotEmpty) {
        final chatState = context.read<AdminChatCubit>();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        color: Colors.grey[200],
        child: Row(
          children: [
            InkWell(
                onTap: () => _send(context),
                child: Image.asset('assets/images/akar-icons_send.png')),
            SizedBox(width: 8,),
            Expanded(
              child: TextField(
                controller: _controller,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: '... اكتب رسالتك',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../core/utils/custom_loader.dart';
import '../../application/acc_bloc.dart';
import '../../domain/models/admin_chat_model.dart';
import '../widgets/top_bar.dart';

class AdminChat extends StatelessWidget {
  static const String routeName = '/adminchat';

  const AdminChat({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetUserDetailsEvent())
        ..add(GetAdminChatHistoryListEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {},
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            body: TopBarDesign(
              isHistoryPage: false,
              title: AppLocalizations.of(context)!.adminChat,
              onTap: () {
                Navigator.of(context).pop();
                context.read<AccBloc>().chatStream!.cancel();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                      controller: context.read<AccBloc>().scroolController,
                      child: Column(
                        children: [
                          buildAdminChatHistoryData(
                              size, context.read<AccBloc>().adminChatList),
                        ],
                      ),
                    )),
                    Container(
                      margin: EdgeInsets.only(top: size.width * 0.020),
                      padding: EdgeInsets.fromLTRB(
                          size.width * 0.025, 0, size.width * 0.025, 0),
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: AppColors.darkGrey, width: 1.2),
                          color: Theme.of(context).scaffoldBackgroundColor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: size.width * 0.7,
                            child: TextField(
                              style: const TextStyle(
                                  // color: AppColors.black,
                                  decoration: TextDecoration.none),
                              controller: context.read<AccBloc>().adminchatText,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    AppLocalizations.of(context)!.typeMessage,
                              ),
                              minLines: 1,
                              maxLines: 4,
                            ),
                          ),
                          InkWell(
                              onTap: () {
                                if (context
                                    .read<AccBloc>()
                                    .adminchatText
                                    .text
                                    .isNotEmpty) {
                                  context.read<AccBloc>().add(
                                      SendAdminMessageEvent(
                                          newChat:
                                              context
                                                      .read<AccBloc>()
                                                      .adminChatList
                                                      .isEmpty
                                                  ? '0'
                                                  : '1',
                                          message:
                                              context
                                                  .read<AccBloc>()
                                                  .adminchatText
                                                  .text,
                                          chatId: context
                                                  .read<AccBloc>()
                                                  .adminChatList
                                                  .isEmpty
                                              ? ""
                                              : context
                                                  .read<AccBloc>()
                                                  .adminChatList[0]
                                                  .conversationId));
                                  context.read<AccBloc>().adminchatText.clear();
                                }
                              },
                              child: const Icon(
                                Icons.send,
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.05,
                    )
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget buildAdminChatHistoryData(Size size, List<ChatData> adminChatList) {
    return adminChatList.isNotEmpty
        ? RawScrollbar(
            radius: const Radius.circular(20),
            child: ListView.builder(
              itemCount: adminChatList.length,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<AccBloc>().scroolController.animateTo(
                      context
                          .read<AccBloc>()
                          .scroolController
                          .position
                          .maxScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease);
                });
                return (userData != null)
                    ? Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: size.width * 0.01),
                            width: size.width * 0.9,
                            alignment: (adminChatList[index].senderId ==
                                    userData!.userId.toString())
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment:
                                  (adminChatList[index].senderId.toString() ==
                                          userData!.userId.toString())
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                (adminChatList[index].senderId.toString() ==
                                        userData!.userId.toString())
                                    ? Card(
                                        elevation: 5,
                                        child: Container(
                                          width: size.width * 0.5,
                                          padding:
                                              EdgeInsets.all(size.width * 0.03),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: (adminChatList[index]
                                                            .senderId
                                                            .toString() ==
                                                        userData!.userId
                                                            .toString())
                                                    ? Radius.circular(
                                                        size.width * 0.02)
                                                    : const Radius.circular(0),
                                                topRight: (adminChatList[index]
                                                            .senderId
                                                            .toString() ==
                                                        userData!.userId
                                                            .toString())
                                                    ? const Radius.circular(0)
                                                    : Radius.circular(
                                                        size.width * 0.02),
                                                bottomRight: Radius.circular(
                                                    size.width * 0.02),
                                                bottomLeft: Radius.circular(
                                                    size.width * 0.02),
                                              ),
                                              color: (adminChatList[index]
                                                          .senderId
                                                          .toString() ==
                                                      userData!.userId
                                                          .toString())
                                                  ? (Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark)
                                                      ? const Color(0xffE7EDEF)
                                                      : AppColors.black
                                                  : const Color(0xffE7EDEF)),
                                          child: MyText(
                                            text: adminChatList[index].message,
                                            overflow: TextOverflow.visible,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: (adminChatList[index]
                                                                .senderId
                                                                .toString() ==
                                                            userData!.userId
                                                                .toString())
                                                        ? (Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark)
                                                            ? AppColors.black
                                                            : AppColors.white
                                                        : AppColors.black),
                                          ),
                                        ),
                                      )
                                    : Card(
                                        elevation: 5,
                                        child: Container(
                                          width: size.width * 0.5,
                                          padding:
                                              EdgeInsets.all(size.width * 0.03),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: (adminChatList[index]
                                                            .senderId
                                                            .toString() ==
                                                        userData!.userId
                                                            .toString())
                                                    ? Radius.circular(
                                                        size.width * 0.02)
                                                    : const Radius.circular(0),
                                                topRight: (adminChatList[index]
                                                            .senderId
                                                            .toString() ==
                                                        userData!.userId
                                                            .toString())
                                                    ? const Radius.circular(0)
                                                    : Radius.circular(
                                                        size.width * 0.02),
                                                bottomRight: Radius.circular(
                                                    size.width * 0.02),
                                                bottomLeft: Radius.circular(
                                                    size.width * 0.02),
                                              ),
                                              color: (adminChatList[index]
                                                          .senderId
                                                          .toString() ==
                                                      userData!.userId
                                                          .toString())
                                                  ? (Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark)
                                                      ? const Color(0xffE7EDEF)
                                                      : AppColors.black
                                                  : const Color(0xffE7EDEF)),
                                          child: MyText(
                                            text: adminChatList[index].message,
                                            overflow: TextOverflow.visible,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: (adminChatList[index]
                                                                .senderId
                                                                .toString() ==
                                                            userData!.userId
                                                                .toString())
                                                        ? (Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark)
                                                            ? AppColors.black
                                                            : AppColors.white
                                                        : AppColors.black),
                                          ),
                                        ),
                                      ),
                                SizedBox(
                                  height: size.width * 0.01,
                                ),
                                MyText(
                                  text: adminChatList[index].userTimezone,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color:
                                              Theme.of(context).dividerColor),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    : const Scaffold(
                        body: Loader(),
                      );
              },
            ),
          )
        : const SizedBox();
  }
}

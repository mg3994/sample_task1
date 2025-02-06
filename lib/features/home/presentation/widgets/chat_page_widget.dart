import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../core/utils/custom_loader.dart';

Stack chatPageWidget(Size size, BuildContext context) {
  return Stack(
    children: [
      Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          image: const DecorationImage(
            alignment: Alignment.topCenter,
            image: AssetImage(AppImages.map),
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
            SizedBox(
              width: size.width * 0.9,
              child: Row(
                children: [
                  Container(
                    height: size.height * 0.07,
                    width: size.width * 0.07,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(5.0, 5.0),
                          blurRadius: 10.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        context.read<HomeBloc>().add(ChatSeenEvent());
                        context.read<HomeBloc>().add(ShowChatEvent());
                      },
                      child: Icon(
                        CupertinoIcons.back,
                        size: 20,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.0,
            ),
            SizedBox(
              width: size.width * 0.9,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {},
                      child: MyText(
                        text: userData!.onTripRequest!.userName,
                        textStyle:
                            Theme.of(context).textTheme.titleLarge!.copyWith(
                                  color: Theme.of(context).primaryColorLight,
                                ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Container(
                    height: size.width * 0.13,
                    width: size.width * 0.13,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color:
                            Theme.of(context).disabledColor.withOpacity(0.2)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: CachedNetworkImage(
                        imageUrl: userData!.onTripRequest!.userImage,
                        fit: BoxFit.fill,
                        placeholder: (context, url) => const Center(
                          child: Loader(),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Text(""),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      Positioned(
          bottom: 0,
          child: Container(
            height: size.height * 0.8,
            width: size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        (languageDirection == 'ltr') ? size.width * 0.14 : 0),
                    topRight: Radius.circular(
                        (languageDirection == 'rtl') ? size.width * 0.14 : 0))),
            padding: EdgeInsets.fromLTRB(size.width * 0.05, size.width * 0.05,
                size.width * 0.05, size.width * 0.05),
            child: Scaffold(
              body: Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: context
                          .read<HomeBloc>()
                          .chats
                          .asMap()
                          .map((k, v) {
                            return MapEntry(
                                k,
                                SizedBox(
                                  width: size.width * 0.9,
                                  child: Column(
                                    crossAxisAlignment: (context
                                                .read<HomeBloc>()
                                                .chats[k]['from_type'] ==
                                            1)
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.end,
                                    children: [
                                      Card(
                                        elevation: 5,
                                        child: Container(
                                          width: size.width * 0.5,
                                          padding:
                                              EdgeInsets.all(size.width * 0.03),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: (context
                                                                .read<HomeBloc>()
                                                                .chats[k]
                                                            ['from_type'] !=
                                                        1)
                                                    ? Radius.circular(
                                                        size.width * 0.02)
                                                    : const Radius.circular(0),
                                                topRight: (context
                                                                .read<HomeBloc>()
                                                                .chats[k]
                                                            ['from_type'] !=
                                                        1)
                                                    ? const Radius.circular(0)
                                                    : Radius.circular(
                                                        size.width * 0.02),
                                                bottomRight: Radius.circular(
                                                    size.width * 0.02),
                                                bottomLeft: Radius.circular(
                                                    size.width * 0.02),
                                              ),
                                              color: (context
                                                              .read<HomeBloc>()
                                                              .chats[k]
                                                          ['from_type'] !=
                                                      1)
                                                  ? (Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark)
                                                      ? const Color(0xffE7EDEF)
                                                      : AppColors.black
                                                  : const Color(0xffE7EDEF)
                                              // ? Theme.of(context)
                                              //     .primaryColor
                                              // : Theme.of(context)
                                              //     .primaryColorDark
                                              ),
                                          child: MyText(
                                            text: context
                                                .read<HomeBloc>()
                                                .chats[k]['message'],
                                            maxLines: 5,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                    color: (context
                                                                    .read<
                                                                        HomeBloc>()
                                                                    .chats[k]
                                                                ['from_type'] !=
                                                            1)
                                                        ? (Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark)
                                                            ? AppColors.black
                                                            : AppColors.white
                                                        : AppColors.black
                                                    // ? AppColors.white
                                                    // : Theme.of(context)
                                                    //     .scaffoldBackgroundColor,
                                                    ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      MyText(
                                        text: context.read<HomeBloc>().chats[k]
                                            ['converted_created_at'],
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                      )
                                    ],
                                  ),
                                ));
                          })
                          .values
                          .toList(),
                    ),
                  )),
                  SizedBox(
                    height: size.width * 0.05,
                  ),
                  SizedBox(
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            controller: context.read<HomeBloc>().chatField,
                            hintText: AppLocalizations.of(context)!.typeMessage,
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.03,
                        ),
                        InkWell(
                            onTap: () {
                              if (context
                                  .read<HomeBloc>()
                                  .chatField
                                  .text
                                  .isNotEmpty) {
                                context.read<HomeBloc>().add(SendChatEvent());
                              }
                            },
                            child: Icon(
                              Icons.send,
                              color: Theme.of(context).primaryColorDark,
                            ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(Scaffold.of(context).context)
                        .viewInsets
                        .bottom,
                  )
                ],
              ),
            ),
          ))
    ],
  );
}

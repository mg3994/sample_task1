import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../core/utils/custom_snack_bar.dart';
import '../../../../core/utils/custom_textfield.dart';

Container reviewPageWidget(Size size, BuildContext context) {
  return Container(
    width: size.width,
    height: size.height,
    decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(size.width * 0.2))),
    padding: EdgeInsets.all(size.width * 0.05),
    child: Column(
      children: [
        SizedBox(
          width: size.width * 0.9,
          child: const Row(
            children: [],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: size.width * 0.29,
                ),
                Container(
                  height: size.width * 0.2,
                  width: size.width * 0.2,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image:
                              NetworkImage(userData!.onTripRequest!.userImage),
                          fit: BoxFit.cover)),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
                MyText(
                  text: AppLocalizations.of(context)!
                      .howWasYourLastRide
                      .toString()
                      .replaceAll('1111', userData!.onTripRequest!.userName),
                  textStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).primaryColorDark),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
                SizedBox(
                  width: size.width * 0.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 1; i < 6; i++)
                        InkWell(
                            onTap: () {
                              context
                                  .read<HomeBloc>()
                                  .add(ReviewUpdateEvent(star: i));
                            },
                            child: Icon(
                              Icons.star,
                              size: size.width * 0.09,
                              color: (context.read<HomeBloc>().review >= i)
                                  ? AppColors.primary
                                  : Theme.of(context).primaryColorDark,
                            )),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * 0.1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CustomTextField(
                    controller: context.read<HomeBloc>().reviewController,
                    filled: true,
                    hintText: AppLocalizations.of(context)!.leaveFeedback,
                    maxLine: 5,
                  ),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: CustomButton(
              buttonName: AppLocalizations.of(context)!.submit,
              width: 250,
              onTap: () {
                if (context.read<HomeBloc>().review != 0) {
                  context.read<HomeBloc>().add(UploadReviewEvent());
                } else {
                  showToast(
                      message: AppLocalizations.of(context)!.giveRatingsError);
                }
              }),
        )
      ],
    ),
  );
}

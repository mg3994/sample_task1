import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/network/endpoints.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../common/app_constants.dart';
import '../../../../common/pickup_icon.dart';
import '../../../../core/utils/custom_divider.dart';
import '../../../../core/utils/custom_sliderbutton.dart';

Widget onRideWidget(Size size, BuildContext context) {
  return Column(
    children: [
      Container(
        color: Colors.black12,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30)),
                  color: Theme.of(context).scaffoldBackgroundColor),
              child: Column(
                children: [
                  SizedBox(height: size.width * 0.04),
                  Container(
                    width: size.width * 0.15,
                    height: size.width * 0.01,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        color:
                            Theme.of(context).disabledColor.withOpacity(0.3)),
                  ),
                  SizedBox(height: size.width * 0.03),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, bottom: 10, top: 10, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: MyText(
                              text: (userData?.onTripRequest!.arrivedAt == null)
                                  ? AppLocalizations.of(context)!.onWayToPickup
                                  : (userData?.onTripRequest!.isTripStart == 0)
                                      ? AppLocalizations.of(context)!
                                          .arrivedWaiting
                                      : AppLocalizations.of(context)!
                                          .onTheWayToDrop,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.bold),
                            )),
                            if (userData!.onTripRequest!.arrivedAt != null &&
                                userData!.onTripRequest!.isBidRide == "0" &&
                                !userData!.onTripRequest!.isRental)
                              Stack(
                                alignment: AlignmentDirectional.bottomCenter,
                                children: [
                                  Image.asset(
                                    AppImages.waitingTime,
                                    color: Theme.of(context).disabledColor,
                                    width: size.width * 0.098,
                                    fit: BoxFit.contain,
                                  ),
                                  Positioned(
                                      child: Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Theme.of(context).shadowColor,
                                            spreadRadius: 1,
                                            blurRadius: 1)
                                      ],
                                      color: AppColors.secondary,
                                    ),
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 2, 5, 2),
                                    child: MyText(
                                      text:
                                          '${(Duration(seconds: (context.read<HomeBloc>().waitingTimeBeforeStart + context.read<HomeBloc>().waitingTimeAfterStart)).inHours.toString().padLeft(2, '0'))} : ${((Duration(seconds: (context.read<HomeBloc>().waitingTimeBeforeStart + context.read<HomeBloc>().waitingTimeAfterStart)).inMinutes - (Duration(seconds: (context.read<HomeBloc>().waitingTimeBeforeStart + context.read<HomeBloc>().waitingTimeAfterStart)).inHours * 60)).toString().padLeft(2, '0'))} hr',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(color: Colors.black),
                                    ),
                                  ))
                                ],
                              )
                          ],
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: HorizontalDotDividerWidget(),
                      ),
                      SizedBox(height: size.width * 0.02),
                      if (userData!.onTripRequest!.arrivedAt != null &&
                          userData!.onTripRequest!.isBidRide == "0" &&
                          !userData!.onTripRequest!.isRental)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: size.width * 0.7,
                                child: MyText(
                                  text: AppLocalizations.of(context)!
                                      .waitingText
                                      .replaceAll("***",
                                          "${userData!.currencySymbol} ${userData!.onTripRequest!.waitingCharge}")
                                      .replaceAll("*", "5"),
                                  maxLines: 2,
                                  textStyle:
                                      Theme.of(context).textTheme.bodySmall!,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: size.width * 0.05),
                  Container(
                    width: size.width * 0.93,
                    padding: EdgeInsets.all(size.width * 0.05),
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 0.5, color: Theme.of(context).disabledColor),
                        borderRadius: BorderRadius.circular(8),
                        color:
                            Theme.of(context).disabledColor.withOpacity(0.3)),
                    child: Row(
                      children: [
                        Container(
                          width: size.width * 0.128,
                          height: size.width * 0.128,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(
                                      userData!.onTripRequest!.userImage),
                                  fit: BoxFit.cover)),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: userData!.onTripRequest!.userName,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: AppColors.black,
                                        fontWeight: FontWeight.w600),
                              ),
                              Row(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 15,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      MyText(
                                        text: userData!.onTripRequest!.ratings
                                            .toString(),
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: AppColors.black,
                                                fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  if (userData!
                                          .onTripRequest!.completedRideCount
                                          .toString() !=
                                      '0')
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: 5),
                                        Container(
                                          width: 1,
                                          height: 20,
                                          color: Theme.of(context)
                                              .disabledColor
                                              .withOpacity(0.5),
                                        ),
                                        const SizedBox(width: 5),
                                        MyText(
                                          text:
                                              '${userData!.onTripRequest!.completedRideCount.toString()} ${AppLocalizations.of(context)!.tripsDoneText}',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  color: AppColors.black,
                                                  fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (userData!.onTripRequest!.showRequestEtaAmount ==
                            true)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              (userData!.onTripRequest!.rentalPackageId == null)
                                  ? MyText(
                                      text: AppLocalizations.of(context)!
                                          .rideFare,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: AppColors.black,
                                              fontWeight: FontWeight.bold),
                                    )
                                  : SizedBox(
                                      width: size.width * 0.3,
                                      child: MyText(
                                        text: userData!
                                            .onTripRequest!.rentalPackageName,
                                        textAlign: (languageDirection == 'ltr')
                                            ? TextAlign.right
                                            : TextAlign.left,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: AppColors.black,
                                                fontWeight: FontWeight.bold),
                                      )),
                              MyText(
                                text: (userData!.onTripRequest!.isBidRide ==
                                        "0")
                                    ? '${userData!.onTripRequest!.currencySymbol}${userData!.onTripRequest!.requestEtaAmount}'
                                    : '${userData!.onTripRequest!.currencySymbol}${userData!.onTripRequest!.acceptedRideFare}',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .headlineLarge!
                                    .copyWith(
                                        color: AppColors.green,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                textAlign: (languageDirection == 'ltr')
                                    ? TextAlign.right
                                    : TextAlign.left,
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                  SizedBox(height: size.width * 0.05),
                  if (userData != null &&
                      userData!.onTripRequest != null &&
                      userData!.onTripRequest!.isTripStart == 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                context
                                    .read<HomeBloc>()
                                    .add(GetRideChatEvent());
                                context.read<HomeBloc>().add(ShowChatEvent());
                              },
                              child: Container(
                                height: size.width * 0.100,
                                width: size.width * 0.110,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context)
                                        .disabledColor
                                        .withOpacity(0.3),
                                    border: Border.all(
                                        width: 0.5,
                                        color: AppColors.darkGrey
                                            .withOpacity(0.8))),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.message,
                                  size: size.width * 0.05,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            if (context.read<HomeBloc>().chats.isNotEmpty &&
                                context
                                    .read<HomeBloc>()
                                    .chats
                                    .where((e) =>
                                        e['from_type'] == 1 && e['seen'] == 0)
                                    .isNotEmpty)
                              Positioned(
                                top: size.width * 0.01,
                                right: size.width * 0.008,
                                child: Container(
                                  height: size.width * 0.03,
                                  width: size.width * 0.03,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          Theme.of(context).colorScheme.error),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: size.width * 0.025),
                        InkWell(
                          onTap: () async {
                            context.read<HomeBloc>().add(OpenAnotherFeatureEvent(
                                value:
                                    'tel:${userData!.onTripRequest!.userMobile}'));
                          },
                          child: Container(
                            height: size.width * 0.100,
                            width: size.width * 0.110,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context)
                                    .disabledColor
                                    .withOpacity(0.3),
                                border: Border.all(
                                    width: 0.5,
                                    color:
                                        AppColors.darkGrey.withOpacity(0.8))),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.call,
                              size: size.width * 0.05,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.025,
                        ),
                        // InkWell(
                        //   onTap: () async {
                        //     if (userData!.onTripRequest!.isTripStart == 0) {
                        //       context.read<HomeBloc>().add(OpenAnotherFeatureEvent(
                        //           value:
                        //               '${ApiEndpoints.openMap}${userData!.onTripRequest!.pickLat},${userData!.onTripRequest!.pickLng}'));
                        //     } else {
                        //       context.read<HomeBloc>().add(OpenAnotherFeatureEvent(
                        //           value:
                        //               '${ApiEndpoints.openMap}${userData!.onTripRequest!.dropLat},${userData!.onTripRequest!.dropLng}'));
                        //     }
                        //   },
                        //   child: Container(
                        //     height: size.width * 0.100,
                        //     width: size.width * 0.110,
                        //     decoration: BoxDecoration(
                        //         shape: BoxShape.circle,
                        //         color: const Color(0xffF8F0F9),
                        //         border: Border.all(
                        //             width: 0.5,
                        //             color: Theme.of(context)
                        //                 .primaryColor
                        //                 .withOpacity(0.8))),
                        //     alignment: Alignment.center,
                        //     child: Icon(
                        //       Icons.near_me_rounded,
                        //       size: size.width * 0.05,
                        //       color: Theme.of(context).primaryColor,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  SizedBox(height: size.width * 0.05),
                  SizedBox(
                    width: size.width * 0.9,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PickupIcon(),
                        SizedBox(
                          width: size.width * 0.025,
                        ),
                        Expanded(
                            child: MyText(
                          text: userData!.onTripRequest!.pickAddress,
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                          maxLines: 5,
                        ))
                      ],
                    ),
                  ),
                  if (userData!.onTripRequest!.pickPocInstruction != null &&
                      userData!.onTripRequest!.pickPocInstruction != '')
                    Column(
                      children: [
                        SizedBox(height: size.width * 0.03),
                        SizedBox(
                          width: size.width * 0.8,
                          child: MyText(
                              text:
                                  userData!.onTripRequest!.pickPocInstruction),
                        )
                      ],
                    ),
                  (userData!.onTripRequest!.requestStops.isEmpty &&
                          userData!.onTripRequest!.dropAddress != null)
                      ? Column(
                          children: [
                            SizedBox(height: size.width * 0.03),
                            SizedBox(
                              width: size.width * 0.91,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const DropIcon(),
                                  SizedBox(width: size.width * 0.025),
                                  Expanded(
                                      child: MyText(
                                    text: userData!.onTripRequest!.dropAddress,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                    maxLines: 5,
                                  )),
                                  if (userData!.onTripRequest!.transportType ==
                                          'delivery' &&
                                      userData!.onTripRequest!.dropPocMobile !=
                                          null)
                                    Row(
                                      children: [
                                        SizedBox(width: size.width * 0.025),
                                        InkWell(
                                          borderRadius: BorderRadius.circular(
                                              size.width * 0.05),
                                          onTap: () {
                                            context.read<HomeBloc>().add(
                                                OpenAnotherFeatureEvent(
                                                    value:
                                                        'tel:${userData!.onTripRequest!.dropPocMobile!}'));
                                          },
                                          child: Image.asset(
                                            AppImages.call,
                                            width: size.width * 0.05,
                                            height: size.width * 0.05,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            if (userData!.onTripRequest!.dropPocInstruction !=
                                    null &&
                                userData!.onTripRequest!.dropPocInstruction !=
                                    '')
                              Column(
                                children: [
                                  SizedBox(height: size.width * 0.03),
                                  SizedBox(
                                    width: size.width * 0.8,
                                    child: MyText(
                                        text: userData!
                                            .onTripRequest!.dropPocInstruction),
                                  )
                                ],
                              )
                          ],
                        )
                      : (userData != null &&
                              userData!.onTripRequest!.requestStops.isNotEmpty)
                          ? Column(
                              children: [
                                for (var i = 0;
                                    i <
                                        userData!
                                            .onTripRequest!.requestStops.length;
                                    i++)
                                  Column(
                                    children: [
                                      SizedBox(height: size.width * 0.03),
                                      SizedBox(
                                        width: size.width * 0.9,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                              AppImages.dropAddressImageIcon,
                                              height: size.width * 0.05,
                                              width: size.width * 0.05,
                                              fit: BoxFit.contain,
                                              color: (userData!.onTripRequest!
                                                              .requestStops[i]
                                                          ['completed_at'] !=
                                                      null)
                                                  ? AppColors.secondary
                                                  : null,
                                            ),
                                            SizedBox(width: size.width * 0.025),
                                            Expanded(
                                                child: MyText(
                                              text: userData!.onTripRequest!
                                                  .requestStops[i]['address'],
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: (userData!
                                                                      .onTripRequest!
                                                                      .requestStops[i]
                                                                  [
                                                                  'completed_at'] !=
                                                              null)
                                                          ? AppColors.darkGrey
                                                          : null,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500),
                                              maxLines: 5,
                                            )),
                                            if (userData!.onTripRequest!
                                                    .transportType ==
                                                'delivery')
                                              Row(
                                                children: [
                                                  SizedBox(
                                                      width:
                                                          size.width * 0.025),
                                                  InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size.width * 0.05),
                                                    onTap: () {
                                                      context.read<HomeBloc>().add(
                                                          OpenAnotherFeatureEvent(
                                                              value:
                                                                  'tel:${userData!.onTripRequest!.requestStops[i]['poc_mobile']}'));
                                                    },
                                                    child: Image.asset(
                                                      AppImages.call,
                                                      width: size.width * 0.05,
                                                      height: size.width * 0.05,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (userData!.onTripRequest!
                                                    .transportType ==
                                                'delivery')
                                              Row(
                                                children: [
                                                  SizedBox(
                                                      width:
                                                          size.width * 0.025),
                                                  InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size.width * 0.05),
                                                    onTap: () {
                                                      context.read<HomeBloc>().add(
                                                          OpenAnotherFeatureEvent(
                                                              value:
                                                                  '${ApiEndpoints.openMap}${userData!.onTripRequest!.requestStops[i]['latitude']},${userData!.onTripRequest!.requestStops[i]['longitude']}'));
                                                    },
                                                    child: Icon(
                                                      CupertinoIcons
                                                          .location_fill,
                                                      size: size.width * 0.05,
                                                      color: AppColors.black,
                                                    ),
                                                  ),
                                                ],
                                              )
                                          ],
                                        ),
                                      ),
                                      if (userData!.onTripRequest!
                                                      .requestStops[i]
                                                  ['poc_instruction'] !=
                                              null &&
                                          userData!.onTripRequest!
                                                      .requestStops[i]
                                                  ['poc_instruction'] !=
                                              '')
                                        Column(
                                          children: [
                                            SizedBox(height: size.width * 0.03),
                                            SizedBox(
                                              width: size.width * 0.8,
                                              child: MyText(
                                                  text: userData!.onTripRequest!
                                                          .requestStops[i]
                                                      ['poc_instruction']),
                                            )
                                          ],
                                        )
                                    ],
                                  ),
                              ],
                            )
                          : Container(),
                  if (userData!.onTripRequest!.isPetAvailable == 1 ||
                      userData!.onTripRequest!.isLuggageAvailable == 1)
                    Column(
                      children: [
                        SizedBox(height: size.width * 0.05),
                        SizedBox(
                          width: size.width * 0.9,
                          child: Row(
                            children: [
                              MyText(
                                  text:
                                      '${AppLocalizations.of(context)!.preferences} :- ',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark)),
                              if (userData!.onTripRequest!.isPetAvailable == 1)
                                Icon(
                                  Icons.pets,
                                  size: size.width * 0.05,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              if (userData!.onTripRequest!.isLuggageAvailable ==
                                  1)
                                Icon(
                                  Icons.luggage,
                                  size: size.width * 0.05,
                                  color: Theme.of(context).primaryColorDark,
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: size.width * 0.1),
                  Container(
                    margin: EdgeInsets.only(
                        left: size.width * 0.05, right: size.width * 0.05),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: size.width * 0.5,
                                child: MyText(
                                    text: userData!.onTripRequest!.isRental
                                        ? userData!
                                            .onTripRequest!.rentalPackageName
                                        : AppLocalizations.of(context)!
                                            .rideFare,
                                    maxLines: 2,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontWeight: FontWeight.w600)),
                              ),
                              (userData!.onTripRequest!.isBidRide == "1")
                                  ? MyText(
                                      text:
                                          '${userData!.currencySymbol} ${userData!.onTripRequest!.acceptedRideFare}',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .copyWith(
                                              color: AppColors.green,
                                              fontWeight: FontWeight.bold))
                                  : (userData!.onTripRequest!.discountedTotal !=
                                              null &&
                                          userData!.onTripRequest!
                                                  .discountedTotal !=
                                              "")
                                      ? MyText(
                                          text:
                                              '${userData!.currencySymbol} ${userData!.onTripRequest!.discountedTotal}',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .displayLarge!
                                              .copyWith(
                                                  color: AppColors.green,
                                                  fontWeight: FontWeight.bold))
                                      : MyText(
                                          text:
                                              '${userData!.currencySymbol} ${userData!.onTripRequest!.requestEtaAmount}',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .displayLarge!
                                              .copyWith(
                                                  color: AppColors.green,
                                                  fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            MyText(
                                text: userData!.onTripRequest!.paymentOpt == '1'
                                    ? AppLocalizations.of(context)!.cash
                                    : userData!.onTripRequest!.paymentOpt == '2'
                                        ? AppLocalizations.of(context)!.wallet
                                        : AppLocalizations.of(context)!.card,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(fontWeight: FontWeight.bold)),
                            SizedBox(
                              width: size.width * 0.025,
                            ),
                            Icon(
                              userData!.onTripRequest!.paymentOpt == '1'
                                  ? Icons.payments_outlined
                                  : userData!.onTripRequest!.paymentOpt == '0'
                                      ? Icons.credit_card_rounded
                                      : Icons.account_balance_wallet_outlined,
                              size: size.width * 0.05,
                              color: AppColors.green,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: size.width * 0.1),
                  CustomSliderButton(
                    sliderIcon: Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      color: AppColors.white,
                      size: size.width * 0.07,
                    ),
                    buttonName: (userData!.onTripRequest!.arrivedAt == null)
                        ? AppLocalizations.of(context)!.arrived
                        : (userData!.onTripRequest!.isTripStart == 0)
                            ? (userData!.onTripRequest!.transportType == 'taxi')
                                ? AppLocalizations.of(context)!.startRide
                                : AppLocalizations.of(context)!.pickGoods
                            : (userData!.onTripRequest!.transportType == 'taxi')
                                ? AppLocalizations.of(context)!.endRide
                                : AppLocalizations.of(context)!.dispatchGoods,
                    onSlideSuccess: () async {
                      if (userData != null && userData!.onTripRequest != null) {
                        if (userData!.onTripRequest!.requestStops.isNotEmpty &&
                            userData!.onTripRequest!.isTripStart == 1 &&
                            userData!.onTripRequest!.requestStops
                                    .where((e) => e['completed_at'] == null)
                                    .length >
                                1) {
                          context.read<HomeBloc>().add(ShowChooseStopEvent());
                        } else if (userData!.onTripRequest!.arrivedAt == null) {
                          context.read<HomeBloc>().add(RideArrivedEvent(
                              requestId: userData!.onTripRequest!.id));
                        } else if (userData!.onTripRequest!.isTripStart == 0) {
                          if (userData!.onTripRequest!.showOtpFeature == true) {
                            context.read<HomeBloc>().add(ShowOtpEvent());
                          } else {
                            if (userData!.onTripRequest!.transportType ==
                                    'delivery' &&
                                userData!.onTripRequest!.enableShipmentLoad ==
                                    '1') {
                              context
                                  .read<HomeBloc>()
                                  .add(ShowImagePickEvent());
                            } else {
                              context.read<HomeBloc>().add(RideStartEvent(
                                  requestId: userData!.onTripRequest!.id,
                                  otp: '',
                                  pickLat: userData!.onTripRequest!.pickLat,
                                  pickLng: userData!.onTripRequest!.pickLng));
                            }
                          }
                        } else {
                          if (userData!.onTripRequest!.transportType ==
                                  'delivery' &&
                              userData!.onTripRequest!.enableShipmentUnload ==
                                  '1') {
                            context.read<HomeBloc>().add(ShowImagePickEvent());
                          } else if (userData!.onTripRequest!.transportType ==
                                  'delivery' &&
                              userData!.onTripRequest!.enableDigitalSignature ==
                                  '1') {
                            context.read<HomeBloc>().add(ShowSignatureEvent());
                          } else {
                            if (userData!.onTripRequest!.isRental == false &&
                                userData!.onTripRequest!.isOutstation != 1 &&
                                userData!.onTripRequest!.dropAddress != null) {
                              context.read<HomeBloc>().add(RideEndEvent());
                            } else {
                              context.read<HomeBloc>().add(GeocodingLatLngEvent(
                                  lat: context
                                      .read<HomeBloc>()
                                      .currentLatLng!
                                      .latitude,
                                  lng: context
                                      .read<HomeBloc>()
                                      .currentLatLng!
                                      .longitude));
                            }
                          }
                        }
                        return true;
                      }
                      return null;
                    },
                  ),
                  if (userData!.onTripRequest!.isTripStart == 0)
                    Column(
                      children: [
                        SizedBox(
                          height: size.width * 0.05,
                        ),
                        InkWell(
                          onTap: () {
                            context
                                .read<HomeBloc>()
                                .add(GetCancelReasonEvent());
                          },
                          child: MyText(
                              text: AppLocalizations.of(context)!.cancelRide,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    color: AppColors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  )),
                        )
                      ],
                    ),
                  SizedBox(
                    height: size.width * 0.05,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

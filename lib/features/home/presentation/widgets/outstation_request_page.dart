import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/pickup_icon.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

Column outstationRequestWidget(BuildContext context, Size size) {
  if (context.read<HomeBloc>().bidRideAmount.text.isEmpty && context.read<HomeBloc>().outStationList.isNotEmpty) {
    context.read<HomeBloc>().bidRideAmount.text =
        '${context.read<HomeBloc>().outStationList.firstWhere((e) => e['request_id'] == context.read<HomeBloc>().choosenRide)['price']}';
  }
  List stops = [];
  if (context.read<HomeBloc>().outStationList.isNotEmpty&&context.read<HomeBloc>().outStationList.firstWhere((e) =>
          e['request_id'] ==
          context.read<HomeBloc>().choosenRide)['trip_stops'] !=
      'null') {
    stops = jsonDecode(context.read<HomeBloc>().outStationList.firstWhere((e) =>
        e['request_id'] == context.read<HomeBloc>().choosenRide)['trip_stops']);
  }
  return Column(
    children: [
      SizedBox(height: size.width * 0.01),
      Container(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Row(
          children: [
            Container(
              width: size.width * 0.128,
              height: size.width * 0.128,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(context
                          .read<HomeBloc>()
                          .outStationList
                          .firstWhere((e) =>
                              e['request_id'] ==
                              context
                                  .read<HomeBloc>()
                                  .choosenRide)['user_img']),
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
                    text: context.read<HomeBloc>().outStationList.firstWhere(
                        (e) =>
                            e['request_id'] ==
                            context.read<HomeBloc>().choosenRide)['user_name'],
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.black, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.star,
                            size: 12.5,
                            color: Theme.of(context).primaryColor,
                          ),
                          MyText(
                            text:
                                '${context.read<HomeBloc>().outStationList.firstWhere((e) => e['request_id'] == context.read<HomeBloc>().choosenRide)['ratings']}',
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      if (context.read<HomeBloc>().outStationList.firstWhere(
                              (e) =>
                                  e['request_id'] ==
                                  context
                                      .read<HomeBloc>()
                                      .choosenRide)['completed_ride_count'] !=
                          '0')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                  '${context.read<HomeBloc>().outStationList.firstWhere((e) => e['request_id'] == context.read<HomeBloc>().choosenRide)['completed_ride_count']} ${AppLocalizations.of(context)!.tripsDoneText}',
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
                  SizedBox(
                    height: size.width * 0.02,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                          text:
                              '${context.read<HomeBloc>().outStationList.firstWhere((e) => e['request_id'] == context.read<HomeBloc>().choosenRide)['start_date']}',
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontSize: 12)),
                      context.read<HomeBloc>().outStationList.firstWhere((e) =>
                                  e['request_id'] ==
                                  context
                                      .read<HomeBloc>()
                                      .choosenRide)['trip_type'] ==
                              'Round Trip'
                          ? MyText(
                              text: context
                                  .read<HomeBloc>()
                                  .outStationList
                                  .firstWhere((e) =>
                                      e['request_id'] ==
                                      context
                                          .read<HomeBloc>()
                                          .choosenRide)['return_date'],
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontSize: 12))
                          : SizedBox()
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: size.width * 0.03,
            ),
            Column(
              children: [
                MyText(
                  text: AppLocalizations.of(context)!.rideFare,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.black, fontWeight: FontWeight.bold),
                ),
                MyText(
                  text:
                      '${context.read<HomeBloc>().outStationList.firstWhere((e) => e['request_id'] == context.read<HomeBloc>().choosenRide)['currency']}${context.read<HomeBloc>().outStationList.firstWhere((e) => e['request_id'] == context.read<HomeBloc>().choosenRide)['price']}',
                  textStyle: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(
                          color: AppColors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                ),
                MyText(
                  text:
                      '${context.read<HomeBloc>().outStationList.firstWhere((e) => e['request_id'] == context.read<HomeBloc>().choosenRide)['trip_type']}',
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.yellowColor,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
      SizedBox(
        height: size.width * 0.03,
      ),
      SizedBox(
        width: size.width * 0.8,
        child: Row(
          children: [
            PickupIcon(),
            SizedBox(
              width: size.width * 0.025,
            ),
            Expanded(
                child: MyText(
              text: context.read<HomeBloc>().outStationList.firstWhere((e) =>
                  e['request_id'] ==
                  context.read<HomeBloc>().choosenRide)['pick_address'],
              textStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
            ))
          ],
        ),
      ),
      (stops.isEmpty)
          ? Column(
              children: [
                SizedBox(
                  height: size.width * 0.03,
                ),
                SizedBox(
                  width: size.width * 0.8,
                  child: Row(
                    children: [
                      Image.asset(
                        AppImages.dropAddressImageIcon,
                        height: size.width * 0.05,
                        width: size.width * 0.05,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Expanded(
                          child: MyText(
                        text: context
                            .read<HomeBloc>()
                            .outStationList
                            .firstWhere((e) =>
                                e['request_id'] ==
                                context
                                    .read<HomeBloc>()
                                    .choosenRide)['drop_address'],
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                                fontSize: 14, fontWeight: FontWeight.w500),
                      ))
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                for (var i = 0; i < stops.length; i++)
                  Column(
                    children: [
                      SizedBox(
                        height: size.width * 0.01,
                      ),
                      SizedBox(
                        width: size.width * 0.8,
                        child: Row(
                          children: [
                            Image.asset(
                              AppImages.dropAddressImageIcon,
                              height: size.width * 0.05,
                              width: size.width * 0.05,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(
                              width: size.width * 0.025,
                            ),
                            Expanded(
                                child: MyText(
                              text: stops[i]['address'],
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                            ))
                          ],
                        ),
                      ),
                    ],
                  )
              ],
            ),
      SizedBox(
        height: size.width * 0.038,
      ),
      if (context
              .read<HomeBloc>()
              .outStationList
              .firstWhere((e) =>
                  e['request_id'] ==
                  context.read<HomeBloc>().choosenRide)['goods']
              .toString() !=
          'null')
        Column(
          children: [
            SizedBox(
              width: size.width * 0.8,
              child: MyText(
                text:
                    '${context.read<HomeBloc>().outStationList.firstWhere((e) => e['request_id'] == context.read<HomeBloc>().choosenRide)['goods']})',
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: size.width * 0.038,
            ),
          ],
        ),
      SizedBox(
        height: size.width * 0.05,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              if (!context.read<HomeBloc>().isBiddingDecreaseLimitReach) {
                context
                    .read<HomeBloc>()
                    .add(BiddingIncreaseOrDecreaseEvent(isIncrease: false));
              }
            },
            child: Container(
              width: size.width * 0.2,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: context.read<HomeBloc>().isBiddingDecreaseLimitReach
                      ? Theme.of(context).disabledColor.withOpacity(0.2)
                      : Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(5)),
              padding: EdgeInsets.all(size.width * 0.025),
              child: MyText(
                text:
                    '-${double.parse(userData!.biddingAmountIncreaseOrDecrease.toString())}',
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: context.read<HomeBloc>().isBiddingDecreaseLimitReach
                        ? AppColors.black
                        : AppColors.white),
              ),
            ),
          ),
          SizedBox(
            width: size.width * 0.3,
            child: TextField(
              enabled: true,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              controller: context.read<HomeBloc>().bidRideAmount,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  double typedFare = double.tryParse(value) ?? 0.0;
                  double minFare = double.parse(context
                      .read<HomeBloc>()
                      .rideList
                      .firstWhere((e) =>
                          e['request_id'] ==
                          context.read<HomeBloc>().choosenRide)['price']);

                  double maxFare = minFare +
                      (minFare *
                          (double.parse(userData!.biddingHighPercentage) /
                              100));

                  if (typedFare < minFare) {
                    context.read<HomeBloc>().isBiddingDecreaseLimitReach = true;
                    context.read<HomeBloc>().isBiddingIncreaseLimitReach =
                        false;
                  } else if (typedFare > maxFare) {
                    context.read<HomeBloc>().isBiddingIncreaseLimitReach = true;
                    context.read<HomeBloc>().isBiddingDecreaseLimitReach =
                        false;
                  } else {
                    context.read<HomeBloc>().isBiddingIncreaseLimitReach =
                        false;
                    context.read<HomeBloc>().isBiddingDecreaseLimitReach =
                        false;
                  }
                }
              },
              decoration: InputDecoration(
                hintText: context.read<HomeBloc>().acceptedRideFare,
                border: const UnderlineInputBorder(borderSide: BorderSide()),
              ),
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Theme.of(context).primaryColor),
            ),
          ),
          InkWell(
            onTap: () {
              if (!context.read<HomeBloc>().isBiddingIncreaseLimitReach) {
                context
                    .read<HomeBloc>()
                    .add(BiddingIncreaseOrDecreaseEvent(isIncrease: true));
              }
            },
            child: Container(
              width: size.width * 0.2,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: context.read<HomeBloc>().isBiddingIncreaseLimitReach
                      ? Theme.of(context).disabledColor.withOpacity(0.2)
                      : Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(5)),
              padding: EdgeInsets.all(size.width * 0.025),
              child: MyText(
                text:
                    '+${double.parse(userData!.biddingAmountIncreaseOrDecrease.toString())}',
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: context.read<HomeBloc>().isBiddingIncreaseLimitReach
                        ? AppColors.black
                        : AppColors.white),
              ),
            ),
          ),
        ],
      ),
      SizedBox(
        height: size.width * 0.05,
      ),
      SizedBox(
        width: size.width * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomButton(
              buttonName: AppLocalizations.of(context)!.accept,
              onTap: () {
                if (!context.read<HomeBloc>().isBiddingIncreaseLimitReach) {
                  context.read<HomeBloc>().add(AcceptBidRideEvent(
                      id: context.read<HomeBloc>().choosenRide!));
                } else {
                  showToast(
                      message: AppLocalizations.of(context)!.biddingLimitText);
                }
              },
              width: size.width * 0.41,
              buttonColor: AppColors.green,
            ),
            CustomButton(
              buttonName: AppLocalizations.of(context)!.decline,
              onTap: () {
                context.read<HomeBloc>().add(DeclineBidRideEvent(
                    id: context.read<HomeBloc>().choosenRide!));
              },
              width: size.width * 0.41,
              buttonColor: AppColors.red,
            )
          ],
        ),
      )
    ],
  );
}

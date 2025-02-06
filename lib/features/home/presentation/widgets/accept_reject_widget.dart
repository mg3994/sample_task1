import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/custom_timer.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../common/pickup_icon.dart';
import '../../../../core/utils/custom_sliderbutton.dart';

Widget acceptRejectWidget(Size size, BuildContext context) {
  return Container(
    decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12))),
    width: size.width,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: size.width * 0.05,
        ),
        if (userData!.metaRequest!.isLater == true)
          Column(
            children: [
              SizedBox(
                width: size.width * 0.9,
                child: MyText(
                  text:
                      '${AppLocalizations.of(context)!.rideAtText} - ${userData!.metaRequest!.tripStartTime}',
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.black, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: size.width * 0.05,
              ),
            ],
          ),
        if (userData!.metaRequest!.isRental)
          Column(
            children: [
              SizedBox(
                width: size.width * 0.9,
                child: MyText(
                  text:
                      '${AppLocalizations.of(context)!.rentalPackageText} - ${userData!.metaRequest!.rentalPackageName}',
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.black, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: size.width * 0.05,
              ),
            ],
          ),
        Container(
          width: size.width * 0.9,
          padding: EdgeInsets.all(size.width * 0.05),
          decoration: BoxDecoration(
              border: Border.all(
                  width: 0.5, color: Theme.of(context).disabledColor),
              borderRadius: BorderRadius.circular(5),
              color: AppColors.darkGrey.withOpacity(0.5)),
          child: Row(
            children: [
              Container(
                width: size.width * 0.128,
                height: size.width * 0.128,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(userData!.metaRequest!.userImage),
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
                      text: userData!.metaRequest!.userName ?? '',
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold),
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
                              text:
                                  userData!.metaRequest!.userRatings.toString(),
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        if (userData!.metaRequest!.userCompletedRideCount
                                .toString() !=
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
                                    '${userData!.metaRequest!.userCompletedRideCount.toString()} ${AppLocalizations.of(context)!.tripsDoneText}',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (userData!.metaRequest!.showRequestEtaAmount == true)
                Column(
                  children: [
                    MyText(
                      text: AppLocalizations.of(context)!.rideFare,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                    MyText(
                      text:
                          '${userData!.metaRequest!.currencySymbol}${userData!.metaRequest!.requestEtaAmount}',
                      textStyle: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(
                              color: AppColors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                    ),
                  ],
                )
            ],
          ),
        ),
        SizedBox(
          height: size.width * 0.05,
        ),
        SizedBox(
          width: size.width * 0.9,
          child: Row(
            children: [
              const PickupIcon(),
              SizedBox(
                width: size.width * 0.025,
              ),
              Expanded(
                  child: MyText(
                text: userData!.metaRequest!.pickAddress,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 12, fontWeight: FontWeight.w500),
              ))
            ],
          ),
        ),
        (userData!.metaRequest!.requestStops.isEmpty &&
                userData!.metaRequest!.dropAddress != null)
            ? Column(
                children: [
                  SizedBox(
                    height: size.width * 0.03,
                  ),
                  SizedBox(
                    width: size.width * 0.91,
                    child: Row(
                      children: [
                        const DropIcon(),
                        SizedBox(
                          width: size.width * 0.025,
                        ),
                        Expanded(
                            child: MyText(
                          text: userData!.metaRequest!.dropAddress,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                        ))
                      ],
                    ),
                  ),
                ],
              )
            : (userData!.metaRequest!.requestStops.isNotEmpty)
                ? Column(
                    children: [
                      for (var i = 0;
                          i < userData!.metaRequest!.requestStops.length;
                          i++)
                        Column(
                          children: [
                            SizedBox(
                              height: size.width * 0.03,
                            ),
                            SizedBox(
                              width: size.width * 0.91,
                              child: Row(
                                children: [
                                  const DropIcon(),
                                  SizedBox(
                                    width: size.width * 0.025,
                                  ),
                                  Expanded(
                                      child: MyText(
                                    text: userData!.metaRequest!.requestStops[i]
                                        ['address'],
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                  ))
                                ],
                              ),
                            ),
                          ],
                        )
                    ],
                  )
                : Container(),
        SizedBox(
          height: size.width * 0.038,
        ),
        if (userData!.metaRequest!.transportType == 'delivery')
          Column(
            children: [
              SizedBox(
                width: size.width * 0.8,
                child: MyText(
                  text:
                      '${userData!.metaRequest!.goodsType} (${userData!.metaRequest!.goodsQuantity})',
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: size.width * 0.038),
            ],
          ),
        Container(
          padding:
              EdgeInsets.only(left: size.width * 0.1, right: size.width * 0.1),
          width: size.width,
          height: size.width * 0.115,
          color: AppColors.secondary,
          child: Row(
            children: [
              Image.asset(
                AppImages.warning,
                height: size.width * 0.04,
                width: size.width * 0.04,
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: MyText(
                  text: AppLocalizations.of(context)!
                      .rideWillCancelAutomatically
                      .toString()
                      .replaceAll('1111', userData!.acceptDuration.toString()),
                  // 'The ride will be cancelled automatically after ${userData!.acceptDuration} seconds.',
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.black.withOpacity(0.6),
                      ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              CustomPaint(
                painter: CustomTimer(
                  width: 5.0,
                  color: AppColors.white,
                  backgroundColor: AppColors.primary,
                  values: (context.read<HomeBloc>().timer) > 0
                      ? 1 -
                          ((userData!.acceptDuration -
                                  context.read<HomeBloc>().timer) /
                              userData!.acceptDuration)
                      : 1,
                ),
                child: Container(
                  height: size.width * 0.077,
                  width: size.width * 0.077,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: size.width * 0.05,
        ),
        SizedBox(
          width: size.width * 0.9,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CustomSliderButton(
                buttonName: AppLocalizations.of(context)!.slideToAccept,
                onSlideSuccess: () async {
                  context.read<HomeBloc>().add(
                        AcceptRejectEvent(
                          requestId: userData!.metaRequest!.id,
                          status: 1,
                        ),
                      );
                  return true;
                },
                height: 50.0,
                width: size.width * 0.68,
                buttonColor: AppColors.green,
                textColor: Colors.white,
                sliderIcon: const Icon(Icons.check, color: Colors.white),
              ),
              InkWell(
                onTap: () {
                  context.read<HomeBloc>().add(
                        AcceptRejectEvent(
                          requestId: userData!.metaRequest!.id,
                          status: 0,
                        ),
                      );
                },
                child: Container(
                  height: 50.0,
                  width: 50.0,
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: size.width * 0.1,
        ),
      ],
    ),
  );
}

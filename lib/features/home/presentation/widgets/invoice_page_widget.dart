import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/Invoice_bottom_painter.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/fare_breakdown_widget.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/invoice_top_painter.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../common/pickup_icon.dart';

Stack invoicePageWidget(Size size, BuildContext context) {
  return Stack(
    children: [
      Container(
        color: AppColors.grey,
        height: size.height,
        width: size.width,
      ),
      Positioned(
          top: 0,
          child: CustomPaint(
            painter: InvoiceTopPainter(),
            child: Container(
              height: size.height * 0.35,
              width: size.width,
              alignment: (languageDirection == 'ltr')
                  ? Alignment.topLeft
                  : Alignment.topRight,
              child: Container(
                height: size.width * 0.1,
                width: size.width * 0.5,
                margin: EdgeInsets.only(top: size.height * 0.07),
                padding: EdgeInsets.fromLTRB(size.width * 0.05,
                    size.width * 0.025, size.width * 0.05, size.width * 0.025),
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10))),
                child: Row(
                  children: [
                    SizedBox(
                      height: size.width * 0.065,
                      width: size.width * 0.065,
                      child: Image.asset(AppImages.tripSummary),
                    ),
                    SizedBox(width: size.width * 0.05),
                    MyText(
                      text: AppLocalizations.of(context)!.tripSummary,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).disabledColor),
                    ),
                  ],
                ),
              ),
            ),
          )),
      Positioned(
          top: size.height * 0.22,
          left: size.width * 0.05,
          child: CustomPaint(
            painter: InvoiceBottomPainter(
                color: Theme.of(context).scaffoldBackgroundColor),
            child: SizedBox(
              height: size.height * 0.76,
              width: size.width * 0.9,
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.1,
                  ),
                  SizedBox(
                    width: size.width * 0.8,
                    child: MyText(
                      text: userData!.onTripRequest!.requestNumber,
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  SizedBox(
                    height: size.width * 0.05,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: size.width * 0.8,
                            padding: EdgeInsets.all(size.width * 0.05),
                            decoration: BoxDecoration(
                                color: AppColors.darkGrey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    RotatedBox(
                                      quarterTurns:
                                          (languageDirection == 'rtl') ? 2 : 0,
                                      child: Icon(
                                        CupertinoIcons.arrowtriangle_right_fill,
                                        size: 15,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .duration,
                                        textStyle: AppTextStyle.normalStyle()
                                            .copyWith(
                                                color: AppColors.darkGrey,
                                                fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    MyText(
                                      text:
                                          '${userData!.onTripRequest!.totalTime} mins',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color:
                                                  Theme.of(context).hintColor),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * 0.05,
                                ),
                                Row(
                                  children: [
                                    RotatedBox(
                                      quarterTurns:
                                          (languageDirection == 'rtl') ? 2 : 0,
                                      child: Icon(
                                        CupertinoIcons.arrowtriangle_right_fill,
                                        size: 15,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .distance,
                                        textStyle: AppTextStyle.normalStyle()
                                            .copyWith(
                                                color: AppColors.darkGrey,
                                                fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    MyText(
                                      text:
                                          '${userData!.onTripRequest!.totalDistance} ${userData!.onTripRequest!.unit}',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color:
                                                  Theme.of(context).hintColor),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * 0.05,
                                ),
                                Row(
                                  children: [
                                    RotatedBox(
                                      quarterTurns:
                                          (languageDirection == 'rtl') ? 2 : 0,
                                      child: Icon(
                                        CupertinoIcons.arrowtriangle_right_fill,
                                        size: 15,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .typeOfRide,
                                        textStyle: AppTextStyle.normalStyle()
                                            .copyWith(
                                                color: AppColors.darkGrey,
                                                fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    MyText(
                                      text: (userData!.onTripRequest!
                                                  .isOutstation ==
                                              1)
                                          ? AppLocalizations.of(context)!
                                              .outStation
                                          : (userData!.onTripRequest!
                                                      .isRental ==
                                                  true)
                                              ? AppLocalizations.of(context)!
                                                  .rental
                                              : AppLocalizations.of(context)!
                                                  .regular,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color:
                                                  Theme.of(context).hintColor),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Container(
                              padding: EdgeInsets.all(size.width * 0.015),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(
                                  width: size.width * 0.001,
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const SizedBox(
                                        width: 1.6,
                                      ),
                                      const PickupIcon(),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 1),
                                          child: MyText(
                                            overflow: TextOverflow.ellipsis,
                                            text: userData!
                                                .onTripRequest!.pickAddress,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (userData!
                                      .onTripRequest!.requestStops.isNotEmpty)
                                    ListView.separated(
                                      itemCount: userData!
                                          .onTripRequest!.requestStops.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const DropIcon(),
                                            SizedBox(width: size.width * 0.02),
                                            Expanded(
                                              child: MyText(
                                                text: userData!.onTripRequest!
                                                        .requestStops[index]
                                                    ['address'],
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return SizedBox(
                                            height: size.width * 0.0025);
                                      },
                                    ),
                                  if (userData!
                                      .onTripRequest!.requestStops.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          const DropIcon(),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              child: MyText(
                                                overflow: TextOverflow.ellipsis,
                                                text: userData!
                                                    .onTripRequest!.dropAddress,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          (userData!.onTripRequest!.isBidRide == '0')
                              ? Column(
                                  children: [
                                    SizedBox(
                                      height: size.width * 0.05,
                                    ),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .fareBreakup,
                                      textStyle: AppTextStyle.boldStyle()
                                          .copyWith(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      height: size.width * 0.025,
                                    ),
                                    Column(
                                      children: [
                                        if (userData!.onTripRequest!
                                                .requestBill!.basePrice !=
                                            0)
                                          fareBreakdownWidget(
                                              size,
                                              context,
                                              AppLocalizations.of(context)!
                                                  .basePrice,
                                              '${userData!.onTripRequest!.requestBill!.currencySymbol}${userData!.onTripRequest!.requestBill!.basePrice}'),
                                        if (userData!.onTripRequest!
                                                .requestBill!.distancePrice !=
                                            0)
                                          fareBreakdownWidget(
                                              size,
                                              context,
                                              AppLocalizations.of(context)!
                                                  .distancePrice,
                                              '${userData!.onTripRequest!.requestBill!.currencySymbol}${userData!.onTripRequest!.requestBill!.distancePrice}'),
                                        if (userData!.onTripRequest!
                                                .requestBill!.timePrice !=
                                            0)
                                          fareBreakdownWidget(
                                              size,
                                              context,
                                              AppLocalizations.of(context)!
                                                  .timePrice,
                                              '${userData!.onTripRequest!.requestBill!.currencySymbol}${userData!.onTripRequest!.requestBill!.timePrice}'),
                                        if (userData!.onTripRequest!
                                                .requestBill!.waitingCharge !=
                                            0)
                                          fareBreakdownWidget(
                                              size,
                                              context,
                                              '${AppLocalizations.of(context)!.waitingPrice} (${userData!.onTripRequest!.requestBill!.currencySymbol}${userData!.onTripRequest!.requestBill!.waitingChargePerMin} x ${userData!.onTripRequest!.requestBill!.calculatedWaitingTime} mins)',
                                              '${userData!.onTripRequest!.requestBill!.currencySymbol}${userData!.onTripRequest!.requestBill!.waitingCharge}'),
                                        if (userData!.onTripRequest!
                                                .requestBill!.adminCommission !=
                                            0)
                                          fareBreakdownWidget(
                                              size,
                                              context,
                                              AppLocalizations.of(context)!
                                                  .convFee,
                                              '${userData!.onTripRequest!.requestBill!.currencySymbol}${userData!.onTripRequest!.requestBill!.adminCommission}'),
                                        if (userData!.onTripRequest!
                                                .requestBill!.serviceTax !=
                                            0)
                                          fareBreakdownWidget(
                                              size,
                                              context,
                                              AppLocalizations.of(context)!
                                                  .taxes,
                                              '${userData!.onTripRequest!.requestBill!.currencySymbol}${userData!.onTripRequest!.requestBill!.serviceTax}'),
                                      ],
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: size.width * 0.05,
                                    ),
                                    MyText(
                                      text:
                                          userData!.onTripRequest!.paymentType,
                                      textStyle: AppTextStyle.boldStyle()
                                          .copyWith(
                                              fontSize: 26,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      height: size.width * 0.025,
                                    ),
                                    MyText(
                                      text:
                                          '${userData!.onTripRequest!.requestBill!.currencySymbol}${userData!.onTripRequest!.requestBill!.totalAmount}',
                                      textStyle: AppTextStyle.boldStyle()
                                          .copyWith(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.width * 0.025,
                  ),
                  SizedBox(
                    width: size.width * 0.8,
                    child: Row(
                      children: [
                        MyText(
                          text: userData!.onTripRequest!.paymentType,
                          textStyle: AppTextStyle.boldStyle().copyWith(
                              fontSize: 18,
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: size.width * 0.025,
                        ),
                        MyText(
                          text:
                              '${userData!.onTripRequest!.requestBill!.currencySymbol}${(userData!.onTripRequest!.requestBill!.totalAmount)}',
                          textStyle: AppTextStyle.boldStyle().copyWith(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: size.width * 0.05,
                        ),
                        Expanded(
                            child: CustomButton(
                                buttonName: (userData!
                                                .onTripRequest!.paymentOpt !=
                                            '0' &&
                                        userData!.onTripRequest!.isPaid == 0)
                                    ? AppLocalizations.of(context)!
                                        .paymentRecieved
                                    : AppLocalizations.of(context)!.confirm,
                                onTap: () {
                                  if (userData!.onTripRequest!.paymentOpt !=
                                          '0' &&
                                      userData!.onTripRequest!.isPaid == 0) {
                                    context
                                        .read<HomeBloc>()
                                        .add(PaymentRecievedEvent());
                                  } else {
                                    context
                                        .read<HomeBloc>()
                                        .add(AddReviewEvent());
                                  }
                                }))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.width * 0.05,
                  ),
                ],
              ),
            ),
          )),
      Positioned(
          top: size.height * 0.162,
          child: Column(
            children: [
              MyText(
                text: userData!.onTripRequest!.userName,
                textStyle: AppTextStyle.boldStyle().copyWith(
                    fontSize: 18,
                    color: AppColors.white,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: size.height * 0.015,
              ),
              Container(
                width: size.width,
                alignment: Alignment.center,
                child: Container(
                  height: size.width * 0.17,
                  width: size.width * 0.17,
                  decoration: BoxDecoration(
                      // color: Theme.of(context).primaryColorDark,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image:
                              NetworkImage(userData!.onTripRequest!.userImage),
                          fit: BoxFit.cover)),
                ),
              ),
            ],
          ))
    ],
  );
}

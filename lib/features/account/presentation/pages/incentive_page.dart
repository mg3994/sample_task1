import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/auth_page.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class IncentivePage extends StatelessWidget {
  static const String routeName = '/incentivePage';
  const IncentivePage({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(GetIncentiveEvent(
            type: userData!.availableIncentive == '0' ||
                    userData?.availableIncentive == '2'
                ? 0
                : 1)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is IncentiveLoadingStartState) {
            CustomLoader.loader(context);
          }

          if (state is ShowErrorState) {
            showToast(message: state.message);
          }

          if (state is IncentiveLoadingStopState) {
            CustomLoader.dismiss(context);
          }
          if (state is UserUnauthenticatedState) {
            final type = await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, AuthPage.routeName, (route) => false,
                arguments: AuthPageArguments(type: type));
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: Stack(
              children: [
                SizedBox(
                  height: size.height,
                  child: Column(children: [
                    SizedBox(
                      height: size.width * 0.55,
                      child: Column(children: [
                        SizedBox(
                          height: MediaQuery.of(context).padding.top,
                        ),
                        Row(
                          children: [
                            Container(
                              height: size.height * 0.08,
                              width: size.width * 0.08,
                              margin: EdgeInsets.only(
                                  left: size.width * 0.05,
                                  right: size.width * 0.05),
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
                              child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(
                                  CupertinoIcons.back,
                                  size: 20,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            MyText(
                              text: AppLocalizations.of(context)!.incentives,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppColors.white),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            SizedBox(
                              width: size.width * 0.9,
                              child: userData?.availableIncentive == '2'
                                  ? Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (context
                                                    .read<AccBloc>()
                                                    .choosenIncentiveData !=
                                                0) {
                                              context.read<AccBloc>().add(
                                                  GetIncentiveEvent(type: 0));
                                            }
                                          },
                                          child: Container(
                                            width: size.width * 0.45,
                                            padding: EdgeInsets.all(
                                                size.width * 0.05),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                    color: (context
                                                                .read<AccBloc>()
                                                                .choosenIncentiveData ==
                                                            0)
                                                        ? AppColors.whiteText
                                                            .withOpacity(0.7)
                                                        : Colors.transparent,
                                                    width: 2),
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .dailyCaps,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge!
                                                  .copyWith(
                                                      fontSize: 16,
                                                      color:
                                                          AppColors.whiteText,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            if (context
                                                    .read<AccBloc>()
                                                    .choosenIncentiveData !=
                                                1) {
                                              context.read<AccBloc>().add(
                                                  GetIncentiveEvent(type: 1));
                                            }
                                          },
                                          child: Container(
                                            width: size.width * 0.45,
                                            padding: EdgeInsets.all(
                                                size.width * 0.05),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                    color: (context
                                                                .read<AccBloc>()
                                                                .choosenIncentiveData ==
                                                            1)
                                                        ? AppColors.whiteText
                                                            .withOpacity(0.7)
                                                        : Colors.transparent,
                                                    width: 2),
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .weeklyCaps,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge!
                                                  .copyWith(
                                                      fontSize: 16,
                                                      color:
                                                          AppColors.whiteText,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : userData?.availableIncentive == '0'
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(
                                                  size.width * 0.05),
                                              child: MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .dailyCaps,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .headlineLarge!
                                                    .copyWith(
                                                        fontSize: 16,
                                                        color: Theme.of(context)
                                                            .scaffoldBackgroundColor,
                                                        fontWeight:
                                                            FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        )
                                      : userData?.availableIncentive == '1'
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(
                                                      size.width * 0.05),
                                                  child: MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .weeklyCaps,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .headlineLarge!
                                                        .copyWith(
                                                            fontSize: 16,
                                                            color: Theme.of(
                                                                    context)
                                                                .scaffoldBackgroundColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const SizedBox(),
                            ),
                          ],
                        )
                      ]),
                    ),
                    Expanded(
                      child: BlocBuilder<AccBloc, AccState>(
                        builder: (context, state) {
                          if (state is ShowUpcomingIncentivesState) {
                            return Container(
                              width: size.width,
                              padding: EdgeInsets.all(size.width * 0.03),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                border: Border.all(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25),
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        size.width * 0.03,
                                        size.height * 0.08,
                                        size.width * 0.03,
                                        size.height * 0.02,
                                      ),
                                      child: Container(
                                        height: size.width * 1.27,
                                        width: size.width,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Theme.of(context).shadowColor,
                                              spreadRadius: 1,
                                              blurRadius: 1,
                                              offset: const Offset(0, 3),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                if (context
                                                        .read<AccBloc>()
                                                        .selectedIncentiveHistory !=
                                                    null)
                                                  Container(
                                                    height: size.width * 0.4,
                                                    width: size.width,
                                                    decoration: BoxDecoration(
                                                      color: context
                                                              .read<AccBloc>()
                                                              .selectedIncentiveHistory!
                                                              .upcomingIncentives
                                                              .any((element) =>
                                                                  element
                                                                      .isCompleted ==
                                                                  false)
                                                          ? AppColors.red
                                                          : AppColors.green,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(10),
                                                        topRight:
                                                            Radius.circular(10),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        MyText(
                                                          text:
                                                              "${AppLocalizations.of(context)!.earnUptoText} ${userData!.currencySymbol}${context.read<AccBloc>().selectedIncentiveHistory!.earnUpto}",
                                                          textStyle:
                                                              const TextStyle(
                                                                  fontSize: 25,
                                                                  color: AppColors
                                                                      .white),
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              size.width * 0.02,
                                                        ),
                                                        MyText(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .byCompletingRideText
                                                              .replaceAll(
                                                                  "12",
                                                                  context
                                                                      .read<
                                                                          AccBloc>()
                                                                      .selectedIncentiveHistory!
                                                                      .totalRides
                                                                      .toString()),
                                                          textStyle:
                                                              const TextStyle(
                                                                  fontSize: 14,
                                                                  color: AppColors
                                                                      .white),
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              size.width * 0.02,
                                                        ),
                                                        Container(
                                                          height: size.height *
                                                              0.04,
                                                          width:
                                                              size.width * 0.7,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .scaffoldBackgroundColor,
                                                          ),
                                                          child: Center(
                                                            child: MyText(
                                                              text: context
                                                                      .read<
                                                                          AccBloc>()
                                                                      .selectedIncentiveHistory!
                                                                      .upcomingIncentives
                                                                      .any((element) =>
                                                                          element
                                                                              .isCompleted ==
                                                                          false)
                                                                  ? AppLocalizations.of(
                                                                          context)!
                                                                      .missedIncentiveText
                                                                  : AppLocalizations.of(
                                                                          context)!
                                                                      .earnedIncentiveText,
                                                              textStyle: TextStyle(
                                                                  fontSize: 16,
                                                                  color: context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .selectedIncentiveHistory!
                                                                          .upcomingIncentives
                                                                          .any((element) =>
                                                                              element.isCompleted ==
                                                                              false)
                                                                      ? AppColors
                                                                          .red
                                                                      : AppColors
                                                                          .green),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10.0, 0, 8, 0),
                                              child: SizedBox(
                                                height: size.width * 0.8,
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: context
                                                        .read<AccBloc>()
                                                        .selectedIncentiveHistory!
                                                        .upcomingIncentives
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                height:
                                                                    size.width *
                                                                        0.05,
                                                                width:
                                                                    size.width *
                                                                        0.05,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .selectedIncentiveHistory!
                                                                          .upcomingIncentives[
                                                                              index]
                                                                          .isCompleted
                                                                      ? AppColors
                                                                          .green
                                                                      : AppColors
                                                                          .red,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            15.0),
                                                                child: SizedBox(
                                                                  width:
                                                                      size.width *
                                                                          0.7,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          MyText(
                                                                            text:
                                                                                "${AppLocalizations.of(context)!.completeText} ${context.read<AccBloc>().selectedIncentiveHistory!.upcomingIncentives[index].rideCount}",
                                                                            maxLines:
                                                                                2,
                                                                            textStyle:
                                                                                TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: context.read<AccBloc>().selectedIncentiveHistory!.upcomingIncentives[index].isCompleted ? Colors.green.shade700 : Colors.red.shade700,
                                                                            ),
                                                                          ),
                                                                          MyText(
                                                                            text:
                                                                                "${userData!.currencySymbol}${context.read<AccBloc>().selectedIncentiveHistory!.upcomingIncentives[index].incentiveAmount}",
                                                                            textStyle:
                                                                                TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: context.read<AccBloc>().selectedIncentiveHistory!.upcomingIncentives[index].isCompleted ? Colors.green.shade700 : Colors.red.shade700,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Text(
                                                                        context.read<AccBloc>().selectedIncentiveHistory!.upcomingIncentives[index].isCompleted
                                                                            ? AppLocalizations.of(context)!.acheivedTargetText
                                                                            : AppLocalizations.of(context)!.missedTargetText,
                                                                        maxLines:
                                                                            2,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                14),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          if (state
                                                                  .upcomingIncentives
                                                                  .indexOf(context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .selectedIncentiveHistory!
                                                                          .upcomingIncentives[
                                                                      index]) !=
                                                              state.upcomingIncentives
                                                                      .length -
                                                                  1)
                                                            Container(
                                                              height:
                                                                  size.height *
                                                                      0.08,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          3),
                                                              child:
                                                                  VerticalDivider(
                                                                color: Theme.of(
                                                                        context)
                                                                    .dividerColor,
                                                                thickness: 1,
                                                                width: 20,
                                                              ),
                                                            ),
                                                        ],
                                                      );
                                                    }),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Center(
                            child: Text(
                              AppLocalizations.of(context)!
                                  .selectDateForIncentives,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
                ),
                Positioned(
                  top: size.width * 0.43,
                  left: size.width * 0.048,
                  right: size.width * 0.048,
                  child: Container(
                    height: size.width * 0.25,
                    padding: EdgeInsets.all(size.width * 0.02),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor,
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: size.width * 0.20,
                      child: BlocBuilder<AccBloc, AccState>(
                        builder: (context, state) {
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            controller: context
                                .read<AccBloc>()
                                .incentiveScrollController,
                            physics: const PageScrollPhysics(),
                            itemCount:
                                context.read<AccBloc>().incentiveDates.length,
                            itemBuilder: (context, index) {
                              final incentiveDate = context
                                  .read<AccBloc>()
                                  .incentiveDates[index]
                                  .date;
                              final day = context
                                  .read<AccBloc>()
                                  .incentiveDates[index]
                                  .day;
                              final formattedDate = context
                                  .read<AccBloc>()
                                  .formatDateBasedOnIndex(
                                      incentiveDate,
                                      context
                                          .read<AccBloc>()
                                          .choosenIncentiveData);
                              // Parse the API date into DateTime
                              final apiDate = context
                                          .read<AccBloc>()
                                          .choosenIncentiveData ==
                                      0
                                  ? DateFormat("dd-MMM-yy").parse(incentiveDate)
                                  : DateFormat('dd').parse(formattedDate);
                              final today = DateTime.now();

                              // Only check if the date is after today when choosenIncentiveData == 0
                              final isAfterToday = context
                                          .read<AccBloc>()
                                          .choosenIncentiveData ==
                                      0
                                  ? apiDate.isAfter(today)
                                  : false;

                              final isSelectedDate =
                                  context.read<AccBloc>().selectedDate ==
                                      formattedDate;

                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    day,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  InkWell(
                                    onTap: isAfterToday &&
                                            context
                                                    .read<AccBloc>()
                                                    .choosenIncentiveData ==
                                                0
                                        ? null // Disable tap for dates after today
                                        : () {
                                            // Update the selected date when tapping on a new date
                                            context
                                                .read<AccBloc>()
                                                .selectedDate = formattedDate;
                                            context.read<AccBloc>().add(
                                                  SelectIncentiveDateEvent(
                                                    selectedDate: formattedDate,
                                                    isSelected: true,
                                                    choosenIndex: context
                                                        .read<AccBloc>()
                                                        .choosenIncentiveData,
                                                  ),
                                                );
                                          },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      height: size.width * 0.086,
                                      width: size.width * 0.086,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelectedDate
                                            ? Theme.of(context)
                                                .primaryColorDark
                                                .withOpacity(0.5)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isAfterToday &&
                                                  context
                                                          .read<AccBloc>()
                                                          .choosenIncentiveData ==
                                                      0
                                              ? Colors.transparent
                                              : Theme.of(context)
                                                  .primaryColorDark
                                                  .withOpacity(0.5),
                                        ),
                                        boxShadow: isSelectedDate
                                            ? [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .primaryColorDark
                                                      .withOpacity(0.2),
                                                  blurRadius: 5,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                            : [],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        formattedDate,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: context
                                                          .read<AccBloc>()
                                                          .choosenIncentiveData ==
                                                      0
                                                  ? 16
                                                  : 9,
                                              color: isAfterToday &&
                                                      context
                                                              .read<AccBloc>()
                                                              .choosenIncentiveData ==
                                                          0
                                                  ? Theme.of(context)
                                                      .disabledColor // Grey text for disabled dates
                                                  : isSelectedDate
                                                      ? Theme.of(context)
                                                          .scaffoldBackgroundColor
                                                      : Theme.of(context)
                                                          .primaryColorDark,
                                              fontWeight: isSelectedDate
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (context, index) =>
                                SizedBox(width: size.width * 0.038),
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}

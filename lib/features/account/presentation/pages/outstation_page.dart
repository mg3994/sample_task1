import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/presentation/pages/trip_summary_history.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/history_card_shimmer.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/top_bar.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/auth_page.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../common/pickup_icon.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../application/acc_bloc.dart';

class OutstationPage extends StatelessWidget {
  static const String routeName = '/outstationPage';

  const OutstationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(HistoryGetEvent(historyFilter: 'out_station=1')),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is AccInitialState) {
            CustomLoader.loader(context);
          } else if (state is HistoryDataLoadingState) {
            CustomLoader.loader(context);
          } else if (state is HistoryDataSuccessState) {
            CustomLoader.dismiss(context);
          } else if (state is UserUnauthenticatedState) {
            final type = await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, AuthPage.routeName, (route) => false,
                arguments: AuthPageArguments(type: type));
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            return Scaffold(
              body: TopBarDesign(
                isHistoryPage: false,
                title: AppLocalizations.of(context)!.outStation,
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Column(
                  children: [
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  if (context.read<AccBloc>().isLoading) {
                                    return HistoryShimmer(size: size);
                                  } else if (context
                                      .read<AccBloc>()
                                      .history
                                      .isEmpty) {
                                    return Center(
                                        child: Padding(
                                      padding: const EdgeInsets.all(50),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(AppImages.historyNoData),
                                          const SizedBox(height: 10),
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .noHistoryAvail,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .disabledColor,
                                                ),
                                          ),
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .makeNewBookingToView,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .disabledColor,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ));
                                  }
                                  if (index == 0) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: Row(
                                        children: [
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .historyDetails,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else if (index <
                                      context.read<AccBloc>().history.length +
                                          1) {
                                    final history = context
                                        .read<AccBloc>()
                                        .history[index - 1];
                                    return Row(
                                      children: [
                                        Expanded(
                                            child: Column(children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5),
                                            child: InkWell(
                                              onTap: () {
                                                if (history.laterRide == true) {
                                                  Navigator.pushNamed(
                                                    context,
                                                    HistoryTripSummaryPage
                                                        .routeName,
                                                    arguments:
                                                        HistoryPageArguments(
                                                      historyData: history,
                                                    ),
                                                  ).then((value) {
                                                    if (!context.mounted) {
                                                      return;
                                                    }
                                                    context.read<AccBloc>().add(
                                                        HistoryGetEvent(
                                                            historyFilter:
                                                                'is_later=1'));

                                                    context
                                                        .read<AccBloc>()
                                                        .add(UpdateEvent());
                                                  });
                                                } else {
                                                  Navigator.pushNamed(
                                                    context,
                                                    HistoryTripSummaryPage
                                                        .routeName,
                                                    arguments:
                                                        HistoryPageArguments(
                                                      historyData: history,
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    bottom: size.width * 0.02),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    width: size.width * 0.001,
                                                    color: Theme.of(context)
                                                        .disabledColor,
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const PickupIcon(),
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5),
                                                              child: MyText(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                text: history
                                                                    .pickAddress,
                                                                textStyle: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall,
                                                              ),
                                                            ),
                                                          ),
                                                          MyText(
                                                            text: history
                                                                .cvTripStartTime,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .disabledColor,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          const DropIcon(),
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 5),
                                                              child: MyText(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                text: history
                                                                    .dropAddress,
                                                                textStyle: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall,
                                                              ),
                                                            ),
                                                          ),
                                                          MyText(
                                                            text: history
                                                                .cvCompletedAt,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .disabledColor,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.width * 0.03),
                                                    Container(
                                                      padding: EdgeInsets.all(
                                                          size.width * 0.025),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .scaffoldBackgroundColor,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            10)),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              MyText(
                                                                text: history
                                                                            .laterRide ==
                                                                        true
                                                                    ? history
                                                                        .tripStartTimeWithDate
                                                                    : history.isCompleted ==
                                                                            1
                                                                        ? history
                                                                            .convertedCompletedAt
                                                                        : history.isCancelled ==
                                                                                1
                                                                            ? history.convertedCancelledAt
                                                                            : history.convertedCreatedAt,
                                                                textStyle: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .labelMedium,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Container(
                                                                      width: 50,
                                                                      height:
                                                                          50,
                                                                      decoration: BoxDecoration(
                                                                          image: history.vehicleTypeImage.isNotEmpty
                                                                              ? DecorationImage(
                                                                                  image: NetworkImage(history.vehicleTypeImage),
                                                                                )
                                                                              : const DecorationImage(
                                                                                  image: AssetImage(AppImages.noImage),
                                                                                ),
                                                                          // shape: BoxShape.circle,
                                                                          color: Theme.of(context).scaffoldBackgroundColor)),
                                                                  SizedBox(
                                                                    width: size
                                                                            .width *
                                                                        0.025,
                                                                  ),
                                                                  MyText(
                                                                    text: history
                                                                        .vehicleTypeName,
                                                                    textStyle: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .labelMedium,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              MyText(
                                                                text: history
                                                                            .isCompleted ==
                                                                        1
                                                                    ? AppLocalizations.of(
                                                                            context)!
                                                                        .completed
                                                                    : history.isCancelled ==
                                                                            1
                                                                        ? AppLocalizations.of(context)!
                                                                            .cancelled
                                                                        : history.isLater ==
                                                                                true
                                                                            ? (history.isRental == false)
                                                                                ? AppLocalizations.of(context)!.upcoming
                                                                                : '${AppLocalizations.of(context)!.rental} ${history.rentalPackageName.toString()}'
                                                                            : '',
                                                                textStyle: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .labelMedium!
                                                                    .copyWith(
                                                                      color: history.isCompleted ==
                                                                              1
                                                                          ? AppColors
                                                                              .green
                                                                          : history.isCancelled == 1
                                                                              ? AppColors.red
                                                                              : history.isLater == true
                                                                                  ? AppColors.secondaryDark
                                                                                  : Theme.of(context).primaryColor,
                                                                    ),
                                                              ),
                                                              MyText(
                                                                  text: (history
                                                                              .isBidRide ==
                                                                          1)
                                                                      ? '${history.requestedCurrencySymbol} ${history.acceptedRideFare}'
                                                                      : (history.isCompleted ==
                                                                              1)
                                                                          ? '${history.requestBill.data.requestedCurrencySymbol} ${history.requestBill.data.totalAmount}'
                                                                          : '${history.requestedCurrencySymbol} ${history.requestEtaAmount}')
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                      ],
                                    );
                                  } else {
                                    return null;
                                  }
                                },
                                childCount:
                                    context.read<AccBloc>().history.length + 1,
                              ),
                            ),
                          ),
                          if (context.read<AccBloc>().historyPaginations !=
                                  null &&
                              context
                                      .read<AccBloc>()
                                      .historyPaginations!
                                      .pagination !=
                                  null &&
                              context
                                      .read<AccBloc>()
                                      .historyPaginations!
                                      .pagination
                                      .currentPage <
                                  context
                                      .read<AccBloc>()
                                      .historyPaginations!
                                      .pagination
                                      .totalPages &&
                              (state is HistoryDataSuccessState ||
                                  state is HistoryTypeChangeState))
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.width * 0.02),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (context
                                                .read<AccBloc>()
                                                .historyPaginations!
                                                .pagination
                                                .currentPage <
                                            context
                                                .read<AccBloc>()
                                                .historyPaginations!
                                                .pagination
                                                .totalPages) {
                                          context.read<AccBloc>().add(
                                              HistoryGetEvent(
                                                  pageNumber: context
                                                          .read<AccBloc>()
                                                          .historyPaginations!
                                                          .pagination
                                                          .currentPage +
                                                      1,
                                                  historyFilter: (context
                                                              .read<AccBloc>()
                                                              .selectedHistoryType ==
                                                          0)
                                                      ? "is_completed=1"
                                                      : (context
                                                                  .read<
                                                                      AccBloc>()
                                                                  .selectedHistoryType ==
                                                              1)
                                                          ? "is_later=1"
                                                          : "is_cancelled=1"));
                                        }
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.all(size.width * 0.02),
                                        decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(3))),
                                        child: Row(
                                          children: [
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .loadMore,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColorLight,
                                                  ),
                                            ),
                                            Icon(
                                              Icons
                                                  .arrow_drop_down_circle_outlined,
                                              color: Theme.of(context)
                                                  .primaryColorLight,
                                              size: 15,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

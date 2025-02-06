import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/utils/custom_background.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/domain/models/subcription_list_model.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/features/account/presentation/pages/paymentgateways.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/subscription_shimmer.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/auth_page.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../domain/models/walletpage_model.dart';

class SubscriptionPage extends StatelessWidget {
  static const String routeName = '/subscriptionPage';
  final SubscriptionPageArguments args;
  const SubscriptionPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(GetSubscriptionListEvent())
        ..add(GetWalletInitEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is SubscriptionPayLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is SubscriptionPayLoadedState) {
            CustomLoader.dismiss(context);
          }
          if (state is SubscriptionPaySuccessState) {
            CustomLoader.dismiss(context);
          }
          if (state is WalletEmptyState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!
                    .lowWalletBalanceForSubscription),
              ),
            );
          }
          if (state is UserUnauthenticatedState) {
            final type = await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, AuthPage.routeName, (route) => false,
                arguments: AuthPageArguments(type: type));
          }
          if (state is WalletPageReUpdateState) {
            Navigator.pushNamed(
              context,
              PaymentGatewaysPage.routeName,
              arguments: PaymentGateWayPageArguments(
                currencySymbol: state.currencySymbol,
                from: '2',
                requestId: state.requestId,
                money: state.money,
                planId: state.planId,
                url: state.url,
                userId: state.userId,
              ),
            ).then((value) {
              if (!context.mounted) return;
              if (value != null && value == true) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) {
                    return AlertDialog(
                      content: SizedBox(
                        height: size.height * 0.4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.paymentSuccess,
                              fit: BoxFit.contain,
                              width: size.width * 0.5,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              AppLocalizations.of(context)!.paymentSuccess,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                context
                                    .read<AccBloc>()
                                    .add(AccGetUserDetailsEvent());
                              },
                              child: Text(AppLocalizations.of(context)!.ok),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) {
                    return AlertDialog(
                      content: SizedBox(
                        height: size.height * 0.4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.paymentFail,
                              fit: BoxFit.contain,
                              width: size.width * 0.5,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              AppLocalizations.of(context)!.paymentFailed,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(AppLocalizations.of(context)!.ok),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            });
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: CustomBackground(
                child: (userData != null &&
                        userData!.subscription == null &&
                        !context.read<AccBloc>().isPlansChooseds)
                    ? noSubscription(context, size)
                    : ((userData != null && userData!.isSubscribed!) ||
                            (context.read<AccBloc>().subscriptionSuccessData !=
                                    null &&
                                context
                                        .read<AccBloc>()
                                        .subscriptionSuccessData!
                                        .isSubscribed ==
                                    '1'))
                        ? succesSection(context, size)
                        : (userData != null && !userData!.hasSubscription!) ||
                                context.read<AccBloc>().isPlansChooseds
                            ? subscriptionDataList(context, size,
                                context.read<AccBloc>().subscriptionList)
                            : (userData != null && userData!.isExpired!) &&
                                    !context.read<AccBloc>().isPlansChooseds
                                ? expiredSection(context, size)
                                : subscriptionDataList(context, size,
                                    context.read<AccBloc>().subscriptionList),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget noSubscription(BuildContext context, Size size) {
    return Center(
        child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppImages.noSubscription),
              SizedBox(height: size.height * 0.04),
              MyText(
                text: AppLocalizations.of(context)!.noSubscription,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: AppColors.blackText, fontSize: 20),
              ),
              SizedBox(height: size.height * 0.03),
              MyText(
                text: AppLocalizations.of(context)!.noSubscriptionContent,
                textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.black,
                      fontSize: 16,
                    ),
                maxLines: 5,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Positioned(
          top: 20,
          left: size.width * 0.02,
          child: Row(
            children: [
              (args.isFromAccPage == true)
                  ? InkWell(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        size: size.width * 0.07,
                        color: AppColors.black,
                      ),
                    )
                  : const SizedBox(),
              SizedBox(
                width: size.width * 0.05,
              ),
              MyText(
                text: AppLocalizations.of(context)!.subscription,
                textStyle: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontSize: 18, color: AppColors.blackText),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: CustomButton(
            buttonName: AppLocalizations.of(context)!.choosePlan,
            borderRadius: 20,
            onTap: () {
              context.read<AccBloc>().add(
                    ChoosePlanEvent(isPlansChoosed: true),
                  );
            },
          ),
        ),
      ],
    ));
  }

  Widget succesSection(BuildContext context, Size size) {
    return Center(
        child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppImages.subscriptionSuccess),
              SizedBox(height: size.height * 0.04),
              MyText(
                text: AppLocalizations.of(context)!.subscriptionSuccess,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: AppColors.blackText, fontSize: 20),
              ),
              SizedBox(height: size.height * 0.03),
              MyText(
                text:
                    '${AppLocalizations.of(context)!.subscriptionSuccessDescOne.replaceAll('\\n', '\n').replaceAll('A', userData!.subscription!.data.subscriptionName)} ${userData!.subscription!.data.expiredAt}.${AppLocalizations.of(context)!.subscriptionSuccessDescTwo.replaceAll("\\n", "\n")}',
                textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.black,
                      fontSize: 16,
                    ),
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Positioned(
          top: 20,
          left: size.width * 0.02,
          child: Row(
            children: [
              (args.isFromAccPage == true)
                  ? InkWell(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        size: size.width * 0.07,
                        color: AppColors.black,
                      ),
                    )
                  : const SizedBox(),
              SizedBox(
                width: size.width * 0.05,
              ),
              MyText(
                text: AppLocalizations.of(context)!.subscription,
                textStyle: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontSize: 18, color: AppColors.blackText),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget expiredSection(BuildContext context, Size size) {
    return Center(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(AppImages.subscriptionExpired),
                SizedBox(height: size.height * 0.04),
                MyText(
                  text: AppLocalizations.of(context)!.subscriptionExpired,
                  textStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: AppColors.red, fontSize: 20),
                ),
                SizedBox(height: size.height * 0.03),
                MyText(
                  text:
                      '${AppLocalizations.of(context)!.subscriptionFailedDescOne} ${userData!.wallet!.data.currencySymbol}${userData!.subscription!.data.paidAmount} ${AppLocalizations.of(context)!.subscriptionFailedDescTwo} ${userData!.subscription!.data.expiredAt}.${AppLocalizations.of(context)!.subscriptionFailedDescThree}',
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.black,
                        fontSize: 16,
                      ),
                  maxLines: 3,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: size.width * 0.03,
            child: Row(
              children: [
                args.isFromAccPage == true
                    ? InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back,
                          size: size.width * 0.07,
                          color: AppColors.black,
                        ),
                      )
                    : const SizedBox(),
                SizedBox(
                  width: size.width * 0.05,
                ),
                MyText(
                  text: AppLocalizations.of(context)!.subscription,
                  textStyle: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(fontSize: 18, color: AppColors.blackText),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: CustomButton(
              buttonName: AppLocalizations.of(context)!.choosePlan,
              borderRadius: 20,
              onTap: () {
                context.read<AccBloc>().add(
                      ChoosePlanEvent(isPlansChoosed: true),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget subscriptionDataList(BuildContext context, Size size,
      List<SubscriptionData> subscriptionListDatas) {
    return BlocBuilder<AccBloc, AccState>(builder: (context, state) {
      return subscriptionListDatas.isNotEmpty
          ? Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(
                    size.width * 0.05,
                  ),
                  child: Row(
                    children: [
                      args.isFromAccPage == true
                          ? InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                size: size.width * 0.07,
                                color: AppColors.black,
                              ),
                            )
                          : const SizedBox(),
                      SizedBox(
                        width: size.width * 0.05,
                      ),
                      MyText(
                        text: AppLocalizations.of(context)!.subscription,
                        textStyle: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(fontSize: 18, color: AppColors.blackText),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.05),
                      child: MyText(
                        text: AppLocalizations.of(context)!
                            .chooseYourSubscription,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: AppColors.blackText),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: subscriptionListDatas.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemBuilder: (_, index) {
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              context.read<AccBloc>().add(
                                    SubscriptionOnTapEvent(
                                        selectedPlanIndex: index),
                                  );
                            },
                            child: Container(
                              width: size.width * 0.9,
                              padding: EdgeInsets.all(size.width * 0.03),
                              margin:
                                  EdgeInsets.only(bottom: size.width * 0.025),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    width: 1,
                                    color: Theme.of(context).dividerColor),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: size.width * 0.05,
                                    height: size.width * 0.05,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 1.5, color: AppColors.black),
                                    ),
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: size.width * 0.03,
                                      height: size.width * 0.03,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (context
                                                      .read<AccBloc>()
                                                      .choosenPlanindex ==
                                                  index)
                                              ? AppColors.black
                                              : Colors.transparent),
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(width: size.width * 0.04),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                MyText(
                                                    text: subscriptionListDatas[
                                                            index]
                                                        .name
                                                        .toString(),
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            color: AppColors
                                                                .blackText,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                SizedBox(
                                                  width: size.width * 0.02,
                                                ),
                                                MyText(
                                                  text: subscriptionListDatas[
                                                          index]
                                                      .amount
                                                      .toString(),
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          color: AppColors
                                                              .blackText,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: size.width * 0.6,
                                              child: MyText(
                                                text:
                                                    subscriptionListDatas[index]
                                                        .description
                                                        .toString(),
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: AppColors
                                                            .blackText),
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(
                        size.width * 0.05,
                      ),
                      child: MyText(
                        text: AppLocalizations.of(context)!.choosePaymentMethod,
                        textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.blackText),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            context.read<AccBloc>().add(
                                SubscriptionPaymentOnTapEvent(
                                    selectedPayIndex: 0));
                          },
                          child: Row(
                            children: [
                              Container(
                                width: size.width * 0.05,
                                height: size.width * 0.05,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.black),
                                ),
                                alignment: Alignment.center,
                                child: Container(
                                  width: size.width * 0.03,
                                  height: size.width * 0.03,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (context
                                                  .read<AccBloc>()
                                                  .choosenSubscriptionPayIndex ==
                                              0)
                                          ? AppColors.black
                                          : Colors.transparent),
                                ),
                              ),
                              SizedBox(
                                width: size.width * 0.025,
                              ),
                              MyText(
                                text: AppLocalizations.of(context)!.card,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(
                                        fontSize: 18,
                                        color: AppColors.blackText),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.025,
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            context.read<AccBloc>().add(
                                  SubscriptionPaymentOnTapEvent(
                                      selectedPayIndex: 2),
                                );
                          },
                          child: Row(
                            children: [
                              Container(
                                width: size.width * 0.05,
                                height: size.width * 0.05,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 1.5, color: AppColors.black),
                                ),
                                alignment: Alignment.center,
                                child: Container(
                                  width: size.width * 0.03,
                                  height: size.width * 0.03,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (context
                                                  .read<AccBloc>()
                                                  .choosenSubscriptionPayIndex ==
                                              2)
                                          ? AppColors.black
                                          : Colors.transparent),
                                ),
                              ),
                              SizedBox(
                                width: size.width * 0.025,
                              ),
                              MyText(
                                text: AppLocalizations.of(context)!.wallet,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(
                                        fontSize: 18,
                                        color: AppColors.blackText),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: size.width * 0.06,
                ),
                CustomButton(
                  buttonName: AppLocalizations.of(context)!.confirm,
                  onTap: () async {
                    if (context.read<AccBloc>().choosenSubscriptionPayIndex ==
                        2) {
                      if (subscriptionListDatas[
                                  context.read<AccBloc>().choosenPlanindex]
                              .amount! >=
                          userData!.wallet!.data.amountBalance) {
                        context.read<AccBloc>().add(WalletEmptyEvent());
                      } else if (subscriptionListDatas[
                                  context.read<AccBloc>().choosenPlanindex]
                              .amount! <=
                          userData!.wallet!.data.amountBalance) {
                        context.read<AccBloc>().add(
                              SubscribeToPlanEvent(
                                  paymentOpt: context
                                      .read<AccBloc>()
                                      .choosenSubscriptionPayIndex!,
                                  amount:
                                      (userData!.wallet!.data.amountBalance -
                                              subscriptionListDatas[context
                                                      .read<AccBloc>()
                                                      .choosenPlanindex]
                                                  .amount!)
                                          .toInt(),
                                  planId: subscriptionListDatas[context
                                          .read<AccBloc>()
                                          .choosenPlanindex]
                                      .id!),
                            );
                      }
                    } else if (context
                            .read<AccBloc>()
                            .choosenSubscriptionPayIndex ==
                        0) {
                      context.read<AccBloc>().walletAmountController.clear();
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: false,
                          enableDrag: false,
                          isDismissible: true,
                          builder: (_) {
                            return BlocProvider.value(
                              value: context.read<AccBloc>(),
                              child: paymentGatewaysList(
                                context,
                                size,
                                context.read<AccBloc>().walletPaymentGatways,
                              ),
                            );
                          });
                    }
                  },
                ),
              ],
            )
          : Padding(
              padding: EdgeInsets.only(
                top: size.width * 0.05,
              ),
              child: SubscriptionShimmer(size: size),
            );
    });
  }

  Widget paymentGatewaysList(BuildContext context, Size size,
      List<PaymentGateway> walletPaymentGatways) {
    return BlocBuilder<AccBloc, AccState>(builder: (context, state) {
      return walletPaymentGatways.isNotEmpty
          ? Column(
              children: [
                SizedBox(
                  height: size.width * 0.05,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: walletPaymentGatways.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemBuilder: (_, index) {
                      return Column(
                        children: [
                          (walletPaymentGatways[index].enabled == true)
                              ? InkWell(
                                  onTap: () {
                                    context.read<AccBloc>().add(
                                        PaymentOnTapEvent(
                                            selectedPaymentIndex: index));
                                  },
                                  child: Container(
                                    width: size.width * 0.9,
                                    padding: EdgeInsets.all(size.width * 0.02),
                                    margin: EdgeInsets.only(
                                        bottom: size.width * 0.025),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            width: 0.5,
                                            color: Theme.of(context)
                                                .primaryColorDark
                                                .withOpacity(0.5))),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl:
                                                    walletPaymentGatways[index]
                                                        .image,
                                                width: 30,
                                                height: 40,
                                                fit: BoxFit.contain,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Center(
                                                  child: Text(
                                                    "",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(
                                                    size.width * 0.01),
                                              ),
                                              MyText(
                                                  text: walletPaymentGatways[
                                                          index]
                                                      .gateway
                                                      .toString(),
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: size.width * 0.05,
                                          height: size.width * 0.05,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  width: 1.5,
                                                  color: Theme.of(context)
                                                      .primaryColorDark)),
                                          alignment: Alignment.center,
                                          child: Container(
                                            width: size.width * 0.03,
                                            height: size.width * 0.03,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: (context
                                                            .read<AccBloc>()
                                                            .choosenPaymentIndex ==
                                                        index)
                                                    ? Theme.of(context)
                                                        .primaryColorDark
                                                    : Colors.transparent),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      );
                    },
                  ),
                ),
                CustomButton(
                    buttonName: AppLocalizations.of(context)!.pay,
                    onTap: () async {
                      Navigator.pop(context);
                      context.read<AccBloc>().add(WalletPageReUpdateEvent(
                            currencySymbol: context
                                .read<AccBloc>()
                                .walletResponse!
                                .currencySymbol,
                            from: '2',
                            requestId: '',
                            planId: context
                                .read<AccBloc>()
                                .subscriptionList[
                                    context.read<AccBloc>().choosenPlanindex]
                                .id!
                                .toString(),
                            money: context
                                .read<AccBloc>()
                                .addMoneySubscription
                                .toString(),
                            url: walletPaymentGatways[context
                                    .read<AccBloc>()
                                    .choosenPaymentIndex!]
                                .url,
                            userId: userData!.userId.toString(),
                          ));
                    }),
                SizedBox(
                  height: size.width * 0.05,
                )
              ],
            )
          : const SizedBox();
    });
  }
}

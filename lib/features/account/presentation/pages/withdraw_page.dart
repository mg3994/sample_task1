import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/wallet_shimmer.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../domain/models/walletpage_model.dart';

class WithdrawPage extends StatelessWidget {
  static const String routeName = '/withdrawPage';

  const WithdrawPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()..add(GetWithdrawInitEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is WithdrawDataLoadingStartState) {
            CustomLoader.loader(context);
          }
          if (state is WithdrawDataLoadingStopState) {
            CustomLoader.dismiss(context);
          }

          if (state is ShowErrorState) {
            context.showSnackBar(color: AppColors.red, message: state.message);
          }

          if (state is BankUpdateSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.paymentMethodSuccess)));
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: Stack(
              children: [
                SizedBox(
                  height: size.height,
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.width * 0.5,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
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
                                ],
                              ),
                              SizedBox(
                                height: size.width * 0.25,
                                width: size.width,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    MyText(
                                        text: AppLocalizations.of(context)!
                                            .walletBalance,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(color: Colors.white)),
                                    if (context
                                            .read<AccBloc>()
                                            .isWithdrawLoading &&
                                        !context
                                            .read<AccBloc>()
                                            .loadWithdrawMore)
                                      SizedBox(
                                        height: size.width * 0.06,
                                        width: size.width * 0.06,
                                        child: const Loader(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    if (context
                                            .read<AccBloc>()
                                            .withdrawResponse !=
                                        null)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          MyText(
                                              text:
                                                  '${context.read<AccBloc>().withdrawResponse!.walletBalance.toString()} ${userData!.currencySymbol.toString()}',
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .displayLarge!
                                                  .copyWith(
                                                      color: Colors.white)),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: size.width,
                          padding: EdgeInsets.all(size.width * 0.05),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: size.width * 0.075,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .recentWithdrawal,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.width * 0.025),
                              if (context.read<AccBloc>().isWithdrawLoading &&
                                  context.read<AccBloc>().firstWithdrawLoad)
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: 8,
                                    itemBuilder: (context, index) {
                                      return ShimmerWalletHistory(size: size);
                                    },
                                  ),
                                ),
                              if (context.read<AccBloc>().isWithdrawLoading ==
                                  false) ...[
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: context
                                        .read<AccBloc>()
                                        .scrollController,
                                    child: Column(
                                      children: [
                                        buildWalletHistoryData(
                                          size,
                                          context.read<AccBloc>().withdrawData,
                                          context,
                                        ),
                                        if (context
                                            .read<AccBloc>()
                                            .loadWithdrawMore)
                                          Center(
                                            child: SizedBox(
                                                height: size.width * 0.08,
                                                width: size.width * 0.08,
                                                child:
                                                    const CircularProgressIndicator()),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                CustomButton(
                                    width: size.width * 0.7,
                                    buttonName: AppLocalizations.of(context)!
                                        .requestWithdraw,
                                    onTap: () {
                                      if (context
                                          .read<AccBloc>()
                                          .bankDetails
                                          .where((e) =>
                                              e['driver_bank_info']['data']
                                                  .toString() !=
                                              '[]')
                                          .isNotEmpty) {
                                        context
                                            .read<AccBloc>()
                                            .withdrawAmountController
                                            .clear();
                                        showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (builder) {
                                              return withdrawMoneyWallet(
                                                  context, size);
                                            });
                                      } else {
                                        showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (builder) {
                                              return Container(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                width: size.width,
                                                padding: EdgeInsets.all(
                                                    size.width * 0.05),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: size.width * 0.9,
                                                      child: MyText(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .paymentMethods,
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: size.width * 0.05,
                                                    ),
                                                    for (var i = 0;
                                                        i <
                                                            context
                                                                .read<AccBloc>()
                                                                .bankDetails
                                                                .length;
                                                        i++)
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);

                                                          context
                                                              .read<AccBloc>()
                                                              .add(AddBankEvent(
                                                                  choosen: i));
                                                        },
                                                        child: Container(
                                                          width:
                                                              size.width * 0.9,
                                                          margin: EdgeInsets.only(
                                                              bottom:
                                                                  size.width *
                                                                      0.025),
                                                          padding:
                                                              EdgeInsets.all(
                                                            size.width * 0.05,
                                                          ),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: Theme.of(
                                                                      context)
                                                                  .disabledColor
                                                                  .withOpacity(
                                                                      0.3)),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: MyText(
                                                                    text: context
                                                                            .read<
                                                                                AccBloc>()
                                                                            .bankDetails[i]
                                                                        [
                                                                        'method_name'],
                                                                    textStyle: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyLarge!
                                                                        .copyWith(
                                                                            color:
                                                                                Theme.of(context).primaryColorDark)),
                                                              ),
                                                              MyText(
                                                                  text: (context
                                                                              .read<
                                                                                  AccBloc>()
                                                                              .bankDetails[i]['driver_bank_info'][
                                                                                  'data']
                                                                              .toString() ==
                                                                          '[]')
                                                                      ? AppLocalizations.of(
                                                                              context)!
                                                                          .textAdd
                                                                      : AppLocalizations.of(
                                                                              context)!
                                                                          .textView,
                                                                  textStyle: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyMedium!
                                                                      .copyWith(
                                                                          color:
                                                                              Theme.of(context).primaryColorDark)),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                  ],
                                                ),
                                              );
                                            });
                                      }
                                    })
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    top: size.width * 0.45,
                    left: size.width * 0.05,
                    right: size.width * 0.05,
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (builder) {
                              return Container(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0.8),
                                width: size.width,
                                padding: EdgeInsets.all(size.width * 0.05),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.9,
                                      child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .paymentMethods,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorDark),
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.width * 0.05,
                                    ),
                                    for (var i = 0;
                                        i <
                                            context
                                                .read<AccBloc>()
                                                .bankDetails
                                                .length;
                                        i++)
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);

                                          (context
                                                      .read<AccBloc>()
                                                      .bankDetails[i]
                                                          ['driver_bank_info']
                                                          ['data']
                                                      .toString() ==
                                                  '[]')
                                              ? context
                                                  .read<AccBloc>()
                                                  .add(AddBankEvent(choosen: i))
                                              : context.read<AccBloc>().add(
                                                  EditBankEvent(choosen: i));
                                        },
                                        child: Container(
                                          width: size.width * 0.9,
                                          margin: EdgeInsets.only(
                                              bottom: size.width * 0.025),
                                          padding: EdgeInsets.all(
                                            size.width * 0.05,
                                          ),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Theme.of(context)
                                                  .disabledColor
                                                  .withOpacity(0.5)),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: MyText(
                                                    text: context
                                                            .read<AccBloc>()
                                                            .bankDetails[i]
                                                        ['method_name'],
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark)),
                                              ),
                                              MyText(
                                                  text: (context
                                                              .read<AccBloc>()
                                                              .bankDetails[i][
                                                                  'driver_bank_info']
                                                                  ['data']
                                                              .toString() ==
                                                          '[]')
                                                      ? AppLocalizations.of(
                                                              context)!
                                                          .textAdd
                                                      : AppLocalizations.of(
                                                              context)!
                                                          .textView,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark)),
                                            ],
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              );
                            });
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                            size.width * 0.05,
                            size.width * 0.025,
                            size.width * 0.05,
                            size.width * 0.025),
                        width: size.width * 0.5,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                offset: const Offset(0, 4),
                                spreadRadius: 0,
                                blurRadius: 5)
                          ],
                        ),
                        alignment: Alignment.center,
                        child: MyText(
                          text:
                              AppLocalizations.of(context)!.updatePaymentMethod,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Theme.of(context).primaryColorDark),
                        ),
                      ),
                    )),
                if (context.read<AccBloc>().addBankInfo ||
                    context.read<AccBloc>().editBank)
                  Positioned(
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(size.width * 0.05),
                      height: size.height,
                      width: size.width,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).padding.top,
                          ),
                          SizedBox(
                            width: size.width * 0.9,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (context.read<AccBloc>().editBank) {
                                      context
                                          .read<AccBloc>()
                                          .add(EditBankEvent(choosen: null));
                                    } else {
                                      context
                                          .read<AccBloc>()
                                          .add(AddBankEvent(choosen: null));
                                    }
                                  },
                                  child: Container(
                                    height: size.height * 0.08,
                                    width: size.width * 0.08,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
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
                                    child: Icon(
                                      CupertinoIcons.back,
                                      size: 20,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                ),
                                MyText(
                                  text: context.read<AccBloc>().editBank
                                      ? AppLocalizations.of(context)!
                                          .editBankDetails
                                      : AppLocalizations.of(context)!
                                          .bankDetails,
                                  textStyle: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: size.width * 0.08,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.width * 0.05,
                          ),
                          SizedBox(
                            height: size.height * 0.6,
                            child: SingleChildScrollView(
                              child: Column(
                                children: context
                                    .read<AccBloc>()
                                    .choosenBankList
                                    .asMap()
                                    .map((k, v) {
                                      return MapEntry(
                                          k,
                                          Column(
                                            children: [
                                              SizedBox(
                                                height: size.width * 0.05,
                                              ),
                                              SizedBox(
                                                width: size.width * 0.9,
                                                child: MyText(
                                                  text: context
                                                          .read<AccBloc>()
                                                          .choosenBankList[k]
                                                      ['placeholder'],
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(fontSize: 16),
                                                ),
                                              ),
                                              SizedBox(
                                                height: size.width * 0.025,
                                              ),
                                              SizedBox(
                                                width: size.width * 0.9,
                                                child: CustomTextField(
                                                  keyboardType: context
                                                                  .read<AccBloc>()
                                                                  .choosenBankList[k]
                                                              [
                                                              'input_field_type'] ==
                                                          "text"
                                                      ? TextInputType.text
                                                      : TextInputType.number,
                                                  readOnly: context
                                                      .read<AccBloc>()
                                                      .editBank,
                                                  controller: context
                                                      .read<AccBloc>()
                                                      .bankDetailsText[k],
                                                  hintText: context
                                                          .read<AccBloc>()
                                                          .choosenBankList[k]
                                                      ['placeholder'],
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark)),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark)),
                                                  disabledBorder:
                                                      UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark)),
                                                ),
                                              ),
                                            ],
                                          ));
                                    })
                                    .values
                                    .toList(),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.width * 0.05,
                          ),
                          CustomButton(
                              buttonName: AppLocalizations.of(context)!.confirm,
                              onTap: () {
                                Map body = {
                                  "method_id": context
                                      .read<AccBloc>()
                                      .choosenBankList[0]['method_id'],
                                };

                                for (var i = 0;
                                    i <
                                        context
                                            .read<AccBloc>()
                                            .choosenBankList
                                            .length;
                                    i++) {
                                  if ((context
                                                  .read<AccBloc>()
                                                  .choosenBankList[i]
                                                      ['is_required']
                                                  .toString() ==
                                              '1' &&
                                          context
                                              .read<AccBloc>()
                                              .bankDetailsText[i]
                                              .text
                                              .isNotEmpty) ||
                                      context
                                          .read<AccBloc>()
                                          .bankDetailsText[i]
                                          .text
                                          .isNotEmpty) {
                                    body["${context.read<AccBloc>().choosenBankList[i]['input_field_name']}"] =
                                        context
                                            .read<AccBloc>()
                                            .bankDetailsText[i]
                                            .text;
                                  } else if (context
                                          .read<AccBloc>()
                                          .choosenBankList[i]['is_required']
                                          .toString() ==
                                      '1') {
                                    showToast(
                                        message: AppLocalizations.of(context)!
                                            .enterRequiredField);
                                    return;
                                  }
                                }
                                context
                                    .read<AccBloc>()
                                    .add(UpdateBankDetailsEvent(body: body));
                              }),
                        ],
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

  Widget buildWalletHistoryData(
      Size size, List walletHistoryList, BuildContext context) {
    return walletHistoryList.isNotEmpty
        ? Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: RawScrollbar(
              radius: const Radius.circular(20),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: walletHistoryList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        width: size.width,
                        height: size.width * 0.175,
                        margin: EdgeInsets.only(bottom: size.width * 0.030),
                        padding: EdgeInsets.all(size.width * 0.025),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              width: 0.5,
                              color: Theme.of(context)
                                  .disabledColor
                                  .withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MyText(
                                      text: walletHistoryList[index]['status'],
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  MyText(
                                      text: walletHistoryList[index]
                                          ['created_at'],
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .disabledColor)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                MyText(
                                    text:
                                        '${userData!.currencySymbol}${walletHistoryList[index]['requested_amount'].toString()}',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            color: AppColors.green,
                                            fontWeight: FontWeight.w600)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        : Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages.walletNoData,
                    height: size.width * 0.6,
                    width: 200,
                  ),
                  const SizedBox(height: 10),
                  MyText(
                    text: AppLocalizations.of(context)!.noPaymentHistory,
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Theme.of(context).disabledColor),
                  ),
                  MyText(
                    text: AppLocalizations.of(context)!.bookingRideText,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).disabledColor,
                        ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget addMoneyWallet(BuildContext context, Size size) {
    return StatefulBuilder(builder: (_, add) {
      return Container(
        padding: MediaQuery.of(context).viewInsets,
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size.width * 0.05),
                topRight: Radius.circular(size.width * 0.05))),
        child: Container(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: size.width * 0.128,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        width: 1.2, color: Theme.of(context).disabledColor)),
                child: Row(
                  children: [
                    Container(
                      width: size.width * 0.15,
                      height: size.width * 0.128,
                      decoration: BoxDecoration(
                          borderRadius: (languageDirection == 'ltr')
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                )
                              : const BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12)),
                          color: Theme.of(context).scaffoldBackgroundColor),
                      alignment: Alignment.center,
                      child: MyText(text: userData!.currencySymbol.toString()),
                    ),
                    SizedBox(
                      width: size.width * 0.05,
                    ),
                    Container(
                      height: size.width * 0.128,
                      width: size.width * 0.6,
                      alignment: Alignment.center,
                      child: TextField(
                        controller:
                            context.read<AccBloc>().withdrawAmountController,
                        onChanged: (value) {
                          context.read<AccBloc>().addMoney = int.parse(value);
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                AppLocalizations.of(context)!.enterAmount),
                        maxLines: 1,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: size.width * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      context.read<AccBloc>().withdrawAmountController.text =
                          '100';
                      context.read<AccBloc>().addMoney = 100;
                    },
                    child: Container(
                      height: size.width * 0.11,
                      width: size.width * 0.17,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).disabledColor,
                              width: 1.2),
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(6)),
                      alignment: Alignment.center,
                      child: MyText(
                          text:
                              '${context.read<AccBloc>().walletResponse!.currencySymbol.toString()}100'),
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.05,
                  ),
                  InkWell(
                    onTap: () {
                      context.read<AccBloc>().withdrawAmountController.text =
                          '500';
                      context.read<AccBloc>().addMoney = 500;
                    },
                    child: Container(
                      height: size.width * 0.11,
                      width: size.width * 0.17,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).disabledColor,
                              width: 1.2),
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(6)),
                      alignment: Alignment.center,
                      child: MyText(
                          text:
                              '${context.read<AccBloc>().walletResponse!.currencySymbol.toString()}500'),
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.05,
                  ),
                  InkWell(
                    onTap: () {
                      context.read<AccBloc>().withdrawAmountController.text =
                          '1000';
                      context.read<AccBloc>().addMoney = 1000;
                    },
                    child: Container(
                      height: size.width * 0.11,
                      width: size.width * 0.17,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).disabledColor,
                              width: 1.2),
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(6)),
                      alignment: Alignment.center,
                      child: MyText(
                          text:
                              '${context.read<AccBloc>().walletResponse!.currencySymbol.toString()}1000'),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: size.width * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: size.width * 0.11,
                      width: size.width * 0.425,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 1.2),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6)),
                      alignment: Alignment.center,
                      child: MyText(
                        text: AppLocalizations.of(context)!.cancel,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (context
                              .read<AccBloc>()
                              .withdrawAmountController
                              .text
                              .isNotEmpty &&
                          context.read<AccBloc>().addMoney != null) {
                        Navigator.pop(context);
                        final confirmPayment = context.read<AccBloc>();
                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: false,
                            enableDrag: true,
                            isDismissible: true,
                            builder: (_) {
                              return BlocProvider.value(
                                value: confirmPayment,
                                child: paymentGatewaysList(
                                    context,
                                    size,
                                    context
                                        .read<AccBloc>()
                                        .walletPaymentGatways),
                              );
                            });
                      }
                    },
                    child: Container(
                      height: size.width * 0.11,
                      width: size.width * 0.425,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(6)),
                      alignment: Alignment.center,
                      child: MyText(
                        text: AppLocalizations.of(context)!.addMoney,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }

  Widget transferMoney(BuildContext context, Size size) {
    return StatefulBuilder(builder: (_, add) {
      return Container(
        padding: MediaQuery.of(context).viewInsets,
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size.width * 0.05),
                topRight: Radius.circular(size.width * 0.05))),
        width: size.width,
        child: Container(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                decoration: InputDecoration(
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  filled: true,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).disabledColor,
                      width: 1.2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Theme.of(context).disabledColor,
                    width: 1.2,
                    style: BorderStyle.solid,
                  )),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Theme.of(context).disabledColor,
                    width: 1.2,
                    style: BorderStyle.solid,
                  )),
                ),
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                value: context.read<AccBloc>().dropdownValue,
                onChanged: (String? newValue) {
                  context.read<AccBloc>().add(TransferMoneySelectedEvent(
                      selectedTransferAmountMenuItem: newValue!));
                },
                items: context.read<AccBloc>().dropdownItems,
              ),
              TextFormField(
                controller: context.read<AccBloc>().transferAmount,
                style: Theme.of(context).textTheme.bodyMedium,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.enterAmount,
                  counterText: '',
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Theme.of(context).disabledColor,
                    width: 1.2,
                    style: BorderStyle.solid,
                  )),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Theme.of(context).disabledColor,
                    width: 1.2,
                    style: BorderStyle.solid,
                  )),
                ),
              ),
              TextFormField(
                controller: context.read<AccBloc>().transferPhonenumber,
                style: Theme.of(context).textTheme.bodyMedium,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.enterMobileNumber,
                  counterText: '',
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Theme.of(context).disabledColor,
                    width: 1.2,
                    style: BorderStyle.solid,
                  )),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Theme.of(context).disabledColor,
                    width: 1.2,
                    style: BorderStyle.solid,
                  )),
                ),
              ),
              SizedBox(
                height: size.width * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: size.width * 0.11,
                      width: size.width * 0.425,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 1.2),
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(6)),
                      alignment: Alignment.center,
                      child: MyText(
                        text: AppLocalizations.of(context)!.cancel,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (context.read<AccBloc>().transferAmount.text == '' ||
                          context.read<AccBloc>().transferPhonenumber.text ==
                              '') {
                      } else {
                        context.read<AccBloc>().add(MoneyTransferedEvent(
                            transferAmount:
                                context.read<AccBloc>().transferAmount.text,
                            role: context.read<AccBloc>().dropdownValue,
                            transferMobile: context
                                .read<AccBloc>()
                                .transferPhonenumber
                                .text));
                      }
                    },
                    child: Container(
                      height: size.width * 0.11,
                      width: size.width * 0.425,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(6)),
                      alignment: Alignment.center,
                      child: MyText(
                        text: AppLocalizations.of(context)!.transferMoney,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }

  Widget paymentGatewaysList(BuildContext context, Size size,
      List<PaymentGateway> walletPaymentGatways) {
    return BlocBuilder<AccBloc, AccState>(builder: (context, state) {
      return walletPaymentGatways.isNotEmpty
          ? Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
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
                                      padding:
                                          EdgeInsets.all(size.width * 0.02),
                                      margin: EdgeInsets.only(
                                          bottom: size.width * 0.025),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(
                                                      size.width * 0.05),
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
                                                                .primaryColor)),
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
                                                        .primaryColor)),
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
                                                          .primaryColor
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
                        context.read<AccBloc>().add(
                              WalletPageReUpdateEvent(
                                currencySymbol: context
                                    .read<AccBloc>()
                                    .walletResponse!
                                    .currencySymbol,
                                from: '',
                                requestId: '',
                                planId: '',
                                money:
                                    context.read<AccBloc>().addMoney.toString(),
                                url: walletPaymentGatways[context
                                        .read<AccBloc>()
                                        .choosenPaymentIndex!]
                                    .url,
                                userId: userData!.userId.toString(),
                              ),
                            );
                      }),
                  SizedBox(
                    height: size.width * 0.05,
                  )
                ],
              ),
            )
          : const SizedBox();
    });
  }
}

Widget withdrawMoneyWallet(BuildContext context, Size size) {
  return StatefulBuilder(builder: (_, add) {
    return Container(
      padding: MediaQuery.of(context).viewInsets,
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size.width * 0.05),
              topRight: Radius.circular(size.width * 0.05))),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: size.width * 0.128,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      width: 1.2, color: Theme.of(context).disabledColor)),
              child: Row(
                children: [
                  Container(
                    width: size.width * 0.15,
                    height: size.width * 0.128,
                    decoration: BoxDecoration(
                        borderRadius: (languageDirection == 'ltr')
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              )
                            : const BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12)),
                        color: Theme.of(context).scaffoldBackgroundColor),
                    alignment: Alignment.center,
                    child: MyText(text: userData!.currencySymbol.toString()),
                  ),
                  SizedBox(
                    width: size.width * 0.05,
                  ),
                  Container(
                    height: size.width * 0.128,
                    width: size.width * 0.6,
                    alignment: Alignment.center,
                    child: TextField(
                      controller:
                          context.read<AccBloc>().withdrawAmountController,
                      onChanged: (value) {
                        context.read<AccBloc>().addMoney = int.parse(value);
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: AppLocalizations.of(context)!.enterAmount),
                      maxLines: 1,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: size.width * 0.05,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    context.read<AccBloc>().withdrawAmountController.text =
                        '100';
                    context.read<AccBloc>().addMoney = 100;
                  },
                  child: Container(
                    height: size.width * 0.11,
                    width: size.width * 0.17,
                    // width: size.width *
                    //     0.275,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).disabledColor, width: 1.2),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(6)),
                    alignment: Alignment.center,
                    child: MyText(
                        text: '${userData!.currencySymbol.toString()}100'),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.05,
                ),
                InkWell(
                  onTap: () {
                    context.read<AccBloc>().withdrawAmountController.text =
                        '500';
                    context.read<AccBloc>().addMoney = 500;
                  },
                  child: Container(
                    height: size.width * 0.11,
                    width: size.width * 0.17,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).disabledColor, width: 1.2),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(6)),
                    alignment: Alignment.center,
                    child: MyText(
                        text: '${userData!.currencySymbol.toString()}500'),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.05,
                ),
                InkWell(
                  onTap: () {
                    context.read<AccBloc>().withdrawAmountController.text =
                        '1000';
                    context.read<AccBloc>().addMoney = 1000;
                  },
                  child: Container(
                    height: size.width * 0.11,
                    width: size.width * 0.17,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).disabledColor, width: 1.2),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(6)),
                    alignment: Alignment.center,
                    child: MyText(
                        text: '${userData!.currencySymbol.toString()}1000'),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: size.width * 0.05,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: size.width * 0.11,
                    width: size.width * 0.425,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).primaryColor, width: 1.2),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6)),
                    alignment: Alignment.center,
                    child: MyText(
                      text: AppLocalizations.of(context)!.cancel,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    if (context
                            .read<AccBloc>()
                            .withdrawAmountController
                            .text
                            .isNotEmpty &&
                        double.parse(context
                                .read<AccBloc>()
                                .withdrawResponse!
                                .walletBalance) >=
                            double.parse(context
                                .read<AccBloc>()
                                .withdrawAmountController
                                .text)) {
                      context.read<AccBloc>().add(RequestWithdrawEvent(
                          amount: context
                              .read<AccBloc>()
                              .withdrawAmountController
                              .text));
                    } else {
                      context.showSnackBar(
                          color: AppColors.red,
                          message: AppLocalizations.of(context)!
                              .insufficientWithdraw);
                    }
                  },
                  child: Container(
                    height: size.width * 0.11,
                    width: size.width * 0.425,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(6)),
                    alignment: Alignment.center,
                    child: MyText(
                      text: AppLocalizations.of(context)!.withdraw,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  });
}

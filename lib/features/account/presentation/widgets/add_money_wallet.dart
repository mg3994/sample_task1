import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/domain/models/subcription_list_model.dart';
import 'package:restart_tagxi/features/account/domain/models/walletpage_model.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class AddMoneyWalletSection extends StatefulWidget {
  final Size size;
  final AccBloc accBloc;
  final VoidCallback onTap;
  final SubscriptionData subscriptionData;

  const AddMoneyWalletSection(
      {super.key,
      required this.size,
      required this.accBloc,
      required this.onTap,
      required this.subscriptionData});

  @override
  State<AddMoneyWalletSection> createState() => _AddMoneyWalletSectionState();
}

class _AddMoneyWalletSectionState extends State<AddMoneyWalletSection> {
  @override
  void initState() {
    widget.accBloc.walletAmountController.text =
        widget.subscriptionData.amount.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MediaQuery.of(context).viewInsets,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.size.width * 0.05),
          topRight: Radius.circular(widget.size.width * 0.05),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(widget.size.width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyInputField(context),
            SizedBox(height: widget.size.width * 0.05),
            _buildPresetAmountOptions(context),
            SizedBox(height: widget.size.width * 0.05),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  // Currency input field widget
  Widget _buildCurrencyInputField(BuildContext context) {
    return Container(
      height: widget.size.width * 0.128,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1.2,
          color: Theme.of(context).disabledColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: widget.size.width * 0.15,
            height: widget.size.width * 0.128,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              color: Color(0xffF0F0F0),
            ),
            alignment: Alignment.center,
            child: MyText(
                text: widget.accBloc.walletResponse?.currencySymbol ?? ''),
          ),
          SizedBox(width: widget.size.width * 0.05),
          Container(
            height: widget.size.width * 0.128,
            width: widget.size.width * 0.6,
            alignment: Alignment.center,
            child: TextField(
              controller: widget.accBloc.walletAmountController,
              onChanged: (value) {
                widget.accBloc.addMoney = int.tryParse(value) ?? 0;
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Amount Here',
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // Preset amount options (100, 500, 1000)
  Widget _buildPresetAmountOptions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _presetAmountButton(context, amount: 100),
        SizedBox(width: widget.size.width * 0.05),
        _presetAmountButton(context, amount: 500),
        SizedBox(width: widget.size.width * 0.05),
        _presetAmountButton(context, amount: 1000),
      ],
    );
  }

  // Preset amount button widget
  Widget _presetAmountButton(BuildContext context, {required int amount}) {
    return InkWell(
      onTap: () {
        widget.accBloc.walletAmountController.text = '$amount';
        widget.accBloc.addMoney = amount;
      },
      child: Container(
        height: widget.size.width * 0.11,
        width: widget.size.width * 0.17,
        decoration: BoxDecoration(
          border:
              Border.all(color: Theme.of(context).disabledColor, width: 1.2),
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: MyText(
          text: '${widget.accBloc.walletResponse?.currencySymbol ?? ''}$amount',
        ),
      ),
    );
  }

  // Action buttons (Cancel, Add Money)
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: widget.size.width * 0.11,
            width: widget.size.width * 0.425,
            decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).primaryColor, width: 1.2),
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
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
          onTap: widget.onTap,
          child: Container(
            height: widget.size.width * 0.11,
            width: widget.size.width * 0.425,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
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
    );
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
            )
          : const SizedBox();
    });
  }
}

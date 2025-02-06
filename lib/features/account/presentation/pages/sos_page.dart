import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_dialoges.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/domain/models/contact_model.dart';
import 'package:restart_tagxi/features/account/presentation/pages/pick_contact.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/sos_card_shimmer.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../common/common.dart';
import '../../application/acc_bloc.dart';
import '../widgets/top_bar.dart';

class SosPage extends StatelessWidget {
  static const String routeName = '/sosPage';
  final SOSPageArguments arg;

  const SosPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()..add(SosInitEvent(arg: arg)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is SelectContactDetailsState) {
            final accBloc = context.read<AccBloc>();
            showModalBottomSheet(
              context: context,
              isDismissible: true,
              enableDrag: true,
              useRootNavigator: true,
              isScrollControlled: true,
              builder: (_) {
                return BlocProvider.value(
                  value: accBloc,
                  child: const PickContact(),
                );
              },
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
              body: TopBarDesign(
                onTap: () {
                  Navigator.pop(context, context.read<AccBloc>().sosdata);
                },
                isHistoryPage: false,
                title: AppLocalizations.of(context)!.sosText,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (context.read<AccBloc>().isSosLoading)
                        ListView.builder(
                          itemCount: 6,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return SosShimmerLoading(size: size);
                          },
                        ),
                      if (!context.read<AccBloc>().isSosLoading)
                        sosDetails(
                            size, context.read<AccBloc>().sosdata, context),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: (context.read<AccBloc>().sosdata.length <= 4)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      child: CustomButton(
                          buttonName: AppLocalizations.of(context)!.addAContact,
                          onTap: () {
                            context.read<AccBloc>().selectedContact =
                                ContactsModel(name: '', number: '');
                            context
                                .read<AccBloc>()
                                .add(SelectContactDetailsEvent());
                          }),
                    )
                  : null);
        }),
      ),
    );
  }

  Widget sosDetails(Size size, List<SOSDatum> sosdata, BuildContext context) {
    return sosdata.isNotEmpty
        ? RawScrollbar(
            radius: const Radius.circular(20),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sosdata.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return (sosdata[index].userType != 'admin')
                    ? Container(
                        width: size.width,
                        margin: const EdgeInsets.only(right: 10, bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1.2,
                                color: Theme.of(context).disabledColor)),
                        child: Padding(
                          padding: EdgeInsets.all(size.width * 0.025),
                          child: Row(
                            children: [
                              SizedBox(width: size.width * 0.025),
                              Container(
                                height: size.width * 0.13,
                                width: size.width * 0.13,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context)
                                      .disabledColor
                                      .withOpacity(0.5),
                                ),
                                alignment: Alignment.center,
                                child: MyText(
                                  text: sosdata[index]
                                      .name
                                      .toString()
                                      .substring(0, 1),
                                ),
                              ),
                              SizedBox(
                                width: size.width * 0.025,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MyText(
                                            text: sosdata[index].name,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w600),
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MyText(
                                            text: sosdata[index].number,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w600),
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: size.width * 0.025),
                              InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext _) {
                                        return BlocProvider.value(
                                          value:
                                              BlocProvider.of<AccBloc>(context),
                                          child: CustomDoubleButtonDialoge(
                                            title: AppLocalizations.of(context)!
                                                .deleteSos,
                                            content:
                                                AppLocalizations.of(context)!
                                                    .deleteContactContent,
                                            yesBtnName:
                                                AppLocalizations.of(context)!
                                                    .yes,
                                            noBtnName:
                                                AppLocalizations.of(context)!
                                                    .no,
                                            yesBtnFunc: () {
                                              context
                                                  .read<AccBloc>()
                                                  .add(SosLoadingEvent());
                                              context.read<AccBloc>().add(
                                                  DeleteContactEvent(
                                                      id: sosdata[index].id));
                                              Navigator.pop(context);
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: const Icon(
                                    Icons.delete,
                                  ))
                            ],
                          ),
                        ),
                      )
                    : (sosdata.length == 1)
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppImages.sosNoData,
                                  height: size.width * 0.6,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .noContactsSos,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color:
                                              Theme.of(context).disabledColor,
                                          fontSize: 18),
                                ),
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .addContactSos,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color:
                                              Theme.of(context).disabledColor,
                                          fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox();
              },
            ),
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: size.width * 0.2,
                ),
                Image.asset(
                  AppImages.sosNoData,
                  height: size.width * 0.6,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyText(
                  text: AppLocalizations.of(context)!.noContactsSos,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                ),
                MyText(
                  text: AppLocalizations.of(context)!.addContactSos,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                ),
              ],
            ),
          );
  }
}

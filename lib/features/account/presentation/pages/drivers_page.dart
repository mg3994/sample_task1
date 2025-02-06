import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/top_bar.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class DriversPage extends StatelessWidget {
  static const String routeName = '/driversPage';

  const DriversPage({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
        create: (context) => AccBloc()..add(GetDriverEvent(from: 0)),
        child: BlocListener<AccBloc, AccState>(listener: (context, state) {
          if (state is DriversLoadingStartState) {
            CustomLoader.loader(context);
          }
          if (state is ShowErrorState) {
            context.showSnackBar(color: AppColors.red, message: state.message);
          }

          if (state is DriversLoadingStopState) {
            CustomLoader.dismiss(context);
          }
        }, child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            body: TopBarDesign(
              onTap: () {
                Navigator.pop(context);
              },
              isHistoryPage: false,
              title: AppLocalizations.of(context)!.drivers,
              child: Column(
                children: [
                  SizedBox(
                    height: size.width * 0.1,
                  ),
                  Expanded(
                      child: (context.read<AccBloc>().driverData.isEmpty)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppImages.noDriversAvail,
                                  width: 300,
                                ),
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .noDriversAdded,
                                  textStyle:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (var i = 0;
                                      i <
                                          context
                                              .read<AccBloc>()
                                              .driverData
                                              .length;
                                      i++)
                                    Stack(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              bottom: size.width * 0.05),
                                          padding:
                                              EdgeInsets.all(size.width * 0.05),
                                          width: size.width * 0.9,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColorDark
                                                  .withOpacity(0.1),
                                              border: Border.all(
                                                  color: Theme.of(context)
                                                      .primaryColorDark
                                                      .withOpacity(0.5)),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Row(
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    height: size.width * 0.15,
                                                    width: size.width * 0.15,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                            image: NetworkImage(
                                                                context
                                                                    .read<
                                                                        AccBloc>()
                                                                    .driverData[
                                                                        i]
                                                                    .profile),
                                                            fit: BoxFit.cover)),
                                                  ),
                                                  SizedBox(
                                                    height: size.width * 0.025,
                                                  ),
                                                  SizedBox(
                                                    width: size.width * 0.2,
                                                    child: MyText(
                                                      text: context
                                                          .read<AccBloc>()
                                                          .driverData[i]
                                                          .name,
                                                      textAlign:
                                                          TextAlign.center,
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodySmall!
                                                          .copyWith(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: size.width * 0.025,
                                              ),
                                              Container(
                                                width: 1,
                                                height: size.width * 0.21,
                                                color: Theme.of(context)
                                                    .primaryColorDark
                                                    .withOpacity(0.5),
                                              ),
                                              SizedBox(
                                                width: size.width * 0.05,
                                              ),
                                              Expanded(
                                                  child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height:
                                                            size.width * 0.06,
                                                        width:
                                                            size.width * 0.06,
                                                        decoration:
                                                            const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: AppColors
                                                                    .darkGrey),
                                                        child: Icon(
                                                          Icons.call,
                                                          color:
                                                              AppColors.white,
                                                          size:
                                                              size.width * 0.04,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            size.width * 0.025,
                                                      ),
                                                      Expanded(
                                                          child: MyText(
                                                        text: context
                                                            .read<AccBloc>()
                                                            .driverData[i]
                                                            .mobile,
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .copyWith(
                                                                fontSize: 14,
                                                                color: AppColors
                                                                    .darkGrey),
                                                      ))
                                                    ],
                                                  ),
                                                  if (context
                                                      .read<AccBloc>()
                                                      .driverData[i]
                                                      .approve)
                                                    Column(
                                                      children: [
                                                        SizedBox(
                                                          height:
                                                              size.width * 0.05,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              height:
                                                                  size.width *
                                                                      0.06,
                                                              width:
                                                                  size.width *
                                                                      0.06,
                                                              decoration: const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: AppColors
                                                                      .darkGrey),
                                                              child: Icon(
                                                                CupertinoIcons
                                                                    .car_detailed,
                                                                color: AppColors
                                                                    .white,
                                                                size:
                                                                    size.width *
                                                                        0.04,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.025,
                                                            ),
                                                            Expanded(
                                                                child: MyText(
                                                              text: context
                                                                      .read<
                                                                          AccBloc>()
                                                                      .driverData[
                                                                          i]
                                                                      .carNumber ??
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .fleetNotAssigned,
                                                              textStyle: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall!
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14,
                                                                      color: AppColors
                                                                          .red,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                            ))
                                                          ],
                                                        ),
                                                      ],
                                                    )
                                                ],
                                              ))
                                            ],
                                          ),
                                        ),
                                        if (context
                                                .read<AccBloc>()
                                                .driverData[i]
                                                .approve ==
                                            false)
                                          Positioned(
                                              top: 0,
                                              right:
                                                  (languageDirection == 'ltr')
                                                      ? 0
                                                      : null,
                                              left: (languageDirection == 'rtl')
                                                  ? 0
                                                  : null,
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    size.width * 0.025),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    color: (context
                                                            .read<AccBloc>()
                                                            .driverData[i]
                                                            .documentUploaded)
                                                        ? Colors.orange
                                                        : const Color.fromARGB(
                                                            255, 248, 92, 81)),
                                                child: MyText(
                                                  text: (context
                                                          .read<AccBloc>()
                                                          .driverData[i]
                                                          .documentUploaded)
                                                      ? AppLocalizations.of(
                                                              context)!
                                                          .waitingForApproval
                                                      : AppLocalizations.of(
                                                              context)!
                                                          .documentNotUploaded,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                          fontSize: 12,
                                                          color:
                                                              AppColors.white),
                                                ),
                                              )),
                                        Positioned(
                                            bottom: 5 + size.width * 0.05,
                                            right: (languageDirection == 'ltr')
                                                ? 5
                                                : null,
                                            left: (languageDirection == 'rtl')
                                                ? 5
                                                : null,
                                            child: InkWell(
                                                onTap: () {
                                                  context
                                                          .read<AccBloc>()
                                                          .choosenDriverForDelete =
                                                      context
                                                          .read<AccBloc>()
                                                          .driverData[i]
                                                          .id;
                                                  showDialog(
                                                      context: context,
                                                      builder: (builder) {
                                                        return AlertDialog(
                                                          title: MyText(
                                                            text: AppLocalizations
                                                                    .of(context)!
                                                                .deleteDriver,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                          content: MyText(
                                                            text: AppLocalizations
                                                                    .of(context)!
                                                                .deleteDriverSure,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                            maxLines: 4,
                                                          ),
                                                          actions: [
                                                            CustomButton(
                                                                buttonName: AppLocalizations.of(
                                                                        context)!
                                                                    .deleteDriver,
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  context
                                                                      .read<
                                                                          AccBloc>()
                                                                      .add(DeleteDriverEvent(
                                                                          driverId: context
                                                                              .read<AccBloc>()
                                                                              .choosenDriverForDelete!));
                                                                })
                                                          ],
                                                        );
                                                      });
                                                },
                                                child: Icon(
                                                  Icons.delete,
                                                  size: size.width * 0.06,
                                                  color: AppColors.red,
                                                ))),
                                      ],
                                    )
                                ],
                              ),
                            )),
                  SizedBox(
                    height: size.width * 0.05,
                  ),
                  SizedBox(
                    width: size.width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (builder) {
                                  return Scaffold(
                                    body: Container(
                                      height: size.height,
                                      width: size.width,
                                      padding:
                                          EdgeInsets.all(size.width * 0.05),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                .padding
                                                .top,
                                          ),
                                          SizedBox(
                                            width: size.width * 0.9,
                                            child: Row(
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Icon(
                                                      Icons.arrow_back,
                                                      size: size.width * 0.07,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    )),
                                                SizedBox(
                                                  width: size.width * 0.05,
                                                ),
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .addDriver,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .headlineMedium!
                                                      .copyWith(
                                                          fontSize: 16,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: size.width * 0.05,
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: size.width * 0.05,
                                                  ),
                                                  SizedBox(
                                                    width: size.width * 0.9,
                                                    child: MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .driverName,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                fontSize: 16,
                                                              ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: size.width * 0.05,
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.9,
                                                      child: CustomTextField(
                                                          focusedBorder:
                                                              const OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                            color: AppColors
                                                                .darkGrey,
                                                            width: 1,
                                                          )),
                                                          hintText: AppLocalizations
                                                                  .of(context)!
                                                              .enterDriverName,
                                                          controller: context
                                                              .read<AccBloc>()
                                                              .driverNameController)),
                                                  SizedBox(
                                                    height: size.width * 0.05,
                                                  ),
                                                  SizedBox(
                                                    width: size.width * 0.9,
                                                    child: MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .driverMobile,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                fontSize: 16,
                                                              ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: size.width * 0.05,
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.9,
                                                      child: CustomTextField(
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          focusedBorder:
                                                              const OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                            color: AppColors
                                                                .darkGrey,
                                                            width: 1,
                                                          )),
                                                          hintText: AppLocalizations
                                                                  .of(context)!
                                                              .enterDriverMobile,
                                                          controller: context
                                                              .read<AccBloc>()
                                                              .driverMobileController)),
                                                  SizedBox(
                                                    height: size.width * 0.05,
                                                  ),
                                                  SizedBox(
                                                    width: size.width * 0.9,
                                                    child: MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .driverEmail,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                fontSize: 16,
                                                              ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: size.width * 0.05,
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.9,
                                                      child: CustomTextField(
                                                          focusedBorder:
                                                              const OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                            color: AppColors
                                                                .darkGrey,
                                                            width: 1,
                                                          )),
                                                          hintText: AppLocalizations
                                                                  .of(context)!
                                                              .enterDriverEmail,
                                                          controller: context
                                                              .read<AccBloc>()
                                                              .driverEmailController)),
                                                  SizedBox(
                                                    height: size.width * 0.05,
                                                  ),
                                                  SizedBox(
                                                    width: size.width * 0.9,
                                                    child: MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .driverAddress,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                fontSize: 16,
                                                              ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: size.width * 0.05,
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.9,
                                                      child: CustomTextField(
                                                          focusedBorder:
                                                              const OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                            color: AppColors
                                                                .darkGrey,
                                                            width: 1,
                                                          )),
                                                          hintText: AppLocalizations
                                                                  .of(context)!
                                                              .enterDriverAddress,
                                                          controller: context
                                                              .read<AccBloc>()
                                                              .driverAddressController)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: size.width * 0.05,
                                          ),
                                          CustomButton(
                                              buttonName:
                                                  AppLocalizations.of(context)!
                                                      .addDriver,
                                              onTap: () {
                                                if (context
                                                        .read<AccBloc>()
                                                        .driverAddressController
                                                        .text
                                                        .isNotEmpty &&
                                                    context
                                                        .read<AccBloc>()
                                                        .driverEmailController
                                                        .text
                                                        .isNotEmpty &&
                                                    context
                                                        .read<AccBloc>()
                                                        .driverMobileController
                                                        .text
                                                        .isNotEmpty &&
                                                    context
                                                        .read<AccBloc>()
                                                        .driverNameController
                                                        .text
                                                        .isNotEmpty) {
                                                  context
                                                      .read<AccBloc>()
                                                      .add(AddDriverEvent());
                                                  Navigator.pop(context);
                                                } else {
                                                  showToast(
                                                      message: AppLocalizations
                                                              .of(context)!
                                                          .enterRequiredField);
                                                }
                                              }),
                                          SizedBox(
                                            height: size.width * 0.05,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: Container(
                            width: size.width * 0.128,
                            height: size.width * 0.128,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.darkGrey),
                                color: AppColors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Theme.of(context).shadowColor,
                                      spreadRadius: 1,
                                      blurRadius: 1)
                                ]),
                            child: Icon(
                              Icons.add,
                              size: size.width * 0.1,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.width * 0.05,
                  ),
                ],
              ),
            ),
          );
        })));
  }
}

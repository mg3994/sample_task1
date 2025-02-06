// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_sliderbutton.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/account/presentation/pages/subscription_page.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/top_bar.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/auth_page.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/pages/driver_profile_pages.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/invoice_page_widget.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/map_widget.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/review_page_widget.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../common/pickup_icon.dart';
import '../../application/home_bloc.dart';
import '../../../../common/common.dart';
import '../widgets/my_service_types.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/homePage';
  final HomePageArguments? args;
  const HomePage({super.key, this.args});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  //Animate
  late AnimationController _animationController;
  late Animation<double> animation;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    //Animate
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: false);

    animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (showBubbleIcon && Platform.isAndroid) {
        HomeBloc().startBubbleHead();
      }
      if (HomeBloc().rideStream != null) {
        HomeBloc().rideStream?.pause();
      }
      if (HomeBloc().rideAddStream != null) {
        HomeBloc().rideAddStream?.pause();
      }
    }
    if (state == AppLifecycleState.resumed) {
      if (showBubbleIcon && Platform.isAndroid) {
        HomeBloc().stopBubbleHead();
      }
      if (HomeBloc().rideStream != null) {
        HomeBloc().rideStream?.resume();
      }
      if (HomeBloc().rideAddStream != null) {
        HomeBloc().rideAddStream?.resume();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    HomeBloc().rideStream?.cancel();
    HomeBloc().requestStream?.cancel();
    HomeBloc().rideAddStream?.cancel();
    HomeBloc().bidRequestStream?.cancel();
    HomeBloc().googleMapController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return builderWidget(size);
  }

  Widget builderWidget(Size size) {
    return BlocProvider(
      create: (context) => HomeBloc()
        ..add(GetDirectionEvent(vsync: this))
        ..add(GetUserDetailsEvent()),
      // ..add(GetCurrentLocationEvent()),
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) async {
          if (state is HomeDataLoadingStartState) {
            CustomLoader.loader(context);
          } else if (state is HomeDataLoadingStopState) {
            CustomLoader.dismiss(context);
          } else if (state is UserUnauthenticatedState) {
            final type = await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, AuthPage.routeName, (route) => false,
                arguments: AuthPageArguments(type: type));
          } else if (state is GetLocationPermissionState) {
            showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                          alignment: languageDirection == 'rtl'
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.cancel_outlined,
                                  color: Theme.of(context).primaryColorDark))),
                      MyText(
                          text: AppLocalizations.of(context)!.locationAccess,
                          maxLines: 4),
                    ],
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () async {
                            await openAppSettings();
                          },
                          child: MyText(
                              text: AppLocalizations.of(context)!.openSetting,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.w600)),
                        ),
                        InkWell(
                          onTap: () async {
                            PermissionStatus status =
                                await Permission.location.status;
                            if (status.isGranted || status.isLimited) {
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              context
                                  .read<HomeBloc>()
                                  .add(GetCurrentLocationEvent());
                            } else {
                              if (!context.mounted) return;
                              Navigator.pop(context);
                            }
                          },
                          child: MyText(
                              text: AppLocalizations.of(context)!.done,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.w600)),
                        ),
                      ],
                    )
                  ],
                );
              },
            );
          } else if (state is ShowChooseStopsState) {
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (builder) {
                  return BlocProvider.value(
                    value: BlocProvider.of<HomeBloc>(context),
                    child: StatefulBuilder(builder: (context, state) {
                      return Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Padding(
                          padding: MediaQuery.of(context).viewInsets,
                          child: Container(
                            height: size.width,
                            width: size.width,
                            padding: EdgeInsets.all(size.width * 0.05),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: size.width * 0.1,
                                ),
                                SizedBox(
                                  width: size.width * 0.9,
                                  child: MyText(
                                    text: AppLocalizations.of(context)!
                                        .chooseStop,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    maxLines: 1,
                                  ),
                                ),
                                SizedBox(
                                  height: size.width * 0.05,
                                ),
                                Expanded(
                                    child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      for (var i = 0;
                                          i <
                                              userData!.onTripRequest!
                                                  .requestStops.length;
                                          i++)
                                        if (userData!.onTripRequest!
                                                    .requestStops[i]
                                                ['completed_at'] ==
                                            null)
                                          InkWell(
                                            onTap: () {
                                              state(() {
                                                context
                                                        .read<HomeBloc>()
                                                        .choosenCompleteStop =
                                                    userData!.onTripRequest!
                                                        .requestStops[i]['id']
                                                        .toString();
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  0,
                                                  size.width * 0.025,
                                                  0,
                                                  size.width * 0.025),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: size.width * 0.05,
                                                    width: size.width * 0.05,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: (context
                                                                        .read<
                                                                            HomeBloc>()
                                                                        .choosenCompleteStop ==
                                                                    userData!
                                                                        .onTripRequest!
                                                                        .requestStops[
                                                                            i][
                                                                            'id']
                                                                        .toString())
                                                                ? Theme.of(
                                                                        context)
                                                                    .primaryColorDark
                                                                : AppColors
                                                                    .darkGrey)),
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      height: size.width * 0.03,
                                                      width: size.width * 0.03,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: (context
                                                                      .read<
                                                                          HomeBloc>()
                                                                      .choosenCompleteStop ==
                                                                  userData!
                                                                      .onTripRequest!
                                                                      .requestStops[
                                                                          i]
                                                                          ['id']
                                                                      .toString())
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColorDark
                                                              : Colors
                                                                  .transparent),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: size.width * 0.025,
                                                  ),
                                                  Expanded(
                                                      child: MyText(
                                                    text: userData!
                                                            .onTripRequest!
                                                            .requestStops[i]
                                                        ['address'],
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                    maxLines: 2,
                                                  ))
                                                ],
                                              ),
                                            ),
                                          )
                                    ],
                                  ),
                                )),
                                SizedBox(
                                  height: size.width * 0.03,
                                ),
                                SizedBox(
                                  height: size.width * 0.03,
                                ),
                                CustomButton(
                                    buttonName: (userData!
                                                .onTripRequest!.transportType ==
                                            'taxi')
                                        ? AppLocalizations.of(context)!.endRide
                                        : AppLocalizations.of(context)!
                                            .dispatchGoods,
                                    onTap: () {
                                      if (context
                                              .read<HomeBloc>()
                                              .choosenCompleteStop !=
                                          null) {
                                        Navigator.pop(context);

                                        if (userData!.onTripRequest!
                                                    .transportType ==
                                                'delivery' &&
                                            userData!.onTripRequest!
                                                    .enableShipmentUnload ==
                                                '1') {
                                          context
                                              .read<HomeBloc>()
                                              .add(ShowImagePickEvent());
                                        } else if (userData!.onTripRequest!
                                                    .transportType ==
                                                'delivery' &&
                                            userData!.onTripRequest!
                                                    .enableDigitalSignature ==
                                                '1') {
                                          context
                                              .read<HomeBloc>()
                                              .add(ShowSignatureEvent());
                                        } else {
                                          context.read<HomeBloc>().add(
                                              CompleteStopEvent(
                                                  id: context
                                                      .read<HomeBloc>()
                                                      .choosenCompleteStop!));
                                        }
                                      }
                                    }),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                });
          } else if (state is InstantEtaSuccessState) {
            await showModalBottomSheet(
                isDismissible: false,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                isScrollControlled: true,
                context: context,
                builder: (builder) {
                  return BlocProvider.value(
                    value: BlocProvider.of<HomeBloc>(context),
                    child: StatefulBuilder(builder: (ctx, state) {
                      return Padding(
                        padding: MediaQuery.of(context).viewInsets,
                        child: Container(
                          height: (context.read<HomeBloc>().choosenGoods ==
                                      null &&
                                  context.read<HomeBloc>().instantRideType ==
                                      null)
                              ? size.width * 1.15
                              : (context.read<HomeBloc>().choosenGoods !=
                                          null &&
                                      context
                                              .read<HomeBloc>()
                                              .instantRideType !=
                                          null)
                                  ? size.width * 1.55
                                  : (context.read<HomeBloc>().choosenGoods !=
                                              null ||
                                          context
                                                  .read<HomeBloc>()
                                                  .instantRideType !=
                                              null)
                                      ? size.width * 1.35
                                      : size.width * 1.2,
                          width: size.width,
                          padding: EdgeInsets.only(
                              bottom: size.width * 0.04,
                              left: size.width * 0.03,
                              right: size.width * 0.03,
                              top: size.width * 0.04),
                          child: Column(
                            children: [
                              SizedBox(
                                width: size.width * 0.9,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Icon(Icons.cancel,
                                            size: size.width * 0.06,
                                            color: Theme.of(context)
                                                .primaryColorDark))
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: size.width * 0.05,
                              ),
                              if (context.read<HomeBloc>().instantRideType !=
                                  null)
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            state(() {
                                              context
                                                  .read<HomeBloc>()
                                                  .instantRideType = 'taxi';
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                width: size.width * 0.05,
                                                height: size.width * 0.05,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: (context
                                                                    .read<
                                                                        HomeBloc>()
                                                                    .instantRideType ==
                                                                'taxi')
                                                            ? Theme.of(context)
                                                                .primaryColorDark
                                                            : AppColors.black)),
                                                alignment: Alignment.center,
                                                child: Container(
                                                  width: size.width * 0.03,
                                                  height: size.width * 0.03,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: (context
                                                                  .read<
                                                                      HomeBloc>()
                                                                  .instantRideType ==
                                                              'taxi')
                                                          ? Theme.of(context)
                                                              .primaryColorDark
                                                          : Colors.transparent),
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width * 0.025,
                                              ),
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .taxi,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color: (context
                                                                  .read<
                                                                      HomeBloc>()
                                                                  .instantRideType ==
                                                              'taxi')
                                                          ? Theme.of(context)
                                                              .primaryColorDark
                                                          : AppColors.black,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.05,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            state(() {
                                              context
                                                  .read<HomeBloc>()
                                                  .instantRideType = 'delivery';
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                width: size.width * 0.05,
                                                height: size.width * 0.05,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: (context
                                                                    .read<
                                                                        HomeBloc>()
                                                                    .instantRideType ==
                                                                'delivery')
                                                            ? Theme.of(context)
                                                                .primaryColorDark
                                                            : AppColors.black)),
                                                alignment: Alignment.center,
                                                child: Container(
                                                  width: size.width * 0.03,
                                                  height: size.width * 0.03,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: (context
                                                                  .read<
                                                                      HomeBloc>()
                                                                  .instantRideType ==
                                                              'delivery')
                                                          ? AppColors.primary
                                                          : Colors.transparent),
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width * 0.025,
                                              ),
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .delivery,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color: (context
                                                                  .read<
                                                                      HomeBloc>()
                                                                  .instantRideType ==
                                                              'delivery')
                                                          ? Theme.of(context)
                                                              .primaryColorDark
                                                          : AppColors.black,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.width * 0.05,
                                    )
                                  ],
                                ),
                              SizedBox(
                                width: size.width * 0.9,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const PickupIcon(),
                                    SizedBox(
                                      width: size.width * 0.029,
                                    ),
                                    Expanded(
                                        child: MyText(
                                      text:
                                          context.read<HomeBloc>().pickAddress,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      maxLines: 2,
                                    ))
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: size.width * 0.03,
                              ),
                              SizedBox(
                                width: size.width * 0.9,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const DropIcon(),
                                    SizedBox(
                                      width: size.width * 0.025,
                                    ),
                                    Expanded(
                                        child: MyText(
                                      text:
                                          context.read<HomeBloc>().dropAddress,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                      maxLines: 2,
                                    )),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: size.width * 0.05,
                              ),
                              SizedBox(
                                  width: size.width * 0.9,
                                  child: CustomTextField(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: Theme.of(context)
                                                .primaryColorDark)),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                    controller: context
                                        .read<HomeBloc>()
                                        .instantUserName,
                                    hintText:
                                        AppLocalizations.of(context)!.userName,
                                  )),
                              SizedBox(
                                height: size.width * 0.05,
                              ),
                              SizedBox(
                                  width: size.width * 0.9,
                                  child: CustomTextField(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: Theme.of(context)
                                                .primaryColorDark)),
                                    keyboardType: TextInputType.number,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                    controller: context
                                        .read<HomeBloc>()
                                        .instantUserMobile,
                                    hintText: AppLocalizations.of(context)!
                                        .userMobile,
                                  )),
                              SizedBox(
                                height: size.width * 0.05,
                              ),
                              SizedBox(
                                width: size.width * 0.8,
                                child: MyText(
                                  text:
                                      '${AppLocalizations.of(context)!.cash}  ${context.read<HomeBloc>().instantRideCurrency!}${context.read<HomeBloc>().instantRidePrice!}',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                height: size.width * 0.03,
                              ),
                              CustomButton(
                                  buttonName:
                                      (userData!.transportType == 'taxi' ||
                                              context
                                                      .read<HomeBloc>()
                                                      .instantRideType ==
                                                  'taxi' ||
                                              context
                                                      .read<HomeBloc>()
                                                      .choosenGoods !=
                                                  null)
                                          ? AppLocalizations.of(context)!
                                              .createRequest
                                          : AppLocalizations.of(context)!
                                              .chooseGoods,
                                  onTap: () {
                                    if (context
                                            .read<HomeBloc>()
                                            .instantUserName
                                            .text
                                            .isNotEmpty &&
                                        context
                                            .read<HomeBloc>()
                                            .instantUserMobile
                                            .text
                                            .isNotEmpty) {
                                      if (userData!.transportType == 'taxi' ||
                                          context
                                                  .read<HomeBloc>()
                                                  .instantRideType ==
                                              'taxi' ||
                                          context
                                                  .read<HomeBloc>()
                                                  .choosenGoods !=
                                              null) {
                                        context
                                            .read<HomeBloc>()
                                            .add(CreateInstantRideEvent());
                                      } else {
                                        context
                                            .read<HomeBloc>()
                                            .add(GetGoodsTypeEvent());
                                      }
                                    } else {
                                      showToast(
                                          message: AppLocalizations.of(context)!
                                              .enterRequiredField);
                                    }
                                  }),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                });
            if (userData!.onTripRequest == null) {
              if (!context.mounted) return;
              context.read<HomeBloc>().polyline.clear();
              context.read<HomeBloc>().markers.removeWhere(
                  (element) => element.markerId != const MarkerId('my_loc'));
              // context.read<HomeBloc>().dropAddress = '';
              context.read<HomeBloc>().add(UpdateEvent());
              setState(() {});
            }
          }
          if (!context.mounted) return;
          if (state is SearchTimerUpdateStatus &&
              context.read<HomeBloc>().timer < 1 &&
              context.read<HomeBloc>().waitingList.isEmpty) {
            context.read<HomeBloc>().searchTimer?.cancel();
            context.read<HomeBloc>().searchTimer = null;
            context.read<HomeBloc>().add(AcceptRejectEvent(
                requestId: userData!.metaRequest!.id, status: 0));
          } else if (state is OutstationSuccessState) {
            // Navigator.pushNamed(context, HistoryPage.routeName,
            //     arguments: HistoryAccountPageArguments(isFrom: 'home'));
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (builder) {
                  return AlertDialog(
                    title: MyText(
                      text: AppLocalizations.of(context)!.success,
                      textStyle: Theme.of(context)
                          .textTheme
                          .displayMedium!
                          .copyWith(fontSize: 16),
                    ),
                    content: MyText(
                      text: AppLocalizations.of(context)!.outStationSuccess,
                      maxLines: 5,
                      textStyle: Theme.of(context).textTheme.bodyMedium!,
                    ),
                    actions: [
                      CustomButton(
                          width: size.width * 0.8,
                          buttonName: AppLocalizations.of(context)!.ok,
                          onTap: () {
                            Navigator.pop(context);
                            context.read<HomeBloc>().add(UpdateEvent());
                          })
                    ],
                  );
                });
          }

          if (context.read<HomeBloc>().vehicleNotUpdated == true &&
              userData!.role == 'driver' &&
              userData!.approve == false) {
            Navigator.pushNamedAndRemoveUntil(
                context,
                DriverProfilePage.routeName,
                arguments: VehicleUpdateArguments(
                  from: 'rejected',
                ),
                (route) => false);
          } else if (context.read<HomeBloc>().vehicleNotUpdated == true &&
              userData!.role == 'owner' &&
              userData!.approve == false) {
            Navigator.pushNamedAndRemoveUntil(
                context,
                DriverProfilePage.routeName,
                arguments: VehicleUpdateArguments(
                  from: 'rejected',
                ),
                (route) => false);
          } else if (state is ShowImagePickState &&
              userData!.onTripRequest == null) {
            showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                context: context,
                builder: (builder) {
                  return BlocProvider.value(
                    value: BlocProvider.of<HomeBloc>(context),
                    child: StatefulBuilder(builder: (context, states) {
                      return BlocListener<HomeBloc, HomeState>(
                          listener: (context, state) {
                            if (state is ImageCaptureSuccessState) {
                              states(() {});
                            }
                          },
                          child: Container(
                            height: size.height,
                            width: size.width,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: TopBarDesign(
                              isHistoryPage: false,
                              isOngoingPage: false,
                              title: AppLocalizations.of(context)!
                                  .shipmentVerification,
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: size.width * 0.2,
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Container(
                                            width: size.width * 0.9,
                                            height: size.width * 0.65,
                                            padding: EdgeInsets.all(
                                                size.width * 0.05),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: AppColors.secondary,
                                                border: Border.all(
                                                    color: Theme.of(context)
                                                        .disabledColor)),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                    width: size.width * 0.8,
                                                    child: MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .uploadShipmentProof,
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: AppColors
                                                                  .whiteText,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                      textAlign:
                                                          TextAlign.center,
                                                    )),
                                                SizedBox(
                                                  height: size.width * 0.05,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    context.read<HomeBloc>().add(
                                                        ImageCaptureEvent());
                                                  },
                                                  child: SizedBox(
                                                    height: size.width * 0.35,
                                                    width: size.width * 0.35,
                                                    child: DottedBorder(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        strokeWidth: 1,
                                                        dashPattern: const [
                                                          6,
                                                          3
                                                        ],
                                                        borderType:
                                                            BorderType.RRect,
                                                        radius: const Radius
                                                            .circular(5),
                                                        child: (context
                                                                        .read<
                                                                            HomeBloc>()
                                                                        .loadImage ==
                                                                    null &&
                                                                context
                                                                        .read<
                                                                            HomeBloc>()
                                                                        .unloadImage ==
                                                                    null)
                                                            ? SizedBox(
                                                                height:
                                                                    size.width *
                                                                        0.35,
                                                                width:
                                                                    size.width *
                                                                        0.35,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .upload,
                                                                      size: size
                                                                              .width *
                                                                          0.05,
                                                                      color: AppColors
                                                                          .black,
                                                                    ),
                                                                    SizedBox(
                                                                      height: size
                                                                              .width *
                                                                          0.025,
                                                                    ),
                                                                    MyText(
                                                                      text: AppLocalizations.of(
                                                                              context)!
                                                                          .dropImageHere,
                                                                      textStyle: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyMedium!
                                                                          .copyWith(
                                                                              color: Theme.of(context).primaryColorDark,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w400),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                    SizedBox(
                                                                      height: size
                                                                              .width *
                                                                          0.025,
                                                                    ),
                                                                    MyText(
                                                                      text: AppLocalizations.of(
                                                                              context)!
                                                                          .supportedImage
                                                                          .toString()
                                                                          .replaceAll(
                                                                              '1111',
                                                                              'jpg,png'),
                                                                      textStyle: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyMedium!
                                                                          .copyWith(
                                                                              color: Theme.of(context).primaryColorDark,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w400),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            : Container(
                                                                height:
                                                                    size.width *
                                                                        0.35,
                                                                width:
                                                                    size.width *
                                                                        0.35,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                5),
                                                                    image: DecorationImage(
                                                                        image: (userData!.onTripRequest == null ||
                                                                                userData!.onTripRequest!.isTripStart == 0)
                                                                            ? FileImage(File(context.read<HomeBloc>().loadImage!))
                                                                            : FileImage(File(context.read<HomeBloc>().unloadImage!)),
                                                                        fit: BoxFit.cover)),
                                                              )),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: size.width * 0.05,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.width * 0.05,
                                  ),
                                  CustomButton(
                                      width: size.width * 0.8,
                                      buttonName: AppLocalizations.of(context)!
                                          .continueText,
                                      onTap: () {
                                        if (userData!.onTripRequest == null ||
                                            userData!.onTripRequest!
                                                    .isTripStart ==
                                                0) {
                                          if (context
                                                  .read<HomeBloc>()
                                                  .loadImage !=
                                              null) {
                                            Navigator.pop(context);
                                            if (userData!.onTripRequest ==
                                                null) {
                                              context.read<HomeBloc>().add(
                                                  CreateInstantRideEvent());
                                            } else {
                                              context.read<HomeBloc>().add(
                                                  UploadProofEvent(
                                                      image: context
                                                          .read<HomeBloc>()
                                                          .loadImage!,
                                                      isBefore: false,
                                                      id: userData!
                                                          .onTripRequest!.id));
                                            }
                                          }
                                        } else {
                                          if (context
                                                  .read<HomeBloc>()
                                                  .unloadImage !=
                                              null) {
                                            Navigator.pop(context);
                                            context.read<HomeBloc>().add(
                                                UploadProofEvent(
                                                    image: context
                                                        .read<HomeBloc>()
                                                        .unloadImage!,
                                                    isBefore: false,
                                                    id: userData!
                                                        .onTripRequest!.id));
                                          }
                                        }
                                      }),
                                  SizedBox(
                                    height: size.width * 0.05,
                                  )
                                ],
                              ),
                            ),
                          ));
                    }),
                  );
                });
          } else if (state is GetGoodsSuccessState) {
            showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                context: context,
                builder: (builder) {
                  return BlocProvider.value(
                    value: BlocProvider.of<HomeBloc>(context),
                    child: StatefulBuilder(builder: (context, state) {
                      return Padding(
                        padding: MediaQuery.of(context).viewInsets,
                        child: Container(
                          height: size.height,
                          width: size.width,
                          padding: EdgeInsets.all(size.width * 0.05),
                          child: Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).padding.top +
                                    size.width * 0.1,
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
                                    Expanded(
                                        child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .chooseGoods,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                      maxLines: 1,
                                    ))
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
                                    for (var i = 0;
                                        i <
                                            context
                                                .read<HomeBloc>()
                                                .goodsList
                                                .length;
                                        i++)
                                      InkWell(
                                        onTap: () {
                                          state(() {
                                            context.read<HomeBloc>().add(
                                                ChangeGoodsEvent(
                                                    id: context
                                                        .read<HomeBloc>()
                                                        .goodsList[i]
                                                        .id));
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.fromLTRB(
                                              0,
                                              size.width * 0.025,
                                              0,
                                              size.width * 0.025),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: size.width * 0.05,
                                                width: size.width * 0.05,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: (context
                                                                    .read<
                                                                        HomeBloc>()
                                                                    .choosenGoods ==
                                                                context
                                                                    .read<
                                                                        HomeBloc>()
                                                                    .goodsList[
                                                                        i]
                                                                    .id)
                                                            ? Theme.of(context)
                                                                .primaryColorDark
                                                            : AppColors
                                                                .darkGrey)),
                                                alignment: Alignment.center,
                                                child: Container(
                                                  height: size.width * 0.03,
                                                  width: size.width * 0.03,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: (context
                                                                  .read<
                                                                      HomeBloc>()
                                                                  .choosenGoods ==
                                                              context
                                                                  .read<
                                                                      HomeBloc>()
                                                                  .goodsList[i]
                                                                  .id)
                                                          ? Theme.of(context)
                                                              .primaryColorDark
                                                          : Colors.transparent),
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width * 0.025,
                                              ),
                                              Expanded(
                                                  child: MyText(
                                                text: context
                                                    .read<HomeBloc>()
                                                    .goodsList[i]
                                                    .name,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                maxLines: 2,
                                              ))
                                            ],
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              )),
                              SizedBox(
                                height: size.width * 0.03,
                              ),
                              SizedBox(
                                width: size.width * 0.9,
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        state(() {
                                          context.read<HomeBloc>().goodsSize =
                                              'Loose';
                                          FocusScope.of(context).unfocus();
                                          context
                                              .read<HomeBloc>()
                                              .goodsSizeText
                                              .clear();
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            height: size.width * 0.05,
                                            width: size.width * 0.05,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: (context
                                                              .read<HomeBloc>()
                                                              .goodsSize ==
                                                          'Loose')
                                                      ? Theme.of(context)
                                                          .primaryColorDark
                                                      : AppColors.darkGrey),
                                            ),
                                            alignment: Alignment.center,
                                            child: Container(
                                              height: size.width * 0.03,
                                              width: size.width * 0.03,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: (context
                                                              .read<HomeBloc>()
                                                              .goodsSize ==
                                                          'Loose')
                                                      ? AppColors.primary
                                                      : Colors.transparent),
                                            ),
                                          ),
                                          SizedBox(
                                            width: size.width * 0.025,
                                          ),
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .loose,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                            maxLines: 2,
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.05,
                                    ),
                                    MyText(
                                        text: AppLocalizations.of(context)!.or,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            )),
                                    SizedBox(
                                      width: size.width * 0.05,
                                    ),
                                    Expanded(
                                        child: CustomTextField(
                                      hintText: AppLocalizations.of(context)!
                                          .qtyWithUnit,
                                      onChange: (v) {
                                        state(() {
                                          if (v.isNotEmpty) {
                                            context.read<HomeBloc>().goodsSize =
                                                v;
                                          } else {
                                            context.read<HomeBloc>().goodsSize =
                                                'Loose';
                                          }
                                        });
                                      },
                                      controller: context
                                          .read<HomeBloc>()
                                          .goodsSizeText,
                                      keyboardType: TextInputType.emailAddress,
                                    ))
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: size.width * 0.03,
                              ),
                              CustomButton(
                                  buttonName: AppLocalizations.of(context)!
                                      .createRequest,
                                  onTap: () {
                                    if (context.read<HomeBloc>().choosenGoods !=
                                        null) {
                                      context
                                          .read<HomeBloc>()
                                          .add(ShowImagePickEvent());
                                    }
                                  }),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                });
          } else if (state is InstantRideSuccessState) {
            if (userData!.onTripRequest!.transportType == 'taxi') {
              Navigator.pop(context);
            } else {
              int count = 0;
              Navigator.popUntil(context, (route) {
                return count++ == 2;
              });
            }
          } else if (state is ShowErrorState) {
            context.showSnackBar(color: AppColors.red, message: state.message);
          }

          if (widget.args == null &&
              context.read<HomeBloc>().isSubscriptionShown == false &&
              subscriptionSkip == false &&
              userData != null &&
              userData!.hasSubscription == true &&
              userData!.approve == true &&
              userData!.isSubscribed == false &&
              (userData!.driverMode == 'subscription' ||
                  userData!.driverMode == 'both')) {
            context.read<HomeBloc>().isSubscriptionShown = true;
            showModalBottomSheet(
                constraints: BoxConstraints(
                  maxHeight: size.width * 0.8,
                ),
                isDismissible: false,
                isScrollControlled: false,
                enableDrag: false,
                context: context,
                builder: (builder) {
                  return PopScope(
                    canPop: false,
                    child: Container(
                      height: userData!.driverMode == 'subscription'
                          ? size.width * 0.5
                          : size.width,
                      width: size.width,
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: Column(
                        children: [
                          SizedBox(height: size.width * 0.1),
                          SizedBox(
                            width: size.width * 0.9,
                            child: MyText(
                              text: AppLocalizations.of(context)!
                                  .subscriptionHeading,
                              maxLines: 4,
                              textAlign: TextAlign.center,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: AppColors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          SizedBox(
                            height: size.width * 0.05,
                          ),
                          CustomSliderButton(
                            buttonName:
                                AppLocalizations.of(context)!.choosePlan,
                            onSlideSuccess: () async {
                              Navigator.pushNamed(
                                context,
                                SubscriptionPage.routeName,
                                arguments: SubscriptionPageArguments(
                                    isFromAccPage: true),
                              ).then((value) {
                                if (!context.mounted) return;
                                if (value != null && value == true) {
                                  Navigator.pop(context);
                                }
                                context
                                    .read<HomeBloc>()
                                    .add(GetUserDetailsEvent());
                              });
                              return true;
                            },
                          ),
                          SizedBox(
                            height: size.width * 0.03,
                          ),
                          if (userData!.driverMode == 'both') ...[
                            SizedBox(
                              width: size.width * 0.9,
                              child: MyText(
                                text: AppLocalizations.of(context)!.or,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                            ),
                            SizedBox(
                              height: size.width * 0.03,
                            ),
                            InkWell(
                              onTap: () {
                                AppSharedPreference.setSubscriptionSkipStatus(
                                    true);
                                Navigator.pop(context);
                              },
                              child: SizedBox(
                                width: size.width * 0.9,
                                child: MyText(
                                  text: AppLocalizations.of(context)!
                                      .continueWithoutPlans,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.width * 0.03,
                            ),
                            SizedBox(
                              width: size.width * 0.9,
                              child: MyText(
                                text: AppLocalizations.of(context)!
                                    .continueWithoutPlanDesc,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context).disabledColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                });
          }

          if (context.read<HomeBloc>().isUserCancelled) {
            context.read<HomeBloc>().isUserCancelled = false;
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (builder) {
                  return AlertDialog(
                    title: MyText(
                      text: AppLocalizations.of(context)!.userCancelledRide,
                      textStyle: Theme.of(context)
                          .textTheme
                          .displayMedium!
                          .copyWith(fontSize: 16),
                    ),
                    content: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.secondary),
                      padding: const EdgeInsets.all(10),
                      child: MyText(
                        text: AppLocalizations.of(context)!.userCancelledDesc,
                        maxLines: 5,
                        textStyle:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                ),
                      ),
                    ),
                    actions: [
                      CustomButton(
                          width: size.width * 0.8,
                          buttonName: AppLocalizations.of(context)!.ok,
                          onTap: () {
                            context.read<HomeBloc>().add(GetUserDetailsEvent());
                            context.read<HomeBloc>().isUserCancelled = false;
                            Navigator.pop(context);
                          })
                    ],
                  );
                });
          }

          if (context.read<HomeBloc>().bidDeclined) {
            context.read<HomeBloc>().bidDeclined = false;
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (builder) {
                  return AlertDialog(
                    title: MyText(
                      text: AppLocalizations.of(context)!.userDeclinedBid,
                      textStyle: Theme.of(context)
                          .textTheme
                          .displayMedium!
                          .copyWith(fontSize: 16),
                    ),
                    content: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.secondary),
                      padding: const EdgeInsets.all(10),
                      child: MyText(
                        text: AppLocalizations.of(context)!.userDeclinedBidDesc,
                        maxLines: 5,
                        textStyle:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                ),
                      ),
                    ),
                    actions: [
                      CustomButton(
                          width: size.width * 0.8,
                          buttonName: AppLocalizations.of(context)!.ok,
                          onTap: () {
                            context.read<HomeBloc>().isUserCancelled = false;
                            Navigator.pop(context);
                          })
                    ],
                  );
                });
          }

          if (state is ShowSubVehicleTypesState) {
            showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                context: context,
                builder: (_) {
                  return BlocProvider.value(
                      value: context.read<HomeBloc>(),
                      child: myServiceVehicleTypes(size, context));
                });
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (mapType == 'google_map' &&
                context.read<HomeBloc>().choosenMenu == 0 &&
                (userData != null &&
                    (userData!.onTripRequest == null ||
                        userData!.onTripRequest!.isCompleted == 0))) {
              if (Theme.of(context).brightness == Brightness.dark) {
                if (context.read<HomeBloc>().googleMapController != null) {
                  if (context.mounted) {
                    context
                        .read<HomeBloc>()
                        .googleMapController!
                        .setMapStyle(context.read<HomeBloc>().darkMapString);
                  }
                }
              } else {
                if (context.read<HomeBloc>().googleMapController != null) {
                  if (context.mounted) {
                    context
                        .read<HomeBloc>()
                        .googleMapController!
                        .setMapStyle(context.read<HomeBloc>().lightMapString);
                  }
                }
              }
            }
            return Material(
              child: PopScope(
                canPop: true,
                onPopInvoked: (didPop) {
                  if (context.read<HomeBloc>().addReview) {
                    context.read<HomeBloc>().add(AddReviewEvent());
                  }
                },
                child: Scaffold(
                  body: ((userData == null ||
                          userData!.onTripRequest == null ||
                          userData!.onTripRequest!.isCompleted == 0))
                      ? mapWidget(context, size)
                      : (context.read<HomeBloc>().addReview == false)
                          ? invoicePageWidget(size, context)
                          : reviewPageWidget(size, context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

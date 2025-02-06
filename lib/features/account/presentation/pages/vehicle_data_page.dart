// ignore_for_file: use_build_context_synchronously
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/top_bar.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/vehicle_owner_shimmer.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/pages/driver_profile_pages.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../widgets/edit_options.dart';

class VehicleDataPage extends StatefulWidget {
  static const String routeName = '/vehicleInformation';
  final VehicleDataArguments? args;

  const VehicleDataPage({super.key, this.args});

  @override
  State<VehicleDataPage> createState() => _VehicleDataPageState();
}

class _VehicleDataPageState extends State<VehicleDataPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
        create: (context) => AccBloc()..add(GetVehiclesEvent()),
        child: BlocListener<AccBloc, AccState>(listener: (context, state) {
          if (state is VehiclesLoadingStartState) {
            CustomLoader.loader(context);
          }
          if (state is VehiclesLoadingStopState) {
            CustomLoader.dismiss(context);
          }
          if (state is ShowAssignDriverState) {
            if (context.read<AccBloc>().driverData.isNotEmpty) {
              showModalBottomSheet(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  context: context,
                  builder: (builder) {
                    return BlocProvider.value(
                      value: BlocProvider.of<AccBloc>(context),
                      child: StatefulBuilder(builder: (context, state) {
                        return Container(
                            width: size.width,
                            padding: EdgeInsets.all(size.width * 0.05),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            child: Column(
                              children: [
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .chooseDriverAssign,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                  maxLines: 5,
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
                                                    .read<AccBloc>()
                                                    .driverData
                                                    .length;
                                            i++)
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                context
                                                    .read<AccBloc>()
                                                    .choosenDriverToVehicle = i;
                                                state(() {});
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    size.width * 0.025),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: size.width * 0.1,
                                                      height: size.width * 0.1,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  context
                                                                      .read<
                                                                          AccBloc>()
                                                                      .driverData[
                                                                          i]
                                                                      .profile),
                                                              fit: BoxFit
                                                                  .cover)),
                                                    ),
                                                    SizedBox(
                                                      width: size.width * 0.05,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          MyText(
                                                            text: context
                                                                .read<AccBloc>()
                                                                .driverData[i]
                                                                .name,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .copyWith(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                            maxLines: 5,
                                                          ),
                                                          MyText(
                                                            text: context
                                                                .read<AccBloc>()
                                                                .driverData[i]
                                                                .mobile,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .copyWith(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                            maxLines: 5,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: size.width * 0.05,
                                                    ),
                                                    Container(
                                                      width: size.width * 0.05,
                                                      height: size.width * 0.05,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: (context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .choosenDriverToVehicle ==
                                                                      i)
                                                                  ? Theme.of(
                                                                          context)
                                                                      .primaryColorDark
                                                                  : AppColors
                                                                      .darkGrey),
                                                          shape:
                                                              BoxShape.circle),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Container(
                                                        width:
                                                            size.width * 0.03,
                                                        height:
                                                            size.width * 0.03,
                                                        decoration: BoxDecoration(
                                                            color: (context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .choosenDriverToVehicle ==
                                                                    i)
                                                                ? Theme.of(
                                                                        context)
                                                                    .primaryColorDark
                                                                : Colors
                                                                    .transparent,
                                                            shape: BoxShape
                                                                .circle),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                                if (context
                                        .read<AccBloc>()
                                        .choosenDriverToVehicle !=
                                    null)
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: size.width * 0.05,
                                      ),
                                      CustomButton(
                                          buttonName:
                                              AppLocalizations.of(context)!
                                                  .assign,
                                          onTap: () {
                                            Navigator.pop(context);
                                            context.read<AccBloc>().add(
                                                AssignDriverEvent(
                                                    driverId: context
                                                        .read<AccBloc>()
                                                        .driverData[context
                                                            .read<AccBloc>()
                                                            .choosenDriverToVehicle!]
                                                        .id,
                                                    fleetId: context
                                                        .read<AccBloc>()
                                                        .choosenFleetToAssign!));
                                          })
                                    ],
                                  )
                              ],
                            ));
                      }),
                    );
                  });
            } else {
              showModalBottomSheet(
                  backgroundColor: AppColors.white,
                  context: context,
                  builder: (builder) {
                    return Container(
                        // margin: EdgeInsets.all(size.width*0.05),
                        width: size.width,
                        padding: EdgeInsets.all(size.width * 0.05),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.white,
                        ),
                        child: MyText(
                          text: AppLocalizations.of(context)!.noDriverAvailable,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.red),
                          maxLines: 5,
                        ));
                  });
            }
          }
        }, child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            body: TopBarDesign(
              onTap: () {
                Navigator.pop(context);
              },
              isHistoryPage: false,
              title: userData!.role == 'driver'
                  ? AppLocalizations.of(context)!.vehicleInfo
                  : AppLocalizations.of(context)!.fleetDetails,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: size.width * 0.1,
                          ),
                          (userData!.role == 'driver')
                              ? (userData!.vehicleTypeName != '')
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Column(
                                        children: [
                                          EditOptions(
                                            text: userData!.vehicleTypeName,
                                            header:
                                                AppLocalizations.of(context)!
                                                    .vehicleType,
                                            onTap: () {},
                                          ),
                                          EditOptions(
                                            text: userData!.carMake,
                                            header:
                                                AppLocalizations.of(context)!
                                                    .vehicleMake,
                                            onTap: () {},
                                          ),
                                          EditOptions(
                                            text: userData!.carModel,
                                            header:
                                                AppLocalizations.of(context)!
                                                    .vehicleModel,
                                            onTap: () {},
                                          ),
                                          EditOptions(
                                            text:
                                                userData!.carNumber.toString(),
                                            header:
                                                AppLocalizations.of(context)!
                                                    .vehicleNumber,
                                            onTap: () {},
                                          ),
                                          EditOptions(
                                            text: userData!.carColor.toString(),
                                            header:
                                                AppLocalizations.of(context)!
                                                    .vehicleColor,
                                            onTap: () {},
                                          ),
                                          SizedBox(height: size.height * 0.05),
                                          CustomButton(
                                              buttonName:
                                                  AppLocalizations.of(context)!
                                                      .edit,
                                              onTap: () async {
                                                await Navigator.pushNamed(
                                                  context,
                                                  DriverProfilePage.routeName,
                                                  arguments:
                                                      VehicleUpdateArguments(
                                                          from: 'vehicle'),
                                                );
                                                setState(() {
                                                  
                                                });
                                              })
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        Image.asset(AppImages.historyNoData),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .vehicleNotAssigned,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    )
                              : (context.read<AccBloc>().vehicleData.isEmpty)
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          AppImages.noVehicleInfo,
                                          // height: 500,
                                          width: 300,
                                        ),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .noVehicleCreated,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        for (var i = 0;
                                            i <
                                                context
                                                    .read<AccBloc>()
                                                    .vehicleData
                                                    .length;
                                            i++)
                                          Stack(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    bottom: size.width * 0.05),
                                                padding: EdgeInsets.all(
                                                    size.width * 0.05),
                                                width: size.width * 0.9,
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .dividerColor
                                                        .withOpacity(0.3),
                                                    border: Border.all(
                                                        color: Theme.of(context)
                                                            .disabledColor
                                                            .withOpacity(0.5)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Row(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Container(
                                                          height:
                                                              size.width * 0.15,
                                                          width:
                                                              size.width * 0.15,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              image: DecorationImage(
                                                                  image: NetworkImage(context
                                                                      .read<
                                                                          AccBloc>()
                                                                      .vehicleData[
                                                                          i]
                                                                      .icon!),
                                                                  fit: BoxFit
                                                                      .cover)),
                                                        ),
                                                        SizedBox(
                                                          height: size.width *
                                                              0.025,
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              size.width * 0.2,
                                                          child: MyText(
                                                            text: context
                                                                .read<AccBloc>()
                                                                .vehicleData[i]
                                                                .name,
                                                            textAlign: TextAlign
                                                                .center,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                                    fontSize:
                                                                        16,
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
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
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
                                                                  .vehicleData[
                                                                      i]
                                                                  .model,
                                                              textStyle: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall!
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14,
                                                                      // fontWeight: FontWeight.w600,
                                                                      color: AppColors
                                                                          .darkGrey),
                                                            ))
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: size.width *
                                                              0.025,
                                                        ),
                                                        (context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .vehicleData[
                                                                            i]
                                                                        .approve ==
                                                                    1 &&
                                                                context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .vehicleData[
                                                                            i]
                                                                        .driverDetail !=
                                                                    null)
                                                            ? Row(
                                                                children: [
                                                                  Container(
                                                                    height: size
                                                                            .width *
                                                                        0.06,
                                                                    width: size
                                                                            .width *
                                                                        0.06,
                                                                    decoration: const BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: AppColors
                                                                            .darkGrey),
                                                                    child: Icon(
                                                                      CupertinoIcons
                                                                          .phone_fill,
                                                                      color: AppColors
                                                                          .white,
                                                                      size: size
                                                                              .width *
                                                                          0.04,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: size
                                                                            .width *
                                                                        0.025,
                                                                  ),
                                                                  Expanded(
                                                                      child:
                                                                          MyText(
                                                                    text: context.read<AccBloc>().vehicleData[i].driverDetail !=
                                                                            null
                                                                        ? context
                                                                            .read<AccBloc>()
                                                                            .vehicleData[i]
                                                                            .driverDetail!['mobile']
                                                                        : AppLocalizations.of(context)!.assignDriver,
                                                                    textStyle: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodySmall!
                                                                        .copyWith(
                                                                            fontSize:
                                                                                14,
                                                                            // fontWeight: FontWeight.w600,
                                                                            color:
                                                                                AppColors.darkGrey),
                                                                  )),
                                                                  InkWell(
                                                                      onTap:
                                                                          () {
                                                                        context.read<AccBloc>().add(GetDriverEvent(
                                                                            from:
                                                                                1,
                                                                            fleetId:
                                                                                context.read<AccBloc>().vehicleData[i].id));
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .edit,
                                                                        size: size.width *
                                                                            0.05,
                                                                      ))
                                                                ],
                                                              )
                                                            : InkWell(
                                                                onTap: () {
                                                                  if (context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .vehicleData[
                                                                              i]
                                                                          .approve ==
                                                                      1) {
                                                                    context.read<AccBloc>().add(GetDriverEvent(
                                                                        from: 1,
                                                                        fleetId: context
                                                                            .read<AccBloc>()
                                                                            .vehicleData[i]
                                                                            .id));
                                                                  } else {
                                                                    String id = context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .vehicleData[
                                                                            i]
                                                                        .id;

                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => DriverProfilePage(
                                                                                    args: VehicleUpdateArguments(
                                                                                  from: 'docs',
                                                                                  fleetId: id,
                                                                                ))));
                                                                  }
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              5),
                                                                      decoration: BoxDecoration(
                                                                          color: Theme.of(context)
                                                                              .dividerColor,
                                                                          borderRadius: const BorderRadius
                                                                              .all(
                                                                              Radius.circular(20))),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          MyText(
                                                                            text: (context.read<AccBloc>().vehicleData[i].approve == 1)
                                                                                ? AppLocalizations.of(context)!.assignDriver
                                                                                : AppLocalizations.of(context)!.uploadDocument,
                                                                            textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.w500,
                                                                                color: Theme.of(context).primaryColorDark),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                size.width * 0.01,
                                                                          ),
                                                                          Icon(
                                                                            CupertinoIcons.arrow_right_circle,
                                                                            color:
                                                                                Theme.of(context).primaryColorDark,
                                                                            size:
                                                                                20,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                      ],
                                                    ))
                                                  ],
                                                ),
                                              ),
                                              if (context
                                                      .read<AccBloc>()
                                                      .vehicleData[i]
                                                      .approve ==
                                                  0)
                                                Positioned(
                                                    top: 0,
                                                    right: (languageDirection ==
                                                            'rtl')
                                                        ? null
                                                        : 0,
                                                    left: (languageDirection ==
                                                            'ltr')
                                                        ? null
                                                        : 0,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.warning_amber_rounded,
                                                              size: 13,
                                                              weight: 35,
                                                              color: (context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .vehicleData[
                                                                              i]
                                                                          .approve ==
                                                                      0)
                                                                  ? Colors
                                                                      .orange
                                                                  : const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      248,
                                                                      92,
                                                                      81)),
                                                          SizedBox(
                                                            width: size.width *
                                                                0.01,
                                                          ),
                                                          MyText(
                                                            text: (context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .vehicleData[
                                                                            i]
                                                                        .approve ==
                                                                    0)
                                                                ? AppLocalizations.of(
                                                                        context)!
                                                                    .waitingForApproval
                                                                : AppLocalizations.of(
                                                                        context)!
                                                                    .documentNotUploaded,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: (context.read<AccBloc>().vehicleData[i].approve ==
                                                                            0)
                                                                        ? Colors
                                                                            .orange
                                                                        : const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            248,
                                                                            92,
                                                                            81)),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                            ],
                                          )
                                      ],
                                    )
                        ],
                      ),
                    ),
                  ),
                  if (userData!.role == 'owner')
                    Column(
                      children: [
                        SizedBox(height: size.width * 0.05),
                        context.read<AccBloc>().isLoading
                            ? VehicleOwnerShimmerWidget.circular(
                                width: size.width, height: size.height)
                            : SizedBox(
                                width: size.width * 0.9,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        var nav = await Navigator.pushNamed(
                                            context,
                                            DriverProfilePage.routeName,
                                            arguments: VehicleUpdateArguments(
                                                from: 'owner'));
                                        if (nav != null && nav == true) {
                                          context
                                              .read<AccBloc>()
                                              .add(GetVehiclesEvent());
                                        }
                                      },
                                      child: Container(
                                        width: size.width * 0.128,
                                        height: size.width * 0.128,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: AppColors.darkGrey),
                                            color: AppColors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Theme.of(context)
                                                      .shadowColor,
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
                      ],
                    ),
                  SizedBox(height: size.width * 0.05)
                ],
              ),
            ),
          );
        })));
  }
}

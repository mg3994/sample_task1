import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

Column vehicleInformationWidget(
    Size size, BuildContext context, VehicleUpdateArguments args) {
  return Column(
    children: [
      if (userData!.enableModulesForApplications == 'both' &&
          args.from != 'owner')
        Column(
          children: [
            SizedBox(
              width: size.width * 0.9,
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.check_mark,
                    size: size.width * 0.07,
                    color: AppColors.black,
                  ),
                  SizedBox(width: size.width * 0.025),
                  Expanded(
                      child: MyText(
                    text: AppLocalizations.of(context)!.registerFor,
                    textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 15,
                          color: AppColors.blackText,
                        ),
                  ))
                ],
              ),
            ),
            SizedBox(height: size.width * 0.05),
            SizedBox(
              width: size.width * 0.9,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.025),
                  Column(
                    children: [
                      for (var i = 0; i < 10; i++)
                        Container(
                          margin: const EdgeInsets.only(bottom: 2),
                          height: 3,
                          width: 1,
                          color:
                              (context.read<DriverProfileBloc>().registerFor !=
                                      null)
                                  ? AppColors.darkGrey
                                  : AppColors.black.withOpacity(0.5),
                        )
                    ],
                  ),
                  SizedBox(width: size.width * 0.02),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var i = 0;
                              i <
                                  context
                                      .read<DriverProfileBloc>()
                                      .vehicleRegisterFor
                                      .length;
                              i++)
                            Padding(
                              padding: EdgeInsets.only(left: size.width * 0.05),
                              child: InkWell(
                                onTap: () {
                                  context.read<DriverProfileBloc>().add(
                                      GetServiceLocationEvent(
                                          type: context
                                              .read<DriverProfileBloc>()
                                              .vehicleRegisterFor[i]));
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      height: size.width * 0.04,
                                      width: size.width * 0.04,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.black),
                                          borderRadius:
                                              BorderRadius.circular(2)),
                                      child: (context
                                                  .read<DriverProfileBloc>()
                                                  .registerFor ==
                                              context
                                                  .read<DriverProfileBloc>()
                                                  .vehicleRegisterFor[i])
                                          ? Icon(
                                              Icons.done,
                                              color: AppColors.black,
                                              size: size.width * 0.03,
                                            )
                                          : Container(),
                                    ),
                                    SizedBox(width: size.width * 0.025),
                                    MyText(
                                      text: context
                                          .read<DriverProfileBloc>()
                                          .vehicleRegisterFor[i],
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontSize: 14,
                                            color: AppColors.blackText,
                                          ),
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
      if (args.from != 'owner')
        Column(
          children: [
            SizedBox(
              width: size.width * 0.9,
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.check_mark,
                    size: size.width * 0.07,
                    color:
                        (context.read<DriverProfileBloc>().registerFor != null)
                            ? AppColors.black
                            : AppColors.black.withOpacity(0.5),
                  ),
                  SizedBox(width: size.width * 0.025),
                  Expanded(
                      child: MyText(
                    text: AppLocalizations.of(context)!.chooseServiceLocation,
                    textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 15,
                          color:
                              (context.read<DriverProfileBloc>().registerFor !=
                                      null)
                                  ? AppColors.blackText
                                  : AppColors.black.withOpacity(0.5),
                        ),
                  ))
                ],
              ),
            ),
            SizedBox(height: size.width * 0.05),
            SizedBox(
              width: size.width * 0.9,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.025),
                  Column(
                    children: [
                      for (var i = 0; i < 15; i++)
                        Container(
                          margin: const EdgeInsets.only(bottom: 2),
                          height: 3,
                          width: 1,
                          color: (context
                                      .read<DriverProfileBloc>()
                                      .choosenServiceLocation !=
                                  null)
                              ? AppColors.darkGrey
                              : AppColors.black.withOpacity(0.5),
                        )
                    ],
                  ),
                  SizedBox(width: size.width * 0.07),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (context.read<DriverProfileBloc>().registerFor !=
                            null) {
                          showModalBottomSheet(
                              context: context,
                              builder: (builder) {
                                return Container(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor
                                      .withOpacity(0.8),
                                  width: size.width,
                                  padding: EdgeInsets.all(size.width * 0.05),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: size.width * 0.8,
                                        child: MyText(
                                          text: AppLocalizations.of(context)!
                                              .chooseServiceLoc,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  fontSize: 15,
                                                  color: (context
                                                              .read<
                                                                  DriverProfileBloc>()
                                                              .registerFor !=
                                                          null)
                                                      ? Theme.of(context)
                                                          .primaryColorDark
                                                      : AppColors.black
                                                          .withOpacity(0.5),
                                                  fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Expanded(
                                          child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            for (var i = 0;
                                                i <
                                                    context
                                                        .read<
                                                            DriverProfileBloc>()
                                                        .serviceLocations
                                                        .length;
                                                i++)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: size.width * 0.05),
                                                child: InkWell(
                                                  onTap: () {
                                                    context
                                                        .read<
                                                            DriverProfileBloc>()
                                                        .add(GetVehicleTypeEvent(
                                                            id: context
                                                                .read<
                                                                    DriverProfileBloc>()
                                                                .serviceLocations[
                                                                    i]
                                                                .id,
                                                            type: context
                                                                .read<
                                                                    DriverProfileBloc>()
                                                                .registerFor!,
                                                            from: args.from));
                                                    Navigator.pop(context);
                                                  },
                                                  child: SizedBox(
                                                    width: size.width * 0.8,
                                                    child: MyText(
                                                      text: context
                                                          .read<
                                                              DriverProfileBloc>()
                                                          .serviceLocations[i]
                                                          .name,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyLarge!
                                                              .copyWith(
                                                                fontSize: 15,
                                                              ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                          ],
                                        ),
                                      ))
                                    ],
                                  ),
                                );
                              });
                        }
                      },
                      child: Container(
                        height: size.width * 0.10,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: (context
                                            .read<DriverProfileBloc>()
                                            .registerFor !=
                                        null)
                                    ? AppColors.darkGrey
                                    : AppColors.black.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(5)),
                        padding: EdgeInsets.only(
                            left: size.width * 0.05, right: size.width * 0.05),
                        child: Row(
                          children: [
                            Expanded(
                              child: MyText(
                                text: (context
                                            .read<DriverProfileBloc>()
                                            .choosenServiceLocation !=
                                        null)
                                    ? context
                                        .read<DriverProfileBloc>()
                                        .serviceLocations
                                        .firstWhere((e) =>
                                            e.id ==
                                            context
                                                .read<DriverProfileBloc>()
                                                .choosenServiceLocation)
                                        .name
                                    : AppLocalizations.of(context)!
                                        .chooseServiceLoc,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontSize: 14,
                                      color: (context
                                                  .read<DriverProfileBloc>()
                                                  .choosenServiceLocation !=
                                              null)
                                          ? AppColors.blackText
                                          : AppColors.black.withOpacity(0.5),
                                    ),
                              ),
                            ),
                            SizedBox(
                              width: size.width * 0.05,
                            ),
                            Icon(
                              CupertinoIcons.placemark_fill,
                              color: (context
                                          .read<DriverProfileBloc>()
                                          .registerFor !=
                                      null)
                                  ? AppColors.black
                                  : AppColors.black.withOpacity(0.5),
                              size: size.width * 0.07,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      (userData!.role == 'driver' || args.from == 'owner')
          ? Column(
              children: [
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.check_mark,
                        size: size.width * 0.07,
                        color: (context
                                    .read<DriverProfileBloc>()
                                    .choosenServiceLocation !=
                                null)
                            ? AppColors.black
                            : AppColors.black.withOpacity(0.5),
                      ),
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Expanded(
                          child: MyText(
                        text: AppLocalizations.of(context)!.selectVehicleType,
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontSize: 15,
                                  color: (context
                                              .read<DriverProfileBloc>()
                                              .choosenServiceLocation !=
                                          null)
                                      ? AppColors.blackText
                                      : AppColors.black.withOpacity(0.5),
                                ),
                      ))
                    ],
                  ),
                ),
                SizedBox(height: size.width * 0.05),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: size.width * 0.025),
                      Column(
                        children: [
                          for (var i = 0; i < 15; i++)
                            Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              height: 3,
                              width: 1,
                              color: (context
                                          .read<DriverProfileBloc>()
                                          .choosenVehicleType !=
                                      null)
                                  ? AppColors.darkGrey
                                  : AppColors.black.withOpacity(0.5),
                            )
                        ],
                      ),
                      SizedBox(width: size.width * 0.07),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (context
                                    .read<DriverProfileBloc>()
                                    .choosenServiceLocation !=
                                null) {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (builder) {
                                    return Container(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor
                                          .withOpacity(0.8),
                                      width: size.width,
                                      padding:
                                          EdgeInsets.all(size.width * 0.05),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: size.width * 0.8,
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .chooseVehicleType,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                      fontSize: 15,
                                                      color: (context
                                                                  .read<
                                                                      DriverProfileBloc>()
                                                                  .registerFor !=
                                                              null)
                                                          ? Theme.of(context)
                                                              .primaryColorDark
                                                          : AppColors.black
                                                              .withOpacity(0.5),
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                          ),
                                          Expanded(
                                              child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (var i = 0;
                                                    i <
                                                        context
                                                            .read<
                                                                DriverProfileBloc>()
                                                            .vehicleType
                                                            .length;
                                                    i++)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: size.width * 0.05),
                                                    child: InkWell(
                                                      onTap: () {
                                                        context
                                                            .read<
                                                                DriverProfileBloc>()
                                                            .add(UpdateVehicleTypeEvent(
                                                                id: context
                                                                    .read<
                                                                        DriverProfileBloc>()
                                                                    .vehicleType[
                                                                        i]
                                                                    .id));
                                                        Navigator.pop(context);
                                                      },
                                                      child: SizedBox(
                                                        width: size.width * 0.8,
                                                        child: Row(
                                                          children: [
                                                            MyText(
                                                              text: context
                                                                  .read<
                                                                      DriverProfileBloc>()
                                                                  .vehicleType[
                                                                      i]
                                                                  .name,
                                                              textStyle: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ))
                                        ],
                                      ),
                                    );
                                  });
                            }
                          },
                          child: Container(
                            height: size.width * 0.10,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: (context
                                                .read<DriverProfileBloc>()
                                                .choosenServiceLocation !=
                                            null)
                                        ? AppColors.darkGrey
                                        : AppColors.black.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.only(
                                left: size.width * 0.05,
                                right: size.width * 0.05),
                            child: Row(
                              children: [
                                Expanded(
                                  child: MyText(
                                    text: (context
                                                .read<DriverProfileBloc>()
                                                .choosenVehicleType !=
                                            null)
                                        ? context
                                            .read<DriverProfileBloc>()
                                            .vehicleType
                                            .firstWhere((e) =>
                                                e.id ==
                                                context
                                                    .read<DriverProfileBloc>()
                                                    .choosenVehicleType)
                                            .name
                                        : AppLocalizations.of(context)!
                                            .chooseVehicleType,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          fontSize: 14,
                                          color: (context
                                                      .read<DriverProfileBloc>()
                                                      .choosenVehicleType !=
                                                  null)
                                              ? AppColors.blackText
                                              : AppColors.black
                                                  .withOpacity(0.5),
                                        ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.05),
                                Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: (context
                                              .read<DriverProfileBloc>()
                                              .choosenServiceLocation !=
                                          null)
                                      ? AppColors.black
                                      : AppColors.black.withOpacity(0.5),
                                  size: size.width * 0.07,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.check_mark,
                        size: size.width * 0.07,
                        color: (context
                                    .read<DriverProfileBloc>()
                                    .choosenVehicleType !=
                                null)
                            ? AppColors.black
                            : AppColors.black.withOpacity(0.5),
                      ),
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Expanded(
                          child: MyText(
                        text: AppLocalizations.of(context)!.provideVehicleMake,
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontSize: 15,
                                  color: (context
                                              .read<DriverProfileBloc>()
                                              .choosenVehicleType !=
                                          null)
                                      ? AppColors.blackText
                                      : AppColors.black.withOpacity(0.5),
                                ),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Column(
                        children: [
                          for (var i = 0; i < 15; i++)
                            Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              height: 3,
                              width: 1,
                              color: (context
                                      .read<DriverProfileBloc>()
                                      .customMake
                                      .text
                                      .isNotEmpty)
                                  ? AppColors.darkGrey
                                  : AppColors.black.withOpacity(0.5),
                            )
                        ],
                      ),
                      SizedBox(
                        width: size.width * 0.07,
                      ),
                      Expanded(
                        child: CustomTextField(
                          // maxLength: 4,
                          onChange: (v) {
                            context
                                .read<DriverProfileBloc>()
                                .add(DataChangeEvent());
                          },
                          // keyboardType: TextInputType.number,
                          enabled: context
                                  .read<DriverProfileBloc>()
                                  .choosenVehicleType !=
                              null,
                          hintText:
                              AppLocalizations.of(context)!.enterVehicleMake,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 14,
                                    color: AppColors.blackText,
                                  ),
                          controller:
                              context.read<DriverProfileBloc>().customMake,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.black.withOpacity(0.5),
                                width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.check_mark,
                        size: size.width * 0.07,
                        color: (context
                                .read<DriverProfileBloc>()
                                .customMake
                                .text
                                .isNotEmpty)
                            ? AppColors.black
                            : AppColors.black.withOpacity(0.5),
                      ),
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Expanded(
                          child: MyText(
                        text: AppLocalizations.of(context)!.provideVehicleModel,
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontSize: 15,
                                  color: (context
                                          .read<DriverProfileBloc>()
                                          .customMake
                                          .text
                                          .isNotEmpty)
                                      ? AppColors.black
                                      : AppColors.black.withOpacity(0.5),
                                ),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Column(
                        children: [
                          for (var i = 0; i < 15; i++)
                            Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              height: 3,
                              width: 1,
                              color: (context
                                      .read<DriverProfileBloc>()
                                      .customModel
                                      .text
                                      .isNotEmpty)
                                  ? AppColors.darkGrey
                                  : AppColors.black.withOpacity(0.5),
                            )
                        ],
                      ),
                      SizedBox(
                        width: size.width * 0.07,
                      ),
                      Expanded(
                        child: CustomTextField(
                          // maxLength: 4,

                          onChange: (v) {
                            context
                                .read<DriverProfileBloc>()
                                .add(DataChangeEvent());
                          },
                          // keyboardType: TextInputType.number,
                          enabled: context
                              .read<DriverProfileBloc>()
                              .customMake
                              .text
                              .isNotEmpty,
                          hintText:
                              AppLocalizations.of(context)!.enterVehicleModel,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 14,
                                    color: AppColors.blackText,
                                  ),
                          controller:
                              context.read<DriverProfileBloc>().customModel,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.black.withOpacity(0.5),
                                width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.check_mark,
                        size: size.width * 0.07,
                        color: (context
                                .read<DriverProfileBloc>()
                                .customModel
                                .text
                                .isNotEmpty)
                            ? AppColors.black
                            : AppColors.black.withOpacity(0.5),
                      ),
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Expanded(
                          child: MyText(
                        text: AppLocalizations.of(context)!.provideModelYear,
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontSize: 15,
                                  color: (context
                                          .read<DriverProfileBloc>()
                                          .customModel
                                          .text
                                          .isNotEmpty)
                                      ? AppColors.blackText
                                      : AppColors.black.withOpacity(0.5),
                                ),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Column(
                        children: [
                          for (var i = 0; i < 15; i++)
                            Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              height: 3,
                              width: 1,
                              color: (context
                                      .read<DriverProfileBloc>()
                                      .vehicleYear
                                      .text
                                      .isNotEmpty)
                                  ? AppColors.darkGrey
                                  : AppColors.black.withOpacity(0.5),
                            )
                        ],
                      ),
                      SizedBox(
                        width: size.width * 0.07,
                      ),
                      Expanded(
                        child: CustomTextField(
                          maxLength: 4,
                          onChange: (v) {
                            context
                                .read<DriverProfileBloc>()
                                .add(DataChangeEvent());
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          enabled: context
                              .read<DriverProfileBloc>()
                              .customModel
                              .text
                              .isNotEmpty,
                          hintText:
                              AppLocalizations.of(context)!.enterModelYear,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 14,
                                    color: AppColors.blackText,
                                  ),
                          controller:
                              context.read<DriverProfileBloc>().vehicleYear,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.black.withOpacity(0.5),
                                width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          validator: (string) {
                            if (string != null && string.length <= 3) {
                              return AppLocalizations.of(context)!
                                  .validDateValue;
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.check_mark,
                        size: size.width * 0.07,
                        color: (context
                                .read<DriverProfileBloc>()
                                .vehicleYear
                                .text
                                .isNotEmpty)
                            ? AppColors.black
                            : AppColors.black.withOpacity(0.5),
                      ),
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Expanded(
                          child: MyText(
                        text:
                            AppLocalizations.of(context)!.provideVehicleNumber,
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontSize: 15,
                                  color: (context
                                          .read<DriverProfileBloc>()
                                          .vehicleYear
                                          .text
                                          .isNotEmpty)
                                      ? AppColors.blackText
                                      : AppColors.black.withOpacity(0.5),
                                ),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Column(
                        children: [
                          for (var i = 0; i < 15; i++)
                            Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              height: 3,
                              width: 1,
                              color: (context
                                      .read<DriverProfileBloc>()
                                      .vehicleNumber
                                      .text
                                      .isNotEmpty)
                                  ? AppColors.darkGrey
                                  : AppColors.black.withOpacity(0.5),
                            )
                        ],
                      ),
                      SizedBox(
                        width: size.width * 0.07,
                      ),
                      Expanded(
                        child: CustomTextField(
                          enabled: context
                              .read<DriverProfileBloc>()
                              .vehicleYear
                              .text
                              .isNotEmpty,
                          onChange: (v) {
                            context
                                .read<DriverProfileBloc>()
                                .add(DataChangeEvent());
                          },
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 14,
                                    color: AppColors.blackText,
                                  ),
                          hintText:
                              AppLocalizations.of(context)!.enterVehicleNumber,
                          controller:
                              context.read<DriverProfileBloc>().vehicleNumber,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.black.withOpacity(0.5),
                                width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.check_mark,
                        size: size.width * 0.07,
                        color: (context
                                .read<DriverProfileBloc>()
                                .vehicleNumber
                                .text
                                .isNotEmpty)
                            ? AppColors.black
                            : AppColors.black.withOpacity(0.5),
                      ),
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Expanded(
                          child: MyText(
                        text: AppLocalizations.of(context)!.provideVehicleColor,
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontSize: 15,
                                  color: (context
                                          .read<DriverProfileBloc>()
                                          .vehicleNumber
                                          .text
                                          .isNotEmpty)
                                      ? AppColors.blackText
                                      : AppColors.black.withOpacity(0.5),
                                ),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Column(
                        children: [
                          for (var i = 0; i < 15; i++)
                            Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              height: 3,
                              width: 1,
                              color: Colors.transparent,
                            )
                        ],
                      ),
                      SizedBox(
                        width: size.width * 0.07,
                      ),
                      Expanded(
                        child: CustomTextField(
                          enabled: context
                              .read<DriverProfileBloc>()
                              .vehicleNumber
                              .text
                              .isNotEmpty,
                          hintText:
                              AppLocalizations.of(context)!.enterVehicleColor,
                          onChange: (v) {
                            context
                                .read<DriverProfileBloc>()
                                .add(DataChangeEvent());
                          },
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 14,
                                    color: AppColors.blackText,
                                  ),
                          controller:
                              context.read<DriverProfileBloc>().vehicleColor,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.black.withOpacity(0.5),
                                width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.check_mark,
                        size: size.width * 0.07,
                        color: (context
                                    .read<DriverProfileBloc>()
                                    .choosenServiceLocation !=
                                null)
                            ? AppColors.black
                            : AppColors.black.withOpacity(0.5),
                      ),
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Expanded(
                          child: MyText(
                        text: AppLocalizations.of(context)!.provideCompanyName,
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontSize: 15,
                                  color: (context
                                              .read<DriverProfileBloc>()
                                              .choosenServiceLocation !=
                                          null)
                                      ? AppColors.blackText
                                      : AppColors.black.withOpacity(0.5),
                                ),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Column(
                        children: [
                          for (var i = 0; i < 15; i++)
                            Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              height: 3,
                              width: 1,
                              color: (context
                                      .read<DriverProfileBloc>()
                                      .companyName
                                      .text
                                      .isNotEmpty)
                                  ? AppColors.darkGrey
                                  : AppColors.black.withOpacity(0.5),
                            )
                        ],
                      ),
                      SizedBox(
                        width: size.width * 0.07,
                      ),
                      Expanded(
                        child: CustomTextField(
                          // maxLength: 4,
                          onChange: (v) {
                            context
                                .read<DriverProfileBloc>()
                                .add(DataChangeEvent());
                          },
                          // keyboardType: TextInputType.number,
                          enabled: context
                                  .read<DriverProfileBloc>()
                                  .choosenServiceLocation !=
                              null,
                          hintText:
                              AppLocalizations.of(context)!.enterCompanyName,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 14,
                                    color: AppColors.blackText,
                                  ),
                          controller:
                              context.read<DriverProfileBloc>().companyName,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.black.withOpacity(0.5),
                                width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.check_mark,
                        size: size.width * 0.07,
                        color: (context
                                .read<DriverProfileBloc>()
                                .companyName
                                .text
                                .isNotEmpty)
                            ? AppColors.black
                            : AppColors.black.withOpacity(0.5),
                      ),
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Expanded(
                          child: MyText(
                        text:
                            AppLocalizations.of(context)!.provideCompanyAddress,
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontSize: 15,
                                  color: (context
                                          .read<DriverProfileBloc>()
                                          .companyName
                                          .text
                                          .isNotEmpty)
                                      ? AppColors.blackText
                                      : AppColors.black.withOpacity(0.5),
                                ),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Column(
                        children: [
                          for (var i = 0; i < 15; i++)
                            Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              height: 3,
                              width: 1,
                              color: (context
                                      .read<DriverProfileBloc>()
                                      .companyAddress
                                      .text
                                      .isNotEmpty)
                                  ? AppColors.darkGrey
                                  : AppColors.black.withOpacity(0.5),
                            )
                        ],
                      ),
                      SizedBox(
                        width: size.width * 0.07,
                      ),
                      Expanded(
                        child: CustomTextField(
                          onChange: (v) {
                            context
                                .read<DriverProfileBloc>()
                                .add(DataChangeEvent());
                          },
                          enabled: context
                              .read<DriverProfileBloc>()
                              .companyName
                              .text
                              .isNotEmpty,
                          hintText:
                              AppLocalizations.of(context)!.enterCompanyAddress,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 14,
                                    color: AppColors.blackText,
                                  ),
                          controller:
                              context.read<DriverProfileBloc>().companyAddress,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.black.withOpacity(0.5),
                                width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.check_mark,
                        size: size.width * 0.07,
                        color: (context
                                .read<DriverProfileBloc>()
                                .companyAddress
                                .text
                                .isNotEmpty)
                            ? AppColors.black
                            : AppColors.black.withOpacity(0.5),
                      ),
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Expanded(
                          child: MyText(
                        text: AppLocalizations.of(context)!.provideCity,
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontSize: 15,
                                  color: (context
                                          .read<DriverProfileBloc>()
                                          .companyAddress
                                          .text
                                          .isNotEmpty)
                                      ? AppColors.blackText
                                      : AppColors.black.withOpacity(0.5),
                                ),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Column(
                        children: [
                          for (var i = 0; i < 15; i++)
                            Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              height: 3,
                              width: 1,
                              color: (context
                                      .read<DriverProfileBloc>()
                                      .companyCity
                                      .text
                                      .isNotEmpty)
                                  ? AppColors.darkGrey
                                  : AppColors.black.withOpacity(0.5),
                            )
                        ],
                      ),
                      SizedBox(
                        width: size.width * 0.07,
                      ),
                      Expanded(
                        child: CustomTextField(
                          onChange: (v) {
                            context
                                .read<DriverProfileBloc>()
                                .add(DataChangeEvent());
                          },
                          enabled: context
                              .read<DriverProfileBloc>()
                              .companyAddress
                              .text
                              .isNotEmpty,
                          hintText: AppLocalizations.of(context)!.enterCity,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 14,
                                    color: AppColors.blackText,
                                  ),
                          controller:
                              context.read<DriverProfileBloc>().companyCity,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.black.withOpacity(0.5),
                                width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.check_mark,
                        size: size.width * 0.07,
                        color: (context
                                .read<DriverProfileBloc>()
                                .companyCity
                                .text
                                .isNotEmpty)
                            ? AppColors.black
                            : AppColors.black.withOpacity(0.5),
                      ),
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Expanded(
                          child: MyText(
                        text: AppLocalizations.of(context)!.providePostalCode,
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontSize: 15,
                                  color: (context
                                          .read<DriverProfileBloc>()
                                          .companyCity
                                          .text
                                          .isNotEmpty)
                                      ? AppColors.blackText
                                      : AppColors.black.withOpacity(0.5),
                                ),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Column(
                        children: [
                          for (var i = 0; i < 15; i++)
                            Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              height: 3,
                              width: 1,
                              color: (context
                                      .read<DriverProfileBloc>()
                                      .companyPostalCode
                                      .text
                                      .isNotEmpty)
                                  ? AppColors.darkGrey
                                  : AppColors.black.withOpacity(0.5),
                            )
                        ],
                      ),
                      SizedBox(
                        width: size.width * 0.07,
                      ),
                      Expanded(
                        child: CustomTextField(
                          enabled: context
                              .read<DriverProfileBloc>()
                              .companyCity
                              .text
                              .isNotEmpty,
                          onChange: (v) {
                            context
                                .read<DriverProfileBloc>()
                                .add(DataChangeEvent());
                          },
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 14,
                                    color: AppColors.blackText,
                                  ),
                          hintText:
                              AppLocalizations.of(context)!.enterPostalCode,
                          keyboardType: TextInputType.number,
                          controller: context
                              .read<DriverProfileBloc>()
                              .companyPostalCode,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.black.withOpacity(0.5),
                                width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          validator: (string) {
                            if (string != null && string.length > 8) {
                              return AppLocalizations.of(context)!
                                  .validPostalCode;
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.check_mark,
                        size: size.width * 0.07,
                        color: (context
                                .read<DriverProfileBloc>()
                                .companyPostalCode
                                .text
                                .isNotEmpty)
                            ? AppColors.black
                            : AppColors.black.withOpacity(0.5),
                      ),
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Expanded(
                          child: MyText(
                        text: AppLocalizations.of(context)!.provideTaxNumber,
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontSize: 15,
                                  color: (context
                                          .read<DriverProfileBloc>()
                                          .companyPostalCode
                                          .text
                                          .isNotEmpty)
                                      ? AppColors.blackText
                                      : AppColors.black.withOpacity(0.5),
                                ),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Column(
                        children: [
                          for (var i = 0; i < 15; i++)
                            Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              height: 3,
                              width: 1,
                              color: Colors.transparent,
                            )
                        ],
                      ),
                      SizedBox(
                        width: size.width * 0.07,
                      ),
                      Expanded(
                        child: CustomTextField(
                          enabled: context
                              .read<DriverProfileBloc>()
                              .companyPostalCode
                              .text
                              .isNotEmpty,
                          hintText: AppLocalizations.of(context)!.enterTaxNumer,
                          onChange: (v) {
                            context
                                .read<DriverProfileBloc>()
                                .add(DataChangeEvent());
                          },
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 14,
                                    color: AppColors.blackText,
                                  ),
                          controller: context
                              .read<DriverProfileBloc>()
                              .companyTaxNumber,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.black.withOpacity(0.5),
                                width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      if (((userData!.role == 'driver' || args.from == 'owner') &&
              context.read<DriverProfileBloc>().vehicleColor.text.isNotEmpty &&
              context.read<DriverProfileBloc>().vehicleNumber.text.isNotEmpty &&
              context.read<DriverProfileBloc>().vehicleYear.text.length >= 4 &&
              context.read<DriverProfileBloc>().customMake.text.isNotEmpty &&
              context.read<DriverProfileBloc>().customModel.text.isNotEmpty) ||
          (userData!.role == 'owner' &&
              context.read<DriverProfileBloc>().companyName.text.isNotEmpty &&
              context.read<DriverProfileBloc>().companyCity.text.isNotEmpty &&
              context
                  .read<DriverProfileBloc>()
                  .companyAddress
                  .text
                  .isNotEmpty &&
              context
                  .read<DriverProfileBloc>()
                  .companyPostalCode
                  .text
                  .isNotEmpty &&
              context
                  .read<DriverProfileBloc>()
                  .companyTaxNumber
                  .text
                  .isNotEmpty))
        Column(
          children: [
            CustomButton(
                buttonName: AppLocalizations.of(context)!.submit,
                onTap: () {
                  context
                      .read<DriverProfileBloc>()
                      .add(UpdateVehicleEvent(from: args.from));
                }),
            SizedBox(height: size.width * 0.05)
          ],
        )
    ],
  );
}

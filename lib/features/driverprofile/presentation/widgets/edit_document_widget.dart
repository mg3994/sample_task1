import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/widgets/image_picker_dialog.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

Container editDocumentWidget(Size size, BuildContext context) {
  return Container(
    padding: EdgeInsets.all(size.width * 0.05),
    height: size.height,
    width: size.width,
    child: Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).padding.top,
        ),
        SizedBox(
          width: size.width * 0.9,
          child: Row(
            children: [
              InkWell(
                  onTap: () {
                    if ((context
                            .read<DriverProfileBloc>()
                            .neededDocuments
                            .firstWhere((e) =>
                                e.id ==
                                context
                                    .read<DriverProfileBloc>()
                                    .choosenDocument)
                            .isUploaded &&
                        context
                            .read<DriverProfileBloc>()
                            .neededDocuments
                            .firstWhere((e) =>
                                e.id ==
                                context
                                    .read<DriverProfileBloc>()
                                    .choosenDocument)
                            .isEditable)) {
                      context
                          .read<DriverProfileBloc>()
                          .add(EnableEditEvent(isEditable: false));
                    } else {
                      context
                          .read<DriverProfileBloc>()
                          .add(ChooseDocumentEvent(id: null));
                    }
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: size.width * 0.07,
                    color: AppColors.blackText,
                  )),
              SizedBox(
                width: size.width * 0.05,
              ),
              Expanded(
                  child: MyText(
                text:
                    '${AppLocalizations.of(context)!.upload} ${context.read<DriverProfileBloc>().neededDocuments.firstWhere((e) => e.id == context.read<DriverProfileBloc>().choosenDocument).name}',
                textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 18,
                      color: AppColors.blackText,
                    ),
              ))
            ],
          ),
        ),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: size.width * 0.1,
              ),
              InkWell(
                onTap: () {
                  context
                              .read<DriverProfileBloc>()
                              .neededDocuments
                              .firstWhere((e) =>
                                  e.id ==
                                  context
                                      .read<DriverProfileBloc>()
                                      .choosenDocument)
                              .isEditable ==
                          true
                      ? showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (builder) {
                            return ImagePickerDialog(
                              size: size.width,
                              onImageSelected: (ImageSource source) {
                                context.read<DriverProfileBloc>().add(
                                      PickImageEvent(
                                          source: source, isFront: true),
                                    );
                              },
                            );
                          })
                      : null;
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text:
                          '${context.read<DriverProfileBloc>().neededDocuments.firstWhere((e) => e.id == context.read<DriverProfileBloc>().choosenDocument).name} Front',
                      textStyle:
                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 18,
                                color: AppColors.blackText,
                              ),
                    ),
                    SizedBox(
                      height: size.width * 0.01,
                    ),
                    SizedBox(
                      height: size.width * 0.5,
                      width: size.width * 0.8,
                      child: DottedBorder(
                        color: AppColors.darkGrey,
                        strokeWidth: 2,
                        dashPattern: const [6, 3],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(5),
                        child: (context.read<DriverProfileBloc>().docImage ==
                                null)
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      color: AppColors.black.withOpacity(0.5),
                                      size: size.width * 0.07,
                                    ),
                                    SizedBox(
                                      height: size.width * 0.025,
                                    ),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .tapToUploadImage,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontSize: 15,
                                            color: AppColors.black
                                                .withOpacity(0.5),
                                          ),
                                    )
                                  ],
                                ),
                              )
                            : Container(
                                height: size.width * 0.5,
                                width: size.width * 0.8,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(
                                      File(context
                                          .read<DriverProfileBloc>()
                                          .docImage!),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      5), // Matching borderRadius
                                ),
                              ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: context
                            .read<DriverProfileBloc>()
                            .neededDocuments
                            .firstWhere((e) =>
                                e.id ==
                                context
                                    .read<DriverProfileBloc>()
                                    .choosenDocument)
                            .isFrontAndBack ==
                        true
                    ? size.width * 0.05
                    : size.width * 0,
              ),
              context
                          .read<DriverProfileBloc>()
                          .neededDocuments
                          .firstWhere((e) =>
                              e.id ==
                              context.read<DriverProfileBloc>().choosenDocument)
                          .isFrontAndBack ==
                      true
                  ? InkWell(
                      onTap: () {
                        context
                                    .read<DriverProfileBloc>()
                                    .neededDocuments
                                    .firstWhere((e) =>
                                        e.id ==
                                        context
                                            .read<DriverProfileBloc>()
                                            .choosenDocument)
                                    .isEditable ==
                                true
                            ? showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (builder) {
                                  return ImagePickerDialog(
                                    size: size.width,
                                    onImageSelected: (ImageSource source) {
                                      context.read<DriverProfileBloc>().add(
                                            PickImageEvent(
                                                source: source, isFront: false),
                                          );
                                    },
                                  );
                                })
                            : null;
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text:
                                '${context.read<DriverProfileBloc>().neededDocuments.firstWhere((e) => e.id == context.read<DriverProfileBloc>().choosenDocument).name} Back',
                            textStyle:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontSize: 18,
                                      color: AppColors.blackText,
                                    ),
                          ),
                          SizedBox(
                            height: size.width * 0.01,
                          ),
                          SizedBox(
                            height: size.width * 0.5,
                            width: size.width * 0.8,
                            child: DottedBorder(
                              color: AppColors.darkGrey,
                              strokeWidth: 2,
                              dashPattern: const [6, 3],
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(5),
                              child: (context
                                          .read<DriverProfileBloc>()
                                          .docImageBack ==
                                      null)
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            color: AppColors.black
                                                .withOpacity(0.5),
                                            size: size.width * 0.07,
                                          ),
                                          SizedBox(
                                            height: size.width * 0.025,
                                          ),
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .tapToUploadImage,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontSize: 15,
                                                  color: AppColors.black
                                                      .withOpacity(0.5),
                                                ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(
                                      height: size.width * 0.5,
                                      width: size.width * 0.8,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: FileImage(
                                            File(context
                                                .read<DriverProfileBloc>()
                                                .docImageBack!),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              if (context
                  .read<DriverProfileBloc>()
                  .neededDocuments
                  .firstWhere((e) =>
                      e.id == context.read<DriverProfileBloc>().choosenDocument)
                  .hasIdNumer)
                Column(
                  children: [
                    SizedBox(
                      height: size.width * 0.07,
                    ),
                    SizedBox(
                      width: size.width * 0.9,
                      child: MyText(
                        text: context
                            .read<DriverProfileBloc>()
                            .neededDocuments
                            .firstWhere((e) =>
                                e.id ==
                                context
                                    .read<DriverProfileBloc>()
                                    .choosenDocument)
                            .idKey,
                        textStyle:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 16,
                                  color: AppColors.blackText,
                                ),
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    Container(
                      color: AppColors.darkGrey.withOpacity(0.1),
                      child: CustomTextField(
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 16,
                              color: AppColors.blackText,
                            ),
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
                        controller:
                            context.read<DriverProfileBloc>().documentId,
                        hintText: context
                            .read<DriverProfileBloc>()
                            .neededDocuments
                            .firstWhere((e) =>
                                e.id ==
                                context
                                    .read<DriverProfileBloc>()
                                    .choosenDocument)
                            .idKey,
                      ),
                    )
                  ],
                ),
              if (context
                  .read<DriverProfileBloc>()
                  .neededDocuments
                  .firstWhere((e) =>
                      e.id == context.read<DriverProfileBloc>().choosenDocument)
                  .hasExpiryDate)
                Column(
                  children: [
                    SizedBox(
                      height: size.width * 0.07,
                    ),
                    SizedBox(
                      width: size.width * 0.9,
                      child: MyText(
                        text: AppLocalizations.of(context)!.chooseExpiryDate,
                        textStyle:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 16,
                                  color: AppColors.blackText,
                                ),
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    InkWell(
                      onTap: () {
                        context
                            .read<DriverProfileBloc>()
                            .add(ChooseDateEvent(context: context));
                      },
                      child: Container(
                        color: AppColors.darkGrey.withOpacity(0.1),
                        child: CustomTextField(
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 16,
                                    color: AppColors.blackText,
                                  ),
                          enabled: false,
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
                            borderSide: const BorderSide(
                                color: AppColors.darkGrey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          controller:
                              context.read<DriverProfileBloc>().documentExpiry,
                          hintText:
                              '${context.read<DriverProfileBloc>().neededDocuments.firstWhere((e) => e.id == context.read<DriverProfileBloc>().choosenDocument).name} ${AppLocalizations.of(context)!.expiryDate}',
                        ),
                      ),
                    )
                  ],
                ),
              SizedBox(
                height: size.width * 0.05,
              ),
            ],
          ),
        )),
        CustomButton(
            buttonName: AppLocalizations.of(context)!.submit,
            onTap: () {
              if (context.read<DriverProfileBloc>().docImage != null &&
                  (context
                              .read<DriverProfileBloc>()
                              .neededDocuments
                              .firstWhere((e) =>
                                  e.id ==
                                  context
                                      .read<DriverProfileBloc>()
                                      .choosenDocument)
                              .hasExpiryDate ==
                          false ||
                      context
                          .read<DriverProfileBloc>()
                          .documentExpiry
                          .text
                          .isNotEmpty) &&
                  (context
                              .read<DriverProfileBloc>()
                              .neededDocuments
                              .firstWhere((e) =>
                                  e.id ==
                                  context
                                      .read<DriverProfileBloc>()
                                      .choosenDocument)
                              .hasIdNumer ==
                          false ||
                      context
                          .read<DriverProfileBloc>()
                          .documentId
                          .text
                          .isNotEmpty)) {
                context.read<DriverProfileBloc>().add(UploadDocumentEvent(
                    id: context.read<DriverProfileBloc>().choosenDocument!,
                    fleetId: context.read<DriverProfileBloc>().fleetId));
              } else {
                context.showSnackBar(
                    color: AppColors.red,
                    message: AppLocalizations.of(context)!.enterRequiredField);
              }
            })
      ],
    ),
  );
}

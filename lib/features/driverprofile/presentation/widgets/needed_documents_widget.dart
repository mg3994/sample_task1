import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../common/common.dart';

Column neededDocumentsWidget(
    Size size, BuildContext context, VehicleUpdateArguments arg) {
  return Column(
    children: [
      SizedBox(
        width: size.width * 0.9,
        child: MyText(
          text: AppLocalizations.of(context)!.submitNecessaryDocs,
          textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black.withOpacity(0.5),
              ),
          maxLines: 2,
        ),
      ),
      SizedBox(height: size.width * 0.05),
      Column(
        children: [
          for (var i = 0;
              i < context.read<DriverProfileBloc>().neededDocuments.length;
              i++)
            SizedBox(
              width: size.width * 0.9,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: size.width * 0.04,
                        width: size.width * 0.04,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.black, width: 2)),
                        alignment: Alignment.center,
                        child: Container(
                          height: size.width * 0.02,
                          width: size.width * 0.02,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: AppColors.black),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.025,
                      ),
                      Expanded(
                          child: MyText(
                        text: context
                            .read<DriverProfileBloc>()
                            .neededDocuments[i]
                            .name,
                        textStyle:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 18,
                                  color: AppColors.blackText,
                                ),
                      ))
                    ],
                  ),
                  SizedBox(
                    width: size.width * 0.9,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: size.width * 0.02,
                        ),
                        Column(
                          children: [
                            for (var k = 0; k < 20; k++)
                              Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                height: 3,
                                width: 1,
                                color: (i !=
                                        context
                                                .read<DriverProfileBloc>()
                                                .neededDocuments
                                                .length -
                                            1)
                                    ? AppColors.darkGrey
                                    : Colors.transparent,
                              )
                          ],
                        ),
                        SizedBox(
                          width: size.width * 0.05,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InkWell(
                              onTap: () {
                                context.read<DriverProfileBloc>().add(
                                    EnableEditEvent(
                                        isEditable: (context
                                                    .read<DriverProfileBloc>()
                                                    .neededDocuments[i]
                                                    .isEditable &&
                                                context
                                                    .read<DriverProfileBloc>()
                                                    .neededDocuments[i]
                                                    .isUploaded)
                                            ? false
                                            : true));
                                context.read<DriverProfileBloc>().add(
                                    ChooseDocumentEvent(
                                        id: context
                                            .read<DriverProfileBloc>()
                                            .neededDocuments[i]
                                            .id));
                              },
                              child: Container(
                                padding: EdgeInsets.fromLTRB(
                                    size.width * 0.05, 0, size.width * 0.05, 0),
                                height: size.width * 0.14,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: AppColors.darkGrey),
                                    borderRadius: BorderRadius.circular(7),
                                    color: AppColors.darkGrey.withOpacity(0.1)),
                                child: (context
                                            .read<DriverProfileBloc>()
                                            .neededDocuments[i]
                                            .document !=
                                        null)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: MyText(
                                              text: context
                                                      .read<DriverProfileBloc>()
                                                      .neededDocuments[i]
                                                      .document!['data']
                                                  ['document_status_string'],
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    fontSize: 16,
                                                    color: AppColors.blackText,
                                                  ),
                                            ),
                                          )
                                        ],
                                      )
                                    : (context
                                                    .read<DriverProfileBloc>()
                                                    .fleetId !=
                                                null &&
                                            context
                                                    .read<DriverProfileBloc>()
                                                    .neededDocuments[i]
                                                    .fleetDocument !=
                                                null)
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: MyText(
                                                  text: context
                                                          .read<DriverProfileBloc>()
                                                          .neededDocuments[i]
                                                          .fleetDocument!['data']
                                                      [
                                                      'document_status_string'],
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        fontSize: 12,
                                                        color:
                                                            AppColors.blackText,
                                                      ),
                                                ),
                                              )
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .upload,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      fontSize: 15,
                                                      color: AppColors.black
                                                          .withOpacity(0.5),
                                                    ),
                                              ),
                                              SizedBox(
                                                width: size.width * 0.025,
                                              ),
                                              Icon(
                                                Icons.cloud_upload,
                                                color: AppColors.black
                                                    .withOpacity(0.5),
                                                size: size.width * 0.05,
                                              )
                                            ],
                                          ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.05,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
      SizedBox(height: size.width * 0.05),
      if (context.read<DriverProfileBloc>().showSubmitButton &&
              arg.from != 'docs' ||
          context.read<DriverProfileBloc>().fleetId != null)
        Column(
          children: [
            CustomButton(
                buttonName: AppLocalizations.of(context)!.submit,
                onTap: () {
                  if (context
                      .read<DriverProfileBloc>()
                      .neededDocuments
                      .every((doc) => doc.isUploaded)) {
                    if (context.read<DriverProfileBloc>().fleetId != null) {
                      Navigator.pop(context);
                    } else {
                      context.read<DriverProfileBloc>().add(ModifyDocEvent());
                    }
                  } else {
                    showToast(
                        message:
                            AppLocalizations.of(context)!.documentMissingText);
                  }
                }),
            SizedBox(height: size.width * 0.05),
          ],
        ),
    ],
  );
}

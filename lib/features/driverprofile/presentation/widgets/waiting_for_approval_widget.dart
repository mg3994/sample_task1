import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

Column waitingForApprovalWidget(Size size, BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(height: MediaQuery.of(context).padding.top),
      Image.asset(
        AppImages.profileDeclined,
        width: size.width * 0.4,
        height: size.width * 0.4,
        fit: BoxFit.contain,
      ),
      SizedBox(height: size.width * 0.05),
      SizedBox(
        width: size.width * 0.9,
        child: MyText(
          text: AppLocalizations.of(context)!.profileDeclined,
          textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 16,
                color: AppColors.red,
              ),
          maxLines: 2,
        ),
      ),
      SizedBox(height: size.width * 0.05),
      Column(
        children: [
          SizedBox(
            width: size.width * 0.9,
            child: MyText(
                text:
                    '${AppLocalizations.of(context)!.evaluatingProfile}\n${AppLocalizations.of(context)!.profileApprove}',
                textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                maxLines: 6),
          ),
        ],
      ),
      SizedBox(height: size.width * 0.05),
      if (userData!.declinedReason != null)
        CustomButton(
            buttonName: AppLocalizations.of(context)!.modifyDocument,
            onTap: () {
              context.read<DriverProfileBloc>().add(ModifyDocEvent());
            }),
      SizedBox(height: size.width * 0.05),
    ],
  );
}

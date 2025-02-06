import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

SizedBox onlineOfflineWidget(Size size, BuildContext context) {
  return SizedBox(
      width: size.width,
      child: Column(
        children: [
          if (userData != null)
            Stack(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.secondary),
                        alignment: Alignment.center,
                        child: MyText(
                          text: userData!.active == true
                              ? AppLocalizations.of(context)!.onlineCaps
                              : AppLocalizations.of(context)!.offlineCaps,
                          textStyle: AppTextStyle.boldStyle().copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      onPressed: () {
                        context
                            .read<HomeBloc>()
                            .add(ChangeOnlineOfflineEvent());
                      }),
                ),
                if (context.read<HomeBloc>().onlineLoader == true)
                  const Positioned(
                    bottom: 0,
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        color: AppColors.white,
                      ),
                    ),
                  )
              ],
            ),
          const SizedBox(
            height: 13,
          ),
          if (userData != null)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.grey),
              child: MyText(
                text: userData!.active == true
                    ? AppLocalizations.of(context)!.yourOnline
                    : AppLocalizations.of(context)!.yourOffline,
              ),
            ),
          if (userData!.showRentalRide == false && userData!.active == true)
            Column(
              children: [
                SizedBox(
                  height: size.width * 0.05,
                ),
                CustomButton(
                    buttonName: AppLocalizations.of(context)!.instantRide,
                    onTap: () {
                      context.read<HomeBloc>().add(ShowGetDropAddressEvent());
                    })
              ],
            )
        ],
      ));
}

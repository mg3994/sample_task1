import 'package:flutter/cupertino.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_text_styles.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';

Container fareBreakdownWidget(
    Size size, BuildContext context, String name, String price) {
  return Container(
    width: size.width * 0.8,
    padding:
        EdgeInsets.only(top: size.width * 0.025, bottom: size.width * 0.025),
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey))),
    child: Row(
      children: [
        Expanded(
            child: MyText(
          text: name,
          textStyle: AppTextStyle.normalStyle().copyWith(
              fontSize: 15,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500),
        )),
        MyText(
          text: price,
          textStyle: AppTextStyle.normalStyle().copyWith(
              fontSize: 15,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500),
        )
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';

class PageOptions extends StatelessWidget {
  final String list;
  final Function()? onTap;
  final Color? color;
  final Icon? icon;

  const PageOptions(
      {super.key, required this.list, this.onTap, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: MyText(
                    text: list,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).disabledColor,
                        fontSize: AppConstants().headerSize),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Theme.of(context).disabledColor,
                )
              ],
            ),
          ),
        ),
        // const SizedBox(height: 20),
        Divider(
          height: 1,
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ],
    );
  }
}

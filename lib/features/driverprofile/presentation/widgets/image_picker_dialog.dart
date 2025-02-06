import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class ImagePickerDialog extends StatelessWidget {
  final double size;
  final Function(ImageSource source) onImageSelected;

  const ImagePickerDialog({
    super.key,
    required this.size,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size * 0.6,
      width: size,
      padding: EdgeInsets.all(size * 0.05),
      child: Column(
        children: [
          MyText(
            text: AppLocalizations.of(context)!.pickImageFrom,
            textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 16,
                  color: Theme.of(context).primaryColorDark,
                ),
          ),
          SizedBox(height: size * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  onImageSelected(ImageSource.camera);
                  Navigator.pop(context); // Close the dialog
                },
                child: Container(
                  height: size * 0.3,
                  width: size * 0.3,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context)
                            .primaryColorDark
                            .withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.camera,
                        size: size * 0.1,
                        color:
                            Theme.of(context).primaryColorDark.withOpacity(0.5),
                      ),
                      MyText(
                        text: AppLocalizations.of(context)!.camera,
                        textStyle:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.5),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  onImageSelected(ImageSource.gallery);
                  Navigator.pop(context); // Close the dialog
                },
                child: Container(
                  height: size * 0.3,
                  width: size * 0.3,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context)
                            .primaryColorDark
                            .withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.folder,
                        size: size * 0.1,
                        color:
                            Theme.of(context).primaryColorDark.withOpacity(0.5),
                      ),
                      MyText(
                        text: AppLocalizations.of(context)!.gallery,
                        textStyle:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.5),
                                ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

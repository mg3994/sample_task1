import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../common/common.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChange;
  final VoidCallback? onTap;
  final Function(String)? onSubmitted;
  final String? hintText;
  final int? maxLine;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FloatingLabelBehavior? labelBehavior;
  final InputBorder? focusedBorder;
  final InputBorder? disabledBorder;
  final InputBorder? enabledBorder;
  final String? labelText;
  final EdgeInsets? contentPadding;
  final bool? filled;
  final TextStyle? labelStyle;
  final Widget? prefixIcon;
  final Color? fillColor;
  final bool? readOnly;
  final Widget? suffixIcon;
  final TextStyle? hintTextStyle;
  final Widget? suffix;
  final int? maxLength;
  final TextStyle? style;
  final TextStyle? errorStyle;
  final TextInputAction? textInputAction;
  final Color? cursorColor;
  final BoxConstraints? suffixConstraints;
  final BoxConstraints? prefixConstraints;
  final bool? dense;
  final bool obscureText;
  final FocusNode? focusNode;
  final String? Function(String? string)? validator;
  final TextAlign textAlign;
  final bool? enabled;
  final double borderRadius;
  const CustomTextField(
      {super.key,
      this.cursorColor,
      this.controller,
      this.readOnly = false,
      this.obscureText = false,
      this.onChange,
      this.onTap,
      this.hintText,
      this.maxLine = 1,
      this.keyboardType = TextInputType.text,
      this.inputFormatters = const [],
      this.focusedBorder,
      this.enabledBorder,
      this.disabledBorder,
      this.contentPadding,
      this.labelBehavior,
      this.labelText,
      this.filled = false,
      this.fillColor,
      this.labelStyle,
      this.prefixIcon,
      this.suffixIcon,
      this.hintTextStyle,
      this.suffix,
      this.maxLength,
      this.style,
      this.textInputAction,
      this.onSubmitted,
      this.suffixConstraints,
      this.dense,
      this.prefixConstraints,
      this.validator,
      this.errorStyle,
      this.focusNode,
      this.textAlign = TextAlign.start,
      this.enabled,
      this.borderRadius = 5});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: obscureText,
      cursorColor: cursorColor,
      readOnly: readOnly!,
      focusNode: focusNode,
      onChanged: onChange,
      onTap: onTap,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      textAlign: textAlign,
      style: style ??
          Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
      maxLength: maxLength,
      decoration: InputDecoration(
          isDense: dense ?? true,
          suffix: suffix,
          suffixIcon: suffixIcon,
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          hintText: hintText,
          hintStyle: hintTextStyle ??
              Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).hintColor),
          filled: filled ?? true,
          fillColor: fillColor ?? Theme.of(context).scaffoldBackgroundColor,
          errorStyle: TextStyle(
            color: AppColors.red.withOpacity(0.8),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          labelText: labelText,
          labelStyle: labelStyle ??
              Theme.of(context).textTheme.labelLarge!.copyWith(
                  fontSize: 17.5,
                  color: Theme.of(context).disabledColor,
                  fontWeight: FontWeight.w500),
          floatingLabelBehavior: labelBehavior ?? FloatingLabelBehavior.always,
          suffixIconConstraints: suffixConstraints,
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: AppColors.errorLight.withOpacity(0.8), width: 1),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          errorBorder: focusedBorder ??
              OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.errorLight.withOpacity(0.5),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
          disabledBorder: disabledBorder ??
              OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).hintColor, width: 1),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
          focusedBorder: focusedBorder ??
              OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).hintColor, width: 1),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
          enabledBorder: enabledBorder ??
              OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).hintColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
          prefixIconConstraints: prefixConstraints,
          prefixIcon: prefixIcon,
          counterText: ''),
      inputFormatters: inputFormatters,
      maxLines: maxLine == 0 ? null : maxLine,
      textInputAction: textInputAction ?? TextInputAction.done,
      autofocus: false,
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.multiline,
    );
  }
}

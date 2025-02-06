import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import '../../../../common/common.dart';
import '../../../../core/utils/custom_background.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../application/auth_bloc.dart';
import '../../domain/models/country_list_model.dart';
import 'refferal_page.dart';

class RegisterPage extends StatelessWidget {
  static const String routeName = '/registerPage';
  final RegisterPageArguments arg;
  const RegisterPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AuthBloc()
        ..add(GetDirectionEvent())
        ..add(RegisterPageInitEvent(arg: arg)),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          }
          if (state is AuthDataLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is AuthDataLoadedState) {
            CustomLoader.dismiss(context);
          }
          if (state is AuthDataSuccessState) {
            CustomLoader.dismiss(context);
          }
          if (state is LoginSuccessState) {
            if (arg.isRefferalEarnings == "1") {
              Navigator.pushNamedAndRemoveUntil(
                  context, RefferalPage.routeName, (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, HomePage.routeName, (route) => false);
            }
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Scaffold(
                body: CustomBackground(
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: context.read<AuthBloc>().formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: size.width * 0.9,
                                child: Row(
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Icon(
                                          Icons.arrow_back,
                                          size: size.width * 0.07,
                                          color: AppColors.black,
                                        )),
                                    SizedBox(
                                      width: size.width * 0.05,
                                    ),
                                    Expanded(
                                      child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .register,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .displayLarge!
                                            .copyWith(
                                                color: AppColors.blackText),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.width * 0.1),
                              buildProfilePick(size, context),
                              SizedBox(height: size.width * 0.1),
                              MyText(
                                text: AppLocalizations.of(context)!.name,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: AppColors.black,
                                        fontSize: AppConstants().subHeaderSize),
                              ),
                              SizedBox(height: size.width * 0.02),
                              buildUserNameField(context),
                              SizedBox(height: size.width * 0.02),
                              MyText(
                                text: AppLocalizations.of(context)!.mobile,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: AppColors.black,
                                    ),
                              ),
                              SizedBox(height: size.width * 0.02),
                              buildMobileField(context, size),
                              SizedBox(height: size.width * 0.02),
                              MyText(
                                text: AppLocalizations.of(context)!.email,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: AppColors.black,
                                        fontSize: AppConstants().subHeaderSize),
                              ),
                              SizedBox(height: size.width * 0.02),
                              buildEmailField(context),
                              SizedBox(height: size.width * 0.02),
                              MyText(
                                text: AppLocalizations.of(context)!.gender,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: AppColors.black,
                                        fontSize: AppConstants().subHeaderSize),
                              ),
                              SizedBox(height: size.width * 0.02),
                              buildDropDownGenderField(context),
                              SizedBox(height: size.width * 0.02),
                              MyText(
                                text: AppLocalizations.of(context)!.password,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: AppColors.black,
                                        fontSize: AppConstants().subHeaderSize),
                              ),
                              SizedBox(height: size.width * 0.02),
                              buildPasswordField(context, size),
                              SizedBox(height: size.width * 0.02),
                              SizedBox(height: size.width * 0.1),
                              buildButton(context),
                              SizedBox(height: size.width * 0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildProfilePick(Size size, BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: size.width * 0.15,
        backgroundColor: Theme.of(context).dividerColor,
        backgroundImage: context.read<AuthBloc>().profileImage.isNotEmpty
            ? FileImage(File(context.read<AuthBloc>().profileImage))
            : const AssetImage(AppImages.defaultProfile),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    _showImageSourceSheet(context);
                  },
                  child: Container(
                    height: size.width * 0.1,
                    width: size.width * 0.1,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: const Center(child: Icon(Icons.edit)),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context) {
    return Center(
      child: CustomButton(
        buttonName: AppLocalizations.of(context)!.register,
        borderRadius: 10,
        height: MediaQuery.of(context).size.height * 0.06,
        isLoader: context.read<AuthBloc>().isLoading,
        onTap: () {
          if (context.read<AuthBloc>().formKey.currentState!.validate() &&
              !context.read<AuthBloc>().isLoading) {
            context.read<AuthBloc>().add(RegisterUserEvent(
                userName: context.read<AuthBloc>().rUserNameController.text,
                mobileNumber: context.read<AuthBloc>().rMobileController.text,
                emailAddress: context.read<AuthBloc>().rEmailController.text,
                password: context.read<AuthBloc>().rPasswordController.text,
                countryCode: arg.contryCode,
                gender: context.read<AuthBloc>().selectedGender,
                loginAs: arg.loginAs,
                profileImage: context.read<AuthBloc>().profileImage));
          }
        },
      ),
    );
  }

  Widget buildPasswordField(BuildContext context, Size size) {
    return CustomTextField(
      controller: context.read<AuthBloc>().rPasswordController,
      filled: true,
      obscureText: !context.read<AuthBloc>().showPassword,
      hintText: AppLocalizations.of(context)!.enterYourPassword,
      suffixConstraints: BoxConstraints(maxWidth: size.width * 0.2),
      suffixIcon: InkWell(
        onTap: () {
          context.read<AuthBloc>().add(ShowPasswordIconEvent(
              showPassword: context.read<AuthBloc>().showPassword));
        },
        child: !context.read<AuthBloc>().showPassword
            ? const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.visibility_off_outlined,
                  color: AppColors.darkGrey,
                ),
              )
            : const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.visibility,
                  color: AppColors.darkGrey,
                ),
              ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return AppLocalizations.of(context)!.enterYourPassword;
        } else if (value.length < 8) {
          return AppLocalizations.of(context)!.minimumCharacRequired;
        } else {
          return null;
        }
      },
    );
  }

  Widget buildEmailField(BuildContext context) {
    return CustomTextField(
      controller: context.read<AuthBloc>().rEmailController,
      enabled: !context.read<AuthBloc>().isLoginByEmail,
      filled: true,
      fillColor: context.read<AuthBloc>().isLoginByEmail
          ? Theme.of(context).disabledColor.withOpacity(0.1)
          : null,
      hintText: AppLocalizations.of(context)!.enterEmail,
      validator: (value) {
        if (value!.isNotEmpty && !AppValidation.emailValidate(value)) {
          return AppLocalizations.of(context)!.enterValidEmail;
        } else if (value.isEmpty) {
          return AppLocalizations.of(context)!.enterEmail;
        } else {
          return null;
        }
      },
    );
  }

  Widget buildMobileField(BuildContext context, Size size) {
    return CustomTextField(
      controller: context.read<AuthBloc>().rMobileController,
      filled: true,
      fillColor: !context.read<AuthBloc>().isLoginByEmail
          ? Theme.of(context).disabledColor.withOpacity(0.1)
          : null,
      enabled: context.read<AuthBloc>().isLoginByEmail,
      hintText: AppLocalizations.of(context)!.mobile,
      keyboardType: TextInputType.number,
      prefixConstraints: BoxConstraints(maxWidth: size.width * 0.2),
      prefixIcon: Center(
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              isScrollControlled: true,
              enableDrag: true,
              context: context,
              builder: (cont) {
                return selectCountryBottomSheet(size, arg.countryList, context);
              },
            );
          },
          child: Row(
            children: [
              Container(
                height: 20,
                width: 25,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Theme.of(context).hintColor,
                  borderRadius: BorderRadius.circular(5),
                  image: (context.read<AuthBloc>().flagImage.isNotEmpty)
                      ? DecorationImage(
                          image:
                              NetworkImage(context.read<AuthBloc>().flagImage),
                          fit: BoxFit.fill)
                      : null,
                ),
              ),
              MyText(text: context.read<AuthBloc>().dialCode),
            ],
          ),
        ),
      ),
      validator: (value) {
        if (value!.isNotEmpty && !AppValidation.mobileNumberValidate(value)) {
          return AppLocalizations.of(context)!.enterValidMobile;
        } else if (value.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnterMobileNumber;
        } else {
          return null;
        }
      },
    );
  }

  Widget buildUserNameField(BuildContext context) {
    return CustomTextField(
      controller: context.read<AuthBloc>().rUserNameController,
      filled: true,
      hintText: AppLocalizations.of(context)!.enterName,
      validator: (value) {
        if (value!.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnterUserName;
        } else {
          return null;
        }
      },
    );
  }

  Widget buildDropDownGenderField(BuildContext context) {
    return DropdownButtonFormField(
      isExpanded: true,
      hint: Text(AppLocalizations.of(context)!.selectGender),
      style: Theme.of(context).textTheme.bodyMedium!,
      dropdownColor: Theme.of(context).dialogBackgroundColor,
      // value: selectedItem,
      icon: const Icon(Icons.arrow_drop_down_circle),
      iconSize: 20,
      elevation: 10,
      onChanged: (newValue) {
        context.read<AuthBloc>().selectedGender = newValue.toString();
      },
      items: context.read<AuthBloc>().genderList.map<DropdownMenuItem>((value) {
        return DropdownMenuItem(
          value: value,
          alignment: AlignmentDirectional.centerStart,
          child: MyText(text: value),
        );
      }).toList(),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        hintText: '',
        hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).hintColor),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        errorStyle: TextStyle(
          color: AppColors.red.withOpacity(0.8),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: AppColors.errorLight.withOpacity(0.8), width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.errorLight.withOpacity(0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).hintColor, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).hintColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (context.read<AuthBloc>().selectedGender.isEmpty) {
          return AppLocalizations.of(context)!.enterRequiredField;
        } else {
          return null;
        }
      },
    );
  }

  StatefulBuilder selectCountryBottomSheet(
      Size size, List<Country> countries, BuildContext context) {
    return StatefulBuilder(
      builder: (cont, set) {
        return SafeArea(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            height: size.height * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 10),
                      MyText(
                        text: AppLocalizations.of(context)!.selectCountry,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: MyText(
                          text: AppLocalizations.of(context)!.cancel,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  color: Theme.of(context).primaryColorDark,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CustomTextField(
                    controller: context.read<AuthBloc>().searchController,
                    borderRadius: 10,
                    onChange: (p0) => set(() {}),
                    onSubmitted: (p0) => set(() {}),
                    suffixConstraints:
                        BoxConstraints(maxWidth: size.width * 0.1),
                    suffixIcon: InkWell(
                      onTap: () => set(() {
                        context.read<AuthBloc>().searchController.clear();
                      }),
                      child: Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.cancel_outlined,
                            color: Theme.of(context).hintColor,
                          )),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: size.height * 0.75,
                  child: ListView.builder(
                    itemCount: countries.length,
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (con, index) {
                      var countryData = countries.elementAt(index);
                      if (countryData.name.toLowerCase().toString().contains(
                              context
                                  .read<AuthBloc>()
                                  .searchController
                                  .text
                                  .toLowerCase()
                                  .toString()) ||
                          countryData.dialCode.toString().contains(context
                              .read<AuthBloc>()
                              .searchController
                              .text
                              .toString())) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          child: InkWell(
                            onTap: () {
                              set(() {
                                context.read<AuthBloc>().dialCode =
                                    countryData.dialCode;
                                context.read<AuthBloc>().dialMaxLength =
                                    countryData.dialMaxLength;
                                context.read<AuthBloc>().flagImage =
                                    countryData.flag!;
                              });
                              context.read<AuthBloc>().searchController.clear();
                              Navigator.pop(context);
                            },
                            child: Row(
                              children: [
                                Container(
                                  height: 20,
                                  width: 30,
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: AppColors.darkGrey,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: CachedNetworkImage(
                                      imageUrl: countryData.flag!,
                                      width: 30,
                                      height: 20,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Center(
                                        child: Text(
                                          "",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: size.width * 0.7,
                                  child: MyText(
                                    text: countryData.name,
                                    maxLines: 2,
                                  ),
                                ),
                                const Spacer(),
                                MyText(text: countryData.dialCode),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).splashColor,
      builder: (_) => Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 1,
                  spreadRadius: 1)
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                size: 20,
                color: Theme.of(context).primaryColorDark,
              ),
              title: MyText(
                text: AppLocalizations.of(context)!.camera,
                textStyle: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).primaryColorDark),
              ),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<AuthBloc>()
                    .add(ImageUpdateEvent(source: ImageSource.camera));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                size: 20,
                color: Theme.of(context).primaryColorDark,
              ),
              title: MyText(
                text: AppLocalizations.of(context)!.gallery,
                textStyle: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).primaryColorDark),
              ),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<AuthBloc>()
                    .add(ImageUpdateEvent(source: ImageSource.gallery));
              },
            ),
          ],
        ),
      ),
    );
  }
}

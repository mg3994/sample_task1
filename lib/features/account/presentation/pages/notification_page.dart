import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_dialoges.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/notification_page_shimmer.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../common/app_images.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../auth/application/auth_bloc.dart';
import '../../application/acc_bloc.dart';
import '../widgets/top_bar.dart';

class NotificationPage extends StatelessWidget {
  static const String routeName = '/notification';

  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(NotificationGetEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          } else if (state is NotificationDeletedSuccess) {
            Navigator.of(context).pop();
            context.read<AccBloc>().add(NotificationGetEvent());
          } else if (state is NotificationClearedSuccess) {
            context.read<AccBloc>().add(NotificationGetEvent());
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            body: TopBarDesign(
              isHistoryPage: false,
              title: AppLocalizations.of(context)!.notifications,
              onTap: () {
                Navigator.of(context).pop();
              },
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (context.read<AccBloc>().isLoading) {
                            return Padding(
                              padding: EdgeInsets.only(
                                top: size.height * 0.03,
                              ),
                              child: NotificationShimmer(size: size),
                            );
                          } else if (context
                                  .read<AccBloc>()
                                  .notificationDatas
                                  .isEmpty &&
                              !context.read<AccBloc>().isLoading) {
                            return Center(
                                child: Padding(
                              padding: const EdgeInsets.all(50),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(AppImages.notificationsNoData),
                                  SizedBox(
                                    height: size.width * 0.05,
                                  ),
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .noNotificationAvail,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .disabledColor
                                                .withOpacity(0.8),
                                            fontSize: 18),
                                  ),
                                ],
                              ),
                            ));
                          }
                          if (index == 0) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: size.height * 0.03, bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .notifications,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      context
                                          .read<AccBloc>()
                                          .add(ClearAllNotificationsEvent());
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!.clearAll,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (index <
                              context.read<AccBloc>().notificationDatas.length +
                                  1) {
                            final datum = context
                                .read<AccBloc>()
                                .notificationDatas[index - 1];
                            return Container(
                              margin:
                                  EdgeInsets.only(bottom: size.width * 0.05),
                              padding: EdgeInsets.all(size.width * 0.025),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .dividerColor
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    width: size.width * 0.0025,
                                    color: Theme.of(context)
                                        .primaryColorDark
                                        .withOpacity(0.5),
                                  )),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.notifications,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              size: 18,
                                            ),
                                            SizedBox(
                                              width: size.width * 0.02,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  MyText(
                                                    text: datum.title,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(fontSize: 16),
                                                    maxLines: 5,
                                                  ),
                                                  MyText(
                                                    text: datum.body,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .disabledColor),
                                                    maxLines: 5,
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            children: [
                                              MyText(
                                                text: datum.convertedCreatedAt
                                                    .split(' ')[0],
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .disabledColor),
                                              ),
                                              MyText(
                                                text: datum.convertedCreatedAt
                                                    .split(' ')[1],
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .disabledColor),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: size.width * 0.01,
                                          ),
                                          Container(
                                            height: size.width * 0.1,
                                            width: size.width * 0.002,
                                            color: const Color(0xFF171717)
                                                .withOpacity(0.5),
                                          ),
                                          SizedBox(
                                            width: size.width * 0.01,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext _) {
                                                  return BlocProvider.value(
                                                    value: BlocProvider.of<
                                                        AccBloc>(context),
                                                    child:
                                                        CustomSingleButtonDialoge(
                                                      title: AppLocalizations
                                                              .of(context)!
                                                          .deleteNotification,
                                                      content: AppLocalizations
                                                              .of(context)!
                                                          .deleteNotificationContent,
                                                      btnName:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .confirm,
                                                      onTap: () {
                                                        context.read<AccBloc>().add(
                                                            DeleteNotificationEvent(
                                                                id: datum.id));
                                                      },
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Icon(
                                              Icons.cancel_rounded,
                                              color: const Color(0xFF171717)
                                                  .withOpacity(0.5),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  datum.image != null && datum.image!.isNotEmpty
                                      ? Column(
                                          children: [
                                            SizedBox(
                                              height: size.height * 0.01,
                                            ),
                                            Image.network(
                                              datum.image!,
                                              // width: 18,
                                              // height: 18,
                                              fit: BoxFit.cover,
                                            ),
                                          ],
                                        )
                                      : SizedBox()
                                ],
                              ),
                            );
                          } else {
                            return null;
                          }
                        },
                        childCount:
                            context.read<AccBloc>().notificationDatas.length +
                                1,
                      ),
                    ),
                  ),
                  if (context.read<AccBloc>().notificationPaginations != null &&
                      context
                              .read<AccBloc>()
                              .notificationPaginations!
                              .pagination !=
                          null &&
                      context
                              .read<AccBloc>()
                              .notificationPaginations!
                              .pagination
                              .currentPage <
                          context
                              .read<AccBloc>()
                              .notificationPaginations!
                              .pagination
                              .totalPages)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: size.width * 0.02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                if (context
                                        .read<AccBloc>()
                                        .notificationPaginations!
                                        .pagination
                                        .currentPage <
                                    context
                                        .read<AccBloc>()
                                        .notificationPaginations!
                                        .pagination
                                        .totalPages) {
                                  context.read<AccBloc>().add(
                                      NotificationGetEvent(
                                          pageNumber: context
                                                  .read<AccBloc>()
                                                  .notificationPaginations!
                                                  .pagination
                                                  .currentPage +
                                              1));
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(size.width * 0.02),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(3))),
                                child: Row(
                                  children: [
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .loadMore,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                          ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down_circle_outlined,
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      size: 15,
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
          );
        }),
      ),
    );
  }
}

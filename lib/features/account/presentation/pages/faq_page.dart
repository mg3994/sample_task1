import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/domain/models/faq_model.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/top_bar.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class FaqPage extends StatelessWidget {
  static const String routeName = '/faqPage';

  const FaqPage({super.key});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()..add(GetFaqListEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {},
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            body: TopBarDesign(
              onTap: () {
                Navigator.pop(context);
              },
              isHistoryPage: false,
              title: AppLocalizations.of(context)!.faq,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // if (context.read<AccBloc>().faqDataList.isNotEmpty) ...[
                    buildFaqDataList(
                        size, context.read<AccBloc>().faqDataList, context),
                    SizedBox(height: size.width * 0.05),
                    // ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget buildFaqDataList(
      Size size, List<FaqData> faqDataList, BuildContext context) {
    return faqDataList.isNotEmpty
        ? SizedBox(
            height: size.height * 0.725,
            child: RawScrollbar(
              radius: const Radius.circular(20),
              child: ListView.builder(
                itemCount: faqDataList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      context
                          .read<AccBloc>()
                          .add(FaqOnTapEvent(selectedFaqIndex: index));
                    },
                    child: Container(
                      width: size.width,
                      margin: const EdgeInsets.only(right: 10, bottom: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1.2,
                              color: Theme.of(context).disabledColor)),
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.025),
                        child: Row(
                          children: [
                            SizedBox(width: size.width * 0.025),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: MyText(
                                          text: faqDataList[index].question,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600),
                                          maxLines: 2,
                                        ),
                                      ),
                                      RotatedBox(
                                          quarterTurns: (context
                                                      .read<AccBloc>()
                                                      .choosenFaqIndex ==
                                                  index)
                                              ? (languageDirection == 'ltr')
                                                  ? 2
                                                  : 4
                                              : (languageDirection == 'ltr')
                                                  ? 4
                                                  : 2,
                                          child: Icon(
                                            Icons.arrow_drop_down,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ))
                                    ],
                                  ),
                                  (context.read<AccBloc>().choosenFaqIndex ==
                                          index)
                                      ? Column(
                                          children: [
                                            SizedBox(
                                              height: size.width * 0.025,
                                            ),
                                            SizedBox(
                                              width: size.width * 0.8,
                                              child: MyText(
                                                text: faqDataList[index].answer,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                                maxLines: 3,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        : SizedBox(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.height * 0.08,
                  ),
                  Image.asset(
                    AppImages.noFaqPage,
                    height: 200,
                    width: 200,
                  ),
                  SizedBox(
                    height: size.height * 0.04,
                  ),
                  Text(AppLocalizations.of(context)!.noDataFound),
                ],
              ),
            ),
          );
  }
}

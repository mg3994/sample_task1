// ignore_for_file: deprecated_member_use

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:restart_tagxi/common/app_constants.dart";
import "package:restart_tagxi/core/utils/custom_button.dart";
import "package:restart_tagxi/features/account/presentation/pages/complaint_list.dart";
import "package:restart_tagxi/features/tripsummary/presentation/widgets/fare_breakup.dart";
import "../../../../common/app_arguments.dart";
import "../../../../common/app_colors.dart";
import "../../../../common/app_images.dart";
import "../../../../common/pickup_icon.dart";
import "../../../../core/utils/custom_dialoges.dart";
import "../../../../core/utils/custom_loader.dart";
import "../../../../core/utils/custom_sliderbutton.dart";
import "../../../../core/utils/custom_text.dart";
import "../../../../l10n/app_localizations.dart";
import "../../../home/presentation/pages/home_page.dart";
import "../../application/acc_bloc.dart";
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as fmlt;

class HistoryTripSummaryPage extends StatelessWidget {
  static const String routeName = '/historytripsummary';
  final HistoryPageArguments arg;

  const HistoryTripSummaryPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(AddHistoryMarkerEvent(
            stops: arg.historyData.requestStops,
            pickLat: arg.historyData.pickLat,
            pickLng: arg.historyData.pickLng,
            dropLat: arg.historyData.dropLat,
            dropLng: arg.historyData.dropLng,
            polyline: arg.historyData.polyLine))
        ..add(ComplaintEvent(complaintType: 'request')),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AccInitialState) {
            CustomLoader.loader(context);
          } else if (state is AccDataLoadingStartState) {
            CustomLoader.loader(context);
          } else if (state is AccDataLoadingStopState) {
            CustomLoader.dismiss(context);
          } else if (state is HistoryTypeChangeState) {
            String filter;
            switch (state.selectedHistoryType) {
              case 0:
                filter = 'is_completed=1';
                break;
              case 1:
                filter = 'is_later=1';
                break;
              case 2:
                filter = 'is_cancelled=1';
                break;
              default:
                filter = '';
            }
            context.read<AccBloc>().add(HistoryGetEvent(historyFilter: filter));
          } else if (state is RequestCancelState) {
            Navigator.pop(context);
            Navigator.pop(context);
          } else if (state is OutstationReadyToPickupState) {
            Navigator.pushNamed(context, HomePage.routeName,
                arguments: HomePageArguments(isFromHistory: true));
          } else if(state is ShowErrorState){
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext ctx) {
                return CustomSingleButtonDialoge(
                  title: AppLocalizations.of(context)!.cancel,
                  content: AppLocalizations.of(context)!.userCancelledRide,
                  btnName: AppLocalizations.of(context)!.ok,
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                );
              },
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          if (Theme.of(context).brightness == Brightness.dark) {
            if (context.read<AccBloc>().googleMapController != null) {
              context
                  .read<AccBloc>()
                  .googleMapController!
                  .setMapStyle(context.read<AccBloc>().darkMapString);
            }
          } else {
            if (context.read<AccBloc>().googleMapController != null) {
              context.read<AccBloc>().googleMapController!.setMapStyle(context.read<AccBloc>().lightMapString);
            }
          }
          return Scaffold(
            backgroundColor: const Color(0xffDEDCDC),
            body: Stack(
              children: [
                SizedBox(
                  height: size.height,
                  width: size.width,
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                          stretch: false,
                          expandedHeight: size.width * 0.7,
                          pinned: true,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          leading: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: AppColors.black,
                              )),
                          flexibleSpace: LayoutBuilder(builder:
                              (BuildContext context,
                                  BoxConstraints constraints) {
                            var top = constraints.biggest.height;
                            return FlexibleSpaceBar(
                              title: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: top > 71 && top < 91 ? 1.0 : 0.0,
                                  child: Text(
                                    top > 71 && top < 91
                                        ? AppLocalizations.of(context)!
                                            .tripDetails
                                        : "",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )),
                              background: (mapType == 'google_map')
                                  ? GoogleMap(
                                      onMapCreated:
                                          (GoogleMapController controller) {
                                        context
                                            .read<AccBloc>()
                                            .googleMapController = controller;
                                      },
                                      initialCameraPosition:
                                          const CameraPosition(
                                        target: LatLng(11.0696161, 76.999307),
                                        zoom: 4.0,
                                      ),
                                      zoomControlsEnabled: false,
                                      polylines:
                                          context.read<AccBloc>().polyline,
                                      markers: Set<Marker>.from(
                                          context.read<AccBloc>().markers),
                                      minMaxZoomPreference:
                                          const MinMaxZoomPreference(0, 11),
                                      buildingsEnabled: false,
                                      myLocationEnabled: false,
                                      myLocationButtonEnabled: false,
                                    )
                                  : Stack(
                                      children: [
                                        fm.FlutterMap(
                                          mapController: context
                                              .read<AccBloc>()
                                              .fmController,
                                          options: fm.MapOptions(
                                              initialCenter: fmlt.LatLng(
                                                  double.parse(
                                                      arg.historyData.dropLat),
                                                  double.parse(
                                                      arg.historyData.dropLng)),
                                              initialZoom: 10,
                                              onTap: (P, L) {}),
                                          children: [
                                            fm.TileLayer(
                                              urlTemplate:
                                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                              userAgentPackageName:
                                                  'com.example.app',
                                            ),
                                            fm.PolylineLayer(
                                              polylines: [
                                                fm.Polyline(
                                                    points: context
                                                        .read<AccBloc>()
                                                        .fmpoly,
                                                    color: Theme.of(context).primaryColor,
                                                    strokeWidth: 4),
                                              ],
                                            ),
                                            fm.MarkerLayer(markers: [
                                              fm.Marker(
                                                  width: 250,
                                                  height: 60,
                                                  alignment: Alignment.center,
                                                  point: fmlt.LatLng(
                                                      double.parse(arg
                                                          .historyData.pickLat),
                                                      double.parse(arg
                                                          .historyData
                                                          .pickLng)),
                                                  child: Image.asset(
                                                    AppImages.pickupIcon,
                                                    height: 50,
                                                    fit: BoxFit.contain,
                                                  )),
                                              if (arg.historyData
                                                          .requestStops ==
                                                      null &&
                                                  arg.historyData.dropLat !=
                                                      'null')
                                                fm.Marker(
                                                    width: 250,
                                                    height: 60,
                                                    alignment: Alignment.center,
                                                    point: fmlt.LatLng(
                                                        double.parse(arg
                                                            .historyData
                                                            .dropLat),
                                                        double.parse(arg
                                                            .historyData
                                                            .dropLng)),
                                                    child: const Icon(
                                                      Icons.location_on_rounded,
                                                      size: 50,
                                                    )),
                                              if ((arg.historyData
                                                      .requestStops !=
                                                  null))
                                                for (var i = 0;
                                                    i <
                                                        arg
                                                            .historyData
                                                            .requestStops!
                                                            .length;
                                                    i++)
                                                  fm.Marker(
                                                      width: 250,
                                                      height: 60,
                                                      alignment:
                                                          Alignment.center,
                                                      point: fmlt.LatLng(
                                                          double.parse(arg
                                                              .historyData
                                                              .requestStops![i]
                                                                  ['latitude']
                                                              .toString()),
                                                          double.parse(arg
                                                              .historyData
                                                              .requestStops![i]
                                                                  ['longitude']
                                                              .toString())),
                                                      child: const Icon(
                                                        Icons
                                                            .location_on_rounded,
                                                        size: 50,
                                                      ))
                                            ])
                                          ],
                                        ),
                                        Positioned(
                                            top: 0,
                                            child: Container(
                                              height: size.width * 0.8,
                                              width: size.width,
                                              color: Colors.transparent,
                                            ))
                                      ],
                                    ),
                            );
                          })),
                      SliverList(
                          delegate: SliverChildBuilderDelegate(childCount: 1,
                              (context, index) {
                        return Container(
                          padding: EdgeInsets.all(size.width * 0.03),
                          width: size.width,
                          color: const Color(0xffDEDCDC),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(size.width * 0.05),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        (arg.historyData.isCancelled == 1)
                                            ? MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .cancelled,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                        color: AppColors.red,
                                                        fontWeight:
                                                            FontWeight.w600),
                                              )
                                            : (arg.historyData.isCompleted == 1)
                                                ? MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .fareBreakup,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  )
                                                : Container()
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.width * 0.025,
                                    ),
                                    (arg.historyData.isBidRide == 1 &&
                                            arg.historyData.isCancelled == 0)
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    height: size.width * 0.025,
                                                  ),
                                                  MyText(
                                                      text: (arg.historyData
                                                                  .paymentOpt ==
                                                              '1')
                                                          ? AppLocalizations.of(
                                                                  context)!
                                                              .cash
                                                          : (arg.historyData
                                                                      .paymentOpt ==
                                                                  '2')
                                                              ? AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .wallet
                                                              : (arg.historyData
                                                                          .paymentOpt ==
                                                                      '0')
                                                                  ? AppLocalizations.of(
                                                                          context)!
                                                                      .card
                                                                  : '',
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .displayLarge),
                                                  (arg.historyData
                                                              .requestBill ==
                                                          null)
                                                      ? MyText(
                                                          text: (arg.historyData
                                                                      .isBidRide ==
                                                                  1)
                                                              ? '${arg.historyData.requestedCurrencySymbol} ${arg.historyData.acceptedRideFare}'
                                                              : (arg.historyData
                                                                          .isCompleted ==
                                                                      1)
                                                                  ? '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}'
                                                                  : '${arg.historyData.requestedCurrencySymbol} ${arg.historyData.requestEtaAmount}')
                                                      : MyText(
                                                          text:
                                                              '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}',
                                                          textStyle:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .displayLarge)
                                                ],
                                              ),
                                            ],
                                          )
                                        : (arg.historyData.isCancelled == 1)
                                            ? const SizedBox()
                                            : (arg.historyData.requestBill !=
                                                    null)
                                                ? Column(
                                                    children: [
                                                      if (arg
                                                              .historyData
                                                              .requestBill
                                                              .data
                                                              .basePrice !=
                                                          0)
                                                        FareBreakup(
                                                            showBorder: false,
                                                            text: AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .basePrice,
                                                            price:
                                                                '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.basePrice}'),
                                                      if (arg
                                                              .historyData
                                                              .requestBill
                                                              .data
                                                              .distancePrice !=
                                                          0)
                                                        FareBreakup(
                                                            showBorder: false,
                                                            text: AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .distancePrice,
                                                            price:
                                                                '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.distancePrice}'),
                                                      if (arg
                                                              .historyData
                                                              .requestBill
                                                              .data
                                                              .timePrice !=
                                                          0)
                                                        FareBreakup(
                                                            showBorder: false,
                                                            text: AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .timePrice,
                                                            price:
                                                                '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.timePrice}'),
                                                      if (arg
                                                              .historyData
                                                              .requestBill
                                                              .data
                                                              .waitingCharge !=
                                                          0)
                                                        FareBreakup(
                                                            showBorder: false,
                                                            text: AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .waitingPrice,
                                                            price:
                                                                '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.waitingCharge}'),
                                                      if (arg
                                                              .historyData
                                                              .requestBill
                                                              .data
                                                              .adminCommision !=
                                                          0)
                                                        FareBreakup(
                                                            showBorder: false,
                                                            text: AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .convFee,
                                                            price:
                                                                '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.adminCommision}'),
                                                      if (arg
                                                              .historyData
                                                              .requestBill
                                                              .data
                                                              .promoDiscount !=
                                                          0)
                                                        FareBreakup(
                                                          showBorder: false,
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .discount,
                                                          price:
                                                              '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.promoDiscount}',
                                                          textcolor: Theme.of(
                                                                  context)
                                                              .primaryColorDark,
                                                          pricecolor: Theme.of(
                                                                  context)
                                                              .primaryColorDark,
                                                        ),
                                                      FareBreakup(
                                                          showBorder: false,
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .taxes,
                                                          price:
                                                              '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.serviceTax}'),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: List.generate(
                                                          150 ~/ 2,
                                                          (index) => Expanded(
                                                            child: Container(
                                                              height: 2,
                                                              color: index
                                                                      .isEven
                                                                  ? AppColors
                                                                      .textSelectionColor
                                                                      .withOpacity(
                                                                          0.5)
                                                                  : Colors
                                                                      .transparent,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height: size.height *
                                                              0.01),
                                                      (arg.historyData.requestBill !=
                                                                  null &&
                                                              arg.historyData
                                                                      .isBidRide !=
                                                                  1)
                                                          ? Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                bottom:
                                                                    size.width *
                                                                        0.025,
                                                                top:
                                                                    size.width *
                                                                        0.025,
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                      child:
                                                                          Row(
                                                                    children: [
                                                                      MyText(
                                                                        text: AppLocalizations.of(context)!
                                                                            .customerPays,
                                                                        textStyle: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyLarge!
                                                                            .copyWith(),
                                                                      )
                                                                    ],
                                                                  )),
                                                                  Row(
                                                                    children: [
                                                                      MyText(
                                                                        text: (arg.historyData.paymentOpt ==
                                                                                '1')
                                                                            ? AppLocalizations.of(context)!.cash
                                                                            : (arg.historyData.paymentOpt == '2')
                                                                                ? AppLocalizations.of(context)!.wallet
                                                                                : (arg.historyData.paymentOpt == '0')
                                                                                    ? AppLocalizations.of(context)!.card
                                                                                    : '',
                                                                        textStyle: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyLarge!
                                                                            .copyWith(fontWeight: FontWeight.bold),
                                                                      ),
                                                                      SizedBox(
                                                                        width: size.width *
                                                                            0.025,
                                                                      ),
                                                                      (arg.historyData.requestBill ==
                                                                              null)
                                                                          ? Row(
                                                                              children: [
                                                                                MyText(
                                                                                  text: (arg.historyData.isBidRide == 1)
                                                                                      ? '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.acceptedRideFare}'
                                                                                      : (arg.historyData.isCompleted == 1)
                                                                                          ? '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}'
                                                                                          : '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.requestEtaAmount}',
                                                                                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: size.width * 0.045),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : MyText(
                                                                              text: '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}',
                                                                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: size.width * 0.045))
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                    ],
                                                  )
                                                : Container(),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: size.width * 0.02,
                              ),
                              if (arg.historyData.requestBill != null)
                                Container(
                                  padding: EdgeInsets.all(size.width * 0.05),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(children: [
                                    Row(
                                      children: [
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .earnings,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .disabledColor,
                                                fontSize: 14,
                                              ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.03),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Row(
                                            children: [
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .totalFare,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              )
                                            ],
                                          )),
                                          (arg.historyData.requestBill != null)
                                              ? MyText(
                                                  text: (arg.historyData
                                                              .isBidRide ==
                                                          1)
                                                      ? '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.acceptedRideFare}'
                                                      : (arg.historyData
                                                                  .isCompleted ==
                                                              1)
                                                          ? '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}'
                                                          : '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.requestEtaAmount}',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                )
                                              : MyText(
                                                  text: '',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                        ],
                                      ),
                                    ),
                                    if (arg.historyData.requestBill != null)
                                      Padding(
                                        padding: EdgeInsets.only(
                                          bottom: size.width * 0.025,
                                          top: size.width * 0.025,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Row(
                                              children: [
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .customerConvenienceFee,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(),
                                                )
                                              ],
                                            )),
                                            MyText(
                                              text:
                                                  '-${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.adminCommision}',
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: AppColors.red),
                                            )
                                          ],
                                        ),
                                      ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: size.width * 0.025,
                                        top: size.width * 0.025,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Row(
                                            children: [
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .commission,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(),
                                              )
                                            ],
                                          )),
                                          MyText(
                                            text:
                                                '-${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.adminCommisionFromDriver}',
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(color: AppColors.red),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: size.width * 0.025,
                                        top: size.width * 0.025,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Row(
                                            children: [
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .taxText,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(),
                                              )
                                            ],
                                          )),
                                          MyText(
                                            text:
                                                '-${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.serviceTax}',
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(color: AppColors.red),
                                          )
                                        ],
                                      ),
                                    ),
                                    if (arg.historyData.requestBill.data
                                            .promoDiscount !=
                                        0)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .discountFromWallet,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(),
                                                  )
                                                ],
                                              ),
                                            ),
                                            MyText(
                                              text:
                                                  '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.promoDiscount}',
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: AppColors.green),
                                            )
                                          ],
                                        ),
                                      )
                                    else
                                      const SizedBox(),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List.generate(
                                              150 ~/ 2,
                                              (index) => Expanded(
                                                child: Container(
                                                  height: 2,
                                                  color: index.isEven
                                                      ? AppColors
                                                          .textSelectionColor
                                                          .withOpacity(0.5)
                                                      : Colors.transparent,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Row(
                                                children: [
                                                  MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .tripEarnings,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16),
                                                  )
                                                ],
                                              )),
                                              MyText(
                                                text:
                                                    '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.driverCommision}',
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),
                              SizedBox(
                                height: size.width * 0.02,
                              ),
                              Container(
                                padding: EdgeInsets.all(size.width * 0.05),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .tripInfo,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .disabledColor,
                                              fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    if (arg.historyData.userDetail != null)
                                      (arg.historyData.isCancelled == 1)
                                          ? const SizedBox()
                                          : SizedBox(
                                              width: size.width,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height:
                                                            size.width * 0.15,
                                                        width:
                                                            size.width * 0.15,
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Theme.of(
                                                                        context)
                                                                    .scaffoldBackgroundColor,
                                                                image: (arg
                                                                        .historyData
                                                                        .userDetail
                                                                        .data
                                                                        .profilePicture
                                                                        .isEmpty)
                                                                    ? DecorationImage(
                                                                        image: NetworkImage(arg
                                                                            .historyData
                                                                            .userDetail
                                                                            .data
                                                                            .profilePicture),
                                                                        fit: BoxFit
                                                                            .cover)
                                                                    : const DecorationImage(
                                                                        image: AssetImage(
                                                                            AppImages.defaultProfile),
                                                                      )),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            size.width * 0.02,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          MyText(
                                                            text: arg
                                                                .historyData
                                                                .userDetail
                                                                .data
                                                                .name,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .copyWith(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 1,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const PickupIcon(),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: MyText(
                                              overflow: TextOverflow.ellipsis,
                                              text: arg.historyData.pickAddress,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ),
                                        ),
                                        MyText(
                                          text: arg.historyData.cvTripStartTime,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .disabledColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    (arg.historyData.requestStops != null)
                                        ? Column(
                                            children: [
                                              for (var i = 0;
                                                  i <
                                                      arg
                                                              .historyData
                                                              .requestStops!
                                                              .length -
                                                          1;
                                                  i++)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      const DropIcon(),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 5),
                                                          child: MyText(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            text: arg
                                                                    .historyData
                                                                    .requestStops![
                                                                i]['address'],
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall,
                                                          ),
                                                        ),
                                                      ),
                                                      MyText(
                                                        text: arg.historyData
                                                            .cvCompletedAt,
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .disabledColor,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          )
                                        : Container(),
                                    (arg.historyData.dropAddress != "")
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                const DropIcon(),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    child: MyText(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      text: arg.historyData
                                                          .dropAddress,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodySmall,
                                                    ),
                                                  ),
                                                ),
                                                MyText(
                                                  text: arg.historyData
                                                      .cvCompletedAt,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                        color: Theme.of(context)
                                                            .disabledColor,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              Container(
                                padding: EdgeInsets.all(size.width * 0.05),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  image: arg
                                                          .historyData
                                                          .vehicleTypeImage
                                                          .isNotEmpty
                                                      ? DecorationImage(
                                                          image: NetworkImage(arg
                                                              .historyData
                                                              .vehicleTypeImage),
                                                        )
                                                      : const DecorationImage(
                                                          image: AssetImage(
                                                              AppImages
                                                                  .noImage),
                                                        ),
                                                  shape: BoxShape.circle,
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor,
                                                ),
                                              ),
                                              MyText(
                                                text: arg.historyData
                                                    .vehicleTypeName,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .typeOfRide,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color: Theme.of(context)
                                                          .hintColor,
                                                    ),
                                              ),
                                              MyText(
                                                text: (arg.historyData
                                                            .isRental ==
                                                        false)
                                                    ? (arg.historyData
                                                                .isOutStation ==
                                                            1)
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .outStation
                                                        : (arg.historyData
                                                                    .isLater ==
                                                                true)
                                                            ? AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .rideLater
                                                            : AppLocalizations
                                                                    .of(context)!
                                                                .regular
                                                    : '${AppLocalizations.of(context)!.rental}-${arg.historyData.rentalPackageName}',
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13),
                                              ),
                                              if(arg.historyData
                                                                .isOutStation ==
                                                            1)
                                               MyText(
                                                  text: (arg.historyData.isOutStation == 1 && arg.historyData.isRoundTrip != '')
                                                      ? AppLocalizations.of(context)!.roundTrip
                                                      : AppLocalizations.of(context)!.oneWayTrip,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        color: AppColors.yellowColor,
                                                      ),
                                                ),
                                                MyText(
                                                text: (arg.historyData.laterRide ==
                                                            true &&
                                                        arg.historyData.isOutStation ==
                                                            1)
                                                    ? arg.historyData.tripStartTime
                                                    : (arg.historyData.laterRide ==
                                                                true &&
                                                            arg.historyData
                                                                    .isOutStation !=
                                                                1)
                                                        ? arg.historyData
                                                            .tripStartTimeWithDate
                                                        : arg.historyData
                                                                    .isCompleted ==
                                                                1
                                                            ? arg.historyData
                                                                .convertedCompletedAt
                                                            : arg.historyData.isCancelled ==
                                                                    1
                                                                ? arg
                                                                    .historyData
                                                                    .convertedCancelledAt
                                                                : arg.historyData
                                                                    .convertedCreatedAt,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: size.width * 0.035,
                                      ),
                                      if (arg.historyData.isCompleted == 1)
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  children: [
                                                    MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .duration,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .hintColor,
                                                              ),
                                                    ),
                                                    MyText(
                                                      text:
                                                          '${arg.historyData.totalTime} ${AppLocalizations.of(context)!.mins}',
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .distance,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .hintColor,
                                                              ),
                                                    ),
                                                    MyText(
                                                      text:
                                                          '${arg.historyData.totalDistance} ${arg.historyData.unit}',
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: size.width * 0.025,
                                            ),
                                          ],
                                        ),
                                      SizedBox(
                                        height: size.width * 0.02,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.width * 0.02,
                              ),
                              Container(
                                  padding: EdgeInsets.all(size.width * 0.05),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .tripId,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .disabledColor,
                                                    fontSize: 14),
                                          ),
                                          MyText(
                                            text: arg.historyData.requestNumber,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                              SizedBox(height: size.width * 0.2),
                            ],
                          ),
                        );
                      })),
                    ],
                  ),
                ),
                if(arg.historyData.isCancelled != 1)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: (arg.historyData.isCompleted == 1)
                      ? Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.report_gmailerrorred,
                                            size: 20, color: AppColors.red),
                                        SizedBox(width: size.width * 0.01),
                                        MyText(
                                            text: AppLocalizations.of(context)!
                                                .reportIssue,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: AppColors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13)),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, ComplaintListPage.routeName,
                                          arguments: ComplaintListPageArguments(
                                              choosenHistoryId: arg
                                                  .historyData.id
                                                  .toString()));
                                    }),
                              ),
                            ),
                          ],
                        )
                      : (arg.historyData.isLater == true &&
                              arg.historyData.isCancelled == 0 &&
                              arg.historyData.isOutStation == 0)
                          ? Container(
                              width: size.width,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                              child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: CustomButton(
                                      width: size.width,
                                      buttonName:
                                          AppLocalizations.of(context)!.cancel,
                                      onTap: () {
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: false,
                                            enableDrag: false,
                                            isDismissible: true,
                                            builder: (_) {
                                              return cancelRide(context, size);
                                            });
                                      })),
                            )
                          : 
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: CustomSliderButton(
                                sliderIcon: Icon(
                                  Icons.keyboard_double_arrow_right_rounded,
                                  color: AppColors.white,
                                  size: size.width * 0.07,
                                ),
                                buttonName:  AppLocalizations.of(context)!.readyToPickup,
                                onSlideSuccess: () async {
                                    context.read<AccBloc>().add(
                                          OutstationReadyToPickupEvent(
                                  requestId: arg.historyData.id));
                                  return true;
                                },
                              ),
                          ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget cancelRide(BuildContext context, Size size) {
    return StatefulBuilder(builder: (_, add) {
      return Container(
        padding: MediaQuery.of(context).viewInsets,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size.width * 0.05),
                topRight: Radius.circular(size.width * 0.05))),
        width: size.width,
        child: Container(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText(
                text: AppLocalizations.of(context)!.cancelRideSure,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
              ),
              SizedBox(
                height: size.width * 0.05,
              ),
              CustomButton(
                  width: size.width * 0.5,
                  buttonName: AppLocalizations.of(context)!.cancel,
                  onTap: () {
                    context.read<AccBloc>().add(
                          RideLaterCancelRequestEvent(
                              requestId: arg.historyData.id),
                        );
                  }),
            ],
          ),
        ),
      );
    });
  }
}

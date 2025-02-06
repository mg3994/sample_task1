import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';

class InvoicePage extends StatefulWidget {
  static const String routeName = '/invoicePage';
  final BuildContext context;
  const InvoicePage({super.key, required this.context});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return builderWidget(size);
  }

  Widget builderWidget(Size size) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {},
      child: BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
        return Scaffold(
          body: Container(),
        );
      }),
    );
  }

  Widget invoiceScreen(Size size, BuildContext context) {
    return Container();
  }
}

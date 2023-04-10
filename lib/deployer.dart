import 'package:flutter/material.dart';
import 'package:yap/yap.dart';

mixin Deployer<X extends StatefulWidget, T extends Object> on State<X> {
  @required
  T deploy();
  late T deployed;

  @required
  void deployBack();

  @override
  void initState() {
    deployed = deploy();
    super.initState();
    then(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    deployBack();
    super.dispose();
  }
}
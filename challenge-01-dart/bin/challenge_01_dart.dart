#!/usr/bin/env dart

import 'package:challenge_01_dart/challenge_01_dart.dart';

void main(List<String> arguments) {
  String? fileName;
  String? command;

  if (arguments.length == 1) {
    fileName = arguments[0];
  } else if (arguments.length == 2) {
    [command, fileName] = arguments;
  }

  ccwc(fileName, command);
}

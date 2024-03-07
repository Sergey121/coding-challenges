import 'dart:io';
import 'package:path/path.dart';
import 'package:challenge_03_dart/challenge_03_dart.dart';

void main(List<String> arguments) {
  Directory directory = Directory('../challenge-03/tests');

  if (directory.existsSync()) {
    List<FileSystemEntity> files = directory.listSync();

    files.sort((a, b) => a.path.compareTo(b.path));

    for (var file in files) {
      if (file is File) {
        String filename = basename(file.path);
        try {
          //TODO: Add support for parsing files with escape characters (pass01)
          String content = file.readAsStringSync();
          jsonParse(content);
          if (filename.startsWith('fail')) {
            print(
                '\x1b[31m[File $filename parsed successfully, but it should not.]\x1b[0m');
          } else {
            print('\x1b[32m[File $filename parsed successfully]\x1b[0m');
          }
        } catch (e) {
          if (filename.startsWith('fail')) {
            print(
                '\x1b[32m[File $filename not parsed successfully, this is ok.]\x1b[0m');
          } else {
            print('\x1b[31m[Error parse file $filename ]\x1b[0m');
          }
        }
      }
    }
  } else {
    print('Directory not found');
    exit(1);
  }
}

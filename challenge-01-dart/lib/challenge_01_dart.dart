import 'dart:async';
import 'dart:convert';
import 'dart:io';

void ccwc(String? path, String? command) async {
  void printResult(dynamic result) {
    if (result is String || result is int) {
      if (path != null && path.isNotEmpty) {
        print('\t$result $path\n');
      } else {
        print('\t$result\n');
      }
    } else {
      throw Exception('Invalid result type');
    }
  }

  if (path == null) {
    int numberOfBytes = 0;
    int countLines = 0;
    int countWords = 0;

    stdin.listen((event) {
      numberOfBytes += event.length;

      var lines = LineSplitter().convert(utf8.decode(event));

      countLines += lines.length;
      for (var line in lines) {
        var trimmed = line.trim();

        if (trimmed.isNotEmpty) {
          countWords += trimmed.split(RegExp(r'\s+')).length;
        }
      }
    }, onDone: () {
      printResult('$countLines\t$countWords\t$numberOfBytes');
    }, onError: (e) {
      throw Exception('Error: $e');
    }, cancelOnError: true);
  } else {
    if (command == null) {
      var bytes = await getNumberOfBytes(path);
      var counter = await findNumberOfLinesAndWords(path);
      printResult('${counter.countLines}\t${counter.countWords}\t$bytes');
    } else {
      switch (command) {
        case '-c':
          int bytes = await getNumberOfBytes(path);
          printResult(bytes);
          break;
        case '-l':
          var counter = await findNumberOfLinesAndWords(path);
          printResult(counter.countLines);
          break;
        case '-w':
          var counter = await findNumberOfLinesAndWords(path);
          printResult(counter.countWords);
          break;
        default:
          throw Exception('Invalid command');
      }
    }
  }
}

class WordAndLinesCounter {
  final int countLines;
  final int countWords;

  WordAndLinesCounter(this.countLines, this.countWords);
}

Future<WordAndLinesCounter> findNumberOfLinesAndWords(String path) async {
  final file = File(path);
  Stream<String> lines =
      file.openRead().transform(utf8.decoder).transform(LineSplitter());

  try {
    int countLines = 0;
    int countWords = 0;
    await for (var line in lines) {
      countLines++;

      var trimmed = line.trim();
      if (trimmed.isNotEmpty) {
        var words = trimmed.split(RegExp(r'\s+'));
        countWords += words.length;
      }
    }
    return WordAndLinesCounter(countLines, countWords);
  } catch (e) {
    throw Exception('Error: $e');
  }
}

Future<int> getNumberOfBytes(String path) async {
  var file = File(path);
  var bytes = await file.readAsBytes();
  return bytes.length;
}

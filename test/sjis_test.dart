import 'package:unittest/unittest.dart';
import '../lib/sjis.dart';
import 'dart:io';

_assertPairs(matcher) {
  var file = new File(r"../tool/asset/sjis-0213-2004-std.txt");
  var lines = file.readAsLinesSync();
  
  // Delete first 21 lines
  lines.removeRange(0, 21);
  expect(lines[0], equals("0x00\tU+0000\t# <control>"));
  
  var convertRegExp = new RegExp(r"0x([0-9A-F]+)\tU\+([0-9A-F]+)\t#.+");
  var singleRegExp = new RegExp(r"0x([0-9A-F]+)[\t ]+#[\t ]+<(doublebytes|reserved)>.*");
  var pairRegExp = new RegExp(r"0x([0-9A-F]+)\tU\+([0-9A-F]+)\+([0-9A-F]+)\t#.+");
  
  for(var line in lines) {
    var match = convertRegExp.firstMatch(line);
    if(match != null) {
      var sjis_code = int.parse(match.group(1), radix: 16);
      var utf_code = int.parse(match.group(2), radix: 16);
      
      matcher(sjis_code, utf_code, line);
      
      continue;
    }
    
    // Ignore single reg exp and pair reg exp.
    match = singleRegExp.firstMatch(line);
    if(match != null) {
      continue;
    }
    match = pairRegExp.firstMatch(line);
    if(match != null) {
      continue;
    }
    expect(false, isTrue, reason: "Illegally formatted line | ${line}");
  }
}

_assertPairsForMS932(matcher) {
  var file = new File(r"../tool/asset/sjis-0213-2004-std.txt");
  var lines = file.readAsLinesSync();
  
  // Delete first 21 lines
  lines.removeRange(0, 21);
  expect(lines[0], equals("0x00\tU+0000\t# <control>"));
  
  var convertRegExp = new RegExp(r"0x([0-9A-F]+).+#.+Windows: U\+([0-9A-F]+)");
  var numOfMatches = 0;
  for(var line in lines) {
    var match = convertRegExp.firstMatch(line);
    if(match != null) {
      var sjis_code = int.parse(match.group(1), radix: 16);
      var utf_code = int.parse(match.group(2), radix: 16);
    
      numOfMatches++;
      matcher(sjis_code, utf_code, line);
    }
  }

  // Num of lines which matches to the pattern is 17
  expect(numOfMatches, equals(17));
}

_convertFromSjisToUtf() {
  _assertPairs((sjis_code, utf_code, line) {    
    var sjis_codes = SJIS.encoder.convert(new String.fromCharCode(utf_code));
    var result = sjis_codes.length > 1 ?
        ((sjis_codes[0] << 8) + sjis_codes[1]) : sjis_codes[0];
    expect(result, equals(sjis_code), reason: "Failed at ${line}");
  });
}

_convertFromUtfToSjis() {
  _assertPairs((sjis_code, utf_code, line) {
    var codes = sjis_code > 255 ? [sjis_code >> 8, sjis_code % 256] : [sjis_code];
    var result = SJIS.decoder.convert(codes);
    expect(result, equals(new String.fromCharCode(utf_code)), reason: "Failed at $line");
  });
}

_convertFromMS932ToUtf() {
  _assertPairsForMS932((ms932_code, utf_code, line) {
    var ms932_codes = MS932.encoder.convert(new String.fromCharCode(utf_code));
    var result = ms932_codes.length > 1 ?
        ((ms932_codes[0] << 8) + ms932_codes[1]) : ms932_codes[0];
    expect(result, equals(ms932_code), reason: "Failed at $line");
  });
}

_convertFromUtfToMS932() {
  _assertPairsForMS932((ms932_code, utf_code, line) {
    var codes = ms932_code > 255 ? [ms932_code >> 8, ms932_code % 256] : [ms932_code];
    var result = MS932.decoder.convert(codes);
    expect(result, equals(new String.fromCharCode(utf_code)), reason: "Failed at $line");
  });
}

void main() {
  test('ConvertFromSjisToUtf', _convertFromSjisToUtf);
  test('ConvertFromUtfToSjis', _convertFromUtfToSjis);
  test('ConvertFromMS932ToUtf', _convertFromMS932ToUtf);
  test('ConvertFromUtfToMS932', _convertFromUtfToMS932);
}
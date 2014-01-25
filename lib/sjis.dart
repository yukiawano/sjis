/**
 * Converters for SJIS(shift_jis)
 * 
 * SjisEncoder and SjisDecoders are extended to implement MS932 d/encoder.
 * Thus they clone the sjis_utf table in constructors of them.
 * Because they patches these table in constructors of MS932 d/encoder.
 */
library sjis;

import 'dart:async';
import "dart:convert";

part 'sjis_utf_map.dart';
part 'ms932_utf_map.dart';
part 'ms932.dart';

const SjisCodec SJIS = const SjisCodec();
const MS932Codec MS932 = const MS932Codec();

/**
 * SjisCodec encodes strings to SJIS code units (bytes) and decodes
 * SJIS code units to strings.
 */
class SjisCodec extends Encoding {
  const SjisCodec();
  
  String get name => "shift_jis";
  
  Converter<String, List<int>> get encoder => new SjisEncoder();
  Converter<List<int>, String> get decoder => new SjisDecoder();
}

/**
 * This class converts Strings to their SJIS code units.
 */
class SjisEncoder extends Converter<String,List<int>> {
  static var _instance = null;
  final Map<int,int> utf_sjis = new Map(); // utf_sjis is generated at constructor of SjisEncoder.
  
  factory SjisEncoder() {
    if(_instance == null) _instance = new SjisEncoder._internal();
    return _instance;
  }
  
  SjisEncoder._internal() {
    g_sjis_utf.keys.forEach((k) {
      utf_sjis[g_sjis_utf[k]] = k;
    });
  }
  
  @override
  List<int> convert(String input) {
    var sjisCodeUnits = [];
    
    input.runes.forEach((codeUnit) {
      if(utf_sjis.containsKey(codeUnit)) {
        int sjisCodeUnit = utf_sjis[codeUnit];
        if(sjisCodeUnit < 256) {
          sjisCodeUnits.add(sjisCodeUnit);
        } else {
          sjisCodeUnits.add(sjisCodeUnit >> 8);
          sjisCodeUnits.add(sjisCodeUnit & 255);
        }
      } else {
        throw new FormatException(
            "Couldn't find corresponding code to U+${codeUnit.toRadixString(16)}");
      }
    });
    
    return sjisCodeUnits;
  }
  
  // Override the base-classes bind, to provide a better type.
  Stream<List<int>> bind(Stream<String> stream) => super.bind(stream);
}

/**
 * This class converts SJIS code units to a string.
 */
class SjisDecoder extends Converter<List<int>, String> {
  final sjis_utf = new Map<int,int>();
  static var _instance = null;
  
  factory SjisDecoder() {
    if(_instance == null) _instance = new SjisDecoder._internal();
    return _instance;
  }
  
  SjisDecoder._internal() {
    sjis_utf.addAll(g_sjis_utf);
  }
  
  @override
  String convert(List<int> input) {
    var stringBuffer = new StringBuffer();
    
    addToBuffer(var charCode) {
      if(sjis_utf.containsKey(charCode)) {
        stringBuffer.writeCharCode(sjis_utf[charCode]);
      } else {
        throw new FormatException("Bad encoding 0x${charCode.toRadixString(16)}"); 
      }
    };
    
    for(int i = 0; i < input.length; i++) {
      var byte = input[i];
      
      if(g_double_bytes.contains(byte)) {
        // Double byte char
        i++;
        
        if(i >= input.length) {
          throw new FormatException("Bad encoding 0x${byte.toRadixString(16)}");
        }
        
        var doubleBytes = (byte << 8) + input[i];
        addToBuffer(doubleBytes);
      } else {
        addToBuffer(byte);
      }
    }
      
    return stringBuffer.toString();
  }
  
  // Override the base-classes bind, to provide a better type.
  Stream<String> bind(Stream<List<int>> stream) => super.bind(stream);
}
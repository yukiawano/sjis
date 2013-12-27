/**
 * Converters for SJIS(shift_jis)
 */
library sjis;

import 'dart:async';
import "dart:convert";

part 'sjis_utf_map.dart';

const SjisCodec SJIS = const SjisCodec();

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
  static Map<int,int> utf_sjis = null; // utf_sjis is generated at constructor of SjisEncoder.
  
  SjisEncoder() {
    if(utf_sjis != null) return;
    
    // Convert sjis_utf map to utf_sjis map
    utf_sjis = new Map();
    sjis_utf.keys.forEach((k) {
      utf_sjis[sjis_utf[k]] = k;
    });
  }
  
  @override
  List<int> convert(String input) {
    var sjisCodeUnits = [];
    
    input.codeUnits.forEach((codeUnit) {
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
            "Couldn't find corresponding SJIS code to U+${codeUnit.toRadixString(16)}");
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
  const SjisDecoder();
  
  @override
  String convert(List<int> input) {
    StringBuffer stringBuffer = new StringBuffer();
    
    int codeUnit = 0;
    
    for(int i = 0; i < input.length; i++) {
      int byte = input[i];
      
      if(codeUnit != 0) {
        codeUnit = (codeUnit << 8) + byte;
        if(sjis_utf.containsKey(codeUnit)) {
          int utf = sjis_utf[codeUnit];
          stringBuffer.writeCharCode(utf);
          codeUnit = 0;
        } else {
          throw new FormatException("Bad SJIS encoding 0x${codeUnit.toRadixString(16)}");
        }
      } else {
        if(sjis_utf.containsKey(byte)) {
          stringBuffer.writeCharCode(sjis_utf[byte]);
        } else {
          codeUnit = byte;
        }
      }
    }
    return stringBuffer.toString();
  }
  
  // Override the base-classes bind, to provide a better type.
  Stream<String> bind(Stream<List<int>> stream) => super.bind(stream);
}
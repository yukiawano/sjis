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
  final Map<int, int> sjis_utf;

  SjisDecoder([this.sjis_utf = g_sjis_utf]);

  @override
  String convert(List<int> input) {
    var buffer = new StringBuffer();
    var unfinishedByte = _decode(input, buffer);
    if (unfinishedByte != null)
      throw new FormatException("Bad encoding 0x${unfinishedByte.toRadixString(16)}");
    return buffer.toString();
  }

  @override
  ByteConversionSink startChunkedConversion(Sink<String> sink) {
    return SjisDecoderSink(sink is StringConversionSink ? sink : StringConversionSink.from(sink));
  }
  
  // Override the base-classes bind, to provide a better type.
  Stream<String> bind(Stream<List<int>> stream) => super.bind(stream);
}

class SjisDecoderSink extends ByteConversionSinkBase {
  Sink<String> _output;
  int _unfinishedByte;

  SjisDecoderSink(this._output);

  @override
  void add(List<int> chunk) {
    var buffer = StringBuffer();
    _unfinishedByte = _decode(chunk, buffer, _unfinishedByte);
    _output.add(buffer.toString());
  }

  @override
  void close() {
    if (_unfinishedByte != null)
      throw new FormatException("Bad encoding 0x${_unfinishedByte.toRadixString(16)}");
    _output.close();
  }
}

int _decode(List<int> input, StringBuffer buffer, [int unfinishedByte]) {
  
  addToBuffer(var charCode) {
    if(g_sjis_utf.containsKey(charCode)) {
      buffer.writeCharCode(g_sjis_utf[charCode]);
    } else {
      throw new FormatException("Bad encoding 0x${charCode.toRadixString(16)}"); 
    }
  };
  
  for(int i = unfinishedByte != null ? -1 : 0; i < input.length; i++) {
    var byte = i == -1 ? unfinishedByte : input[i];
    
    if(g_double_bytes.contains(byte)) {
      // Double byte char
      i++;
      
      if(i >= input.length) {
        return byte;
      }
      
      var doubleBytes = (byte << 8) + input[i];
      addToBuffer(doubleBytes);
    } else {
      addToBuffer(byte);
    }
  }
    
  return null;
}

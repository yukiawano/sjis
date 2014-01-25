part of sjis;

/**
 * MS932 is an extension of SJIS. Code units of 6 characters are different from SJIS.
 * Reference: http://www2d.biglobe.ne.jp/~msyk/cgi-bin/charcode/59.html
 */
class MS932Codec extends Encoding {
  const MS932Codec();
  
  String get name => "Windows-31J";

  Converter<String, List<int>> get encoder => new MS932Encoder();
  Converter<List<int>, String> get decoder => new MS932Decoder();
}

/**
 * This class converts Strings to their MS932 code units.
 */
class MS932Encoder extends SjisEncoder {
  static var _instance = null;
  
  factory MS932Encoder() {
    if(_instance == null) _instance = new MS932Encoder._internal();
    return _instance;
  }
  
  MS932Encoder._internal(): super._internal() {
    utf_sjis.addAll(new Map.fromIterables(g_ms932_utf.values, g_ms932_utf.keys));   
  }  
}

/**
 * This class converts MS932 code units to a string.
 */
class MS932Decoder extends SjisDecoder {
  static var _instance = null;
  
  factory MS932Decoder() {
    if(_instance == null) _instance = new MS932Decoder._internal();
    return _instance;
  }
  
  MS932Decoder._internal(): super._internal() {
    sjis_utf.addAll(g_ms932_utf);
  }
}
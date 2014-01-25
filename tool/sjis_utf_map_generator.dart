/**
 * Generator to generate a map which converts from sjis code to utf code.
 */
import "dart:io";

main() {
  var file = new File(r"asset/sjis-0213-2004-std.txt");
  
  var ms932ConvertRegExp = new RegExp(r"0x([0-9A-F]+).+#.+Windows: U\+([0-9A-F]+)");
  var doubleByteRegExp = new RegExp(r"0x([0-9A-F]+)[\t ]+# <doublebytes>");
  var convertRegExp = new RegExp(r"0x([0-9A-F]+)\tU\+([0-9A-F]+)\t# .+");
  file.readAsLines().then((data) {
    StringBuffer str = new StringBuffer();
    str.writeln("part of sjis;");
    str.writeln("// This map is generated from http://x0213.org/codetable/sjis-0213-2004-std.txt , http://x0213.org/codetable/.");
    str.write("final g_sjis_utf={");
    
    var doubleBytes = [];
    var ms932Utf = {};
    
    data.forEach((line) {
      var match = convertRegExp.firstMatch(line);
      if(match != null) {
        var sjis_code = int.parse(match.group(1), radix: 16);
        var utf_code = int.parse(match.group(2), radix: 16);
        
        str.write("$sjis_code:$utf_code,");
      }
      
      var doubleByteMatch = doubleByteRegExp.firstMatch(line);
      if(doubleByteMatch != null) {
        doubleBytes.add(int.parse(doubleByteMatch.group(1), radix: 16));
      }
      
      match = ms932ConvertRegExp.firstMatch(line);
      if(match != null) {
        ms932Utf[int.parse(match.group(1), radix:16)] =
            int.parse(match.group(2), radix: 16);
      }
    });
    str.write("};");
    print("Copy and paste below to lib/sjis_utf_map.dart \n===");
    print(str);
    print("final g_double_bytes = [${doubleBytes.join(",")}];");
    
    var ms932_utf = "part of sjis;\n" +
      "final g_ms932_utf={" + 
      ms932Utf.keys
        .map((k) => "$k:${ms932Utf[k]},")
        .join() +
      "};";
    
    print("\nCopy and paste below to lib/ms932_utf_map.dart \n===");
    print(ms932_utf);
  });
 }

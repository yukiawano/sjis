/**
 * Generator to generate a map which converts from sjis code to utf code.
 */
import "dart:io";

main() {
  var file = new File(r"asset/sjis-0213-2004-std.txt");
  
  var convertRegExp = new RegExp(r"0x([0-9A-F]+)\tU\+([0-9A-F]+)\t# .+");
  file.readAsLines().then((data) {
    StringBuffer str = new StringBuffer();
    str.writeln("part of sjis;");
    str.writeln("// This map is generated from http://x0213.org/codetable/sjis-0213-2004-std.txt , http://x0213.org/codetable/.");
    str.write("var sjis_utf={");
    
    data.forEach((line) {
      var match = convertRegExp.firstMatch(line);
      if(match != null) {
        var sjis_code = int.parse(match.group(1), radix: 16);
        var utf_code = int.parse(match.group(2), radix: 16);
        
        str.write("$sjis_code:$utf_code,");
      }
    });
    str.write("};");
    print("Copy and paste below to lib/sjis_utf_map_generator.\n===");
    print(str);
  });
 }

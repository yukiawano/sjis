SJIS
-----
[![Build Status](https://drone.io/github.com/yukiawano/sjis/status.png)](https://drone.io/github.com/yukiawano/sjis/latest)

Converter for SJIS(shift_jis) and MS932(Windows-31J).

Convertion table(Hash map) from SJIS code unit to UTF code unit is hard-corded in sjis_utf_map.dart.
Hash map from UTF code unit to SJIS code unit is generated in the constructor of SjisEncoder(Converts from String to Sjis code units).

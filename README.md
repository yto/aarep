# aarep

Amazonアソシエイトのレポートを分析する簡単ツール

perl aarep.pl -u UNIT -m MODE INPUT.csv

INPUT: 対象（入力）ファイル

アソシエイトのページからダウンロードできる、注文または売上のCSVファイル。
zipファイルとしてダウンロードできるのでそれを解凍、すると拡張子csvのCSVファイルが出てくる。それ。

以下、説明のため、
例えば2017年7月分の注文データのCSVファイル
15...Fee-Order....csv は FO201707.csv、
同じく売上のCSVファイルは
FE201707.csv という名前に変えて扱う。

出力単位: "-u" で指定。

- y : 年単位
- ym : 年月
- ymd : 年月日
- ymdh : 年月日時
- h : 時
- hm : 時分
- hms : 時分秒
- w : 曜日

モード: "-m" で指定。

- i : item。ASIN単位で表示
- t : traking id。XXX-22などの。
- s : ストア
- d : デバイス







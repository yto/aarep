# aarep

Amazonアソシエイトのレポートを分析する簡単ツール

```
perl aarep.pl -u UNIT -m MODE -d DATE INPUT.csv
```

- INPUT: 対象（入力）ファイル
  - アソシエイトのページからダウンロードできる、注文または売上のCSVファイル。
  - zipファイルとしてダウンロードできるのでそれを解凍、すると拡張子csvのCSVファイルが出てくる。それ。
  - 以下、説明のため、例えば2017年7月分の注文データのCSVファイル15...Fee-Order....csv は FO201707.csv、同じく売上のCSVファイルはFE201707.csv という名前に変えて扱う。
- 出力単位: "-u" で指定。
  - y : 年単位
  - ym : 年月
  - ymd : 年月日
  - ymdh : 年月日時
  - h : 時
  - hm : 時分
  - hms : 時分秒
  - w : 曜日
  - wh : 曜日x時
- モード: "-m" で指定。
  - i : item。ASIN単位で表示
  - t : traking id。XXX-22などの。
  - s : ストア
  - d : デバイス
  - "," でつなぐことができる : i,t i,t,s など
- 日付指定: "--date", "-d" で指定。
  - 日付（年、年月、年月日）の指定を行う。
  - 例: "2017-09", "2017-09-10", "2017-09-(1[5-9]|20)"

## 実行例

出力サンプルには架空のデータを用いています。

売上：2017年7月の商品数と紹介料の合計
```
perl aarep.pl FE201707.csv
all	497	17598
```

売上：2017年7月7日の商品数と紹介料の合計
```
perl aarep.pl --date 2017-07-07 FE201707.csv
all	66	1826
```

注文：2017年7月の商品数と売上高（価格）の合計
```
perl aarep.pl FO201707.csv
all	501	287949
```

売上：2016年の月ごとの商品数と紹介料
```
aarep.pl -u ym FE2016.csv
2016-01	1320	36761
2016-02	244	9473
2016-03	214	8444
2016-04	221	9579
2016-05	245	10051
2016-06	691	10297
2016-07	408	13693
2016-08	774	31069
2016-09	1362	43736
2016-10	2807	97682
2016-11	1351	72919
2016-12	2543	90049
```

売上：2017年7月の日別の商品数と紹介料
```
aarep.pl -u ymd FE201707.csv
2017-07-01	243	7475
2017-07-02	269	8009
2017-07-03	265	8896
2017-07-04	317	8670
2017-07-05	266	6714
2017-07-06	256	6291
2017-07-07	266	8265
2017-07-08	291	8845
```

注文：2017年7月の時間別の注文数と価格合計
```
aarep.pl -u h FO201707.csv
00	325	161568
01	203	113887
02	123	73227
03	78	34152
04	52	26497
05	58	64782
...
21	435	226965
22	454	254015
23	501	258738
```

注文：2017年1-6月の曜日別の注文数と価格合計
```
aarep.pl -u w FO2017H1.csv
Sun	289	165983
Mon	193	96964
Tue	175	85747
Wed	197	102262
Thu	226	125493
Fri	327	188071
Sat	294	168263
```

注文：2017年7月の商品の注文数ランキング（注文数と価格）
```
aarep.pl -m i FO201707.csv
all	B00KYEH7GW	15	1070	メイドインアビス（１） (バンブーコミックス)
all	B06ZZH4CKN	14	1400	海外ドラマはたった350の単語でできている
all	B00O438BF0	14	430	ラーメン大好き小泉さん（１） (バンブーコミックス)
...
```

売上：2017年7月の商品の売上ランキング（売上数と紹介料）
```
aarep.pl -m i FE201707.csv
all	B00KYEH7GW	15	85	メイドインアビス（１） (バンブーコミックス)
all	B06ZZH4CKN	14	100	海外ドラマはたった350の単語でできている
all	B00O438BF0	14	35	ラーメン大好き小泉さん（１） (バンブーコミックス)
...
```

売上：2017年7月のトラッキングID別売上ランキング（売上数と紹介料）
```
aarep.pl -m t FE201707.csv
all	example1-22	205	6992
all	example0-22	142	4872
all	example5-22	85	2901
...
```

売上：2017年7月のストア別売上ランキング（売上数と紹介料）
```
aarep.pl -m s FE201707.csv
all	本	53	1816
all	ドラッグストア・ビューティー	44	2749
all	食品＆飲料	31	3456
...
```

売上：2017年7月のデバイス別売上ランキング（売上数と紹介料）
```
aarep.pl -m d FE201707.csv
all	DESKTOP	262	9616
all	PHONE	174	5895
all	TABLET	61	2086
```

売上：特定のトラッキングIDでの商品売上ランキングを得る
```
aarep.pl -m i,t FE201707.csv | grep example4-22
all	B002RUYBUQ	example4-22	3	150	サクセス ステップカラー 110g
all	B01BWK3SOQ	example4-22	3	75	トクホ 江崎グリコ ポスカ<グレープ>エコパウチ 初期虫歯対策ガム 75g
all	B00Z60G3P0	example4-22	2	16	マルちゃん 麺づくり鶏だし塩 86g
...
```

売上：特定の日付での商品売上ランキングを得る
```
aarep.pl -u ymd -m i FE201707.csv | grep 2017-07-07
2017-07-07	B06XNVS99T	5	120	ちおちゃんの通学路　6 (コミックフラッパー)
2017-07-07	B072N7Q34M	5	385	ひきこもらない (幻冬舎単行本)
2017-07-07	B009KWUN7Y	4	28	行け！稲中卓球部（１） (ヤングマガジンコミックス)
...
```




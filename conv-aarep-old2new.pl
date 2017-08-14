#!/usr/bin/env perl
# -*- coding: utf-8 -*-
# 2016年よりも前の売上レポートCSVを現行フォーマットに変換する
use strict;
use warnings;
use utf8;
use open ":utf8";
binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my @_month_names = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
my %month = map {$_month_names[$_] => $_ + 1} 0..11;

my $sep = "\t";
my @labels;
while (<>) {
    chomp;
    if (/^売上レポート /) {
	print "Fee-Earnings reports from ...\n";
	next;
    } elsif (/^ストア$sep/) {
	@labels = map {s/\(.+?\)$//; s/\s+$//; $_} split($sep, $_);
	print join(",", @labels)."\n";
	next;
    }
    my @c = split($sep, $_);
    next if @c <= 1;
    my %h = map {$labels[$_] => $c[$_]} 0..$#c;

    my ($mn, $d, $y) = split(/[ ,]+/, $h{発送日});
    my $m = sprintf("%02d", $month{substr($mn, 0, 3)});
    $h{発送日} = "$y-$m-$d";
    $h{商品名} =~ s/,/，/g;
    $h{紹介料率} =~ s/\%.*$//;

    print join(",", map {$h{$_}} @labels)."\n";
}


#!/usr/bin/env perl
# -*- coding: utf-8 -*-
use strict;
use warnings;
use Getopt::Long;
use Time::Local;
use POSIX qw(strftime);
use utf8;
use open ":utf8";
binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my $unit_time = "all";
# y:year, ym:month, ymd:day, w:dow, h:hour,
# hm:hour-min, hms:hour-min-sec,
# ymdh, ymdhm, ymdhms, wh, all:all
my $mode = ""; 
# "":count, i:item, t:trackingid, s:store, d:device"
my $date = "";
# 日付（年、年月、年月日）の指定： -date "2017-09-10", -date "2017-09-(1[5-9]|20)"

GetOptions(
    "unit=s" => \$unit_time,
    "mode=s" => \$mode,
    "date=s" => \$date,
    );

my @mode_ids = map {
    /^t/ ? "トラッキングID"
	: /^s/ ? "ストア"
	: /^i/ ? "ASIN"
	: /^d/ ? "デバイスの種類"
	: /^n/ ? "商品リンク経由" # only "o"
	: ""
} split(/,/, $mode);

my $report_type = "e"; # e:ernings, o:orders
my $sep = ",";

my @labels;
my %stat;
my %line_seen;
while (<>) {
    chomp;
    next if defined $line_seen{$_};
    $line_seen{$_} = 1;
    if (/^Fee-(.).+? reports from/) {
	$report_type = lc($1); # "e" or "o"
	next;
    } elsif (/^ストア$sep/) {
	@labels = map {s/\(.+?\)$//; s/\s+$//; $_} split($sep, $_);
	next;
    }
    my @c = split($sep, $_);
    #    next if @c < 11 or $c[4] !~ /-22$/;
    next if @c <= 1;
    my %h = map {$labels[$_] => $c[$_]} 0..$#c;
    my ($y, $m, $d, $H, $M, $S);
    if ($report_type eq "e") {
#	($y, $m, $d) = $h{発送日} =~ /^(\d+)-(\d+)-(\d+)/;
	my $_hms;
	($y, $m, $d, $_hms, $H, $M, $S) = $h{発送日} =~ /^(\d+)-(\d+)-(\d+)( (\d+):(\d+):(\d+))?/;
	$H ||= 0;
	$M ||= 0;
	$S ||= 0;
    } elsif ($report_type eq "o") {
	($y, $m, $d, $H, $M, $S) = $h{日付} =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)/;
    } else {
	die "bad report type [$report_type]";
    }
    next if $date and "$y-$m-$d" !~ /^$date/;
    my $dow = (localtime timelocal(0,0,0,$d,$m-1,$y))[6];
    my $str = $unit_time eq "ymd" ? "$y-$m-$d"
	: $unit_time eq "ym" ? "$y-$m"
	: $unit_time eq "y" ? "$y"
	: $unit_time eq "w" ? $dow
	: $unit_time eq "wh" ? "$dow-$H"
	: $unit_time eq "h" ? "$H"
	: $unit_time eq "hm" ? "$H:$M"
	: $unit_time eq "hms" ? "$H:$M:$S"
	: $unit_time eq "ymdh" ? "$y-$m-$d $H"
	: $unit_time eq "ymdhm" ? "$y-$m-$d $H:$M"
	: $unit_time eq "ymdhms" ? "$y-$m-$d $H:$M:$S"
	: "all";
    my $keys = join("\t", map {$h{$_}} @mode_ids);
    if ($report_type eq "e") {
	my $num = $h{発送済み商品} - ($h{返品済み商品}||0);
	if (defined $h{売上}) {
	    $stat{$unit_time}{$str}{$keys}{Gross} += $h{売上};
	} else {
	    $stat{$unit_time}{$str}{$keys}{Gross} += $h{価格} * $num;
	}
	$stat{$unit_time}{$str}{$keys}{Income} += $h{紹介料};
	$stat{$unit_time}{$str}{$keys}{Num} += $num;
    } elsif ($report_type eq "o") {
	$stat{$unit_time}{$str}{$keys}{Gross} += $h{価格} * $h{数量};
	$stat{$unit_time}{$str}{$keys}{Num} += $h{数量};
    }
    $stat{$unit_time}{$str}{$keys}{Name} = $h{商品名};
}

foreach my $t (sort keys %{$stat{$unit_time}}) {
    my $r = $stat{$unit_time}{$t};
    my @res;
    foreach my $i (sort keys %$r) {
	next if $r->{$i}{Num} <= 0;
	my @info;
	push @info, $i if $i ne "";
#	push @info, (qw(Sun Mon Tue Wed Thu Fri Sat))[$i] 

	push @info, $r->{$i}{Num};
	push @info, $r->{$i}{Income} if $report_type eq "e";
	push @info, $r->{$i}{Gross};
	if (grep {/^ASIN/} @mode_ids) {
	    push @info, $r->{$i}{Name};
	} else {
#	    my $tanka = $r->{$i}{Num} ? $r->{$i}{Income}/$r->{$i}{Num} : 0;
#	    push @info, int($tanka*100)/100;
	}
	push @res, \@info;
    }
    foreach my $i (sort {$b->[1] <=> $a->[1]} @res) {
	my $l = $unit_time eq "w"
	    ? (qw(Sun Mon Tue Wed Thu Fri Sat))[$t] : $t;
	print join("\t", $l, @$i)."\n";
    }
}

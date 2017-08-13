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
# y:year, ym:month, ymd:day, w:dow, h:hour, hm:hour-min, all:all
my $mode = ""; 
# "":count, i:item, t:trackingid, :sstore, d:device"

GetOptions(
    "unit=s" => \$unit_time,
    "mode=s" => \$mode,
    );

my @mode_ids = map {
    /^t/ ? "トラッキングID"
	: /^s/ ? "ストア"
	: /^i/ ? "ASIN"
	: /^d/ ? "デバイスの種類"
	: ""
} split(/,/, $mode);

my $report_type = "e"; # e:ernings, o:orders
my $sep = ",";

my @labels;
my %stat;
while (<>) {
    chomp;
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
	($y, $m, $d) = $h{発送日} =~ /^(\d{4})-(\d{2})-(\d{2})/;
    } elsif ($report_type eq "o") {
	($y, $m, $d, $H, $M, $S) = $h{日付} =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)/;
    } else {
	die "bad report type [$report_type]";
    }
    my $dow = (localtime timelocal(0,0,0,$d,$m-1,$y))[6];
    my $str = $unit_time eq "ymd" ? "$y-$m-$d"
	: $unit_time eq "ym" ? "$y-$m"
	: $unit_time eq "y" ? "$y"
	: $unit_time eq "w" ? $dow
	: $unit_time eq "wh" ? "$dow-$H"
	: $unit_time eq "h" ? "$H"
	: $unit_time eq "hm" ? "$H:$M"
	: $unit_time eq "hms" ? "$H:$M:$S"
	: $unit_time eq "ymdh" ? "$y-$m-$d-$H"
	: "all";
    my $keys = join("\t", map {$h{$_}} @mode_ids);
    if ($report_type eq "e") {
	$stat{$unit_time}{$str}{$keys}{Income} += $h{紹介料};
	$stat{$unit_time}{$str}{$keys}{Num} += $h{発送済み商品} - ($h{返品済み商品}||0);
    } elsif ($report_type eq "o") {
	$stat{$unit_time}{$str}{$keys}{Income} += $h{価格};
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
	push @info, $r->{$i}{Income};
	if (grep {/^ASIN/} @mode_ids) {
	    push @info, $r->{$i}{Name};
	} else {
	    my $tanka = $r->{$i}{Num} ? $r->{$i}{Income}/$r->{$i}{Num} : 0;
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

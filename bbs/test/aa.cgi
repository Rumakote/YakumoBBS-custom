#!/usr/bin/perl --

use utf8;
$call = 'aa.cgi';
require './sub/common.pl';	#初期設定と共通サブルーチン
if ($ifo{'img_lib'} == 1) {
	require './sub/a1.pl';
} elsif ($ifo{'img_lib'} == 2) {
	require './sub/a2.pl';
}
require './sub/ac.pl';

cgi_main();
exit(0);

sub cgi_main{
	my $size;
	($opt,$bbs,$key,$opt) = split( /\//,$ENV{'PATH_INFO'});
	my ($num) = $opt =~ /(\d+)/;
	if (index($opt,'w') < 0) {
		$size = 1;
	} else {
		$size = 2;
	}
	my $str;
	if(open(LOG,"< ../$bbs/dat/$key.dat")) {
#		flock(LOG,1);
		my $fpt;
		if ($fpt = get_index($num)) {
			if ($num == 1) {$fpt = 0;}
			seek(LOG,$fpt,0);
			($str,$str,$str,$str) = split(/<>/,<LOG>);
		}
		close(LOG);
	}
	my $sp = enc_str($sp = '　');	#全角スペース
	$str =~ s/(?:\s|$sp|<br>)+$//;	#文末の余分な改行とスペースの除去
	my @text = html_txt($str);
	my $width = shift(@text) * 10;
	my $height = @text * 18;
	img_init($width,$height);
	my @pos = img_str(2,$width,$height,@text);
	if ($pos[0] > 0 && $pos[0] < 240 * $size) {
		$pos[0] /= 2;
		my $big = int($size * 240 / $pos[0] + 0.999);
		if ($big > 16) {$big =16;}
		$width *= $big;
		$height *= $big;
		img_del($width / 2,$height / 2);
		@pos = img_str($big,$width / 2,$height / 2,@text);
	}
	img_resize($size,@pos);
	img_print();
	exit(0);
}

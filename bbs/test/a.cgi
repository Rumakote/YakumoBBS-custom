#!/usr/bin/perl

use utf8;
$call = 'a.cgi';
require './sub/common.pl';	#初期設定と共通サブルーチン

cgi_main();
exit(0);

sub cgi_main {
	my $pathinfo = $ENV{'PATH_INFO'};
	($opt,$bbs,$key,$opt) = split( /\//,$pathinfo);
	my $re;
	{my $cgi = new CGI;
	$re = $cgi->param('re');}
	my ($num) = $opt =~ /(\d+)/;
	my $name;
	my $info;
	if(open(LOG,"< ../$bbs/dat/$key.dat")) {
#		flock(LOG,1);
		my $fpt;
		if ($fpt = get_index($num)) {
			if ($num == 1) {$fpt = 0;}
			seek(LOG,$fpt,0);
			($name,$info,$info) = split(/<>/,<LOG>);
		}
		close(LOG);
	}
	print "Content-type: text/html\n\n";
	print '<html>';
	print '<head>';
	print '<meta http-equiv="Content-Type" content="text/html; charset=shift_jis">';
	print '<title>AA</title>';
	print '</head>';
	print '<body>';
	if ($info ne '') {
		$name =~ s/<.*?>//g;	#htmlタグ削除
		print val_sjis("$num:$name $info<hr>");
		print "<center><img src=../../../aa.cgi$pathinfo border=0></a><br>";
	} else {
		print enc_sjis("$bbs/$key/$num/$name レスが見付かりませんでした。<br><center>");
	}
#	if(index($re,'a') < 0) {$re .= 'a';}
	print "<hr><a href=$num",(index($opt,'w') < 0 ? "w\?re=$re>480px" : "\?re=$re>240px"),'</a> ';
	print "<a href=../../../r.cgi/$bbs/$key/$re>",enc_sjis('戻る'),'</a>';
	print '</center></body>';
	print '</html>';
}

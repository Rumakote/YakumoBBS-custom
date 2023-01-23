#!/usr/bin/perl --

use utf8;
$call = 'h.cgi';
require './sub/common.pl';	#初期設定と共通サブルーチン

$bbs = substr($ENV{'PATH_INFO'},1);	#引数の取得
$text = val_sjis(read_file("../$bbs/head.txt"));
print "Content-type: text/html\n\n";
print '<html>';
print '<head>';
print '<meta http-equiv="Content-Type" content="text/html; charset=shift_jis">';
print '<title>local rule</title>';
print '<body>';
print $text;
print "<a href=../m.cgi/$bbs/>".enc_sjis('戻る').'</a>';
print '</body></html>';
exit(0);

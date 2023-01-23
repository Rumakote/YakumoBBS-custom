#!/usr/bin/perl --

use utf8;
$call = 'kako.cgi';
require './sub/common.pl';		#初期設定と共通サブルーチン
require './sub/check_mobile.pl';	#携帯判定サブルーチン

cgi_main();
exit(0);

sub cgi_main {
	$page_max = 100;		#１ページに表示するスレッド数（偶数で）
	my $bbs;
	my $page;
	($bbs,$bbs,$page) = split( /\//, $ENV{'PATH_INFO'});	#引数の取得
	if (check_mobile()) {
		$url = get_top();
		print "Location: $url"."test/m.cgi/$bbs/k\n";
	}
	if ($page eq '' || $page =~ /[^0-9]/) {$page = 1;}	#表示ページ
	my $board = $bbs.'_kako';
	$url = get_top();
	my %setting = get_setting_txt($bbs);
	
	my @list = read_tbl("../$board/subject.txt");
	my $count = count_kako($bbs);
	my $page_end = int($count / $page_max + 0.99);
	if ($page > $page_end) {$page = $page_end;}
	my $tbl_begin = "<table border=1 cellspacing=7 cellpadding=3 width=95% bgcolor=";
	my $tbl_end = "</td></tr>\n</table><br>\n";
	print "Content-type: text/html\n\n";
	print "<html>\n";
	print "<head>\n";
	print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=$ifo{'outchr'}\">\n";
	print "<base href=\"$url$board/\">\n";
	print "<title>",$setting{'TITLE'},enc_str('@過去ログ倉庫'),"</title>\n";
	print "<style type='text/css'>\n";
	print enc_str("body {font-family:'ＭＳ Ｐゴシック','IPA モナー Pゴシック',sans-serif;\n");
	print "font-size:16px;line-height:18px;\n";
	print "word-break:break-all;}\n";
	print "</style>\n";
	print "</head>\n";
	print "<body bgcolor=$setting{'BG_COLOR'} text=$setting{'TEXT_COLOR'} ";
	print "link=$setting{'LINK_COLOR'} alink=$setting{'ALINK_COLOR'} vlink=$setting{'VLINK_COLOR'} ";
	print "background=$setting{'BG_PICTURE'}>\n<center>\n";
	my $file = rtrim(read_file("../$bbs/banner1.txt"));
	if ($file ne '') {
		print $tbl_begin.$setting{'MENU_COLOR'}.">\n<tr><td>";
		print $file;
		print $tbl_end;
	}
	print $tbl_begin.$setting{'THREAD_COLOR'}.">\n<tr><td colspan=\"2\">";
	print "<center><b><font size=\"+1\" color=\"$setting{'TITLE_COLOR'}\">";
	print $setting{'SUBTITLE'},enc_str("<br>過去ログ倉庫"),"\n";
	print "</font></b></center><br>\n";
	print "&nbsp$count",enc_str("件のスレッドが有ります<br>");
	print enc_str("<div align=\"right\"><font size='2'><b><a href=\"../$bbs/\">投稿用掲示板はこちら</a></b></font>\n");
	print "</tr><tr><td valign=\"top\">\n";

	my $start = ($page -1) * $page_max;
	if ($start < 0) {$start = 0;}
	my $point = $start;
	my $cnt = 0;
	while ($cnt < $page_max && $point < $count) {
		my ($key,$name) = split('.dat<>',trim($list[$point]));
		print $point+1,":$key <a href=\"../test/read.cgi/$board/$key/-100\">$name</a><br>\n";
		if ($cnt == $page_max / 2 -1) {
			print "</td><td valign=\"top\">\n";
		}
		$point++;
		$cnt++;
	}
	if ($count > $page_max) {
		print "</td></tr><td colspan=\"2\"><center>\n";
		my $page_count = int($count / $page_max + 0.99);
		if ($page != 1) {
			print "<a href=\"../test/kako.cgi/$bbs/1\">\n";
			print enc_str("最初</a>&nbsp");
			print " <a href=\"../test/kako.cgi/$bbs/",$page - 1,"\">\n";
			print enc_str("前</a>&nbsp\n");
		}
		$cnt = 1;
		while ($cnt <= $page_count) {
			if ($cnt == $page) {
				print " <b>$cnt</b>&nbsp";
			} else {
				print " <a href=\"../test/kako.cgi/$bbs/$cnt\">\n";
				print "$cnt</a>&nbsp\n";
			}
			$cnt++;
		}
		if ($page != $page_count) {
			print " <a href=\"../test/kako.cgi/$bbs/",$page + 1,"\">\n";
			print enc_str("次</a>&nbsp\n");
			print " <a href=\"../test/kako.cgi/$bbs/$page_count\">\n";
			print enc_str("最後</a>\n");
		}
	}
	print $tbl_end;
	$file = rtrim(read_file("../$bbs/banner2.txt"));
	if ($file ne '') {
		print $tbl_begin.$setting{'MENU_COLOR'}.">\n<tr><td>";
		print $file;
		print $tbl_end;
	}
	print "</center></body>\n</html>\n";
}

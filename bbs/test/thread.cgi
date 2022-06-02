#!/usr/bin/perl

use utf8;

$call = 'thread.cgi';
require './sub/common.pl';			#初期設定と共通サブルーチン
main();

sub main {
	my $cgi = new CGI;
	my $bbs = $cgi->param('bbs');
	my $file =read_file("../$bbs/head.txt");
	$name = $cgi->cookie('NAME');
	Encode::from_to($name,'utf-8',$ifo{'outchr'});
	$mail = $cgi->cookie('MAIL');
	Encode::from_to($mail,'utf-8',$ifo{'outchr'});
	if ($name) {$name = " value=\"$name\"";}
	if ($mail) {$mail = " value=\"$mail\"";}
	my %setting = get_setting_txt($bbs);
	print "Content-type: text/html\n\n";
	print "<html>\n<head>\n";

	#headerタグ
	open(FH, "$dir/$bbs/header.txt");
		while ($header = <FH>) {
		print "$header\n";
		}
	close(FH);
	#reCaptcha
	if($setting{'SITE_KEY'} ne '' && $setting{'SECRET_KEY'} ne ''){
	print '<script src="https://www.google.com/recaptcha/api.js"></script>';
	}
	#hCaptcha
	if($setting{'SITE_KEY'} ne '' && $setting{'H_SECRET_KEY'} ne ''){
	print '<script src="https://www.hCaptcha.com/1/api.js" async defer></script>';
	}

	print '<meta http-equiv="Content-Type" content="text/html; charset=',$ifo{'outchr'},"\">\n";
	print '<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1">',"\n";
	print '<title>',$setting{'TITLE'},"</title>\n";
	print "<style type='text/css'>\n<!--\n";
	print enc_str("body {font-family:'ＭＳ Ｐゴシック','IPA モナー Pゴシック',sans-serif;\n");
	print "font-size:16px;line-height:18px;\n";
	print "word-break:break-all;}\n";
	print "img {max-width:100%;height:auto;}\n";
	print "textarea {width:80%;}\n";
	print "-->\n</style>\n</head>\n";
	print "<body bgcolor=$setting{'BG_COLOR'} text=$setting{'TEXT_COLOR'} ";
	print "link=$setting{'LINK_COLOR'} alink=$setting{'ALINK_COLOR'} vlink=$setting{'VLINK_COLOR'} ";
	print "background=$setting{'BG_PICTURE'}>\n<center>\n";
	if ($setting{'TITLE_PICTURE'} ne '') {
		print "<a href=\"$setting{'TITLE_LINK'}\"><img src=\"$setting{'TITLE_PICTURE'}\" border=0></a>\n";
	}
	print "<table border=1 cellspacing=7 cellpadding=3 width=95% bgcolor=$setting{'MENU_COLOR'}>\n<tr><td>";
	print "<table border=0 cellpadding=1 width=100%><tr><td nowrap COLSPAN=2><font size=+1 color=$setting{'TITLE_COLOR'}>";
	print "<b>$setting{'SUBTITLE'}</b></font><br></td><td nowrap width=5% align=right><a href=#menu>$mn</a> <a href=#1>$dw</a></td></tr>\n";
	print "<tr><td colspan=2>$file\n";
	print enc_str("<dl><dt><br><b>スレッド新規作成</b></dt>\n");
	print "<form method=POST action=\"../test/bbs.cgi?guid=ON\" style=\"margin:0px;\"".($setting{'IMG_MODE'} eq 'checked' ? ' ENCTYPE="multipart/form-data">' : '>')."\n";
	print enc_str("<dd>タイトル：<input type=\"text\" name=\"subject\" size=30>　");
	print enc_str("<input type=submit value=\"新規スレッド作成\" name=submit><br>\n");
	print enc_str("名前： <input type=\"text\" name=FROM size=19"),"$name>\n";
	print enc_str(" E-mail<font size=1> (省略可) </font>: <input type=\"text\" name=mail size=19"),"$mail><br>\n";
	if ($setting{'IMG_MODE'} eq 'checked') {
		print enc_str('画像：<input type ="file" name ="file" size="80" style="width:50%;"><br>')."\n";
	}
		#サイトキー
		if($setting{'SITE_KEY'} ne '' && $setting{'SECRET_KEY'} ne ''){
		print '<div class="g-recaptcha" data-sitekey=';
		print "$setting{'SITE_KEY'}".'></div>';
		}
		if($setting{'SITE_KEY'} ne '' && $setting{'H_SECRET_KEY'} ne ''){
		print '<div class="h-captcha" data-sitekey=';
		print "$setting{'SITE_KEY'}".'></div>';
		}

	print "<textarea rows=5 cols=70 wrap=off name=MESSAGE></textarea></dd>\n";
	print "<input type=hidden name=bbs value=$bbs>\n";
	print "<input type=hidden name=time value=$time>\n";
	print "</dl></form>\n";
	print "</td></tr>\n</table><br>\n";
	exit(0);
}

use utf8;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);

sub put_page {
	my $board = shift;
	put_pc($board);		#パソコン用index.html
	put_subback($board);	#パソコン用スレッド一覧
	put_mobile($board);	#携帯用index.html
}

sub put_pc {
	if ($ifo{'maintenance'}) {return(0);}
	my $dat = $key;
	my $mn = enc_str('■');
	my $up = enc_str('▲');
	my $dw = enc_str('▼');
	my $sp = enc_str('　');
	my $file;
	my $cnt;
	my $bbstable= "$ifo{'site_top'}bbstable.html";
	my $tbl_begin = "<table border=1 cellspacing=7 cellpadding=3 width=95% bgcolor=";
	my $tbl_end = "</td></tr>\n</table><br>\n";
	$file = rtrim(read_file("$dir/$bbs/head.txt"));
	if (-e "$dir/$bbs/index.html") {
		open(WR,"+<$dir/$bbs/index.html") or return(1);
	} else {
		open(WR,">$dir/$bbs/index.html") or return(1);
	}
	flock(WR, 2);
	seek(WR, 0, 0);
	print WR "<html>\n<head>\n";
	print WR '<meta http-equiv="Content-Type" content="text/html; charset=',$ifo{'outchr'},"\">\n";
	print WR '<script type="text/javascript" src="../test/index.js"></script>',"\n";
	print WR "<meta http-equiv=\"pragma\" content=\"no-cache\">\n";
	print WR "<meta http-equiv=\"cache-control\" content=\"no-cache\">\n";
	print WR '<meta http-equiv="expires" content="0">',"\n";
	print WR '<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1">',"\n";
	print WR '<title>',$setting{'TITLE'},"</title>\n";
	print WR "<style type='text/css'>\n<!--\n";
	print WR enc_str("body {font-family:'ＭＳ Ｐゴシック','IPA モナー Pゴシック',sans-serif;\n");
	print WR "font-size:16px;line-height:18px;\n";
	print WR "word-break:break-all;}\n";
	print WR "img {max-width: 100%;height: auto;}\n";
	print WR "dd {style=font-size:16px;line-height:18px;}\n";
	print WR "dl {style=font-size:16px;line-height:18px;}\n";
	print WR "textarea {width:80%;}\n";
	print WR "-->\n</style>\n";

	#headerタグ
	open(FH, "$dir/$bbs/header.txt");
		while ($header = <FH>) {
		print WR "$header\n";
		}
	close(FH);


	#画像以外のOGP設定 画像は絶対パスが面倒くさすぎる
    print WR '<meta property="og:type" content="article" >'."\n";
    print WR '<meta property="og:title" content=';
    print WR $setting{'SUBTITLE'}.'>'."\n";
	if($setting{'DESCRIPTION'} ne ''){
    print WR '<meta property="og:description" content=';
    print WR $setting{'DESCRIPTION'}.'>'."\n";
	}
    print WR '<meta property="og:site_name" content=';
    print WR $setting{'SUBTITLE'}.'>'."\n";
    print WR '<meta name="twitter:card" content="summary_large_image" />';


	#metaタグ
	if($setting{'KEYWORDS'} ne ''){
	print WR '<meta name="keywords" content=';
	print WR $setting{'KEYWORDS'}.'>'."\n";
	}
	if($setting{'DESCRIPTION'} ne ''){
	print WR '<meta name="description" content=';
	print WR $setting{'DESCRIPTION'}.'>'."\n";
	}

	#reCaptcha
	if($setting{'SITE_KEY'} ne '' && $setting{'SECRET_KEY'} ne ''){
	print WR '<script src="https://www.google.com/recaptcha/api.js"></script>'."\n";
	}
	#hCaptcha
	if($setting{'SITE_KEY'} ne '' && $setting{'H_SECRET_KEY'} ne ''){
	print WR '<script src="https://www.hCaptcha.com/1/api.js" async defer></script>'."\n";
	}

	print WR "</head>\n";
	print WR "<body bgcolor=$setting{'BG_COLOR'} text=$setting{'TEXT_COLOR'} ";
	print WR "link=$setting{'LINK_COLOR'} alink=$setting{'ALINK_COLOR'} vlink=$setting{'VLINK_COLOR'} ";

	#">"を追加して背景を表示できるように
	print WR "background=$setting{'BG_PICTURE'}>";
	if ($ifo{'dir'}) {print WR " onload=\"page()";}
	print WR "\n<center>\n";
	if ($setting{'TITLE_PICTURE'} ne '') {
		print WR "<a href=\"$setting{'TITLE_LINK'}\" target=\"_top\"><img src=\"$setting{'TITLE_PICTURE'}\" border=0></a>\n";
	}
	print WR $tbl_begin.$setting{'MENU_COLOR'}.">\n<tr><td>";
	print WR "<table border=0 cellpadding=1 width=100%><tr><td nowrap COLSPAN=2><font size=+1 color=$setting{'TITLE_COLOR'}>";
	print WR "<b>$setting{'SUBTITLE'}</b></font><br></td><td nowrap width=5% align=right><a href=#menu>$mn</a> <a href=#1>$dw</a></td></tr>\n";
	print WR "<tr><td colspan=2>$file</tr></td></table></td></tr>\n";	#ローカルルールの表示
	if ($ifo{'bbslist'}) {
		print WR "<tr><td align=center><font size=-1><a href=\"$bbstable\">".enc_str('<b>■掲示板一覧■</b>')."</a></font>";
	}
	print WR $tbl_end;
	my $bn = 0;
	$file = rtrim(read_file("$dir/$bbs/banner1.txt"));
	if ($file ne '') {
		print WR $tbl_begin.$setting{'MENU_COLOR'}.">\n<tr><td>";
		print WR $file;
		print WR "</td></tr></table>\n";
		$bn = 1;
	}
	$file = rtrim(read_file("$dir/$bbs/banner2.txt"));
	if ($file ne '') {
		print WR $tbl_begin.$setting{'MENU_COLOR'}.">\n<tr><td>";
		print WR $file;
		print WR "</td></tr></table>\n";
		$bn = 1;
	}
	if ($bn) {print WR "<br>\n";}
	print WR "<a name=\"menu\"></a>";
	print WR "$tbl_begin$setting{'MENU_COLOR'}>\n<tr><td><font size=2>\n";
	if (@sbj_txt < $setting{'MAX_MENU_THREAD'}) {$setting{'MAX_MENU_THREAD'}=@sbj_txt;}
	for($cnt = 1;$cnt <= $setting{'MAX_MENU_THREAD'};$cnt++) {
		($key,$subject) = split(/\.dat<>/,$sbj_txt[$cnt - 1]);
		$subject =~ s/\s*$//;		#改行文字の消去
		if ($cnt <= $setting{'THREAD_NUMBER'}) {
			print WR "<a href=\"../test/read.cgi/$bbs/$key/l50\" target=\"_blank\">$cnt:</a> <a href=\"#$cnt\">$subject</a>$sp\n";
		} else {
			print WR "<a href=\"../test/read.cgi/$bbs/$key/l50\" target=\"_blank\">$cnt: $subject</a>$sp\n";
		}
	}
	print WR enc_str("<div align=\"right\"><a href=\"subback.html\"><b>スレッド一覧はこちら</b></a>");
	print WR "</font>$tbl_end";
	if (@sbj_txt < $setting{'THREAD_NUMBER'}) {$setting{'THREAD_NUMBER'}=@sbj_txt;}
	for($cnt = 1;$cnt <= $setting{'THREAD_NUMBER'};$cnt++) {
		($key,$subject) = split(/\.dat<>/,$sbj_txt[$cnt - 1]);
		print WR $tbl_begin.$setting{'THREAD_COLOR'}.">\n<tr><td>";
		my $max = get_index(1);
		$max = abs($max);
		my $start = $max - $setting{'CONTENTS_NUMBER'} + 1;
		if ($start <= 1) {$start = 2};
		if ($max - $start + 1 < 0) {$start=0;}
		$subject = substr($subject,0,rindex($subject,'('));
		print WR "<a name=\"$cnt\"></a><div align=right><a href=\"#menu\">$mn</a>";
		print WR '<a href="#',($cnt == 1 ? $setting{'THREAD_NUMBER'} : $cnt - 1),"\">$up</a>";
		print WR '<a href="#',($cnt == $setting{'THREAD_NUMBER'} ? 1 : $cnt + 1),"\">$dw</a></div>\n";
		print WR '<b>',enc_str("【$cnt:$max】");
		print WR "<font size=5 color=\"$setting{'SUBJECT_COLOR'}\">$subject</font></b><br>\n";
		print WR "<dl>\n";
		if (open(LOG,"<$dir/$bbs/dat/$key.dat")) {
			flock(LOG,1);
			my $line = <LOG>;		#レス１の表示
			res_tr(1,\$line);
			print WR $line;
			my $fpt = 0;
			if ($start) {$fpt = get_index($start);}
			if ($fpt) {
				if (seek(LOG,$fpt,0)) {
					while($line = <LOG>) {	#レス２以降の表示
						res_tr($start,\$line);
						print WR $line;
						$start++;
					}
				}
			}
			close(LOG);
		}
		print WR "<dd><form method=POST action=\"../test/bbs.cgi?guid=ON\" style=\"margin:0px;\"";
		print WR ($setting{'IMG_MODE'} eq 'checked' ? ' ENCTYPE="multipart/form-data">' : '>')."\n";
		print WR enc_str("<input type=submit value=\"書き込む\" name=submit>\n");
		print WR enc_str("名前： <input name=FROM size=19>\n");
		print WR enc_str(" E-mail<font size=1> (省略可) </font>: <input name=mail size=19><br>\n");
		if ($setting{'IMG_MODE'} eq 'checked') {
			print WR enc_str('画像：<input type ="file" name ="file" size="88" style="width:50%;"><br>')."\n";
		}

		#サイトキー
		if($setting{'SITE_KEY'} ne ''){

			if($setting{'SECRET_KEY'} ne ''){
			print WR '<div class="g-recaptcha" data-sitekey=';
			print WR "$setting{'SITE_KEY'}".'></div>';
			}elsif($setting{'H_SECRET_KEY'} ne ''){
			print WR '<div class="h-captcha" data-sitekey=';
			print WR "$setting{'SITE_KEY'}".'></div>';
			}

		}

		print WR "</dd><ul><textarea rows=5 cols=70 wrap=off name=MESSAGE></textarea>\n";
		print WR "<input type=hidden name=bbs value=$bbs>\n";
		print WR "<input type=hidden name=key value=$key>\n";
		print WR "<input type=hidden name=time value=$time>\n";
		print WR "</ul></form>\n";
		print WR enc_str("<ul><b><a href=\"../test/read.cgi/$bbs/$key/\">全部読む</a> \n");
		print WR enc_str("<a href=\"../test/read.cgi/$bbs/$key/l50\">最新50</a> \n");
		print WR "<a href=\"../test/read.cgi/$bbs/$key/-100\">1-100</a> \n";
		print WR enc_str("<a href=\"#top\">板のトップ</a> <a href=\"../$bbs/?t=$time\">リロード</a></b></ul>");
		print WR "</dl>\n";
		print WR $tbl_end;
	}
	print WR $tbl_begin.$setting{'MAKETHREAD_COLOR'}.">\n<tr><td>";
	if ($setting{'PASSWORD_CHECK'} eq 'checked') {
		print WR '<dl><br><form method=POST action="../test/thread.cgi">',"\n";
		print WR '<input type=submit value="'.enc_str('新規スレッド作成画面へ')."\" name=submit>\n";
	} else {
		print WR enc_str("<dl><dt><br><b>スレッド新規作成</b></dt>\n");
		print WR '<form method=POST action="../test/bbs.cgi?guid=ON" style="margin:0px;"';
		print WR ($setting{'IMG_MODE'} eq 'checked' ? ' ENCTYPE="multipart/form-data">' : '>')."\n";
		print WR enc_str("<dd>タイトル：<input type=\"text\" name=\"subject\" size=30>　");
		print WR enc_str("<input type=submit value=\"新規スレッド作成\" name=submit><br>\n");
		print WR enc_str("名前： <input type=\"text\" name=FROM size=19>\n");
		print WR enc_str(" E-mail<font size=1> (省略可) </font>: <input type=\"text\" name=mail size=19><br>\n");
		if ($setting{'IMG_MODE'} eq 'checked') {
			print WR enc_str('画像：<input type ="file" name ="file" size="80" style="width:50%;"><br>')."\n";
		}

		#サイトキー
		if($setting{'SITE_KEY'} ne '' && $setting{'SECRET_KEY'} ne ''){
		print WR '<div class="g-recaptcha" data-sitekey=';
		print WR "$setting{'SITE_KEY'}".'></div>';
		}
		if($setting{'SITE_KEY'} ne '' && $setting{'H_SECRET_KEY'} ne ''){
		print WR '<div class="h-captcha" data-sitekey=';
		print WR "$setting{'SITE_KEY'}".'></div>';
		}

		print WR "<textarea rows=5 cols=70 wrap=off name=MESSAGE></textarea></dd>\n";
	}
	print WR "<input type=hidden name=bbs value=$bbs>\n";
	print WR "<input type=hidden name=time value=$time>\n";
	print WR "</dl></form>\n";
	print WR $tbl_end;
	$file = rtrim(read_file("$dir/$bbs/foot.txt"));
	if ($file ne '') {print WR $file;}
	print WR "</center>\n</body>\n</html>\n";
	truncate(WR,tell(WR));
	close(WR);
	$key = $dat;
	return(0);
}

sub res_tr {
	my $num = shift;
	my $line = shift;
	my ($name,$mail,$ifo,$message) = split(/<>/,$$line);
	$$line = "<dt>$num <font color =\"$setting{'NAME_COLOR'}\">";
	if ($mail) {$$line .= "<a href=\"mailto:$mail\">";}
	$$line .= "<b>$name </b>";
	if ($mail) {$$line .= '</a>';}
	$$line .= enc_str('</b></font>：').$ifo."</dt>\n";
	my $end;
	my $ent=0;
	my $cnt = 0;
	while($ent >= 0){
		$cnt++;
		last if $cnt > $setting{'LINE_NUMBER'};
		$ent = index($message,'<br>',$ent);
		if ($ent >= 0) {$ent += 4;}
	}
	if ($cnt > $setting{'LINE_NUMBER'} && $ent > 0) {
		$message = substr($message,0,$ent);
		$message =~ s/<br>$//;
		$message .= "<br>\n<font color =\"$setting{'NAME_COLOR'}\">";
		$message .= enc_str("（省略されました・・全てを読むには");
		$message .= "<a href=\"../test/read.cgi/$bbs/$key/$num\" target=\"_blank\">";
		$message .= enc_str("ここ</a>を押してください）</font>");
	}
	$message =~ s/(<a href=\"\.\.\/test\/read\.cgi\/)[^\/]+/$1$bbs/g;
	if ($setting{'IMG_MODE'} eq 'checked') {
		show_smn($num,\$message,$setting{'IMG_THUMBNAIL_X'},$setting{'IMG_THUMBNAIL_Y'});
	} else {
		$message .= '<br>';
	}
	if ($ifo{'jump'}) {
		my $jump = "../test/j.cgi?jmp=";
		my $h = 'h';
		$message =~ s/(s?https?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/"<a href=\"$jump".url_encode($1)."\" target=\"_blank\">$1<\/a>"/eg;
		$message =~ s/([^h])(ttps?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/"$1<a href=\"$jump".url_encode($h.$2)."\" target=\"_blank\">$2<\/a>"/eg;
		$message =~ s/^(ttps?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/"<a href=\"$jump".url_encode($h.$1)."\" target=\"_blank\">$1<\/a>"/eg;
	} else {
		my $h = 'h';
		$message =~ s/(s?https?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/<a href="$1" target="_blank">$1<\/a>/g;
		$message =~ s/([^h])(ttps?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/$1<a href="$h$2" target="_blank">$2<\/a>/g;
		$message =~ s/^(ttps?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/<a href="$h$1" target="_blank">$1<\/a>/g;
	}
	$$line .= "<dd>$message<br></dd>\n";
}

sub put_subback {
	if ($ifo{'maintenance'}) {return(0);}
	my $sp = enc_str('　');
	if (-e "$dir/$bbs/subback.html") {
		open(WR,"+<$dir/$bbs/subback.html") or return(1);
	} else {
		open(WR,">$dir/$bbs/subback.html") or return(1);
	}
	flock(WR, 2);
	seek(WR, 0, 0);
	print WR "<html>\n";
	print WR "<head>\n";
	print WR "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=$ifo{'outchr'}\">\n";
	print WR "<meta http-equiv=\"pragma\" content=\"no-cache\">\n";
	print WR "<meta http-equiv=\"cache-control\" content=\"no-cache\">\n";
	print WR "<style type='text/css'>\n<!--\n";
	print WR "body {word-break:break-all;}\n";
	print WR "-->\n</style>\n";
	print WR '<title>',$setting{'TITLE'},enc_str('＠スレッド一覧'),"</title>\n";
	print WR "<body bgcolor=$setting{'BG_COLOR'} text=$setting{'TEXT_COLOR'} ";
	print WR "link=$setting{'LINK_COLOR'} alink=$setting{'ALINK_COLOR'} vlink=$setting{'VLINK_COLOR'}>";
	print WR "<small>\n";
	my $max = @sbj_txt;
	my $cnt;
	for($cnt = 1;$cnt <= $max;$cnt++) {
		my ($dat,$subject) = split(/\.dat<>/,$sbj_txt[$cnt - 1]);
		$subject =~ s/\s*$//;		#改行文字の消去
		print WR "<a \nhref=\"../test/read.cgi/$bbs/$dat/l50\" target=\"_blank\">$cnt: $subject</a>$sp";
	}
	if ($ifo{'max_kako'} && count_kako($bbs)) {
		print WR "<div align=right><a href=\"../test/kako.cgi/$bbs/\"><b>".enc_str('過去ログ倉庫はこちら')."</b></a></div>\n";
	}
	print WR "</small>\n</body>\n</html>\n";
	truncate(WR,tell(WR));
	close(WR);
	return(0);
}

1;
#!/usr/bin/perl --

use utf8;
$call = 'read.cgi';
require './sub/common.pl';		#初期設定と共通サブルーチン
require './sub/check_mobile.pl';	#携帯判定サブルーチン
get_parm();
if ($img_mode) {
	if ($ifo{'img_lib'}) {
		require "./sub/smn".$ifo{'img_lib'}.".pl";
	} else {
		require './sub/smn.pl';
	}
}
show_thread();
exit(0);

sub get_parm {
	$head = 1;		#header関数が呼ばれたら0
	$url = get_top();
	($opt,$bbs,$key,$opt) = split( /\//, $ENV{'PATH_INFO'});	#引数の取得
	$cgi = CGI->new();
	$c_name = $cgi->cookie('NAME');
	Encode::from_to($c_name,'utf-8',$ifo{'outchr'});
	$c_name =~ s/"/&quot;/g;
	$c_name =~ s/\n|\r//g;
	$c_mail = $cgi->cookie('MAIL');
	Encode::from_to($c_mail,'utf-8',$ifo{'outchr'});
	$c_mail =~ s/"/&quot;/g;
	$c_mail =~ s/\n|\r//g;
	write_cookie($ifo{'c_name'},$ifo{'c_val'},0);
	if ($c_name) {$c_name = " value=\"$c_name\"";}
	if ($c_mail) {$c_mail = " value=\"$c_mail\"";}
	if ($bbs eq '') {
		$bbs = $cgi->param('bbs');
		$key = $cgi->param('key');
		$opt = '';
		if ($cgi->param('nofirst') eq 'true') {$opt .= 'n';}
		my $ls = $cgi->param('ls');
		if ($ls ne '') {$opt .= 'l'.$ls;}
		my $st = $cgi->param('st');
		my $to = $cgi->param('to');
		if ($st eq $to) {
			$opt .= $st;
		} else {
			$opt .= $st . '-' . $to;
		}
	}
	get_setting();		#SETTING.TXTの変数化
}

sub show_thread {
	open(LOG,"< ../$bbs/dat/$key.dat") or error_exit("いやですよー　そんなスレッド無いでしょー");
#	flock(LOG,1);
	my $max;
	if (!($max = get_index(1))) {		#索引から総レス数取得
		close(LOG);
		error_exit("ごめんなさい、索引が読めないので表示できないですよ");
	}
	my $mode = 1;
	if ($max < 0) {
		$mode = 0;
		$max = abs($max);
	}
	my ($first,$start,$count);
	if (length($opt)) {		#オプション有り
		$first = (index($opt,'n') >=0 ? 0 : 1);	#nオプション
		if (index($opt,'l') >=0) {		#lオプション
			($count) = $opt =~ /([0-9]+)/g;
			$count = ($count eq '' ? 10 : $count);
			$start = $max -$count + 1;
			$opt = 'l' . ($count >10 ? 10 : $count );
			if ($start <= 1) {
				$first = 1;		#レス１表示
				$start = 2;		#開始レス番号-1（２から表示）
				$count = $max -1;	#表示件数
				$opt = 'l10';		#携帯のオプション
			}
		} elsif (index($opt,'-') >=0) {		#-オプション
			($start,$count) = split(/-/,$opt);
			($start) = $start =~ /([0-9]+)/g;
			$start = ($start eq '' ? 1 : $start);
			$start = ($start > $max ? $max : $start);
			($count) = $count =~ /([0-9]+)/g;
			$count = ($count eq '' ? $max : $count );
			$count =($count > $max ? $max : $count );
			if ($start > $count) {
				($start,$count) = ($count,$start);
			}
			$opt = $start . '-' . (($count - $start) >=9 ? $start + 9 : $start);
			if ($start == 1) {
				$start = 2;
				$first = 1;
			}
			$count = $count - $start +1;
		} else {				#数値指定
			($start) = $opt =~ /([0-9]+)/g;
			if ($start eq '') {
				$start = 2;
				$count = $max -1;
				$opt = 'l10';
			} elsif ($start == 1) {
				$first = 1;
				$start = 2;
				$count = 0;
				$opt = '1';
			} else {
				$start = ($start > $max ? $max : $start);
				$first = 0;
				$count =1;
				$opt = $start;
			}
		}
	} else {			#オプション無し
		$first = 1;		#レス１表示
		$start = 2;		#開始レス番号-1（２から表示）
		$count = $max -1;	#表示件数
		$opt = 'l10';		#携帯のオプション
	}
	my $term = check_mobile();
	if ($term == 1) {		#携帯からか？
		close(LOG);
		print "Location: $url"."test/r.cgi/$bbs/$key/$opt\n\n";
	}
	seek(LOG,0,0) or (close(LOG) and error_exit("ファイルが壊れています"));
	my ($name,$mail,$info,$message,$title) = split( /<>/,<LOG>) or (close(LOG) and error_exit("ファイルが壊れています"));
	$head = header($title,$mode,$max,$term);
	if ($first) {	#レス１表示
		view(1,\$name,\$mail,\$info,\$message);
	}
	if ($max != 1) {
		my $fpt = get_index($start) or (close(LOG) and error_exit("索引が壊れています"));
		seek(LOG,$fpt,0) or (close(LOG) and error_exit("索引が壊れています"));
	}
	my $cnt = $count;
	my $num = $start;
	while($cnt--) {		#レス２以降の表示
		($name,$mail,$info,$message,$title) = split( /<>/,<LOG>) or (close(LOG) and error_exit("ファイルが壊れています"));
		view($num,\$name,\$mail,\$info,\$message);
		$num++;
	}
	close(LOG);
	footer($mode,$start,$count,$max,$term);	#htmlフッタ出力
}

#SETTING.TXTの読み込み
sub get_setting {
	my $board = $bbs;
	if (index($bbs,'_kako') >= 0) {$board = substr($bbs,0,index($bbs,'_kako'));}
	my %setting = get_setting_txt($board);
	$thread_color = $setting{'THREAD_COLOR'};
	$text_color = $setting{'TEXT_COLOR'};
	$name_color = $setting{'NAME_COLOR'};
	$link_color = $setting{'LINK_COLOR'};
	$alink_color = $setting{'ALINK_COLOR'};
	$vlink_color = $setting{'VLINK_COLOR'};
	$subject_color = $setting{'SUBJECT_COLOR'};
	$img_mode = ($setting{'IMG_MODE'} eq 'checked' ? 1 : 0);
	$img_x = $setting{'IMG_THUMBNAIL_X'};
	$img_y = $setting{'IMG_THUMBNAIL_Y'};
	$keywords = $setting{'KEYWORDS'};
	$description = $setting{'DESCRIPTION'};
	$site_key_if = ($setting{'SITE_KEY'} ne '' ? 1 : 0);
	$site_key = $setting{'SITE_KEY'};
	$secret_key = ($setting{'SECRET_KEY'} ne '' ? 1 : 0);
	$h_secret_key = ($setting{'H_SECRET_KEY'} ne '' ? 1 : 0);
	$sns_share = ($setting{'SNS_SHARE'} eq 'checked' ? 1 : 0);
	$picture_preview = ($setting{'PICTURE_PREVIEW'} eq 'checked' ? 1 : 0);
	$youtube_preview = ($setting{'YOUTUBE_PREVIEW'} eq 'checked' ? 1 : 0);
}

sub view {
	my $num = shift;
	my $name = shift;
	my $mail = shift;
	my $info = shift;
	my $message = shift;

	print '<dt>',$num,enc_str(" ：");
	print "<font color =\"$name_color\">";
	if ($$mail) {print '<a href="mailto:',$$mail,'">';}
	print '<b>',$$name,'</b>';
	if ($$mail) {print '</a>';}
	print enc_str('</b></font>：'),$$info,"</dt>\n";
	$$message =~ s/(<a href=\"\.\.\/test\/read\.cgi\/)[^\/]+/$1$bbs/g;
	if ($img_mode) {
		show_smn($num,$message,$img_x,$img_y);
	} else {
		$$message .= '<br>';
	}

	#画像プレビュー用のメッセージ aタグなし
	if($picture_preview){
	$pic_preview = $$message;
	}

	if ($ifo{'jump'}) {
		my $h = 'h';
		my $jump = '../test/j.cgi?jmp=';
		$$message =~ s/(s?https?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/"<a href=\"$jump".url_encode($1)."\" target=\"_blank\">$1<\/a>"/eg;
		$$message =~ s/([^h])(ttps?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/"$1<a href=\"$jump".url_encode($h.$2)."\" target=\"_blank\">$2<\/a>"/eg;
		$$message =~ s/^(ttps?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/"<a href=\"$jump".url_encode($h.$1)."\" target=\"_blank\">$1<\/a>"/eg;
	} else {
		my $h = 'h';
		$$message =~ s/(s?https?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/<a href="$1" target="_blank">$1<\/a>/g;
		$$message =~ s/([^h])(ttps?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/$1<a href="$h$2" target="_blank">$2<\/a>/g;
		$$message =~ s/^(ttps?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/<a href="$h$1" target="_blank">$1<\/a>/g;
	}
	print "<dd>$$message<br></dd>\n";

$text = $$message;


#画像プレビュー
if($picture_preview){

	#１行ずつ文章を分割
	my @strtext = split(/<br>/, $pic_preview);

	# URLを抽出するための正規表現
	@patterns = (
	'https?:\/\/[a-zA-Z0-9-_.~\/?:&=%+#]+\.(jpg|jpeg|gif|png|bmp)',
	);

	foreach my $text (@strtext) {
		# 正規表現にマッチしたURLを出力する
		foreach my $pattern (@patterns){
			while ($text =~ /$pattern/gp) {
			print "\n";
			print "<p></p>\n";

			print '<dd><div class="img_preview"><img src=';
			print "${^MATCH}"."    ";
			print '></div></dd>'."\n\n";
			}
		print "\n";
		}
	}
}

#Youtube動画プレビュー
if($youtube_preview){

	#１行ずつ文章を分割
	my @strtext = split(/<br>/, $text);

	# URLを抽出するための正規表現
	@patterns = (
	'(?:https:\/\/www\.youtube\.com(?:\/embed\/|\/watch\?v=)|https:\/\/youtu\.be\/)([^\n\r&]+)', # 短縮URL
	);

	foreach my $text (@strtext) {
		# 正規表現にマッチしたURLを出力する
		foreach my $pattern (@patterns){
			while ($text =~ /$pattern/gp) {
			print "\n";
			print "<p></p>\n";

			print '<dd><div class="youtube"><iframe data-src=';
			print "${^MATCH}"."    ";
			print 'frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div></dd>'."\n\n";
			}
		print "\n";
		}
	}
}

}

#ヘッダ出力
sub header{
	my $title = shift;
	my $mode = shift;
	my $max = shift;
	my $term = shift;
	my $board = $bbs;
	if (index($bbs,'_kako') >= 0) {$board = substr($bbs,0,index($bbs,'_kako'));}
	$title = trim($title);
	my $fname = "../test/read.cgi/$bbs/$key";
	print "Content-type: text/html\n\n";
	print "<html>\n";
	print "<head>\n";
	print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=$ifo{'outchr'}\">\n";
	print "<base href=\"$url$bbs/\">\n";
	print "<title>",$title,"</title>\n";
	print '<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1">',"\n";
	print "<style type='text/css'>\n<!--\n";
	print enc_str("body {font-family:'ＭＳ Ｐゴシック','IPA モナー Pゴシック',sans-serif;\n");
	print "font-size:16px;line-height:18px;\n";
	print "word-break:break-all;}\n";
	print "img {max-width: 100%;height: auto;}\n";
	if ($term) {
		print "dt {style=font-size:16px;line-height:18px;background:#E0E0FF;}\n";
		print "dd {style=font-size:16px;line-height:18px;background:#FFFFFF;margin-left:0px;}\n";
	} else {
		print "dt {style=font-size:16px;line-height:18px;}\n";
		print "dd {style=font-size:16px;line-height:18px;}\n";
	}
	print "textarea {width:80%;}\n";
	print "-->\n</style>\n";

	#CSS読み込み
	print '<link rel="stylesheet" href="../test/design.css">';

	#headerタグ
	open(FH, "$dir/$bbs/header.txt");
		while ($header = <FH>) {
		print "$header\n";
		}
	close(FH);
	#metaタグ
	print '<meta name="keywords" content=';
	print $keywords.'></div>';
	print '<meta name="description" content=';
	print $description.'></div>';
	#reCaptcha
	if($site_key_if && $secret_key){
	print '<script src="https://www.google.com/recaptcha/api.js"></script>';
	}
	#hCaptcha
	if($site_key_if && $h_secret_key){
	print '<script src="https://www.hCaptcha.com/1/api.js" async defer></script>';
	}

	print "</head>\n";
	print "<body bgcolor=$thread_color text=$text_color link=$link_color alink=$alink_color vlink=$vlink_color>\n";

	# youtube
	if($youtube_preview){
	print '<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>';
	print '<script src="../test/youtube.js"></script>';
	}

	my $banner = '';
	if ($term) {$banner = read_file("../$board/s/banner1.txt");}
	unless(trim($banner)) {$banner = read_file("../$board/banner1.txt");}
	if (trim($banner)) {print $banner."<br>\n";}
	my $top = get_top();
	if ($top eq $ifo{'site_top'}) {
		$top = '../';
	} else {
		$top = $ifo{'site_top'};
	}
	print " <a href=\"$top\" target=\"_top\">";
	print enc_str('トップ'),'</a>';
	if (index($bbs,'_kako') < 0 ) {
		print ' <a href="./" target="_top">',enc_str('■掲示板に戻る■'),'</a>';
	} else {
		print " <a href=\"../test/kako.cgi/$board\" target=\"_top\">",enc_str('■過去ログ倉庫に戻る■'),'</a>';
	}
	print " <a href=\"$fname/\">",enc_str('全部'),'</a>';
	print " <a href=\"$fname/-100\">1-</a>";
	print " <a href=\"$fname/l50\">",enc_str('最新50'),'</a>';
	if ($mode == 0) {				#書き込み禁止か？
		print " <a href=\"./dat/$key.dat\">dat</a><br>\n";
		print '<table border=0><tr><td bgcolor=#FF0000><font color=#FFFFFF>';
		print enc_str('このスレッドには書き込めません');
		print '</font><br></td></tr></table>';
	} elsif ($max >= ($ifo{'max_res'} -100)) {	#でなければ900レス以上か？
		print '<table border=0><tr><td bgcolor=#FF0000><font color=#FFFFFF>';
		print enc_str('レス数が');
		print ($max >= ($ifo{'max_res'} -50) ? $ifo{'max_res'} - 50 : $ifo{'max_res'} - 100);
		print enc_str('を超えています。');
		print $ifo{'max_res'},enc_str('を超えると書けなくなりますよ。');
		print '</font><br></td></tr></table>';
	}
	print "<hr><font color=$subject_color size=+1>",$title,"</font><br>\n";	#スレタイ表示
	print "<dl>\n";
	return (0);
}

#htmlフッタ出力
sub footer{
	my $mode = shift;
	my $start = shift;
	my $count = shift;
	my $max = shift;
	my $term = shift;
	my $board = $bbs;
	if (index($bbs,'_kako') >= 0) {$board = substr($bbs,0,index($bbs,'_kako'));}

	my $fname = "../test/read.cgi/$bbs/$key";
	$count = $start + $count;
	print "</dl>\n";

if($sns_share){
# シェアボタン
# http://stooorm.com/memo/2020/10/16/post-342/
print '<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>';

print '<div id="share">';
print '<ul>';

print '<!-- Facebook -->';
print '<li class="share-facebook">';
print '<div><a href="javascript:window.open(';
print "'http://www.facebook.com/sharer.php?u='+encodeURIComponent(location.href),'sharewindow','width=550, height=450, personalbar=0, toolbar=0, scrollbars=1, resizable=!');";
print '">Facebook</a></div>';
print '</li>';

print '<!-- Twitter -->';
print '<li class="share-twitter">';
print '<div><a href="javascript:window.open(';
print "'http://twitter.com/share?text='+encodeURIComponent(document.title)+'&url='+encodeURIComponent(location.href),'sharewindow','width=550, height=450, personalbar=0, toolbar=0, scrollbars=1, resizable=!')";
print '">Twitter</a></div>';
print '</li>';

print '<!-- LINE -->';
print '<li class="share-line">';
print '<div><a href="javascript:window.open(';
print "'http://line.me/R/msg/text/?'+encodeURIComponent(document.title)+'%20'+encodeURIComponent(location.href),'sharewindow','width=550, height=450, personalbar=0, toolbar=0, scrollbars=1, resizable=!')";
print '">LINE</a></div>';
print '</li>';

print '</ul>';
print '</div>';

print "<br>\n";
print "<br>\n";
print "<br>\n";
}

	my $banner = '';
	if ($term) {$banner = read_file("../$board/s/banner2.txt");}
	unless(trim($banner)) {$banner = read_file("../$board/banner2.txt");}
	if (trim($banner)) {print $banner."<br>\n";}
	if (index($bbs,'_kako') < 0 ) {
		print '<hr><a href="./" target="_top">',enc_str('掲示板に戻る'),'</a>';
	} else {
		print "<hr><a href=\"../test/kako.cgi/$board\" target=\"_top\">",enc_str('過去ログ倉庫に戻る'),'</a>';
	}
	print " <a href=\"$fname/\">",enc_str('全部'),'</a>';
	my $end = $start - 1;
	if ($end < 1) {$end = 1;}
	my $begin = $end - 99;
	if ($begin < 1) {$begin =1;}
	print " <a href=\"$fname/$begin\-$end\">",enc_str('前100'),'</a>';
	$begin = $count;
	if ($begin > $max) {$begin = $max;}
	$end = $begin + 99;
	if ($end > $max) {$end = $max;}
	print " <a href=\"$fname/$begin\-$end\">",enc_str('次100'),'</a>';
	print " <a href=\"$fname/l50\">",enc_str('最新50'),"</a>\n";
	if ($mode) {
		print '<form method=POST action="../test/bbs.cgi?guid=ON"'.($img_mode ? ' ENCTYPE="multipart/form-data">' : '>')."\n";
		print enc_str("<input type=submit value=\"書き込む\" name=submit><br class=\"smartphone\">\n");
		print enc_str("名前： <input name=FROM size=19").$c_name.">\n";
		print enc_str("<br class=\"smartphone\">E-mail<font size=1> (省略可) </font>: <input name=mail size=19").$c_mail."><br>\n";
		if ($img_mode) {
			print enc_str('画像：<input type ="file" name ="file" size="60" style="width:50%;"><br>')."\n";
		}

		#サイトキー
		if($site_key_if){

			if($secret_key){
			print '<div class="g-recaptcha" data-sitekey=';
			print "$site_key".'></div>';
			}elsif($h_secret_key){
			print '<div class="h-captcha" data-sitekey=';
			print "$site_key".'></div>';
			}

		}

		print "<textarea rows=5 cols=70 wrap=off name=MESSAGE></textarea>\n";
		print "<input type=hidden name=bbs value=$bbs>\n";
		print "<input type=hidden name=key value=$key>\n";
		my $time = time();
		print "<input type=hidden name=time value=$time>\n";
		print "</form>\n";
	}
	print "</body>\n";
	print "</html>\n";
}

sub error_exit {
	my $text = shift;
	if ($head) {
		print "Content-type: text/html\n\n";
		print "<html>\n";
		print "<head>\n";
		print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=$ifo{'outchr'}\">\n";
		print "<title>",enc_str("エラーですよ"),"</title>\n";
		print "<body>\n";
		print "<dl>\n";
	}
	print "</dl>\n";
	print '<br>',enc_str($text),"<br>\n";
	print "</body>\n";
	print "</html>\n";
	exit(0);
}
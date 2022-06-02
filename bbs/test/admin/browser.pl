use utf8;
use File::Path;

require "$admcmd/z_bbs.pl";
$opt = $cgi->param('opt');
my $submit = $cgi->param('submit');
$cmd_str = '<input type="hidden" name="cmd" value="browser">'."\n";

if ($opt eq 'modoru') {
	menu_bbs();
} elsif ($opt eq 'title') {
	edit_title($submit);
	print $cmd_str;
} elsif ($opt eq 'title_exe') {
	exe_title($submit);
	print $cmd_str;
} elsif ($opt eq 'key') {
	edit_key($submit);
} elsif ($opt eq 'key_exe') {
	exe_key($submit);
} elsif ($opt eq 'edit') {
	edit_page($submit);
} elsif ($opt eq 'edit_exe') {
	exe_page($submit);
} elsif ($opt eq 'write') {
	write_browser($submit);
} else {
	menu_bbs($submit);
}

sub menu_bbs {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("専ブラ設定");
	echo "<td><input type='radio' name='opt' value='title'>掲示板タイトル編集<br>\n";
	echo "<input type='radio' name='opt' value='key'>BBS_KEY編集<br>\n";
	my ($bbs_title,$bbs_subtitle) = get_bbs_title();
	if ($ifo{'bbskey'} ne '' && -d '../2ch_browser' && $bbs_title ne '') {
		echo "<input type='radio' name='opt' value='write'>専ブラ設定更新<br>\n";
	}
	submit_select();
	print $cmd_str;
}

sub edit_key {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("BBS_KEY編集");
	echo "<td>BBS_KEY（半角）<br>\n";
	print "<input type='text' name='bbs_key' value='$ifo{'bbskey'}'>\n";
	print "<input type='hidden' name='old_key' value='$ifo{'bbskey'}'>\n";
	submit_exe();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='key_exe'>\n";
}

sub exe_key {
	my $submit = shift;
	if ($submit eq $modoru) {
		menu_bbs();
		footer();
	}
	my $bbs_key = $cgi->param('bbs_key');
	my $old_key = $cgi->param('old_key');
	header("BBS_KEY更新");
	my $er = '';
	if ($old_key eq '' && $bbs_key eq '') {
		$er = "BBS_KEYが設定されていません<br>\n";
	} elsif ($old_key eq $bbs_key) {
		$er = "BBS_KEYは変更しませんでした<br>\n";
	} elsif ($bbs_key =~ /[^a-zA-Z0-9._]/) {
		$er = "BBS_KEYに使用できない文字が有ります<br>\n";
	} elsif ($bbs_key eq '') {
		rmtree("../$old_key");
		$ifo{'bbskey'} = $bbs_key;
		write_ifo();
		$er = "BBS_KEY及び専ブラ設定を削除しました<br>\n";
	} elsif (-d "../$bbs_key") {
		$er = "同じ名前のディレクトリが有るので別の名称にして下さい<br>\n";
	} elsif ($old_key ne '') {
		rename("../$old_key","../$bbs_key");
		$ifo{'bbskey'} = $bbs_key;
		write_ifo();
		$er = "BBS_KEYを変更しました<br>\n";
	} else {
		mkdir("../$bbs_key");
		$ifo{'bbskey'} = $bbs_key;
		write_ifo();
		$er = "BBS_KEYを登録しました<BR>\n";
	}
	echo "<td>$er";
	submit_ret();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='modoru'>\n";
}

sub write_browser {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("専ブラ設定更新");
	print "<td>\n";
	if (unlink glob("../$ifo{'bbskey'}/*")) {
		echo "旧設定消去<br>\n"
	}
	my $text = '';
	$text = rewrite_bbstxt();
	if ($text eq '') {
		echo "bbs.txt更新<br>\n";
	} else {
		echo $text;
		submit_ret();
		footer();
	}
	my ($bbs_title,$bbs_subtitle) = get_bbs_title();
	$bbs_title = val_sjis($bbs_title);
	if (put_bbsmenu($bbs_title)) {
		echo "bbsmenu更新<br>\n";
	} else {
		echo "bbsmenu更新失敗<br>\n";
	}
	$text = val_sjis(read_file('../bbs.txt'));
	@bbs_txt = split("\n",trim($text));
	shift(@bbs_txt);
	shift(@bbs_txt);
	my @list;
	if (jane($bbs_title)) {push(@list,'jane<>Jane系ブラウザ');}
	if (katjusha($bbs_title)) {push(@list,'katjusha<>かちゅーしゃ');}
	if (gikonavi($bbs_title)) {push(@list,'gikonavi<>ギコナビ');}
	if (live2ch($bbs_title)) {push(@list,'live2ch<>Live 2ch');}
	if (abone2($bbs_title)) {push(@list,'abone<>A Bone2');}
	if (hotzonu($bbs_title)) {push(@list,'hotzonu<>ホットゾヌ２');}
	if (softalk($bbs_title)) {push(@list,'softalk<>SofTalk WEB');}
	if (twintail($bbs_title)) {push(@list,'twintail<>twintail及びOpenTwin based on twintail');}
	if (emanon($bbs_title)) {push(@list,'emanon<>えまのん');}
	if (duawin($bbs_title)) {push(@list,'duawin<>Duawin');}
	if (put_howto(@list)) {
		echo "設定方法更新<br>\n"
	} else {
		echo "設定方法更新失敗<br>\n";
	}
	submit_ret();
}

sub put_bbsmenu {
	my $bbs_title = shift;
	my $bbs_list = get_bbs_list('category_bbs','tate',' ');
	$bbs_list = val_sjis($bbs_list);
	open(MN,"> ../$ifo{'bbskey'}/bbsmenu.html") or return(0);
	print MN "<html>\n<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=shift_jis\">\n";
	print MN "<title>".$bbs_title."</title></head>\n<body>\n";
	print MN "<br>\n$bbs_list\n";
	print MN "</body>\n</html>\n";
	close(MN);
	return(1);
}

sub put_howto {
	my %set = get_setting_txt('ifo');
	my $back = '';
	if ($set{'BG_PICTURE'} ne '') {
		$back = " background=\"$set{'BG_PICTURE'}\"";
	}
	my $top = get_top();
	if ($top eq $ifo{'site_top'}) {
		$top = '../';
	} else {
		$top = $ifo{'site_top'};
	}
	open(MN,"> ../$ifo{'bbskey'}/index.html") or return(0);
	print MN "<html>\n\n<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=shift_jis\">\n";
	print MN "<title>".enc_sjis('専ブラ設定')."</title>\n</head>\n<body$back>\n";
	print MN "<br><br>\n<div align=\"center\">\n<table border=\"1\" width=\"535\" bgcolor=\"#FFFFFF\">\n<tr>\n<td width=\"525\">\n";
	print MN "<h2 style=\"mso-char-indent-count: 1.0; mso-char-indent-size: 10.5pt; line-height: 200%\" align=\"center\">";
	print MN enc_sjis("２ちゃんねる専用ブラウザ設定方法") . "</h2>\n";
	print MN "<p align=\"center\">\n";
	foreach $data(@_) {
		my ($file,$name) = split('<>',$data);
		print MN "<a href=\"$file.html\">";
		print MN enc_sjis($name)."</a><br>\n";
	}
	print MN "</p>\n<p align=\"center\">\n<a href=\"$top\" target=\"_top\">TOP</a>\n</p><br>\n";
	print MN "</td>\n</tr>\n</table>\n</div>\n\n</body>\n\n</html>\n";
	close(MN);
	return(1);
}

sub server_board {
	my $address = shift;
	$address =~ s/\/$//;
	my $pos = rindex($address,'/');
	my $board = substr($address,$pos + 1);
	$address = substr($address,0,$pos);
	$address = substr($address,index($address,'://') + 3);
	return($address,$board);
}

sub bbskey_txt {	#ギコナビ＆Duawin用ファイル出力
	if (-e "../$ifo{'bbskey'}/$ifo{'bbskey'}.txt") {return(1);}
	open(BR,"> ../$ifo{'bbskey'}/$ifo{'bbskey'}.txt") or return(0);
	foreach $data(@bbs_txt) {
		my ($address,$name) = split('<>',$data);
		if ($address eq 'category') {
			print BR "[".$name."]\r\n";
		} else {
			print BR "$name=$address\r\n";
		}
	}
	close(BR);
	return(1);
}

sub hotzonu {
	my $title = shift;
	if ($ifo{'outchr'} eq 'utf-8') {return(0);}
	my $chrset = 'SJIS';
	if ($ifo{'outchr'} eq 'euc-jp') {$chrset = 'EUC';}
	my $text = "[SITE]\r\n";
	$text .= "NAME=$title\r\n";
	$text .= "URL=$ifo{'site_top'}\r\n";
	$text .= "SITEID=$ifo{'bbskey'}\r\n";
	$text .= "BBSTYPE=2chScript\r\n";
	$text .= "CHARSET=$chrset\r\n";
	my $tmp = $ifo{'site_top'};
	if (index($tmp,'.') > 0) {
		$tmp = substr($tmp,0,index($tmp,'.'));
	}
	$text .= "INCLUDE=$tmp\r\n";
	$text .= "LOCALRULE=http://<boardpath>/<bbs>/head.txt\r\n";
	$tmp = val_sjis($member{'name'});
	$text .= "ADMIN=$tmp\r\n\r\n";
	$text .= "[BOARDLIST]\r\nCOUNT=1\r\nCURRENT=0\r\n";
	$text .= "BOARDLIST1=$ifo{'site_top'}bbs.txt\r\n\r\n";
	$text .= "[NINKINET]\r\nID=$ifo{'bbskey'}\r\n";
	unless (write_file("../$ifo{'bbskey'}/site.ini",\$text,0)) {return(0);}
	$text = read_file('../2ch_browser/ParseBoard.giko');
	substr($text,index($text,'SITE_TOP'),length('SITE_TOP'),$ifo{'site_top'});
	unless (write_file("../$ifo{'bbskey'}/ParseBoard.giko",\$text,0)) {return(0);}
	open(BR,"> ../$ifo{'bbskey'}/board.dat") or return(0);
	print BR "2\r\n";
	foreach $data(@bbs_txt) {
		my ($address,$name) = split('<>',$data);
		if ($address eq 'category') {
			print BR "$name\t0\r\n";
		} else {
			my ($server,$board) = server_board($address);
			print BR "\t$server\t$board\t$name\t\t\t\t$chrset\r\n";
		}
	}
	close(BR);
	put_html('hotzonu',$title) or return(0);
	echo "ホットゾヌ２設定更新<br>\n";
	return(1);
}

sub jane {
	my $title = shift;
	if ($ifo{'outchr'} eq 'utf-8') {return(0);}
	if ($ifo{'outchr'} eq 'euc-jp') {return(0);}
	put_html_list('jane',$title) or return(0);
	echo "Jane系設定更新<br>\n";
	return(1);
}

sub katjusha {
	my $title = shift;
	if ($ifo{'outchr'} eq 'utf-8') {return(0);}
	if ($ifo{'outchr'} eq 'euc-jp') {return(0);}
	open(BR,"> ../$ifo{'bbskey'}/katjusha.txt") or return(0);
	foreach $data(@bbs_txt) {
		my ($address,$name) = split('<>',$data);
		if ($address eq 'category') {next;}
		my ($server,$board) = server_board($address);
		print BR "$server\t$board\t$name\r\n";
	}
	close(BR);
	put_html_txt('katjusha',$title) or return(0);
	echo "かちゅーしゃ設定更新<br>\n";
	return(1);
}

sub gikonavi {
	my $title = shift;
	if ($ifo{'outchr'} eq 'utf-8') {return(0);}
	if ($ifo{'outchr'} eq 'euc-jp') {return(0);}
	bbskey_txt() or return(0);
	put_html('gikonavi',$title) or return(0);
	echo "ギコナビ設定更新<br>\n";
	return(1);
}

sub duawin {
	my $title = shift;
	if ($ifo{'outchr'} eq 'utf-8') {return(0);}
	if ($ifo{'outchr'} eq 'euc-jp') {return(0);}
	bbskey_txt() or return(0);
	put_html('duawin',$title) or return(0);
	echo "duawin設定更新<br>\n";
	return(1);
}

sub live2ch {
	my $title = shift;
	if ($ifo{'outchr'} eq 'utf-8') {return(0);}
	if ($ifo{'outchr'} eq 'euc-jp') {return(0);}
	open(BR,"> ../$ifo{'bbskey'}/live2ch.txt") or return(0);
	foreach $data(@bbs_txt) {
		my ($address,$name) = split('<>',$data);
		if ($address eq 'category') {next;}
		my ($server,$board) = server_board($address);
		print BR "\t$server\t$board\t$name\r\n";
	}
	close(BR);
	put_html_txt('live2ch',$title) or return(0);
	echo "Live 2ch設定更新<br>\n";
	return(1);
}

sub abone2 {
	my $title = shift;
	if ($ifo{'outchr'} eq 'utf-8') {return(0);}
	if ($ifo{'outchr'} eq 'euc-jp') {return(0);}
	put_html_list('abone',$title) or return(0);
	echo "A Bone2設定更新<br>\n";
	return(1);
}

sub twintail {
	my $title = shift;
	if ($ifo{'outchr'} eq 'utf-8') {return(0);}
	if ($ifo{'outchr'} eq 'euc-jp') {return(0);}
	put_twintail($title) or return(0);
	echo "twintail系設定更新<br>\n";
	return(1);
}

sub emanon {
	my $title = shift;
	my $outchr = $ifo{'outchr'};
	if ($outchr eq 'shift_jis') {$outchr = 'Shift_JIS';}
	my ($server,$path) = server_path($ifo{'site_top'});
	@list = check_path($path);
	my $cnt = shift(@list);
	unless($cnt) {return(0);}
	unshift(@list,$server);
	open(BR,"> ../$ifo{'bbskey'}/Comp2ch.2CA") or return(0);
	print BR "[$ifo{'bbskey'}.2CM]\r\n";
	print BR "Name=$title\r\n";
	$path =~ s/\/$//;
	if ($path ne '') {print BR "ItaRootPath=$path\r\n";}
	print BR "ReadCGIName=$path/test/read.cgi\r\n";
	print BR "WriteCGIName=$path/test/bbs.cgi\r\n";
	print BR "PathInfo=Y\r\n";
	print BR "DatEnable=Y\r\n";
	print BR "MaxResuCount=$ifo{'max_res'}\r\n";
	$cnt = 0;
	foreach $data(@list) {
		print BR "ExistsServers".sprintf("%04d",$cnt)."=$data\r\n";
		$cnt++;
	}
	print BR "\r\n";
	close(BR);
	open(BR,"> ../$ifo{'bbskey'}/$ifo{'bbskey'}.2CM") or return(0);
	print BR '[*BBS]'."\r\n";
	print BR "DefaultEncoding=$outchr\r\n";
	print BR "UseAuth=N\r\nAuthUserID=\r\nAuthPassword=\r\n\r\n";
	my $cat_name = '';
	foreach $data(@bbs_txt) {
		my ($address,$name) = split('<>',$data);
		if ($address eq 'category') {
			$cat_name = $name;
			next;
		}
		print BR "[$address]\r\n";
		print BR "Name=$name\r\n";
		print BR "Category=".($cat_name eq '' ? $title : "$cat_name\@$title")."\r\n";
		my ($server,$board) = server_board($address);
		$server =~ s/\//\\/g;
		print BR "Filename=$server\\$board\\index2.2ci\r\n";
		($server) = server_path($address);
		print BR "Servers0000=$server\r\n\r\n";
	}
	close(BR);
	put_html('emanon',$title) or return(0);
	echo "えまのん設定更新<br>\n";
	return(1);
}

sub softalk {
	my $title = shift;
	my $outchr = $ifo{'outchr'};
	if ($outchr eq 'shift_jis') {$outchr = 'Shift_JIS';}
	my ($server,$path) = server_path($ifo{'site_top'});
	@list = check_path($path);
	my $cnt = shift(@list);
	unless($cnt) {return(0);}
	unshift(@list,$server);
	$path =~ s/\/$//;
	open(BR,"> ../$ifo{'bbskey'}/SofTalkWEB.txt") or return(0);
	print BR "SITE_NAME\t=\t$title\r\n";
	print BR "DOMAIN_NAME\t=";
	foreach $data(@list) {
		print BR "\t".server_name($data);
	}
	print BR "\r\n";
	print BR "FOLDER\t\t=\t$ifo{'bbskey'}\r\n";
	print BR "ADDRESS\t\t=\t[SCHEME]/[HOST_NAME]\r\n";
	print BR "BOAD\t\t=\t[ADDRESS]$path/[GENRE]\r\n";
	print BR "POST_URL1\t=\t[ADDRESS]$path\r\n";
	print BR "POST_URL2\t=\t[BOAD]\r\n";
	print BR "POST_FILE\t=\t$path/test/bbs.cgi\r\n";
	print BR "POST_MULTI\t=\tFALSE\r\n";
	print BR "POST_FORMAT\t=\tbbs=[GENRE]&time=[POST_TIME]&FROM=[POST_NAME]&mail=[POST_MAIL]&MESSAGE=[POST_MESSAGE]\r\n";
	print BR "POST_FORMAT1\t=\t[POST_FORMAT]&subject=[POST_TITLE]&submit=".enc_sjis("新規スレッド作成")."\r\n";
	print BR "POST_FORMAT2\t=\t[POST_FORMAT]&key=[THREAD]&submit=".enc_sjis("書き込む")."\r\n";
	print BR "POST_ADJUST\t=\t-0.5\r\n";
	print BR "SUBJECT_URL\t=\t$path/[GENRE]/subject.txt\r\n";
	print BR "SUBJECT_FORMAT\t=\t[THREAD].dat<>[TITLE] ([COUNT])\r\n";
	print BR "SUBJECT_ALL\t=\tFALSE\r\n";
	print BR "SUBJECT_CODE\t=\t$outchr\r\n";
	print BR "HEAD_TYPE\t=\t0\r\n";
	print BR "HEAD_URL\t=\t$path/[GENRE]/head.txt\r\n";
	print BR "HEAD_CODE\t=\t$outchr\r\n";
	print BR "SETTING_TYPE\t=\t0\r\n";
	print BR "SETTING_URL\t=\t$path/[GENRE]/SETTING.TXT\r\n";
	print BR "SETTING_CODE\t=\t$outchr\r\n";
	print BR "DAT_URL1\t\t=\t$path/[GENRE]/dat/[THREAD].dat\r\n";
	print BR "DAT_URL2\t\t=\r\n";
	print BR "DAT_CODE\t=\t$outchr\r\n";
	print BR "DAT_ALL\t\t=\tFALSE\r\n";
	print BR "DAT_MODIFIED\t=\tTRUE\r\n";
	print BR "CGI_URL\t\t=\t[ADDRESS]$path/test/read.cgi/[GENRE]/[THREAD]/\r\n";
	print BR "MENU_TYPE\t=\t0\r\n";
	print BR "MENU_HOST\t=\t$server\r\n";
	$path .= '/';
	$path =~ s/^\///;
	print BR "MENU_FILE\t=\t$path"."$ifo{'bbskey'}/bbsmenu.html\r\n";
	print BR "MENU_GNR\t=\tTRUE\r\n";
	print BR "MENU_CODE\t=\tShift_JIS\r\n";
	print BR "RES_SPLIT\t=\t\r\n";
	print BR "RES_FORMAT1\t=\t[RES_NAME]<>[RES_MAIL]<>[RES_DATE_ID]<>[RES_MESSAGE]<>[RES_TITLE]\r\n";
	print BR "RES_FORMAT2\t=\t\r\n";
	my $tmp = $ifo{'max_res'} +1;
	print BR "RES_MAX\t\t=\t$tmp\r\n";
	print BR "KAKO_LOG\t=\tTRUE\r\n";
	print BR "KAKO_URL\t=\t/$path"."[GENRE]_kako/dat/[THREAD].dat\r\n";
	print BR "KAKO_URL2\t=\t\r\n";
	print BR "KAKO_SPLIT\t=\t\r\n";
	print BR "KAKO_FORMAT\t=\t[RES_FORMAT1]\r\n\r\n";
	close(BR);
	put_html_txt('softalk',$title) or return(0);
	echo "SofTalk Web設定更新<br>\n";
	return(1);
}

sub server_name {
	my $name = shift;
	my $posL = index($name,'.');
	my $posR = index($name,'.co.jp');
	if ($posR < 0) {$posR = rindex($name,'.ne.jp');}
	if ($posR < 0) {$posR = rindex($name,'.or.jp');}
	if ($posR < 0) {$posR = rindex($name,'.gr.jp');}
	if ($posR < 0) {$posR = rindex($name,'.ac.jp');}
	if ($posR < 0) {$posR = rindex($name,'.go.jp');}
	if ($posR < 0) {$posR = rindex($name,'.');}
	if ($posL == $posR) {return($name);}
	return(substr($name,$posL));
}

sub server_path {
	my $address = shift;
	$address = substr($address,index($address,'://') + 3);
	my $pos = index($address,'/');
	my $path = substr($address,$pos);
	$address = substr($address,0,$pos);
	return ($address,$path);
}

sub check_path {
	my $top = shift;
	my @list = read_tbl('../ifo/category.cgi');
	my $flg = @list;
	unless($flg) {return(1);}
	my @ret;
	foreach $data(@list) {
		if (index($data,'http://') < 0) {next;}
		my ($server,$path) = server_path(trim($data));
		if ($path ne $top) {return(0);}
		push(@ret,$server);
	}
	return(1,@ret);
}

sub put_html {
	my $browser = shift;
	my $title = shift;
	my $page = read_file("../2ch_browser/$browser.html");
	change_str(\$page,$title);
	return(write_file("../$ifo{'bbskey'}/$browser.html",\$page,0));
}

sub put_html_txt {
	my $browser = shift;
	my $title = shift;
	my $page = read_file("../2ch_browser/$browser.html");
	change_str(\$page,$title);
	my $fname = "../$ifo{'bbskey'}/$browser.txt";
	if ($browser eq 'softalk') {$fname = "../$ifo{'bbskey'}/SofTalkWEB.txt";}
	my $text = read_file($fname);
	substr($page,index($page,'BROWSER_TXT'),length('BROWSER_TXT'),$text);
	return(write_file("../$ifo{'bbskey'}/$browser.html",\$page,0));
}

sub put_html_list {
	my $browser = shift;
	my $title = shift;
	my $page = read_file("../2ch_browser/$browser.html");
	change_str(\$page,$title);
	my $text = '';
	foreach $data(@bbs_txt) {
		my ($adr,$name) = split('<>',$data);
		if ($adr eq 'category') {
			$text .= "$name<br>\n";
		} else {
			$text .= "<input type=\"text\" size=\"50\" value=\"$adr\" readonly=\"readonly\" onfocus=\"this.select()\">\n";
			$text .= "<input type=\"text\" size=\"25\" value=\"$name\" readonly=\"readonly\" onfocus=\"this.select()\"><br>\n";
		}
	}
	substr($page,index($page,'BBS_LIST'),length('BBS_LIST'),$text);
	return(write_file("../$ifo{'bbskey'}/$browser.html",\$page,0));
}

sub put_twintail {
	my $page = read_file("../2ch_browser/twintail.html");
	my $title = shift;
	change_str(\$page,$title);
	my $text = '';
	foreach $data(@bbs_txt) {
		$text .= "<tr>\n";
		my ($adr,$name) = split('<>',$data);
		if ($adr eq 'category') {
			$text .= "<td colspan=\"3\" align=\"center\">$name</td>\n";
		} else {
			my ($server,$board) = server_board($adr);
			$text .= "<td><input type=\"text\" size=\"25\" value=\"$name\" readonly=\"readonly\" onfocus=\"this.select()\"></td>\n";
			$text .= "<td><input type=\"text\" size=\"40\" value=\"$server\" readonly=\"readonly\" onfocus=\"this.select()\"></td>\n";
			$text .= "<td><input type=\"text\" size=\"20\" value=\"$board\" readonly=\"readonly\" onfocus=\"this.select()\"></td>\n";
		}
		$text .= "</tr>\n";
	}
	substr($page,index($page,'BBS_LIST'),length('BBS_LIST'),$text);
	return(write_file("../$ifo{'bbskey'}/twintail.html",\$page,0));
}

sub change_str {
	my $page = shift;
	my $title = shift;
	my $top = get_top();
	$$page =~ s/BBS_TITLE/$title/g;
	$$page =~ s/BBS_KEY/$ifo{'bbskey'}/g;
	$$page =~ s/BBS_TOP/$top/g;
	$$page =~ s/src="/src="..\/2ch_browser\//g;
}
1;
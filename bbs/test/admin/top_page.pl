use utf8;
use Time::HiRes qw(gettimeofday);

require "$admcmd/z_bbs.pl";
require "$subcmd/info.pl";	#時間と文字変換

$opt = $cgi->param('opt');
my $submit = $cgi->param('submit');
$cmd_str = '<input type="hidden" name="cmd" value="top_page">'."\n";

if ($opt eq 'modoru') {
	menu_bbs();
} elsif ($opt eq 'title') {
	edit_title($submit);
	print $cmd_str;
} elsif ($opt eq 'title_exe') {
	exe_title($submit);
	print $cmd_str;
} elsif ($opt eq 'edit') {
	edit_page($submit);
} elsif ($opt eq 'edit_exe') {
	exe_page($submit);
} elsif ($opt eq 'file') {
	edit_file();
} elsif ($opt eq 'file_exe') {
	exe_file($submit);
} else {
	menu_bbs($submit);
}

sub menu_bbs {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("トップページ編集");
	echo "<td><input type='radio' name='opt' value='title'>掲示板タイトル編集<br>\n";
	echo "<input type='radio' name='opt' value='file'>表示ファイル設定<br>\n";
	echo "<input type='radio' name='opt' value='edit'>トップページ更新<br>\n";
	submit_select();
	print $cmd_str;
}

sub edit_file {
	open(TOP,"<../index.cgi") or error_exit("index.cgiが存在しません");
	flock(TOP,1);
	my $file1 = <TOP>;
	my $file2 = <TOP>;
	$file1 = <TOP>;
	$file2 =  <TOP>;
	my $file3 = <TOP>;
	close(TOP);
	header("表示ファイル設定");
	$file1 =~ /'(.*)'/;
	$file1 = $1;
	$file2 =~ /'(.*)'/;
	$file2 = $1;
	$file3 =~ /'(.*)'/;
	$file3 = $1;
	echo "<td>パソコン用ページ<br> <input type='text' size='30' name='file1' value='$file1'></td><tr><td>";
	echo "携帯用ページ<br> <input type='text' size='30' name='file2' value='$file2'></td><tr><td>";
	echo "スマートフォン用ページ<br> <input type='text' size='30' name='file3' value='$file3'>";
	submit_exe();
	print "<input type='hidden' name='opt' value='file_exe'>\n";
	print $cmd_str;
}

sub exe_file {
	my $submit = shift;
	if ($submit eq $modoru) {
		menu_bbs();
		footer();
	}
	header("表示ファイル設定");
	my $file1 = $cgi->param('file1');
	my $file2 = $cgi->param('file2');
	my $file3 = $cgi->param('file3');
	my $tmp = time().'.tmp';
	if(open(TOP,"+<../index.cgi")) {
		if(open(TMP,"+>$tmp")) {
			my $line = <TOP>;
			print TMP $line;
			$line = <TOP>;
			print TMP $line;
			print TMP '$file1 = '."'$file1';\n";
			print TMP '$file2 = '."'$file2';\n";
			print TMP '$file3 = '."'$file3';\n";
			$file1 = <TOP>;
			$file2 = <TOP>;
			$file3 = <TOP>;
			while(<TOP>) {
				print TMP;
			}
			seek(TMP,0,0);
			seek(TOP,0,0);
			while(<TMP>) {
				print TOP;
			}
			truncate(TOP,tell(TOP));
			close(TOP);
			close(TMP);
			unlink $tmp;
			echo "<td>トップページを書き換えました\n";
 		} else {
			close(TOP);
			echo "<td>トップページの書き換えに失敗しました\n";
		}
 	} else {
		echo "<td>トップページの書き換えに失敗しました\n";
	}
	print $cmd_str;
	print "<input type='hidden' name='opt' value='file_exe'>\n";
	submit_ret();
}

sub edit_page {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("トップページ設定＆更新");
	my $cnt = category_cnt();
	my ($index_list,$index_pattern,$menu_list,$target,$menu_pattern) = split("\n",read_file('../ifo/page_setting.txt'));
	echo "<td align='center'>bbsmenu.htmlのBBS_LIST設定<br>（パソコン用の設定です）</td></tr>\n";
	echo "<tr align='center'><td>表示内容<br>\n";
	print "<select name='menu_list' size='1'>\n";
	if ($cnt) {
		echo "<option value='category_bbs'".($menu_list eq 'category_bbs' ? ' selected' : '').">カテゴリとボード</option>\n";
		echo "<option value='category'".($menu_list eq 'category' ? ' selected' : '').">カテゴリ名称のみ</option>\n";
	}
	echo "<option value='bbs'".($menu_list eq 'bbs' ? ' selected' : '').">全てのボード</option>\n";
	print "</select><br>\n";
	echo "ターゲット<br>\n";
	print "<select name='target' size='1'>\n";
	echo "<option value=' '>標準（無し）</option>\n";
	echo "<option value=' target=\"_self\"'".($target eq ' target="_self"' ? ' selected' : '').">同じウィンドウ</option>\n";
	echo "<option value=' target=\"_top\"'".($target eq ' target="_top"' ? ' selected' : '').">ページ全体</option>\n";
	echo "<option value=' target=\"_blank\"'".($target eq ' target="_blank"' ? ' selected' : '').">新規ウィンドウ</option>\n";
	print "</select><br>\n";
	echo "表示形式<br>\n";
	print "<select name='menu_pattern' size='1'>\n";
	echo "<option value='tate'".($menu_pattern eq 'tate' ? ' selected' : '').">縦１列</option>\n";
	echo "<option value='yoko'".($menu_pattern eq 'yoko' ? ' selected' : '').">横に並べる</option>\n";
	print "</select></td></tr>\n";
	echo "<tr align='center'><td>mobile.htmlのBBS_LIST設定<br>（携帯用の設定です）</td></tr>\n";
	print "<tr align='center'><td>\n";
	echo "表示内容<br>\n";
	print "<select name='index_list' size='1'>\n";
	if ($cnt) {
		echo "<option value='category_bbs'".($index_list eq 'category_bbs' ? ' selected' : '').">カテゴリとボード</option>\n";
		echo "<option value='category'".($index_list eq 'category' ? ' selected' : '').">カテゴリ名称のみ</option>\n";
	}
	echo "<option value='bbs'".($index_list eq 'bbs' ? ' selected' : '').">全てのボード</option>\n";
	print "</select><br>\n";
	echo "表示形式<br>\n";
	print "<select name='index_pattern' size='1'>\n";
	echo "<option value='tate'".($index_pattern eq 'tate' ? ' selected' : '').">縦１列</option>\n";
	echo "<option value='yoko'".($index_pattern eq 'yoko' ? ' selected' : '').">横に並べる</option>\n";
	print "</select>\n";
	submit_exe();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='edit_exe'>\n";
}

sub category_cnt {
	my @list = read_tbl('../ifo/category.cgi');
	my $cnt = @list;
	return($cnt);
}

sub exe_page {
	my $submit = shift;
	if ($submit eq $modoru) {
		menu_bbs();
		footer();
	}
	my $index_list = $cgi->param('index_list');
	my $index_pattern = $cgi->param('index_pattern');
	my $menu_list = $cgi->param('menu_list');
	my $target = $cgi->param('target');
	my $menu_pattern = $cgi->param('menu_pattern');
	header("トップページ設定＆更新");
	my $text = "$index_list\n$index_pattern\n$menu_list\n$target\n$menu_pattern\n";
	if (write_file('../ifo/page_setting.txt',\$text,0)) {
		echo "<td>トップページ設定を更新しました<br>\n";
	} else {
		echo "<td>トップページ設定の更新に失敗しました<br>\n";
	}
	my ($bbs_title,$bbs_subtitle) = get_bbs_title();
	my $er = '';
	if ($bbs_title eq '') { $er = "掲示板タイトルが設定されていません<br>\n";}
	if ($index_list eq '') {$er .= "トップページ設定がされていません<br>\n";}
	if ($er eq '') {$er .= rewrite_bbstxt();}
	unlink glob("../category*.html");
	if ($er eq '') {
		my $bbs_list;
		my $page;
		if (-e '../tmp_bbsmenu.html') {
			$bbs_list = get_bbs_list($menu_list,$menu_pattern,$target);
			$page = read_file('../tmp_bbsmenu.html');
			$page =~ s/BBS_TITLE/$bbs_title/g;
			$page =~ s/BBS_SUBTITLE/$bbs_subtitle/g;
			$page =~ s/tmp_//g;
			$page =~ s/BBS_KEY/$ifo{'bbskey'}/g;
			substr($page,index($page,'BBS_LIST'),length('BBS_LIST'),$bbs_list);
			if (write_file('../bbsmenu.html',\$page,0)) {
				$er .= "bbsmenu.htmlを更新しました<br>\n";
			} else {
				$er .= "bbsmenu.htmlの更新に失敗しました<br>\n";
			}
		} else {
			$er .= "tmp_bbsmenu.htmlが無いので更新しませんでした<br>\n";
		}
		if ($ifo{'bbslist'}) {
			if (put_bbstable($bbs_title)) {
				$er .= "bbstable.htmlを更新しました<br>\n";
			} else {
				$er .= "bbstable.htmlの更新に失敗しました<br>\n";
			}
		}
		if (-e '../tmp_mobile.html') {
			$bbs_title = val_sjis($bbs_title);
			$bbs_subtitle = val_sjis($bbs_subtitle);
			$bbs_list = get_bbs_list($index_list,$index_pattern);
			$bbs_list = val_sjis(get_bbs_list($index_list,$index_pattern));
			$page = read_file('../tmp_mobile.html');
			$page =~ s/BBS_TITLE/$bbs_title/g;
			$page =~ s/BBS_SUBTITLE/$bbs_subtitle/g;
			$page =~ s/tmp_//g;
			substr($page,index($page,'BBS_LIST'),length('BBS_LIST'),$bbs_list);
			if (write_file('../mobile.html',\$page,0)) {
				$er .= "mobile.htmlを更新しました<br>\n";
			} else {
				$er .= "mobile.htmlの更新に失敗しました<br>\n";
			}
		} else {
			$er .= "tmp_mobile.htmlが無いので更新しませんでした<br>\n";
		}
	}
	echo "$er";
	submit_ret();
}

sub put_bbstable {
	my $bbs_title = shift;
	$bbs_title .= enc_str("掲示板リスト");
	my %set = get_setting_txt('ifo');
	my @list = read_tbl('../bbs.txt');
	shift(@list);
	shift(@list);
	my $cnt = @list;
	unless($cnt) {return(0);}
	open(TXT,">../bbstable.html") or return(0);
	print TXT "<html>\n<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=$ifo{'outchr'}\">\n";
	print TXT "<title>".$bbs_title."</title><base target=\"_blank\"></head>\n";
	my $tmp = $set{'BG_PICTURE'};
	if (index($tmp,'../') == 0) {$tmp = substr($tmp,3);}
	print TXT "<body text=\"$set{'TEXT_COLOR'}\" link=\"$set{'LINK_COLOR'}\" alink=\"$set{'ALINK_COLOR'}\" vlink=\"$set{'VLINK_COLOR'}\" background=\"$tmp\">\n";
	my $text = rtrim(read_file('../ifo/banner1.txt'));
	if ($text ne '') {
		print TXT "<br><table border=\"1\" align=\"center\" cellspacing=\"7\" cellpadding=\"3\" width=\"95%\" bgcolor=\"$set{'MENU_COLOR'}\">\n<tr><td>";
		print TXT "<p>".$text."</p>\n";
		print TXT "</td></tr></table>\n";
	}
	print TXT "<br><table border=\"1\" cellspacing=\"11\" cellpadding=\"2\" width=\"95%\" bgcolor=\"$set{'MENU_COLOR'}\" align=center>\n";
	print TXT "<tr><td>\n";
	print TXT "<table border=\"0\" width=\"100%\"><tr><td>\n";
	print TXT "<font size=\"2\">\n";
	print TXT "<a href=\"$ifo{'site_top'}\" target=\"_top\">".enc_str("掲示板トップ")."</a>\n";
	$tmp = '/';
	foreach $data(@list) {
		$data = trim($data);
		my ($adr,$name) = split('<>',$data);
		if ($adr eq 'category') {
			print TXT enc_str('【')."<b>$name</b>".enc_str('】')."\n";
			$tmp = '';
		} else {
			print TXT "$tmp<a href=\"$adr\">$name</a>\n";
			$tmp = '/';
		}
	}
	print TXT $tmp.enc_str("更新日").get_date()."\n";
	print TXT "</font></td></tr></table></td></tr></table>\n";
	$text = rtrim(read_file('../ifo/banner2.txt'));
	if ($text ne '') {
		print TXT "<br><table border=\"1\" align=\"center\" cellspacing=\"7\" cellpadding=\"3\" width=\"95%\" bgcolor=\"$set{'MENU_COLOR'}\">\n<tr><td>";
		print TXT "<p>".$text."</p>\n";
		print TXT "</td></tr></table>\n";
	}
	print TXT "</body>\n</html>\n";
	close (TXT);
	return(1);
}

1;
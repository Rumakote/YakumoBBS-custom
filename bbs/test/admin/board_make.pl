use utf8;

$cmd_str = "<input type='hidden' name='cmd' value='board_make'>\n";

my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');
if ($opt eq 'exe') {
	require "$admcmd/z_setting.pl";
	require "$admcmd/z_permission.pl";
	exe($submit);
	} else {
	menu();
}

sub menu {
	my $title = $cgi->param('TITLE');
	my $subtitle = $cgi->param('SUBTITLE');
	my $board = $cgi->param('board');
	my $category_name = $cgi->param('category_name');
	header('ボード作成');
	echo "<td>ボードディレクトリ</td>\n";
	print "<td><input type ='text' name='board' size='20' value='$board'> ";
	echo "半角英数</td></tr>\n";
	echo "<tr><td>ボードタイトル<br></td>\n";
	print "<td><input type ='text' name='TITLE' size='40' value='$title'>\n";
	echo '</td></tr><tr><td>';
	echo "ボードサブタイトル</td>\n";
	print "<td><input type ='text' name='SUB_TITLE' size='40' value='$subtitle'>\n";
	my $text = trim(read_file('../ifo/category.cgi'));
	if ($category_name eq '') {$category_name = $category;}
	if ($category) {
		$text .= "\n$category_non";
		my @list = split(/\n/,$text);
		if ($category_name eq $category_all) {$category_name = bbs_to_category($bbs);}
		echo "</td></tr><td>カテゴリ</td><td>\n";
		print "<select name='category_name' size='1' style='width:100%'>\n";
		foreach $data(@list) {
			if (index($data,'http://') >= 0) {next;}
			my $check = ($category_name eq $data ? ' selected' : '');
			print "<option value='$data'$check>$data</option>\n";
		}
		print "</select>\n";
	}
	submit_exe();
	print "<input type='hidden' name='opt' value='exe'>\n";
	print $cmd_str;
}

sub exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my $title = $cgi->param('TITLE');
	my $subtitle = $cgi->param('SUB_TITLE');
	my $board = $bbs;
	$bbs = $cgi->param('board');
	if ($subtitle eq '') {$subtitle = $title;}
	my $category_name = $cgi->param('category_name');

	header("ボード作成");
	print "<td>";
	my $er = '';
	my $kako = $bbs . '_kako';
	if ($bbs =~ /[^a-zA-Z0-9]/) {$er .= "ディレクトリ文字には半角英数しか使えません<br>\n";}	
	if ($bbs eq '') {$er = "ディレクトリ名を指定して下さい<br>\n";
	} elsif (-d "../$bbs") {$er .= "そのディレクトリのボードは既に存在するか、ディレクトリに使えない名前です<br>\n";
	} elsif (-e "../$bbs") {$er .= "同名のファイルが存在するのでディレクトリが作成できません<br>\n";}
	if ($title eq '') {$er .= "ボードタイトルが設定されていません<br>\n";}
	if ($er eq '') {
		mkdir "../$bbs" or $er = "$bbs ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$bbs/m" or $er .= "$bbs/m ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$bbs/dat" or $er .= "$bbs/dat ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$bbs/idx" or $er .= "$bbs/idx ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$bbs/img" or $er .= "$bbs/img ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$bbs/smn" or $er .= "$bbs/smn ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$bbs/ifo" or $er .= "$bbs/ifo ディレクトリの作成に失敗しました<br>\n";
		if ($ifo{perm_dir}) {chmod(oct($ifo{'perm_dir'}) , "../$bbs/ifo") or $er .= "$bbs/$ifo のパーミッションの設定に失敗しました<br>\n";}
		copy_login($bbs);
	} else {
		echo "$er";
		submit_ret();
		print $cmd_str;
		print "<input type='hidden' name='TITLE' value='$title'>\n";
		print "<input type='hidden' name='SUBTITLE' value='$subtitle'>\n";
		print "<input type='hidden' name='board' value='$bbs'>\n";
		print "<input type='hidden' name='category_name' value='$category_name'>\n";
		$bbs = $board;
		footer();
	}
	if ($er eq '' && $ifo{'max_kako'}) {
		mkdir "../$kako" or $er = "$kako ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$kako/dat" or $er .= "$kako/dat ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$kako/idx" or $er .= "$bbs/idx ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$kako/img" or $er .= "$kako/img ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$kako/smn" or $er .= "$kako/smn ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$kako/ifo" or $er .= "$kako/ifo ディレクトリの作成に失敗しました<br>\n";
		if ($ifo{perm_dir}) {chmod(oct($ifo{'perm_dir'}) , "../$kako/ifo") or $er .= "$kako/$ifo のパーミッションの設定に失敗しました<br>\n";}
	}
	if ($er eq '') {
		my $text = read_file("../ifo/banner1.txt");
		if ($text ne '') {write_file("../$bbs/banner1.txt",\$text,0);}
		$text = read_file("../ifo/banner2.txt");
		if ($text ne '') {write_file("../$bbs/banner2.txt",\$text,0);}
		$text = read_file("../ifo/m/banner1.txt");
		if ($text ne '') {write_file("../$bbs/m/banner1.txt",\$text,0);}
		$text = read_file("../ifo/m/banner2.txt");
		if ($text ne '') {write_file("../$bbs/m/banner2.txt",\$text,0);}
		$text = read_file("../ifo/last.txt");
		if ($text ne '') {write_file("../$bbs/last.txt",\$text,0);}
		$text = read_file("../ifo/stop.txt");
		if ($text ne '') {write_file("../$bbs/stop.txt",\$text,0);}
		if (-e "../ifo/head.txt") {
			$text = read_file("../ifo/head.txt");
		} else {
			$text = enc_str("<br>\n<ul type=\"square\">\n<li>投稿内容の著作権に注意しましょう<br>\n<li>掲示板であっても世間一般のマナーは守りましょう<br>\n楽しく利用しましょうね<br>\n</ul>\n");
		}
		write_file("../$bbs/head.txt",\$text);
		if (-e "../ifo/foot.txt") {
			$text = read_file("../ifo/foot.txt");
		} else {
			$text = enc_str("<font color=#FFFFFF><b>予告なしに削除する場合があります</b></font>\n");
		}
		write_file("../$bbs/foot.txt",\$text,0);
		my %setting = get_setting_txt('ifo');
		$setting{'TITLE'} = $title;
		$setting{'SUBTITLE'} = $subtitle;
		put_setting($bbs,%setting);
		open(FN,">../$bbs/subject.txt");
		close(FN);
		if ($ifo{'max_kako'}) {
			open(FN,">../$kako/subject.txt");
			close(FN);
			open(FN,">../$kako/index.html");
			print FN "<html>\n<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=$ifo{'outchr'}\">\n";
			print FN "<title>".$title.enc_str(" 過去ログ倉庫")."</title></head><body>\n";
			print FN $title.enc_str("の過去ログ倉庫は");
			print FN "<a href=\"../test/kako.cgi/$bbs/\">".enc_str("こちら")."</a>".enc_str("です\n");
			print FN "</body>\n</html>\n";
			close(FN);
		}
		require "$admcmd/z_indexhtml.pl";
		rewrite_index_html($bbs);
		my $flg = 0;
		$text = '';
		if (open(IN,'+<../ifo/board.cgi')) {
			flock(IN,2);
			my @board = <IN>;
			foreach $data(@board) {
				my ($dir,$name) = split('<>',$data);
				if ($dir ne $bbs) {$text .= $data;}
			}
			seek(IN,0,0);
		} elsif (open(IN,'>../ifo/board.cgi')) {
			flock(IN,2);
			$flg = 1;
		} else {
			$er .="ボード一覧ファイルの更新に失敗しました<br>";
		}
		if ($er eq '') {
			$text .= "$bbs<>$title<>\n";
			print IN $text;
			truncate(IN,tell(IN));
			close(IN);
			if ($flg && $ifo{'perm_file'}) {chmod(oct($ifo{'perm_file'}),'../ifo/board.cgi');}
		}
		if ($er eq '' && $category_name ne '' && $category_name ne $category_non) {
			$text = get_board($category_name);
			$text .= "$bbs<>board<>";
			my @list = split(/\n/,trim($text));
			put_board($category_name,@list);
		}
		my $uri = get_top();
		$er .= "<br><a href='$uri$bbs/' target='_blank'>ボード（ＰＣ）確認</a><br>";
		$er .= "<a href='$uri$bbs/m/' target='_blank'>ボード(携帯)確認</a>";
	}
	echo "$er";
	submit_ret();
}
1;
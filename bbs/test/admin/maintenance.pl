use utf8;

$opt = $cgi->param('opt');
my $submit = $cgi->param('submit');
$cmd_str = '<input type="hidden" name="cmd" value="maintenance">'."\n";

if ($opt eq 'modoru') {
	mainte_menu();
	footer();
} elsif ($opt eq 'edit') {
	mainte_edit($submit);
} elsif ($opt eq 'edit_exe') {
	edit_exe($submit);
} elsif ($opt eq 'exe') {
	mainte_exe($submit);
} elsif ($opt eq 'cancell') {
	require "$admcmd/z_setting.pl";
	if ($ifo{'img_lib'}) {
		require "$dir/test/sub/smn".$ifo{'img_lib'}.'.pl';
	} else {
		require "$dir/test/sub/smn.pl";
	}
	require "$subcmd/page.pl";
	require "$subcmd/mobile.pl";
	mainte_cancell();
} else {
	mainte_menu($submit);
}

sub mainte_menu {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("メンテナンス告知");
	echo "<td><input type='radio' name='opt' value='edit'>メンテナンス告知編集<br>\n";
	echo "<input type='radio' name='opt' value='exe'>メンテナンス告知実行<br>\n";
	echo "<input type='radio' name='opt' value='cancell'>メンテナンス告知解除\n";
	submit_select();
	print $cmd_str;
}

sub mainte_edit {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("メンテナンス告知編集");
	my $text = read_file('../ifo/maintenance.txt');
	my $title = trim(substr($text,0,index($text,"\n")));
	if ($title eq '') {$title = enc_str("メンテナンスのお知らせ");}
	$text = rtrim(substr($text,index($text,"\n")));
	if ($text eq '') {$text = enc_str("○月×日△時より掲示板のメンテナンスを行っております。<br>\n１時間位で終了の予定ですので、しばらく時間を置いてからのご利用をお願い致します。<br>\nご迷惑をお掛けして申し訳ありません。\n");}
	echo "<td align='center'>タイトル<br>";
	print "<input type='text' name='title' value='$title' style='width:60%'><hr>\n";
	echo "告知内容<br>\n";
	print "<textarea name='text' cols=80 rows=30>$text</textarea>\n";
	submit_exe();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='edit_exe'>\n";
}

sub edit_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		mainte_menu();
		footer();
	}
	my $title = $cgi->param('title');
	my $text = $cgi->param('text');
	$text = "$title\n$text";
	header("メンテナンス告知更新");
	if (write_file('../ifo/maintenance.txt',\$text,0)) {
		echo "<td>メンテナンス告知を更新しました。\n";
	} else {
		echo "<td>メンテナンス告知の更新に失敗しました。\n";
	}
	submit_ret();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='modoru'>\n";
}

sub mainte_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("メンテナンス告知表示");
	$ifo{'maintenance'} = 1;
	write_ifo();
	my $text = read_file('../ifo/maintenance.txt');
	my $title = trim(substr($text,0,index($text,"\n")));
	if ($title eq '') {$title = enc_str("メンテナンスのお知らせ");}
	$text = rtrim(substr($text,index($text,"\n")));
	if ($text eq '') {$text = enc_str("掲示板のメンテナンス中です。\n");}
	my $text_mb = '<html><head><meta http-equiv="Content-Type" content="text/html; charset=shift_jis"><title>';
	$text_mb .= val_sjis($title).'</title><body>'.val_sjis($text).'</body></html>';
	my $text_pc = '<html><head><meta http-equiv="Content-Type" content="text/html; charset='.$ifo{'outchr'}.'">';
	$text_pc .= "\n<title>".$title."</title>\n<body>\n<center>\n<table border=2 width=70%><tr><td>".$text."</td></tr></table>\n</center>\n";
	$text_pc .= "</body>\n</html>\n";
	my @list = read_tbl('../ifo/board.cgi');
	foreach $data(@list) {
		my ($board) = split('<>',$data);
		write_file("../$board/index.html",\$text_pc,0);
		write_file("../$board/m/index.html",\$text_mb,0);
	}
	echo "<td>メンテナンス告知を表示します\n";
	submit_ret();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='modoru'>\n";
}

sub mainte_cancell {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("メンテナンス告知解除");
	print "<td>";
	if ($ifo{'maintenance'}) {
		flash_server();
		$ifo{'maintenance'} = 0;
		write_ifo();
		my $tmp = $bbs;
		my @list = read_tbl('../ifo/board.cgi');
		foreach $data(@list) {
			($bbs) = split('<>',$data);
			flash_board();
		}
		$bbs = $tmp;
		echo "メンテナンス告知を解除しました\n";
	} else {
		echo "メンテナンス告知は既に解除済です\n";
	}
	submit_ret();
}

sub flash_server {
	my $text = check_double($ifo{'twenty'});
	if ($text) {echo "ID生成文字列に" . $text . "が重複しています<br>";}
	 my ($hihumi) = split('<>',trim(read_file('../ifo/enigma.cgi')));
	if (!$text && $ifo{'dir'} && $ifo{'c_name'} && $ifo{'c_val'}) {
		$text = check_double($hihumi);
		if ($text) {echo "クッキー暗号用文字列に" . $text . "が重複しています<br>";}
		$text = read_file('./sub/index.js');
		$text =~ s/IZUMO=TAISHA/$ifo{'c_name'}=$ifo{'c_val'}/g;
		$text =~ s/DOMAIN/$ifo{'domain'}/g;
		$text =~ s/PATH/$ifo{'dir'}/g;
		if (write_file('./index.js',\$text)) {
			echo "JavaScript更新<br>\n";
		} else {
			echo "JavaScript更新失敗<br>\n";
		}
	}
	my %sett = get_setting_txt('ifo');
	put_setting('ifo',%sett);
	foreach my $fname ('./admin/cap.pl','./admin/through_trip.pl','./admin/ng_log_board.pl','./admin/ng_log.pl') {
		if (-e $fname) {
			print $fname;
			if (unlink $fname) {
				echo "削除<br>\n";
			} else {
				echo "削除失敗<br>\n";
			}
		}
	}
	conv_ng('../ifo');
}

sub flash_board {
	conv_ng("../$bbs/ifo");
	get_setting($bbs);
	put_setting($bbs,%setting);
	get_subject();
	put_pc();
	put_subback();
	put_mobile();
}

sub conv_ng {
	my $dir = shift;
	my $fname = '';
	my $text = trim(read_file("$dir/nogood.cgi"));
	if ($text) {$text .= "\n";}
	foreach my $name ('nghost.cgi!rh','ngipid.cgi!ip','ngthreadipid.cgi!th','ngword.cgi!wd') {
		my ($fn,$kind) = split('!',$name);
		$fname = "$dir/$fn";
		if (-e $fname) {
			my $tmp = trim(read_file($fname));
			if ($tmp) {
				$tmp =~ s/<>/&lt;&gt;/g;
				$tmp =~ s/\n/\n$kind<>/g;
				$text .= "$kind<>$tmp\n";
			}
			print $fname;
			if(unlink $fname) {
				echo "削除<br>\n";
			} else {
				echo "削除失敗<br>\n";
			}
		}
	}
	if (write_file("$dir/nogood.cgi",\$text,1)) {echo "$dir/nogood.cgi更新<br>\n";}
}
1;

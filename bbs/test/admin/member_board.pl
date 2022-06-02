use utf8;

require "$admcmd/z_admin.pl";
$cmd_str = '<input type="hidden" name="cmd" value="member_board">'."\n";
my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'modoru') {
	select_member();
	footer();
} elsif ($opt eq 'pass') {
	select_pass($submit);
} elsif ($opt eq 'pass_exe') {
	exe_pass($submit);
} elsif ($opt eq 'board') {
	select_board($submit);
} elsif ($opt eq 'board_exe') {
	exe_board($submit);
} elsif ($opt eq 'category') {
	select_category($submit);
} elsif ($opt eq 'category_exe') {
	exe_category($submit);
} else {
	select_member($submit);
}

sub select_member {
	my $submit = shift;
	unless ($member{'level'} & 4) {
		select_pass($submit);
		footer();
	}
	if ($call eq 'owner' || $call eq 'master') {
		select_board();
		footer();
	}
	if ($submit eq $modoru) {
		show_menu();
	}
	header("管理者設定");
	echo "<td><input type='radio' name='opt' value='pass'>パスワード変更<br>\n";
	echo "<input type='radio' name='opt' value='board'>ボード管理者設定<br>\n";
	if ($call eq 'category') {
		print "<center><select name='board' size='1'>\n";
		my @list = split(/\n/,trim(get_board($category)));
		foreach $data(@list) {
			my ($dir,$name) = split('<>',$data);
			my $ck = ($dir eq $bbs ? ' selected' : '');
			print "<option value='$dir'$ck>$name</option>\n";
		}
		print "</select></center>\n";
		echo "<input type='radio' name='opt' value='category'>カテゴリ管理者設定<br>\n";
	}
	submit_select();
	print $cmd_str;
}

sub select_pass {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	pass_word($mem_file);
	print $cmd_str;
	print "<input type='hidden' name='opt' value='pass_exe'>\n";
	submit_exe();
}

sub exe_pass {
	my $submit = shift;
	if ($submit eq $modoru) {
		if ($member{'level'} & 4) {$submit = '';}
		select_member($submit);
		footer();
	}
	header("パスワード変更");
	pass_write();
	print $cmd_str;
}

sub select_board {
	my $submit = shift;
	if ($submit eq $modoru && $cgi->param('flg') eq '') {
		show_menu();
	}
	my $board = $cgi->param('board');
	if ($board eq '') {$board = $bbs;}
	header("$board 管理者設定");
	show_member("../$board/ifo/member.cgi");
	print $cmd_str;
	print "<input type='hidden' name='opt' value='board_exe'>\n";
}

sub exe_board {
	my $submit = shift;
	if ($submit eq $modoru) {
		if ($call eq 'owner' || $call eq 'master') {show_menu();}
		select_member();
		footer();
	}
	header("ボード管理者設定");
	write_member();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='board'>\n";
}

sub select_category {
	my $submit = shift;
	if ($submit eq $modoru && $cgi->param('flg') eq '') {
		show_menu();
	}
	header(dec_str($category)." 管理者設定");
	show_member("$mem_file");
	print $cmd_str;
	print "<input type='hidden' name='opt' value='category_exe'>\n";
}

sub exe_category {
	my $submit = shift;
	if ($submit eq $modoru) {
		select_member();
		footer();
	}
	header("カテゴリ管理者設定");
	write_member();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='category'>\n";
}
1;
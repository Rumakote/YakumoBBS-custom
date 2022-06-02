use utf8;

require "$admcmd/z_admin.pl";
$cmd_str = '<input type="hidden" name="cmd" value="member">'."\n";
my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'modoru') {
	select_member();
	footer();
} elsif ($opt eq 'pass') {
	select_pass($submit);
} elsif ($opt eq 'pass_exe') {
	exe_pass($submit);
} elsif ($opt eq 'owner') {
	select_owner($submit);
} elsif ($opt eq 'owner_exe') {
	exe_owner($submit);
} elsif ($opt eq 'master') {
	select_master($submit);
} elsif ($opt eq 'master_exe') {
	exe_master($submit);
} elsif ($opt eq 'category') {
	select_category($submit);
} elsif ($opt eq 'category_exe') {
	exe_category($submit);
} else {
	select_member($submit);
}

sub select_member {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("管理者設定");
	echo "<td><input type='radio' name='opt' value='pass'>パスワード変更<br>\n";
	if ($call eq 'owner') {echo "<input type='radio' name='opt' value='owner'>オーナー設定<br>\n";}
	echo "<input type='radio' name='opt' value='master'>マスター設定<br>\n";
	echo "<input type='radio' name='opt' value='category'>カテゴリ管理者設定<br>\n";
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
		select_member();
		footer();
	}
	header("パスワード変更");
	pass_write();
	print $cmd_str;
}

sub select_owner {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("オーナー設定変更");
	my $text = read_file("../ifo/owner.cgi");
	my ($name,$id_num,$pass,$level,$cap,$id) = split('<>',$text);
	echo "<td valign='top' align='center'>名前<br>";
	print "<input type='text' name='name' value='$name' size='25' maxlength='20'><br>\n";
	echo "ログインID<br>";
	print "<input type='text' name='id_num' value='$id_num' size='25' maxlength='20'><br>\n";
	echo "キャップ名称<br>";
	print "<input type='text' name='cap' value='$cap' size='25' maxlength='20'><br>\n";
	echo "表示ID<br>";
	print "<input type='text' name='id' value='$id' size='25' maxlength='20'>\n";
	print "<input type='hidden' name='pass' value='$pass'>\n";
	submit_exe();
	print "<input type='hidden' name='opt' value='owner_exe'>\n";
	print $cmd_str;
}

sub exe_owner {
	my $submit = shift;
	if ($submit eq $modoru) {
		select_member();
		footer();
	}
	my $name = trim($cgi->param('name'));
	my $id_num = trim($cgi->param('id_num'));
	my $cap = trim($cgi->param('cap'));
	my $id = trim($cgi->param('id'));
	my $pass = $cgi->param('pass');
	my $er = '';
	if ($name eq '') {
		$er .= "名前が設定されていません<br>\n";
	} else {
		$er .= check_name($name,"名前");
	}
	$er .= check_id_num($id_num);
	if ($cap eq '') {
		$er .= "キャップ名称が設定されていません<br>\n";
	} else {
		$er .= check_name($cap,"キャップ名称");
	}
	if ($id eq '') {
		$er .= "表示IDが設定されていません<br>\n";
	} else {
		$er .= check_id($id);
	}
	if ($er eq '') {
		my $text = "$name<>$id_num<>$pass<>31<>$cap<>$id<>\n";
		if (write_file("../ifo/owner.cgi",\$text,1)) {
			$er = "オーナー設定を変更しました";
		} else {
			$er = "オーナー設定の変更に失敗しました";
		}
	}
	header("オーナー設定変更");
	echo "<td>$er";
	submit_ret();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='modoru'>\n";
}

sub select_master {
	my $submit = shift;
	if ($submit eq $modoru && $cgi->param('flg') eq '') {
		show_menu();
	}
	header("マスター設定");
	show_member("../ifo/master.cgi");
	print $cmd_str;
	print "<input type='hidden' name='opt' value='master_exe'>\n";
}

sub exe_master {
	my $submit = shift;
	if ($submit eq $modoru) {
		select_member();
		footer();
	}
	header("マスター設定");
	write_member();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='master'>\n";
}

sub select_category {
	my $submit = shift;
	if ($submit eq $modoru && $cgi->param('flg') eq '') {
		show_menu();
	}
	header("カテゴリ管理者設定");
	show_member("../ifo/member.cgi",1);
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
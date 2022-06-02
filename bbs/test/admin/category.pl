use utf8;

$opt = $cgi->param('opt');
my $submit = $cgi->param('submit');
$cmd_str = '<input type="hidden" name="cmd" value="category">'."\n";

if ($opt eq 'modoru') {
	category_menu();
	footer();
} elsif ($opt eq 'category_edit') {
	category_edit($submit);
} elsif ($opt eq 'edit_exe') {
	edit_exe($submit);
} elsif ($opt eq 'board_view') {
	board_view($submit);
} elsif ($opt eq 'board_ent') {
	board_ent($submit);
} elsif ($opt eq 'ent_exe') {
	ent_exe($submit);
} elsif ($cgi->param('new_name') ne '') {
	rename_category();
} else {
	category_menu($submit);
}

sub category_menu {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my $name;
	$name = $category_name;
	if ($name eq '') {$name = $cgi->param('category_name');}
	if ($name eq '') {$name = $category;}
	header("カテゴリ設定");
	print "<td valign='top'>\n";
	my $text = read_file('../ifo/category.cgi');
	if ($text ne '') {
		if ($name eq $category_all) {$name = bbs_to_category($bbs);}
		my @list = split(/\n/,trim($text));
		echo "<select name='category_name' size='10'>\n";
		foreach $data(@list) {
			if (index($data,'http') >= 0) {next;}
			if ($data ne '') {
				if ($name eq '' && trim(get_board($data)) eq '') {
					$name = $data;
				}
				my $check = ($name eq $data ? ' selected' : '');
				print "<option value='$data' label='$data' $check>\n";
			}
		}
		print "</td><td valign='top'>\n";
	}
	print "<input type='radio' name='opt' value='category_edit'>\n";
	echo "カテゴリ名称登録<br>\n";
	print "<input type='radio' name='opt' value='board_view'>\n";
	echo "未登録ボード一覧<br>\n";
	if ($text ne '') {
		print "<input type='radio' name='opt' value='board_ent'>\n";
		echo "ボード編集<br>\n";
		echo "<br>カテゴリ名称変更<br>\n";
		echo "<input type='text' name='new_name'>\n";
	}
	print $cmd_str;
	submit_select();
}

sub rename_category {
	my $name = $cgi->param('new_name');
	$category_name = $cgi->param('category_name');
	my $text = trim(read_file('../ifo/category.cgi'));
	@list = split(/\n/,$text);
	if (check_category($name,@list)) {
		category_menu();
		footer();
	}
	$text = '';
	foreach $data(@list) {
		if ($data eq $name) {
		category_menu();
		footer();
		}
	}
	foreach $data(@list) {
		if ($data eq $category_name) {$data = $name;}
		$text .= "$data\n";
	}
	my $flg = write_file('../ifo/category.cgi',\$text,1);
	if ($flg) {
		@list = read_tbl('../ifo/member.cgi');
		$text = '';
		foreach $data(@list) {
			my ($nm,$in,$pw,$lv,$cp,$id,$ct) = split('<>',$data);
			if (trim($ct) eq $category_name) {$data = "$nm<>$in<>$pw<>$lv<>$cp<>$id<>$name\n";}
			$text .= $data;
		}
		$flg = write_file('../ifo/member.cgi',\$text,1);
	}
	$text = trim(read_file('../category.txt'));
	if ($text ne '') {
		@list = split(/\n/,$text);
		$text = '';
		foreach $data(@list) {
			if ($data eq "<>$category_name<>") {$data = "<>$name<>";}
			$text .= "$data\n";
		}
		$flg = write_file('../category.txt',\$text,0);
		
	}
	if ($flg) {
		if ($category eq $category_name) {$category = $name;}
		$category_name = $name;
		category_menu();
		footer();
	} else {
		header("カテゴリ名称変更");
		echo "<td>カテゴリファイルの変更に失敗しました";
		print $cmd_str;
		print "<input type='hidden' name='opt' value='modoru'>\n";
		print "<input type='hidden' name='category_name' value='$category_name'>\n";
		submit_ret();
	}
}


sub board_ent {
	my $submit = shift;
	$name = $cgi->param('category_name');
	if ($submit eq $modoru) {
		show_menu();
	}
	header("ボード登録");
	if ($name eq '' || $name eq $category_all || $name eq $category_non) {
		echo "<td>カテゴリを選択して下さい\n";
		print "<input type='hidden' name='opt' value='modoru'>\n";
		print "<input type='hidden' name='category_name' value='$name'>\n";
		submit_ret();
	} else {
		print "<td>\n";
		print "$name<br>\n";
		print '<textarea name="list" cols="30" rows="30">';
		print get_board($name);
		print "</textarea>\n";
		print "<input type='hidden' name='opt' value='ent_exe'>\n";
		print "<input type='hidden' name='category_name' value='$name'>\n";
		submit_exe();
	}
	print $cmd_str;
}

sub ent_exe {
	my $submit = shift;
	my @list = split(/\n/,$cgi->param('list'));
	$name = $cgi->param('category_name');
	if ($submit eq $modoru) {
		category_menu();
		footer();
	}
	header ("ボード登録");
	print "<td>$name";
	echo "を登録<br>\n";
	put_board($name,@list);
	print "<input type='hidden' name='opt' value='modoru'>\n";
	print "<input type='hidden' name='category_name' value='$name'>\n";
	print $cmd_str;
	submit_ret();
}

sub board_view {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my $name = $cgi->param('category_name');
	header("未登録ボード一覧");
	echo "<td>ボードリスト<br>\n";
	print '<textarea name="list" cols="30" rows="30">';
	print category_nothing();
	print "</textarea><br>\n";
	print $cmd_str;
	print "<input type='hidden' name='opt' value='modoru'>\n";
	print "<input type='hidden' name='category_name' value='$name'>\n";
	submit_ret();
}

sub category_edit {
	$submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my $name = $cgi->param('category_name');
	header("カテゴリ登録");
	echo "<td>カテゴリ入力<br>";
	print '<textarea name="table" cols="50" rows="30">';
	print read_file('../ifo/category.cgi');
	print "</textarea><br>\n";
	print '<input type="hidden" name="opt" value="edit_exe">'."\n";
	print "<input type='hidden' name='category_name' value='$name'>\n";
	print $cmd_str;
	submit_exe();
}

sub edit_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		category_menu();
		footer();
	}
	my $name = $cgi->param('category_name');
	my @list = split(/\n/,$cgi->param('table'));
	header("カテゴリ名称登録");
	print "<td>\n";
	@list = make_category(@list);
	my $fname = '../ifo/category.cgi';
	if ($#list < 0) {
		if (-e $fname) {
			echo "$fname を削除";
			if (unlink $fname) {
				echo "しました<br>\n";
				if (unlink '../category.txt') {
					echo "../category.txtを削除しました<br>\n";
				} else {
					echo "../category.txtを削除できませんでした<br>\n";
				}
			} else {
				echo "出来ませんでした<br>\n";
			}
		}
	} else {
		my $text = '';
		foreach $data(@list) {
			$text .= "$data\n";
		}
		echo "$fname を更新";
		if (write_file($fname,\$text,1)) {
			echo "しました<br>\n";
			write_category(\$text);
			
		} else {
			echo "できませんでした<br>\n";
		}
	}
	print $cmd_str;
	print "<input type='hidden' name='category_name' value='$name'>\n";
	print "<input type='hidden' name='opt' value='modoru'>\n";
	submit_ret();
}

sub write_category {
	my $text = shift;
	my @list = split(/\n/,trim($$text));
	my $tmp = '';
	my $cat_text = '';
	foreach $data(@list) {
		if (index($data,'http') >= 0) {next;}
		$cat_text .= "<>$data<>\n";
		my $cat = get_board($data);
		$cat_text .= $cat;
		$tmp .= $cat;
	}
	$tmp = trim($tmp);
	if ($tmp eq '' && -e '../category.txt') {
		if (unlink '../category.txt') {
			echo "../category.txt を削除しました<br>\n";
		} else {
			echo "../category.txt を削除できませんでした<br>\n";
		}
	} elsif ($tmp ne '') {
		if(write_file('../category.txt',\$cat_text,0)) {
			echo "../category.txt を変更しました<br>\n";
		} else {
			echo "../category.txt の変更に失敗しました<br>\n";
		}
	}
}

sub make_category {
	my @list = @_;
	my @category;
	foreach $data(@list) {
		$data = trim($data);
		if ($data eq '') {next;}
		my $msg = check_category($data,@category);
		if ($msg) {
			print "$msg<br>\n";
		} else {
			push(@category,$data);
		}
	}
	return(@category);
}

sub check_category {
	my $name = shift;
	my @list = @_;
	if ($name eq $category_all || $name eq $category_non || $name eq enc_str('未設定')) {
		return($name . enc_str(' カテゴリ名に使えない名前です'));
	}
	if ($name =~ /[<>]/) {return($name . enc_str(' カテゴリ名に半角不等号は使えません'));}
	foreach $data(@list) {
		if ($name eq $data) {return($name . enc_str(' カテゴリ名が重複しています'));}
	}
	return (0);
}
1;
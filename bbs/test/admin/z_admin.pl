use utf8;

sub pass_word {
	$fname = shift;
	header("パスワード変更");
	echo "<td>現在のパスワード</td>\n";
	print "<td><input type='password' name='pass_old' size='8' maxlength='8'></td></tr>\n";
	echo "<td>新しいパスワード</td>\n";
	print "<td><input type='password' name='pass1' size='8' maxlength='8'></td></tr>\n";
	echo "<td>確認の為もう一度</td>\n";
	print "<td><input type='password' name='pass2' size='8' maxlength='8'></td></tr>\n";
	print "<input type='hidden' name='file' value='$fname'>\n";
}

sub pass_write {
	my $er = '';
	my $pass_old = val_sjis(trim($cgi->param('pass_old')));
	$pass_old = substr(crypt($pass_old,$salt),2);
	my $pass1 = val_sjis(trim($cgi->param('pass1')));
	my $pass2 = val_sjis(trim($cgi->param('pass2')));
	my $fname = $cgi->param('file');
	if ($pass_old ne $member{'pass'}) {$er = "パスワードが間違っています<br>\n";}
	if (length($pass1) < 4) {$er.= "パスワードは４文字以上にして下さい<br>\n";}
	if ($pass1 ne $pass2) {$er.= "パスワードの確認が間違っています<br>\n";}
	if ($er eq '') {
		if (open(IN,"+<$fname")) {
			flock(IN,2);
			my @list;
			while (<IN>) {
				my ($name,$id_num,$pass,$level,$cap,$id,$area) = split('<>',$_);
				if ($member{'id_num'} eq $id_num) {
					$pass1 = substr(crypt($pass1,$salt),2);
					push(@list,"$name<>$id_num<>$pass1<>$level<>$cap<>$id<>$area");
				} else {
					push(@list,$_);
				}
			}
			seek(IN,0,0);
			foreach $data(@list) {
				print IN $data;
			}
			truncate(IN,tell(IN));
			close(IN);
			$er ="パスワードの変更をしました<br>\n";
		} else {
			$er.="ファイルの書き換えに失敗しました<br>\n";
		}
	}
	echo "<td>$er";
	submit_ret();
	print "<input type='hidden' name='opt' value='modoru'>\n";
}

sub show_member {
	my $fname = shift;
	my $flg = shift;
	my @list = read_tbl($fname);
	my $member = $cgi->param('member');
	my $area = $cgi->param('area');
	my $id_num = trim($cgi->param('id_num'));
	my $name = trim($cgi->param('name'));
	my $cap = trim($cgi->param('cap'));
	my $id = trim($cgi->param('id'));
	my $level = trim($cgi->param('level'));

	if ($call eq 'category' && $fname eq $mem_file) {
		print "<input type='hidden' name='area' value='$category'>\n";
		@list = category_member(@list);
	}
	my $cnt = @list;
	if ($cnt) {
		print "<td valign='top'>\n";
		print '<select name="member" size="24">',"\n";
		foreach $data(@list) {
			$data = trim($data);
			my ($t_name,$t_id_num,$t_pass,$t_level,$t_cap,$t_id,$t_area) = split('<>',$data);
			$t_area = "|$t_area";
			my $ck = ($t_id_num eq $member ? ' selected' : '');
			if ($flg eq '') {$t_area = '';}
			print "<option value='$t_id_num'$ck>$t_id_num|$t_name|$t_level|$t_cap|$t_id$t_area</option>\n";
		}
		print "</select></td>\n";
	}
	print "<td align='center'>\n";
	if ($flg == 1) {
		@list = read_tbl("../ifo/category.cgi");
		$cnt = @list;
		if ($cnt) {
			unshift(@list,enc_str('未設定'));
			echo "担当カテゴリ<br>\n";
			print '<select name="area" size="1">',"\n";
			foreach $data(@list) {
				$data = trim($data);
				if (index($data,'http://') >= 0) {next;}
				if ($area eq '') {$area = $category;}
				my $ck = ($data eq $area ? ' selected' : '');
				print "<option value='$data'$ck>$data</option>\n";
			}
			print "</select><br>\n";
		}
	}
	echo "ログインID<br>\n";
	print "<input type='text' name='id_num' value='$id_num' size='25' maxlength='20'><br>\n";
	echo "名前";
	print "<br><input type='text' name='name' value='$name' size='25' maxlength='20'><br>\n";
	echo "キャップ名称";
	print "<br><input type='text' name='cap' value='$cap' size='25' maxlength='20'><br>\n";
	echo "表示ID";
	print "<br><input type='text' name='id' value='$id' size='25' maxlength='20'><br>\n";
	echo "管理者権限";
	print "<br><select name='level' size='1' style='width:80%'>\n";
	echo "<option value=''>未設定</option>\n";
	echo "<option value='1'",($level == 1 ? ' selected' : ''),">1:レス管理</option>\n";
	echo "<option value='2'",($level == 2 ? ' selected' : ''),">2:スレッド管理</option>\n";
	echo "<option value='3'",($level == 3 ? ' selected' : ''),">3:レス＆スレッド管理</option>\n";
	echo "<option value='7'",($level == 7 ? ' selected' : ''),">7:責任管理</option>\n";
	print "</select><br>\n";
	echo "パスワード<br><input type='password' name='pass1' size='8' maxlength='8'><br>\n";
	echo "確認の為もう１度<br><input type='password' name='pass2' size='8' maxlength='8'><br>\n";
	print "</td></tr><tr><td align='center' colspan='2'>\n";
	echo "<input type='submit' name='submit' value='削除'>　\n";
	echo "<input type='submit' name='submit' value='変更'>　\n";
	echo "<input type='submit' name='submit' value='追加'>　\n";
	echo "<input type='submit' name='submit' value='戻る'>\n";
	print "<input type='hidden' name='file' value='$fname'>\n";
}

sub category_member {
	my @list;
	foreach $data(@_) {
		if (index($data,"<>$category\n") > 0) {push(@list,$data);}
	}
	return(@list);
}

sub write_member {
	my $fname = $cgi->param('file');
	my $member = $cgi->param('member');
	my $area = $cgi->param('area');
	my $id_num = trim($cgi->param('id_num'));
	my $name = trim($cgi->param('name'));
	my $cap = trim($cgi->param('cap'));
	my $id = trim($cgi->param('id'));
	my $level = trim($cgi->param('level'));
	my $pass1 = val_sjis(trim($cgi->param('pass1')));
	my $pass2 = val_sjis(trim($cgi->param('pass2')));
	my $submit = dec_str($cgi->param('submit'));
	my @list = read_tbl($fname);
	my $er = '';
	if ($submit eq '削除') {
		if ($member eq '') {
			$er = "削除対象が選択されていません<br>\n";
		} else {
			my $text = '';
			foreach $data(@list) {
				my ($dt1,$key) = split('<>',$data);
				unless ($member eq $key) {$text .= $data;}
			}
			if (write_file($fname,\$text,1)) {
				echo "<td>１件削除しました<br>\n";
			} else {
				echo "<td>データの変更に失敗しました<br>\n";
			}
		}
	} elsif ($submit eq '変更') {
		if ($member eq '') {$er .= "変更対象が選択されていません<br>\n";}
		if ($area eq enc_str("未設定")) {$area = '';}
		if ($member eq $id_num) {$id_num = '';}
		if ($id_num ne '') {
			$er .= check_id_num($id_num);
			foreach $data(@list) {
				my ($nm,$t_id_num) = split('<>',$data);
				if ($id_num eq $t_id_num) {
					$er .= "そのログインIDは既に存在します<br>\n";
					last;
				}
			}
		}
		if ($name ne '') {$er .= check_name($name,"名前");}
		if ($cap ne '') {$er .= check_name($name,"キャップ名称");}
		if ($id ne '') {$er .= check_id($id);}
		if ($pass1.$pass2 ne '') {
			my $text = check_pass($pass1,$pass2);
			if ($text eq '') {
				$pass1 = substr(crypt($pass1,$salt),2);
			} else {
				$er .= $text;
			}
		}
		if ($er eq '') {
			my $text = '';
			my $flg = 0;
			foreach $data(@list) {
				my ($nm,$in,$pw,$lv,$cp,$i,$ar) = split('<>',$data);
				if ($member eq $in) {
					if ($nm ne $name && $name ne '') {
						$nm = $name;
						$flg = 1;
					}
					if ($in ne $id_num && $id_num ne '') {
						$in = $id_num;
						$flg = 1;
					}
					if ($pw ne $pass1 && $pass1 ne '') {
						$pw = $pass1;
						$flg = 1;
					}
					if ($lv ne $level && $level ne '') {
						$lv = $level;
						$flg = 1;
					}
					if ($cp ne $cap && $cap ne '') {
						$cp = $cap;
						$flg = 1;
					}
					if ($i ne $id && $id ne '') {
						$i = $id;
						$flg = 1;
					}
					$area .= "\n";
					if ($ar ne $area && $area ne "\n") {
						$ar = $area;
						$flg = 1;
					}
					$text .= "$nm<>$in<>$pw<>$lv<>$cp<>$i<>$ar";
				} else {
					$text .= $data;
				}
			}
			if ($flg) {
				if (write_file($fname,\$text,1)) {
					echo "<td>管理者データを変更しました<br>";
				} else {
					echo "<td>管理者データの変更に失敗しました<br>";
				}
			} else {
				$er = "変更箇所が有りませんでした<br>\n";
			}
		}
	} else {
		if ($area eq enc_str('未設定')) {$er .= "担当カテゴリが選択されていません<br>\n";}
		if ($id_num eq '') {
			$er .= "ログインIDが指定されていません<br>\n";
		} else {
			$er .= check_id_num($id_num);
		}
		foreach $data(@list) {
			my ($nm,$ck_id) = split('<>',$data);
			if ($ck_id eq $id_num) {
				$er .= "そのログインIDは既に使われています<br>\n";
				last;
			}
		}
		if ($name eq '') {
			$er .= "名前が指定されていません<br>\n";
		} else {
			$er .= check_name($name,"名前");
		}
		if ($cap eq '') {
			$er .= "キャップ名称が指定されていません<br>\n";
		} else {
			$er .= check_name($cap,"キャップ名称");
		}
		if ($id eq '') {
			$er .= "表示IDが指定されていません<br>\n";
		} else {
			$er .= check_id($id);
		}
		if ($level eq '') {$er.= "管理者権限を設定してください<br>\n";}
		if ($pass1 eq '') {$er .= "パスワードが指定されていません<br>\n";}
		if ($pass2 eq '') {$er .= "確認用パスワードが指定されていません<br>\n";}
		if ($pass1.$pass2 ne '') {$er .= check_pass($pass1,$pass2);}
		if ($er eq '') {$pass1 = substr(crypt($pass1,$salt),2);}
		if ($name eq '') {$er .= "表示名称が設定されていません<br>\n";}
		if ($id eq '') {$er .= "表示IDが設定されていません<br>\n";}
		if ($er eq '') {
			push(@list,"$name<>$id_num<>$pass1<>$level<>$cap<>$id<>$area\n");
			my $text = '';
			foreach $data(@list) {
				$text .= $data;
			}
			if (write_file($fname,\$text,1)) {
				echo "<td>管理者データを追加しました<br>";
			} else {
				echo "<td>管理者データの追加に失敗しました<br>";
			}
		}
	}
	if ($er ne '') {echo "<td>$er";}
	submit_ret();
	if ($er eq '') {
		$member = '';
		$area = '';
		$id_num = '';
		$name = '';
		$cap = '';
		$id = '';
		$level = '';
	}
	print "<input type='hidden' name='member' value='$member'>\n";
	print "<input type='hidden' name='area' value='$area'>\n";
	print "<input type='hidden' name='id_num' value='$id_num'>\n";
	print "<input type='hidden' name='name' value='$name'>\n";
	print "<input type='hidden' name='cap' value='$cap'>\n";
	print "<input type='hidden' name='id' value='$id'>\n";
	print "<input type='hidden' name='level' value='$level'>\n";
	print "<input type='hidden' name='flg' value='1'>\n";
}

sub check_id_num {
	my $id_num = shift;
	my $er = '';
	if ($id_num =~ /[<>]/) {$er .= "半角不等号はログインIDに使えません<br>\n";}
	if (length($id_num) < 4) {$er .= "ログインIDは４文字以上にして下さい<br>\n";}
	return($er);
}

sub check_pass {
	my $pass1 = shift;
	my $pass2 = shift;
	my $er = '';
	if ($pass1 ne $pass2) {$er .= "確認用パスワードが間違っています<br>\n";}
	if (length($pass1) < 4) {$er.= "パスワードは４文字以上にして下さい<br>\n";}
	return ($er);
}

sub check_name {
	my $name = shift;
	my $kind = shift;
	my $er = '';
	if ($name =~ /[<>]/) {$er .= "半角不等号は".$kind."に使えません<br>\n";}
	return($er);
}

sub check_id {
	my $id = shift;
	my $er = '';
	if ($id =~ /[<>]/) {$er .= '不等号は表示IDに使えません<br>';}
	if ($id =~ /[^\x21-\x7E]/) {$er .= '全角文字は表示IDに使えません<br>';}
	return($er);
}
1;
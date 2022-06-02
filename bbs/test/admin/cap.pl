use utf8;

$cmd_str = '<input type="hidden" name="cmd" value="cap">'."\n";
my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'exe') {
	cap_exe($submit);
} else {
	cap_ed();
}

sub cap_ed {
	my @caps = read_tbl("../$bbs/ifo/cap.cgi");
	header("キャップの編集");
	my $cnt = @caps;
	if ($cnt) {
		print "<td valign='top'>\n";
		print '<select name="cap" size="10">',"\n";
		foreach $data(@caps) {
			my $key = substr($data,0,index($data,'<>'));
			$data = trim($data);
			$data =~ s/<>/\|/g;
			print "<option value='$key'>$data</option>\n";
		}
		print "</select></td>\n";
	}
	print "<td valign='top' align='center'>\n";
	echo "キャップID<br>\n";
	print "<input type='text' name='pw' size='20'><br>\n";
	echo "キャップ名称<br>\n";
	print "<input type='text' name='name' size='20'><br>\n";
	echo "表示ID<br>\n";
	print "<input type='text' name='id' size='20'><br>\n";
	print "</td></tr><tr><td align='center' colspan='2'>\n";
	echo "<input type='submit' name='submit' value='削除'>　\n";
	echo "<input type='submit' name='submit' value='変更'>　\n";
	echo "<input type='submit' name='submit' value='追加'>　\n";
	echo "<input type='submit' name='submit' value='戻る'>\n";
	print '<input type="hidden" name="opt" value="exe">'."\n";
	print $cmd_str;
}

sub cap_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my $fname = "../$bbs/ifo/cap.cgi";
	header("キャップ変更");
	print "<td>\n";
	$submit = dec_str($submit);
	$edit = $cgi->param('cap');
	@caps = read_tbl($fname);
	if ($submit eq '削除') {
		if ($edit eq '') {
			echo "削除対象が選択されていません<br>\n";
		} else {
			my $text = '';
			foreach $data(@caps) {
				my $key = substr($data,0,index($data,'<>'));
				unless ($key eq $edit) {$text .= $data;}
			}
			echo "削除して";
			echo $fname,"を",(write_file($fname,\$text,1) ? '変更しました' : '変更失敗'),"<br>\n";
		}
	} elsif ($submit eq '変更') {
		my $pw = $cgi->param('pw');
		my $name = $cgi->param('name');
		my $id =  $cgi->param('id');
		if ($edit eq '') {$er .= "変更対象が選択されていません<br>\n";}
		if ($pw.$name.$id eq '') {$er .= "変更内容が設定されていません<br>\n";}
		if ($pw ne '') {
			my $cnt = 0;
			foreach $data(@caps) {
				if($pw eq substr($data,0,index($data,'<>'))) {
					$cnt++;
				}
			}
			if ($cnt && $edit ne $pw) {$er .= "そのパスワードには変更できません<br>\n";}
		}
		if ($er eq '') {
			my $text = '';
			foreach $data(@caps) {
				if ($edit eq substr($data,0,index($data,'<>'))) {
					$data = trim($data);
					my ($ps,$nm,$i) = split(/<>/,$data);
					$pw = ($pw eq '' ? $ps : $pw);
					$name = ($name eq '' ? $nm : $name);
					$id = ($id eq '' ? $i : $id);
					$text .= "$pw<>$name<>$id\n";
				} else {
					$text .= $data;
				}
			}
			echo "キャップデータの変更を $fname に<br>";
			echo '記録',(write_file($fname,\$text,1) ? '' : '失敗'),"しました<br>\n";
		} else {
			echo $er;
		}
	} else {
		my $pw = $cgi->param('pw');
		my $name = $cgi->param('name');
		my $id =  $cgi->param('id');
		my $er = '';
		if ($pw eq '') {
			$er .= "パスワードが指定されていません<br>\n";
		} else {
			foreach $data(@caps) {
				if($pw eq substr($data,0,index($data,'<>'))) {
					$er .= "そのパスワードは既に使われています<br>\n";
					last;
				}
			}
		}
		if ($name eq '') {$er .= "表示名称が設定されていません<br>\n";}
		if ($id eq '') {$er .= "表示IDが設定されていません<br>\n";}
		if ($er eq '') {
			push(@caps,"$pw<>$name<>$id\n");
			my $text = '';
			foreach $data(@caps) {
				$text .= $data;
			}
			echo "キャップデータを $fname に<br>";
			echo '追加',(write_file($fname,\$text,1) ? '' : '失敗'),"しました<br>\n";
		} else {
			echo $er;
		}
	}
	submit_ret();
}

1;

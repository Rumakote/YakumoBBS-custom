use utf8;

sub ng_select {
	my $submit = shift;
	my $kind = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header ('規制設定');
	print "<td>";
	print "<input type='radio' name='opt' value='term_ed'>\n";
	echo "規制端末設定<br>\n";
	print "<input type='radio' name='opt' value='word_ed'>\n";
	echo "規制文字設定<br>\n";
	if ($kind eq 'ifo') {
		print "<input type='radio' name='opt' value='access_ed'>\n";
		echo "アクセス制限設定<br>\n";
	}
	print "<input type='radio' name='opt' value='log_ed'>\n";
	echo "エラーログ閲覧編集<br>\n";
	print "<input type='radio' name='opt' value='trip_ed'>\n";
	echo "規制外トリップ設定<br>\n";
	print "<input type='radio' name='opt' value='cap_ed'>\n";
	echo "キャップ設定<br>\n";
	print $cmd_str;
	submit_select();
}

sub term_ed {
	my $submit = shift;
	my $board = shift;
	if ($submit eq $modoru) {show_menu();}
	if ($board ne 'ifo') {$board .= '/ifo';}
	my @text = read_tbl("../$board/nogood.cgi");
	header('規制端末設定');
	print '<td>';
	print_ng('rh',@text);
	print "</td></tr><tr><td>\n";
	print_ng('ip',@text);
	print "</td></tr><tr><td>\n";
	print_ng('ua',@text);
	print "</td></tr><tr><td>\n";
	print_ng('th',@text);
	print "</td></tr><tr><td>\n";
	print_ng('bl',@text);
	print $cmd_str;
	print '<input type="hidden" name="opt" value="term_exe">'."\n";
	submit_exe();
}

sub word_ed {
	my $submit = shift;
	my $board = shift;
	if ($board ne 'ifo') {$board .= '/ifo';}
	if ($submit eq $modoru) {show_menu();}
	my @text = read_tbl("../$board/nogood.cgi");
	header('規制文字設定');
	print '<td>';
	print_ng('wd',@text);
	print "</td></tr><tr><td>\n";
	print_ng('rw',@text);
	print $cmd_str;
	print '<input type="hidden" name="opt" value="word_exe">'."\n";
	submit_exe();
}

sub print_ng {
	my $ng = shift;
	my @list = @_;
	my $head = '';
	my $name = '';
	if ($ng eq 'rh') {
		$head = " 規制するホスト名";
		$name = 'host';
	} elsif ($ng eq 'ip') {
		$head = "投稿禁止IPアドレスまたは端末ID";
		$name = 'ipid';
	} elsif ($ng eq 'ua') {
		$head = "規制するユーザーエージェント";
		$name = 'agent';
	} elsif ($ng eq 'th') {
		$head = "スレ立て禁止IPアドレスまたは端末ID";
		$name = 'thread';
	} elsif ($ng eq 'bl') {
		$head = "外部サイトを利用した規制(DNSBL)";
		$name = 'dnsbl';
	} elsif ($ng eq 'wd') {
		$head = "ＮＧワード設定";
		$name = 'word';
	} elsif ($ng eq 'rw') {
		$head = "リライトワード設定";
		$name = 'rewrite';
	}
	if ($name) {
		echo "$head<br>\n<textarea name=$name cols=80 rows=10>";
		foreach my $tmp (@list) {
			my ($cmd,$word) = split('<>',$tmp);
			if ($cmd eq $ng) {print $word;}
		}
 		print "</textarea>\n"; 
	}
}

sub term_exe {
	my $submit = shift;
	my $board = shift;
	if ($board ne 'ifo') {$board .= '/ifo';}
	if ($submit eq $modoru) {
		ng_select('',$board);
		footer();
	}
	my @list = read_tbl("../$board/nogood.cgi");
	my @table = ();
	foreach my $tmp (@list)  {
		if ($tmp =~ /^ng<>|^rw<>/) {push(@table,$tmp);}
	}
	@list = ();
	push(@table,text_list('rh',$cgi->param('host')));
	push(@table,text_list('ip',$cgi->param('ipid')));
	push(@table,text_list('ua',$cgi->param('agent')));
	push(@table,text_list('th',$cgi->param('thread')));
	push(@table,text_list('bl',$cgi->param('dnsbl')));
	my $text = join('',@table);
	header('規制文字設定');
	print '<td>';
	if (write_file("../$board/nogood.cgi",\$text,1)) {
		echo "規制設定ファイルを更新しました\n";
	} else {
		echo "規制設定ファイルの更新を失敗しました\n";
	}
	submit_ret();
}

sub word_exe {
	my $submit = shift;
	my $board = shift;
	if ($board ne 'ifo') {$board .= '/ifo';}
	if ($submit eq $modoru) {
		ng_select('',$board);
		footer();
	}
	my @list = read_tbl("../$board/nogood.cgi");
	my @table = ();
	foreach my $tmp (@list)  {
		if ($tmp =~ /^rh<>|^ip<>|^ua|^th|^bl/) {push(@table,$tmp);}
	}
	@list = ();
	push(@table,text_list('wd',$cgi->param('word')));
	push(@table,text_list('rw',$cgi->param('rewrite')));
	my $text = join('',@table);
	header('規制文字設定');
	print '<td>';
	if (write_file("../$board/nogood.cgi",\$text,1)) {
		echo "規制設定ファイルを更新しました\n";
	} else {
		echo "規制設定ファイルの更新を失敗しました\n";
	}
	submit_ret();
}

sub text_list {
	my $kind = shift;
	my $text = shift;
	my @list = split("\n",$text);
	my @table = ();
	foreach my $tmp (@list) {
		$tmp =~ s/<>/&lt;&gt;/g;
		push(@table,"$kind<>$tmp\n");
	}
	return(@table);
}

sub log_ed {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my $board = shift;
	if ($board ne 'ifo') {$board .= '/ifo';}
	header("エラーログ");
	echo "<td>\n";
	echo "エラーログ<br>";
	my $logs = read_file("../$board/nglog.cgi");
	print '<textarea name=nglog cols=80 rows=40>';
	print $logs;
	print "</textarea><br>\n";
	submit_exe();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='log_exe'>\n";
}

sub log_exe {
	my $submit = shift;
	my $board = shift;
	if ($board ne 'ifo') {$board .= '/ifo';}
	if ($submit eq $modoru) {
		ng_select('',$board);
		footer();
	}
	header("エラーログ変更");
	print "<td>\n";
	my $fname = "../$board/nglog.cgi";
	write_log_exe($fname,$cgi->param('nglog'));
	submit_ret();
}

sub write_log_exe {
	my $fname = shift;
	my $text = shift;
	if (trim($text) ne '') {
		echo $fname,(write_file($fname,\$text,1) ? "更新" : "失敗"),"<br>\n";
	} else {
		echo $fname,(delete_file($fname) ? "削除" : "削除失敗"),"<br>\n";
	}
}

sub trip_ed {
	my $submit = shift;
	my $board = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("規制外トリップ設定");
	show_trip($board);
	print $cmd_str;
	print "<input type='hidden' name='opt' value='trip_exe'>\n";
}

sub trip_exe {
	my $submit = shift;
	my $board = shift;
	if ($submit eq $modoru) {
		ng_select('',$board);
		footer();
	}
	header("規制外トリップ変更");
	print "<td>\n";
	write_trip($board);
	submit_ret();
}

sub show_trip {
	my $board = shift;
	my $fname = "../$board/ifo/through.cgi";
	if ($board eq 'ifo') {$fname = "../ifo/through.cgi";}
	echo "<td>\n";
	echo "規制外トリップ<br>";
	my $logs = read_file($fname);
	print '<textarea name=trip cols=40 rows=20>';
	print $logs;
	print "</textarea><br>\n";
	submit_exe();
}

sub write_trip {
	my $board = shift;
	my $fname = "../$board/ifo/through.cgi";
	if ($board eq 'ifo') {$fname = "../ifo/through.cgi";}
	write_trip_exe($fname,$cgi->param('trip'));
}

sub write_trip_exe {
	my $fname = shift;
	my $text = shift;
	$text = trim($text);
	if ($text) {
		$text .= "\n";
		echo $fname,(write_file($fname,\$text,1) ? "更新" : "失敗"),"<br>\n";
	} else {
		echo $fname,(delete_file($fname) ? "削除" : "削除失敗"),"<br>\n";
	}
}

sub cap_ed {
	my $submit = shift;
	my $board = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my $fname = "../$board/ifo/cap.cgi";
	if ($board eq 'ifo') {$fname = "../ifo/cap.cgi";}
	my @caps = read_tbl($fname);
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
	print '<input type="hidden" name="opt" value="cap_exe">'."\n";
	print $cmd_str;
}

sub cap_exe {
	my $submit = shift;
	my $board = shift;
	if ($submit eq $modoru) {
		ng_select('',$board);
		footer();
	}
	my $fname = "../$board/ifo/cap.cgi";
	if ($board eq 'ifo') {$fname = "../ifo/cap.cgi";}
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
	print '<input type="hidden" name="opt" value="cap_exe">'."\n";
	print $cmd_str;
	submit_ret();
}
1;

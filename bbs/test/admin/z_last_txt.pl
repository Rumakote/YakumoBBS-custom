use utf8;

sub show_last_txt {
	my $fname = shift;
	echo "<td>終了レス編集<br></td></tr><td>\n";
	my $text = read_file($fname);
	if ($text eq '' && index($fname,'/ifo/') < 0) {
		substr($fname,0,rindex($fname,'/'),'../ifo/');
		$text = read_file($fname);
	}
	if ($text eq '') {
		if (index($fname,'last.txt') > 0) {
			$text = enc_str("１00１<><>Over Limit Thread<>このスレッドは書き込み限界を超えました。<br>新しいスレッドを立ててください。<>\n");
		} else {
			$text = enc_str("スレッドストッパー<><>Thread Stop<>このスレッドは強制終了しました。<>\n");
		}
	}
	my ($name,$mail,$time,$message) = split('<>',$text);
	echo "名前欄：";
	print "<input type='text' name='name' value='$name'>";
	echo "メール欄：";
	print "<input type='text' name='mail' value='$mail'><br>";
	echo "日付ID欄：";
	print "<input type='text' name='time' value='$time' size='40'><br>";
	$message =~ s/<br>/\n/g;
	print "<textarea name='message' cols='60' rows='20'>\n";
	print $message;
	print "</textarea><br>\n";
	submit_exe();
}

sub write_last_txt {
	my $fname = shift;
	my $name = trim($cgi->param('name'));
	my $meil = trim($cgi->param('mail'));
	my $time = trim($cgi->param('time'));
	my $message = rtrim($cgi->param('message'));
	$message =~ s/\n/<br>/g;
	$message =~ s/\r//g;
	my $text = "$name<>$mail<>$time<>$message<>\n";
	if ($text eq "<><><><>\n") {
		echo $fname,(delete_file($fname) ? "削除" : "削除失敗"),"<br>\n";
	} else {
		echo $fname,(write_file($fname,\$text,0) ? "更新" : "失敗"),"<br>\n";
	}
}
1;
use utf8;

$cmd_str = '<input type="hidden" name="cmd" value="through_trip">'."\n";
my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'trip_exe') {
	trip_exe($submit);
} else {
	trip_ed();
}

sub trip_ed {
	header("規制外トリップ設定");
	show_trip();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='trip_exe'>\n";
}

sub trip_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("規制外トリップ変更");
	print "<td>\n";
	write_trip();
	submit_ret();
}

sub show_trip {
	echo "<td>\n";
	echo "規制外トリップ<br>";
	my $logs = read_file("../$bbs/ifo/through.cgi");
	print '<textarea name=trip cols=40 rows=20>';
	print $logs;
	print "</textarea><br>\n";
	submit_exe();
}

sub write_trip {
	my $fname = "../$bbs/ifo/through.cgi";
	write_trip_exe($fname,$cgi->param('trip'));
}

sub write_trip_exe {
	my $fname = shift;
	my $text = shift;
	if (trim($text) ne '') {
		echo $fname,(write_file($fname,\$text,1) ? "更新" : "失敗"),"<br>\n";
	} else {
		echo $fname,(delete_file($fname) ? "削除" : "削除失敗"),"<br>\n";
	}
}
1;

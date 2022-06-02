use utf8;

$cmd_str = '<input type="hidden" name="cmd" value="nonames">'."\n";
my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'nonames_exe') {
	nonames_exe($submit);
} else {
	nonames_ed();
}

sub nonames_ed {
	header("$bbs 携帯で消す名無し編集");
	show_nonames($bbs);
	print $cmd_str;
	print "<input type='hidden' name='opt' value='nonames_exe'>\n";
}

sub nonames_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("$bbs 携帯で消す名前変更");
	print "<td>\n";
	write_nonames($bbs);
	submit_ret();
}

sub show_nonames {
	my $bbs = shift;
	echo "<td>\n";
	echo "携帯で消す名無しの名前<br>";
	my $nonames = read_file("../$bbs/nonames.txt");
	print '<textarea name=nonames cols=60 rows=20>';
	print $nonames;
	print "</textarea><br>\n";
	submit_exe();
}

sub write_nonames {
	my $bbs = shift;
	my $fname = "../$bbs/nonames.txt";
	write_nonames_exe($fname,$cgi->param('nonames'));
}

sub write_nonames_exe {
	my $fname = shift;
	my $text = shift;
	if (trim($text) ne '') {
		echo $fname,(write_file($fname,\$text,0) ? "更新" : "失敗"),"<br>\n";
	} else {
		echo $fname,(delete_file($fname) ? "削除" : "削除失敗"),"<br>\n";
	}
}
1;

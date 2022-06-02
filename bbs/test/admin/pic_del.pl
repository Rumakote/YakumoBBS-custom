use utf8;

my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');
$cmd_str = '<input type="hidden" name="cmd" value="pic_del">',"\n";


if ($opt eq 'exe') {
	del_exe($submit);
} else {
	del_select();
}

sub del_select {
	my @pic = glob("$ifo{'images'}*");
	header("画像ファイル削除");
	echo "複数選択できます<br>\n";
	print "<td>\n";
	print "<select name='files' size='17' multiple>\n";
	foreach $data(@pic) {
		print "<option value='$data'>$data</option>\n";
	}
	print "</select>\n";
	submit_exe();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='exe'>\n";
}

sub del_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my @list = $cgi->param('files');
	header("画像ファイル削除");
	my $cnt = unlink(@list);
	echo "<td>",$cnt,"個のファイルを削除しました\n";
	submit_ret();
}
1;

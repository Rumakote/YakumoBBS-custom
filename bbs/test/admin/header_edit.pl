use utf8;

require "$admcmd/z_header_edit.pl";
$cmd_str = '<input type="hidden" name="cmd" value="header_edit">'."\n";
my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'header_edit_exe') {
	header_edit_exe($submit);
} else {
	header_edit();
}

sub header_edit {
	header("$bbs ＜head＞内要素追加・編集");
	show_header_edit($bbs);
	print $cmd_str;
	print "<input type='hidden' name='opt' value='header_edit_exe'>\n";
}

sub header_edit_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("$bbs ＜head＞内要素追加・変更");
	print "<td>\n";
	write_header_edit($bbs);
	submit_ret();
}
1;
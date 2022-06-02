use utf8;

require "$admcmd/z_ng_sub.pl";
$cmd_str = '<input type="hidden" name="cmd" value="ng_log_board">'."\n";
my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'log_exe') {
	log_exe($submit);
} else {
	log_ed();
}

sub log_ed {
	header("$bbs 規制に掛かったログ");
	show_logs("$bbs/ifo");
	print $cmd_str;
	print "<input type='hidden' name='opt' value='log_exe'>\n";
}

sub log_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("$bbs 規制ログ変更");
	print "<td>\n";
	write_log("$bbs/ifo");
	submit_ret();
}
1;

use utf8;

require "$admcmd/z_ng_sub.pl";
$cmd_str = '<input type="hidden" name="cmd" value="ng_log">'."\n";
my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'log_exe') {
	log_exe($submit);
} else {
	log_ed();
}

sub log_ed {
	header("規制に掛かったログ");
	show_logs('ifo');
	print $cmd_str;
	print "<input type='hidden' name='opt' value='log_exe'>\n";
}

sub log_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("規制ログ変更");
	print "<td>\n";
	write_log('ifo');
	submit_ret();
}
1;

use utf8;

require "$admcmd/z_rule.pl";
$cmd_str = '<input type="hidden" name="cmd" value="rule_ed">'."\n";
my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'rule_exe') {
	rule_exe($submit);
} else {
	rule_ed();
}

sub rule_ed {
	header("$bbs ローカルルール編集");
	show_rule($bbs);
	print $cmd_str;
	print "<input type='hidden' name='opt' value='rule_exe'>\n";
}

sub rule_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("$bbs ローカルルール変更");
	print "<td>\n";
	write_rule($bbs);
	submit_ret();
}
1;
use utf8;

require "$admcmd/z_ng_sub.pl";
$cmd_str = '<input type="hidden" name="cmd" value="ng_set_board">'."\n";
my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'term_exe') {
	term_exe($submit,$bbs);
} elsif ($opt eq 'word_exe') {
	word_exe($submit,$bbs);
} elsif ($opt eq 'log_exe') {
	log_exe($submit,$bbs);
} elsif ($opt eq 'term_ed') {
	term_ed($submit,$bbs);
} elsif ($opt eq 'word_ed') {
	word_ed($submit,$bbs);
} elsif ($opt eq 'log_ed') {
	log_ed($submit,$bbs);
} elsif ($opt eq 'trip_ed') {
	trip_ed($submit,$bbs);
} elsif ($opt eq 'trip_exe') {
	trip_exe($submit,$bbs);
} elsif ($opt eq 'cap_ed') {
	cap_ed($submit,$bbs);
} elsif ($opt eq 'cap_exe') {
	cap_exe($submit,$bbs);
} else {
	ng_select($submit,$bbs);
}

sub ng_setting_ed {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("$bbs 規制情報設定");
	ng_set_ed("$bbs/ifo");
}

sub ng_setting_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("$bbs ＮＧ情報設定");
	ng_set_exe("$bbs/ifo");
}
1;
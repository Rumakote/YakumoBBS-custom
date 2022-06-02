use utf8;

require "$admcmd/z_banner.pl";
$cmd_str = '<input type="hidden" name="cmd" value="banner_ed">'."\n";
my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'banner_exe') {
	banner_exe($submit);
} else {
	banner_ed();
}

sub banner_ed {
	header("$bbs バナー編集");
	show_banner($bbs);
	print $cmd_str;
	print "<input type='hidden' name='opt' value='banner_exe'>\n";
}

sub banner_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("$bbs バナー変更");
	print "<td>\n";
	write_banner($bbs);
	submit_ret();
}
1;
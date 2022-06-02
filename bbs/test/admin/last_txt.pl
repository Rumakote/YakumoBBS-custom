use utf8;

require "$admcmd/z_last_txt.pl";
$cmd_str = '<input type="hidden" name="cmd" value="last_txt">'."\n";

my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'last_exe') {
	last_exe($submit);
} else {
	last_ed();
}

sub last_ed {
	header("$bbs 終了レス編集");
	show_last_txt("../$bbs/last.txt");
	print $cmd_str;
	print "<input type='hidden' name='opt' value='last_exe'>\n";	
}

sub last_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("$bbs 終了レス変更");
	print "<td>\n";
	write_last_txt("../$bbs/last.txt");
	submit_ret();
}
1;
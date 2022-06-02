use utf8;

require "$admcmd/z_thread.pl";

my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');
$cmd_str = '<input type="hidden" name="cmd" value="thread_rest">'."\n";

if ($opt eq 'exe') {
	thread_exe($submit);
} else {
	thread_menu($submit);
}

sub thread_menu {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("どのスレッドを再開しますか？");
	if (threst_view(0,$bbs)) {
		submit_select();
	} else {
		submit_ret();
	}
	print '<input type="hidden" name="opt" value="exe">'."\n";
	print $cmd_str;
}

sub thread_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("スレッド再開");
	my @list = $cgi->param('dat_name');
	my $cnt = 0;
	print "<td>\n";
	foreach $data(@list) {
		my ($dat,$name) = split('.dat<>',$data);
		if (thread_mode("../$bbs/idx/$dat.idx",1)) {
			$cnt++;
		} else {
			print $name;
			echo " は再開できませんでした<br>\n";
		}
	}
	echo $cnt,"件のスレッドを再開しました";
	submit_ret();
}
1;
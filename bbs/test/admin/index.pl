use utf8;

require "$admcmd/z_thread.pl";
$cmd_str = '<input type="hidden" name="cmd" value="index">'."\n";

my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'exe') {
	index_exe($submit);
} else {
	index_select();
}

sub index_select {
	header("どのスレッドの索引を再構築しますか？");
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	if (out_thread(1,$board)) {
		submit_exe();
	} else {
		submit_ret();
	}
	print $cmd_str;
	print '<input type="hidden" name="opt" value="exe">'."\n";
}

sub index_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my @dat = $cgi->param('dat_name');
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	header("索引再構築");
	print "<td>\n";
	foreach $data(@dat) {
		$data = substr($data,0,index($data,'.dat'));
		my $sign = (get_index(1,$board,$data) < 0 ? -1 : 1);
		echo makeindex($board,$data,$sign),"<br>\n";
	}
	submit_ret();
}
1;
use utf8;
use File::Path;

require "$admcmd/z_thread.pl";
my $opt = $cgi->param('opt');

if ($opt eq 'exe') {
	require "$subcmd/move.pl";
	if ($ifo{'img_lib'}) {
		require "$dir/test/sub/smn".$ifo{'img_lib'}.'.pl';
	} else {
		require "$dir/test/sub/smn.pl";
	}
	require "$subcmd/page.pl";
	require "$subcmd/mobile.pl";
	th_clr_exe();
} else {
	select_thr();
}

sub select_thr{
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	header("スレッド消去");
	echo "消去するスレッドを選択して下さい。";
	if (out_thread(1,$board)) {
		submit_exe();
	} else {
		submit_ret();
	}
	echo '<input type="hidden" name="cmd" value="thread_clr">',"\n";
	echo '<input type="hidden" name="opt" value="exe">',"\n";
}

sub th_clr_exe {
	if ($cgi->param('submit') eq $modoru) {
		show_menu();
	}
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	header("スレッド消去");
	my @dat_name =  $cgi->param('dat_name');
	@dat_name = del_subject($board,@dat_name);
	my $cnt = del_thread($board,@dat_name);
	print "<td>$cnt";
	echo "件のスレッドを削除しました<br>\n";
	if ($type ne 'kako' || count_kako($bbs) == 0) {
		get_setting($bbs);
		get_subject();
		put_pc();
		put_subback();
		put_mobile();
	}
	submit_ret();
}
1;

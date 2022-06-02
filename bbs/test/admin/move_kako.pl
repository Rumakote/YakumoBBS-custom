use utf8;

require "$admcmd/z_thread.pl";
require "$subcmd/move.pl";

my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');
$cmd_str = '<input type="hidden" name="cmd" value="move_kako">'."\n";

if ($opt eq 'exe') {
	move_exe($submit);
} else {
	move_menu($submit);
}

sub move_menu {
	my $submit = shift;
	my $board = $bbs;
	if ($submit eq $modoru) {
		show_menu();
	}
	if ($type eq 'kako') {
		header("投稿用ボードへ移動");
		$board = $bbs.'_kako';
	} else {
		header("過去ログ倉庫へ移動");
	}
	echo '移動するスレッドを選択して下さい';
	if (out_thread(1,$board)) {
		submit_exe();
	} else {
		submit_ret();
	}
	print '<input type="hidden" name="opt" value="exe">'."\n";
	print $cmd_str;
}

sub move_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my @list = $cgi->param('dat_name');
	my $from;
	my $to;
	if ($type eq 'kako') {
		header("投稿用ボードへ移動");
		$from = $bbs.'_kako';
		$to = $bbs;
	} else {
		header("過去ログ倉庫へ移動");
		$from = $bbs;
		$to = $bbs.'_kako';
	}
	print "<td>\n";
	my @dat_name;
	foreach $data(@list) {	#要改造
		my ($key,$title) = split('.dat<>',trim($data));
		if (-e "../$to/dat/$key.dat") {
			print $title;
			echo " スレッドキー重複に付き移動不可<br>\n";
			next;
		}
		unshift(@dat_name,trim($data)."\n");
	}
	my $cnt = move_kako_th($from,$to,@dat_name);
	echo $cnt,"件スレッドを移動しました\n";
	if ($cnt) {
		if ($ifo{'img_lib'}) {
			require "$dir/test/sub/smn".$ifo{'img_lib'}.'.pl';
		} else {
			require "$dir/test/sub/smn.pl";
		}
		require "$subcmd/page.pl";
		require "$subcmd/mobile.pl";
		get_setting($bbs);
		get_subject();
		put_pc();
		put_subback();
		put_mobile();
	}
	submit_ret();
}
1;
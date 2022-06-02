use utf8;

require "$admcmd/z_thread.pl";
require "$subcmd/move.pl";

my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');
$cmd_str = '<input type="hidden" name="cmd" value="thread_move">'."\n";

if ($opt eq 'exe') {
	move_exe($submit);
} else {
	move_menu($submit);
}

sub move_menu {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	header("ボード間移動");
	my $board_name = check_board($bbs);
	if ($type eq 'kako') {$board_name .= enc_str(" 過去ログ倉庫");}
	echo "<td colspan='3'>移動元ボード　$bbs ： ";
	print "$board_name</td></tr><td colspan='3'>\n";
	echo "移動先選択";
	@list = board_list();
	print "<select name='to_bbs' size='1'>\n";
	foreach $data(@list) {
		my ($dir,$label) = split('<>',$data);
		my $check = '';
		if ($dir eq '') {
			$dir = '-';
			$check = ' disabled';
		} else {
			$label = "$dir:$label";
		}
		print "<option value='$dir'$check>$label</option>\n";
	}
	print "</select>\n";
	print "</td></tr><td colspan='3'>\n";
	echo "移動するスレッドを選択して下さい</td></tr>";
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
	my $from_bbs = $bbs;
	my @list = $cgi->param('dat_name');
	my $to_bbs = $cgi->param('to_bbs');
	header("ボード間移動");
	print "<td>\n";
	my $er = '';
	if ($bbs eq $to_bbs) {$er = "移動元と移動先が同じです<br>";}
	if ($type eq 'kako') {
		$from_bbs .= '_kako';
		$to_bbs .= '_kako';
	}
	@list = move_check($to_bbs,@list);
	my $cnt = @list;
	if ($cnt == 0) {$er = "移動するスレッドが有りません<br>";}	
	if ($er ne '') {
		echo $er;
		$er .= "スレッドの移動はしませんでした";
	} else {
		$cmp_flg = 0;
		$cnt = move_kako_th($from_bbs,$to_bbs,@list);
		echo $cnt,"件のスレッドを移動しました";
		if ($type eq 'board') {
			if ($ifo{'img_lib'}) {
				require "$dir/test/sub/smn".$ifo{'img_lib'}.'.pl';
			} else {
				require "$dir/test/sub/smn.pl";
			}
			require "$subcmd/page.pl";
			require "$subcmd/mobile.pl";
			my $tmp = $bbs;
			$bbs = $from_bbs;
			get_setting($bbs);
			get_subject();
			put_pc();
			put_subback();
			put_mobile();
			$bbs = $to_bbs;
			get_setting($bbs);
			get_subject();
			put_pc();
			put_subback();
			put_mobile();
			$bbs = $tmp;
		}
	}
	submit_ret();
}

sub move_check {
	my $board = shift;
	my @list;
	foreach $data(@_) {
		my ($dat,$name) = split('<>',$data);
		if (-e "../$board/dat/$dat") {
			print $name;
			echo "は移動先にも有ります<br>\n";
		} else {
			push(@list,$data);
		}
	}
	return(@list);
}
1;

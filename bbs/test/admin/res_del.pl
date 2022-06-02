use utf8;

require "$admcmd/z_thread.pl";

my $opt = $cgi->param('opt');
if ($opt eq 'exe') {
	get_setting($bbs);
	if ($setting{'IMG_MODE'} eq 'checked') {
		if ($ifo{'img_lib'}) {
			require "$dir/test/sub/smn".$ifo{'img_lib'}.'.pl';
		} else {
			require "$dir/test/sub/smn.pl";
		}
	}
	require "$subcmd/page.pl";
	del_exe($submit);
} elsif ($opt eq 'select') {
	del_select();
} else {
	del_menu();
}

sub del_menu {
	my $submit = $cgi->param('submit');
	if ($submit eq $modoru) {
		show_menu();
	}
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	header("どのスレッドからレスを削除しますか？");
	if (out_thread(0,$board)) {
		submit_select();
	} else {
		submit_ret();
	}
	echo '<input type="hidden" name="cmd" value="res_del">',"\n";
	echo '<input type="hidden" name="opt" value="select">',"\n";
}

sub del_select {
	my $submit = $cgi->param('submit');
	if ($submit eq $modoru) {
		show_menu();
	}
	my $key = $cgi->param('dat_name');
	my $thr;
	if ($key eq '') {
		del_menu();
		footer();
	}
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	($key,$thr) = split(/\.dat<>/,$key);
	open(LOG,"<../$board/dat/$key.dat") or error_exit($board.$key."ファイルのオープンに失敗しました");
#	flock(LOG,1);
	if (!open(IFO,"<../$board/ifo/$key.cgi")) {
		close(LOG);
	 	error_exit('ifoファイルのオープンに失敗しました');
	}
#	flock(IFO,1);
	header(dec_str($thr));
	my $count = 0;
	while(<LOG>) {
		my ($name,$mail,$info,$message,$title,$admin) = split( /<>/,$_);
		my $cnt = $.;
		$ifo = <IFO>;
		if (index($ifo,'<>') < 0) {
			res_view('削除',$cnt,\$name,\$mail,\$info,\$message,\$ifo,$admin);
			$count++;
		}
	}
	close(LOG);
	close(IFO);
	if ($count) {
		submit_exe('選択したレスを削除');
	} else {
		echo "<td>削除できるレスが有りません";
		submit_ret();
	}
	echo "<input type='hidden' name='cmd' value='res_del'>\n";
	echo "<input type='hidden' name='opt' value='exe'>\n";
	echo "<input type='hidden' name='key' value='$key'>\n";
}

sub del_exe {
	my $submit = $cgi->param('submit');
	if ($submit eq $modoru) {
		del_menu();
		footer();
	}
	my @num =  $cgi->param('num');
	$key = $cgi->param('key');
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	my $tmp1 = time().'.tmp';
	my $tmp2 = "../$board/ifo/$tmp1";
	my $tmp1 = "../$board/dat/$tmp1";
	my $fname1 = "../$board/dat/$key.dat";
	my $fname2 = "../$board/ifo/$key.cgi";
	my $sig = (get_index(1,$board,$key) < 0 ? -1 : 1);
	my $cnt = 0;
	my $del = shift(@num);
	get_setting($bbs);
	$abone = $setting{'DELETE_NAME'};
	get_subject();
	open(DAT,"+<$fname1") or error_exit('レスの削除に失敗しました');
	flock(DAT,2);
	open(DTM,"+>$tmp1") or (close(DAT) and error_exit('レスの削除に失敗しました'));
	if (!open(IFO,"+<$fname2")) {
		close(DAT);
		close(DTM);
		error_exit('レスの削除に失敗しました');
	}
	flock(IFO,2);
	if (!open(ITM,"+>$tmp2")) {
		close(DAT);
		close(DTM);
		close(IFO);
		error_exit('レスの削除に失敗しました');
	}
	seek(DAT,0,0);
	seek(IFO,0,0);
	while(<DAT>) {
		$line1 = $_;
		$line2 = <IFO>;
		if ($. == $del) {
			$line2 =~ s/\s*$/<>deleted$member{'name'}<>$line1/;
			$line1 = "$abone<>$abone<>$abone<>$abone".substr($line1,rindex($line1,'<>'));
			$del = shift(@num);
			$cnt++;
		}
		print DTM $line1;
		print ITM $line2;
	}
	seek(DAT,0,0);
	seek(IFO,0,0);
	seek(ITM,0,0);
	seek(DTM,0,0);
	print DAT <DTM>;
	print IFO <ITM>;
	truncate(IFO,tell(IFO));
	truncate(DAT,tell(DAT));
	close(IFO);
	close(DAT);
	close(DTM);
	close(ITM);
	unlink $tmp1,$tmp2;
	header('レス削除');
	echo "<td>$cnt",'件削除しました<br>';
	if ($cnt > 0) {echo makeindex($board,$key,$sig);}
	if ($type ne 'kako') {put_pc();}
	submit_ret();
}
1;

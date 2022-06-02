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
	reb_exe();
} elsif ($opt eq 'select') {
	reb_select();
} else {
	reb_menu();
}

sub reb_menu {
	header("どのスレッドからレスを復活させますか？");
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	if (out_thread(0,$board)) {
		submit_select();
	} else {
		submit_ret();
	}
	echo '<input type="hidden" name="cmd" value="res_reb">',"\n";
	echo '<input type="hidden" name="opt" value="select">',"\n";
}

sub reb_select {
	my $submit = $cgi->param('submit');
	if ($submit eq $modoru) {
		show_menu();
	}
	my $key = $cgi->param('dat_name');
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	my $thr;
	if ($key eq '') {
		rev_menu();
		footer();
	}
	($key,$thr) = split(/\.dat<>/,$key);
	open(IFO,"<../$board/ifo/$key.cgi") or error_exit("IFOファイルのオープンに失敗しました");
#	flock(IFO,1);
	header(dec_str($thr));
	my $cnt = 0;
	while(<IFO>) {
		my ($ifo,$admin,$name,$mail,$info,$message,$title) = split( /<>/,$_);
		if ($info ne '') {
			res_view('復活',$.,\$name,\$mail,\$info,\$message,\$ifo,$admin);
			$cnt++;
		}
	}
	close(IFO);
	if ($cnt) {
		submit_exe('選択したレスを復活');
	} else {
		echo "<td>復活できるレスが有りません";
		submit_ret();
	}
	echo "<input type='hidden' name='cmd' value='res_reb'>\n";
	echo "<input type='hidden' name='opt' value='exe'>\n";
	echo "<input type='hidden' name='key' value='$key'>";
}

sub reb_exe {
	my $submit = $cgi->param('submit');
	if ($submit eq $modoru) {
		reb_menu();
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
	my $reb = shift(@num);
	get_setting($bbs);
	get_subject();
	open(DAT,"+<$fname1") or error_exit('レスの復活に失敗しました');
	flock(DAT,2);
	open(DTM,"+>$tmp1") or (close(DAT) and error_exit('レスの復活に失敗しました'));
	if (!open(IFO,"+<$fname2")) {
		close(DAT);
		close(DTM);
		error_exit('レスの復活に失敗しました');
	}
	flock(IFO,2);
	if (!open(ITM,"+>$tmp2")) {
		close(DAT);
		close(DTM);
		close(IFO);
		error_exit('レスの復活に失敗しました');
	}
	seek(DAT,0,0);
	seek(IFO,0,0);
	while(<DAT>) {
		$line1 = $_;
		$line2 = <IFO>;
		if ($. == $reb) {
			$line1 = substr($line2,index($line2,'<>') + 2);
			$line1 = substr($line1,index($line1,'<>') + 2);
			$line2 = substr($line2,0,index($line2,'<>'))."\n";
			$reb = shift(@num);
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
	header('レス復活');
	echo "<td>$cnt",'件復活させました<br>';
	if ($cnt > 0) {echo makeindex($bbs,$key,$sig);}
	if ($type ne 'kako') {put_pc();}
	submit_ret();
}

1;

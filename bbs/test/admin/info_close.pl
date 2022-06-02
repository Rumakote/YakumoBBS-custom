use utf8;

require "$admcmd/z_thread.pl";
$cmd_str = '<input type="hidden" name="cmd" value="info_close">',"\n";
$submit = $cgi->param('submit');

$opt = $cgi->param('opt');

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
	info_exe($submit);
} elsif ($opt eq 'select') {
	info_select($submit);
} else {
	info_menu($submit);
}

sub info_menu {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	header("どのスレッドのレスの端末情報を非公開にしますか？");
	if (out_thread(0,$board)) {
		submit_select();
	} else {
		submit_ret();
	}
	print $cmd_str;
	echo "<input type='hidden' name='board' value='$board'>\n";
	echo '<input type="hidden" name="opt" value="select">',"\n";
}

sub info_select {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my $key = $cgi->param('dat_name');
	my $thr;
	if ($key eq '') {
		info_menu();
		footer();
	}
	my $board = $cgi->param('board');
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
		if (index($message,'<hr>') >= 0) {
			res_view("非公開",$cnt,\$name,\$mail,\$info,\$message,\$ifo,$admin);
			$count++;
		}
	}
	close(LOG);
	close(IFO);
	if ($count) {
		submit_exe();
	} else {
		echo "<td>端末情報を公開されたレスが有りません";
		submit_ret();
	}
	print $cmd_str;
	echo "<input type='hidden' name='opt' value='exe'>\n";
	echo "<input type='hidden' name='board' value='$board'>\n";
	echo "<input type='hidden' name='thr' value='$thr'>\n";
	echo "<input type='hidden' name='key' value='$key'>\n";
}

sub info_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my @num =  $cgi->param('num');
	$key = $cgi->param('key');
	my $board = $cgi->param('board');
	my $tmp = time().'.tmp';
	my $fname = "../$board/dat/$key.dat";
	my $sig = (get_index(1,$board,$key) < 0 ? -1 : 1);
	my $cnt = 0;
	get_subject();
	open(DAT,"+<$fname") or error_exit('レスの書き換えに失敗しました');
	flock(DAT,2);
	open(DTM,"+>$tmp") or (close(DAT) and error_exit('レスの書き換えに失敗しました'));
	seek(DAT,0,0);
	my $edit = shift(@num);
	while(<DAT>) {
		my $line = $_;
		if ($. == $edit) {
			my ($name,$mail,$inf,$message,$title) = split(/<>/,$_);
			$message = substr($message,0,index($message,'<hr>'));
			$line = "$name<>$mail<>$inf<>$message<>$title";
			$edit = shift(@num);
			$cnt++;
		}
		print DTM $line;
	}
	seek(DAT,0,0);
	seek(DTM,0,0);
	print DAT <DTM>;
	truncate(DAT,tell(DAT));
	close(DAT);
	close(DTM);
	unlink $tmp;
	header('端末情報公開');
	echo "<td>$cnt",'件の情報を公開しました<br>';
	if ($cnt > 0) {echo makeindex($board,$key,$sig);}
	if ($type ne 'kako') {put_pc();}
	submit_ret();
}

1;

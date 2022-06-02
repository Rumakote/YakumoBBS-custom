use utf8;

require "$admcmd/z_thread.pl";
$cmd_str = '<input type="hidden" name="cmd" value="res_edit">',"\n";
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
	edit_exe($submit);
} elsif ($opt eq 'select') {
	edit_select($submit);
} elsif ($opt eq 'edit') {
	edit_edit($submit);
} else {
	edit_menu($submit);
}

sub edit_menu {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	header("どのスレッドのレスを編集しますか？");
	if (out_thread(0,$board)) {
		submit_select();
	} else {
		submit_ret();
	}
	print $cmd_str;
	echo "<input type='hidden' name='board' value='$board'>\n";
	echo '<input type="hidden" name="opt" value="select">',"\n";
}

sub edit_select {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my $key = $cgi->param('dat_name');
	my $thr;
	if ($key eq '') {
		edit_menu();
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
		if (index($ifo,'<>') < 0) {
			res_view('編集',$cnt,\$name,\$mail,\$info,\$message,\$ifo,$admin);
			$count++;
		}
	}
	close(LOG);
	close(IFO);
	if ($count) {
		submit_select('選択したレスを編集');
	} else {
		echo "<td>編集できるレスが有りません";
		submit_ret();
	}
	print $cmd_str;
	echo "<input type='hidden' name='opt' value='edit'>\n";
	echo "<input type='hidden' name='board' value='$board'>\n";
	echo "<input type='hidden' name='thr' value='$thr'>\n";
	echo "<input type='hidden' name='key' value='$key'>\n";
}

sub edit_edit {
	my $submit = shift;
	if ($submit eq $modoru) {
		edit_menu();
		footer();
	}
	my @num =  $cgi->param('num');
	my $thr = $cgi->param('thr');
	my $key = $cgi->param('key');
	my $board = $cgi->param('board');
	header(レス編集);
	my $fpt = @num;
	if ($fpt < 1) {
		echo "<td>編集するレスが有りません";
		submit_ret();
	} else {
		$fpt = 0;
		open(LOG,"<../$board/dat/$key.dat") or error_exit($board.$key."ファイルのオープンに失敗しました");
#		flock(LOG,1);
		foreach $idx (@num) {
			echo "<input type='hidden' name='num' value='$idx'>\n";
			if ($idx > 1) {$fpt = get_index($idx,$board,$key);}
			seek(LOG,$fpt,0);
			my ($name,$mail,$info,$message,$title) = split( /<>/,<LOG>);
			$title = trim($title);
			echo "<td>$idx 名前:";
			print "<input type='text' name='$idx","_name' value=\"$name\"> \n";
			print "mail:<input type='text' name='$idx","_mail' value=\"$mail\"> $info\n";
			print "<input type='hidden' name='$idx","_info' value=\"$info\">\n";
			$message =~ s/<br>/\n/g;
			print "</td></tr><tr><td><textarea name='$idx","_message' rows='6' cols='90'>$message</textarea>\n";
			print "<input type='hidden' name='$idx","_title' value=\"$title\"></tr><tr>\n";
		}
		close(LOG);
		submit_exe();
	}
	print $cmd_str;
	echo "<input type='hidden' name='board' value='$board'>\n";
	echo "<input type='hidden' name='opt' value='exe'>\n";
	echo "<input type='hidden' name='key' value='$key'>\n";
}

sub edit_exe {
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
	my $edit = shift(@num);
	get_subject();
	open(DAT,"+<$fname") or error_exit('レスの書き換えに失敗しました');
	flock(DAT,2);
	open(DTM,"+>$tmp") or (close(DAT) and error_exit('レスの書き換えに失敗しました'));
	seek(DAT,0,0);
	while(<DAT>) {
		my $line = $_;
		if ($. == $edit) {
			$line = $cgi->param($edit.'_message');
			$line =~ s/\n/<br>/g;
			$line = $cgi->param($edit.'_name').'<>'.$cgi->param($edit.'_mail').'<>'.$cgi->param($edit.'_info').'<>'.$line.'<>'.$cgi->param($edit.'_title')."\n";
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
	header('レス編集');
	echo "<td>$cnt",'件書き換えました<br>';
	if ($cnt > 0) {echo makeindex($board,$key,$sig);}
	if ($type ne 'kako') {put_pc();}
	submit_ret();
}

1;
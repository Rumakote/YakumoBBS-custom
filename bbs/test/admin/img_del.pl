use utf8;

require "$admcmd/z_thread.pl";

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
	del_exe();
} elsif ($opt eq 'select') {
	del_select();
} else {
	$bbs = $cgi->param('bbs');
	del_menu();
}

sub del_menu {
	header("どのスレッドから画像を削除しますか？");
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	if(out_thread(0,$board)) {
		submit_select();
	} else {
		submit_ret();
	}
	echo '<input type="hidden" name="cmd" value="img_del">',"\n";
	echo '<input type="hidden" name="opt" value="select">',"\n";
}

sub del_select {
	my $submit = $cgi->param('submit');
	if ($submit eq $modoru) {
		show_menu();
	}
	my $key = $cgi->param('dat_name');
	my $thr;
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	if ($key eq '') {
		del_menu();
		footer();
	}
	($key,$thr) = split(/\.dat<>/,$key);
	open(LOG,"<../$board/dat/$key.dat") or error_exit($board.$key."ファイルのオープンに失敗しました");
	flock(LOG,1);
	if (!open(IFO,"<../$board/ifo/$key.cgi")) {
		close(LOG);
	 	error_exit('ifoファイルのオープンに失敗しました');
	}
	flock(IFO,1);
	header(dec_str($thr));
	my $img_path = get_top()."$board/img/$key";
	while(<LOG>) {
		my ($name,$mail,$info,$message,$title,$admin) = split( /<>/,$_);
		my $cnt = $.;
		$ifo = <IFO>;
		if (index($message,"$img_path/$cnt.") >= 0) {res_view('削除',$cnt,\$name,\$mail,\$info,\$message,\$ifo,$admin);}
	}
	close(LOG);
	close(IFO);
	submit_exe('選択した画像を削除');
	echo "<input type='hidden' name='cmd' value='img_del'>\n";
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
	my $line;
	my $tmp = time().'.tmp';
	$tmp = "../$board/dat/$tmp";
	my $fname = "../$board/dat/$key.dat";
	my $sig = (get_index(1,$board,$key) < 0 ? -1 : 1);
	open(DAT,"+<$fname") or error_exit('レスの削除に失敗しました');
	flock(DAT,2);
	open(TMP,"+>$tmp") or (close(DAT) and error_exit('レスの削除に失敗しました'));
	seek(DAT,0,0);
	my $del = shift(@num);
	my $cnt = 0;
	header('画像削除');
	print '<td>';
	while(<DAT>) {
		$line = $_;
		if ($. == $del) {
			my $delname = "../$board/smn/$key/$del.jpg";
			if (-e $delname) {
				if(unlink $delname) {
					echo "$delname 削除<br>";
				} else {
					echo "$delname 削除失敗<br>";
				}
			}
			my ($name,$mail,$info,$message,$title) = split(/<>/,$line);
			$delname = substr($message,0,index($message,' '));
			$delname = substr($delname,-3);
			$delname = "../$board/img/$key/$del.$delname";
			if (unlink $delname) {
				echo "$delname 削除<br>";
			} else {
				echo "$delname 削除失敗<br>";
			}
			$message =~ s/^.+?\)<br>//o;
			$line = "$name<>$mail<>$info<>$message<>$title";
			$del = shift(@num);
			$cnt++;
		}
		print TMP $line;
	}
	seek(DAT,0,0);
	seek(TMP,0,0);
	print DAT <TMP>;
	truncate(DAT,tell(DAT));
	close(DAT);
	close(TMP);
	unlink $tmp;
	echo "$cnt",'件リンクを削除<br>';
	if ($cnt > 0) {echo makeindex($bbs,$key,$sig);}
	get_subject();
	if ($type ne 'kako') {put_pc();}
	submit_ret();
}
1;

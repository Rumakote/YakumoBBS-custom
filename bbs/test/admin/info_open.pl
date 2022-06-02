use utf8;

require "$admcmd/z_thread.pl";
$cmd_str = '<input type="hidden" name="cmd" value="info_open">',"\n";
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
	header("どのスレッドのレスの端末情報を公開しますか？");
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
		if (index($message,'<hr>') < 0) {
			info_view($cnt,\$name,\$mail,\$info,\$message,\$ifo,$admin);
			$count++;
		}
	}
	close(LOG);
	close(IFO);
	if ($count) {
		submit_exe();
	} else {
		echo "<td>端末情報公開できるレスが有りません";
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
		my $edit = $.;
		if ($cgi->param($edit.'_host') || $cgi->param($edit.'_ip') || $cgi->param($edit.'_agent') || $cgi->param($edit.'_referer')) {
			my ($name,$mail,$inf,$message,$title) = split(/<>/,$_);
			$line = $message.'<hr>'.$cgi->param($edit.'_host').$cgi->param($edit.'_ip').$cgi->param($edit.'_agent').$cgi->param($edit.'_referer');
			$line =~ s/<br>$//;
			$line = "$name<>$mail<>$inf<>$line<>$title";
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

sub info_view {
	my $num = shift;
	my $name = shift;
	my $mail = shift;
	my $info1 = shift;
	my $message = shift;
	my $ifo = shift;
	my $admin = shift;
	($$ifo) = split(/<>/,$$ifo);
	my ($info2,$host,$ipad,$id,$agent,$referer,$proxy,$level) = split(/\|_\|/,$$ifo);
	$referer = trim($referer);
	print "<td bgcolor=\"#cceecc\">\n";
	print "$num:<b>$$name</b>[$$mail]$$info1</td></tr>\n";
	print "<tr><td>\n";
	echo "<input type=\"checkbox\" name=\"$num","_host\" value='".substr($host,5)." '>リモートホスト \n";
	echo "<input type=\"checkbox\" name=\"$num","_ip\" value='(".substr($ipad,15).")<br>'>IPアドレス\n";
	html_spchar(\$agent);
	echo "<input type=\"checkbox\" name=\"$num","_agent\" value=\"".substr($agent,6)."<br>\">ユーザーエージェント\n";
	echo "<input type=\"checkbox\" name=\"$num","_referer\" value=\"".substr($referer,8)."\">リファラ\n";
	my ($img_path) = $$message =~ /^(s?http[^ ]+)/o;
	my $path = get_top();
	if (index($img_path,$path) == 0) {
		substr($img_path,0,length($path),'../');
		substr($img_path,-3,3,'jpg');
		substr($img_path,index($img_path,'img'),3,'smn');
	}
	if (-e $img_path) {
		$$message =~ s/^[^ ]+//g;
		$$message .= '<br clear="all">';
		$img_path = "<img src='$img_path' align='left' border='0'>";
	} else {
		$img_path = '';
	}
	print "<hr>$img_path$$message";
	if ($member{'level'} & 4) {
		print '<hr>',($info2 eq $$info1 ? '' : '<font color="#FF0000">'.$info2.'</font> ');
		if ($proxy) {$proxy .= "<br>";}
		print "$host $ipad $id $level<br>$proxy$agent<br>$referer<br>\n";
	}
	print '</td></tr><tr>';
}

sub html_spchar {	#&と'の変換はしない
	my $text = shift;
	$$text =~ s/"/&quot;/g;	#"の変換
	$$text =~ s/</&lt;/g;	#<の変換
	$$text =~ s/>/&gt;/g;	#>の変換
	$$text =~ s/\n|\r\n|\r/<br>/g;	#改行の変換
}
1;

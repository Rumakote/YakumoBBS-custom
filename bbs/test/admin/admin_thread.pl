use utf8;
use Time::HiRes qw(gettimeofday);

require "$subcmd/info.pl";	#時間と文字変換

$opt = $cgi->param('opt');
my $submit = $cgi->param('submit');
$cmd_str = '<input type="hidden" name="cmd" value="admin_thread">'."\n";

if ($opt eq 'exe') {
	exe_thread($submit);
} else {
	edit_thread();
}

sub edit_thread {
	header("管理者スレ立て");
	echo "<td>書き込み禁止<input type='checkbox' name='mode' value='kinshi'></td></tr>\n";
	echo "<tr><td>スレッドタイトル<input type='text' name='subject' size='50'></td></tr><tr><td>名前：";
	print "<b>$member{'name'}</b> @ $member{'cap'} ",enc_str("★ "),"ID:$member{'id'}";
	print " E-mail <input type='text' name='mail'></td></tr>\n";
	print "<tr><td><textarea name='message' cols='70' rows='20'>\n";
	print "</textarea><br>\n";
	submit_exe();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='exe'>\n";
}

sub exe_thread {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my $mode = $cgi->param('mode');
	$mode = ($mode eq 'kinshi' ? -1 : 1);
	my $subject = trim($cgi->param('subject'));
	my $mail = $cgi->param('mail');
	my $text = $cgi->param('message');
	header("管理者投稿");
	print "<td>\n";
	my $er = '';
	$text = rtrim($text);
	if ($text eq '') {$er = "本文の無い投稿はできません<br>\n";}
	my ($subject_cnt,$mail_cnt,$mes_cnt,$id_ck) = setting_get();	#メール欄、本文の最大長、IDの表示
	if (index($mail,'#') >= 0) {
		$mail = substr($mail,0,index($mail,'#'));
	}
	if (length($subject) > $subject_cnt) {$er .= "スレッドタイトルが長すぎます<br>\n";}
	if (length($mail) > $mail_cnt) {$er .= "メール欄が長過ぎます<br>\n";}
	if (length($text) > $mes_cnt) {$er .= "本文が長過ぎます<br>\n";}
	if ($er ne '') {
		echo $er;
		submit_ret();
		footer();
	}
	html_spchar(\$subject);
	html_spchar(\$mail);
	html_spchar(\$text);
	my $name = "$member{'name'}</b> @ $member{'cap'} ".enc_str('★')."<b>";
	my $id = ($id_ck ? " ID:$member{'id'}" : '');
	my $key = time();
	if (write_res($mode,\$subject,$key,\$name,\$mail,\$id,\$text)) {
		print $subject;
		echo "スレッドを立てました";
		require "$admcmd/z_indexhtml.pl";
		rewrite_index_html($bbs);
	} else {
		echo "スレ立てに失敗しました";
	}
	submit_ret();
}

sub setting_get {
	my %setting = get_setting_txt($bbs);
	my $id = ($setting{'FORCE_ID'} eq 'checked' ? 1 : 0);
	return($setting{'SUBJECT_COUNT'},$setting{'MAIL_COUNT'},$setting{'MESSAGE_COUNT'},$id);
}

sub write_res {
	my $mode = shift;
	my $subject = shift;
	my $key = shift;
	my $name = shift;
	my $mail = shift;
	my $id = shift;
	my $text = shift;
	my $info = get_datetime() . $$id;
	$$text =~ s/(&gt;&gt;)(\d+-?\d*)/<a href="..\/test\/read.cgi\/$bbs\/$key\/$2" target="_blank">$1$2<\/a>/g;
	$$text =~ s/(&gt;&gt;)(-\d+)/<a href="..\/test\/read.cgi\/$bbs\/$key\/$2" target="_blank">$1$2<\/a>/g;
	my $line = $$name.'<>'.$$mail.'<>'.$info.'<>'.$$text.'<>'."$$subject\n";
	my $ifline = "$info|_|$call|_|level=$member{'level'}|_|admin|_|admin|_|admin\n";
	if (-e "../$bbs/dat/$key.dat") {return(0);}
	open(LOG,"> ../$bbs/dat/$key.dat") or return(0);
	flock(LOG,2);
	unless (open(IDX,">../$bbs/idx/$key.idx")) {
		close(LOG);
		return(0);
	}
	flock(IDX,2);
	binmode(IDX);
	unless (open(IFO,"> ../$bbs/ifo/$key.cgi")) {
		close(IDX);
		close(LOG);
		return(0);
	}
	flock(IFO,2);
	my $buf = pack("l",$mode);
	print IDX $buf;
	print LOG $line;
	print IFO $ifline;
	close(IDX);
	close(IFO);
	if ($ifo{'perm_file'} ) {
		chmod(oct($ifo{'perm_file'}),"../$bbs/ifo/$key.cgi");
	}
	sbj_rewrite($key,$subject);
	return (1);
}

sub sbj_rewrite {
	my $key = shift;
	my $subject = shift;
	my @list;
	my $line;
	push(@list,"$key.dat<>$$subject (1)\n");
	open(SBJ,"+< ../$bbs/subject.txt") or return(0);
	flock(SBJ, 2);
	seek(SBJ, 0, 0);
	while(<SBJ>) {
		push(@list,$_);
	}
	seek(SBJ, 0, 0);
	print SBJ @list;
	truncate(SBJ,tell(SBJ));
	close(SBJ);
	@sbj_txt = @list;
	return(0);
}

1;

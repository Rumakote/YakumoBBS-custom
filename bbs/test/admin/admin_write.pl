use utf8;
use Time::HiRes qw(gettimeofday);

require "$subcmd/info.pl";	#時間と文字変換

$opt = $cgi->param('opt');
my $submit = $cgi->param('submit');
$cmd_str = '<input type="hidden" name="cmd" value="admin_write">'."\n";

if ($opt eq 'form') {
	write_form($submit);
} elsif ($opt eq 'exe') {

	write_exe($submit);
} else {
	write_select();
}

sub write_select {
	header("書き込むスレッドを選択");
	if (show_thread($bbs)) {
		submit_select();
	} else {
		submit_ret();
	}
	print "<input type='hidden' name='opt' value='form'>\n";
	print $cmd_str;
}

sub write_form {
	my $submit = shift;
	my @list = $cgi->param('key');
	my $cnt = @list;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("管理者投稿");
	if ($cnt == 0) {
		echo "<td>スレッドが選択されていません";
		submit_ret();
		footer();
	}
	echo "<td>名前：";
	print "<b>$member{'name'}</b> @ $member{'cap'} ",enc_str("★ "),"ID:$member{'id'}";
	print " E-mail <input type='text' name='mail'></td></tr>\n";
	print "<tr><td><textarea name='message' cols='70' rows='20'>\n";
	print "</textarea><br>\n";
	foreach $data(@list) {
		print "<input type='hidden' name='key' value='$data'>\n";
	}
	submit_exe();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='exe'>\n";
}

sub write_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		write_select();
		footer();
	}
	my $mail = $cgi->param('mail');
	my @list = $cgi->param('key');
	my $text = $cgi->param('message');
	header("管理者投稿");
	print "<td>\n";
	my $er = '';
	$text = rtrim($text);
	if ($text eq '') {$er = "本文の無い投稿はできません<br>\n";}
	my ($mail_cnt,$mes_cnt,$id_ck) = setting_get();	#メール欄、本文の最大長、IDの表示
	if (index($mail,'#') >= 0) {
		$mail = substr($mail,0,index($mail,'#'));
	}
	if (length($mail) > $mail_cnt) {$er .= "メール欄が長過ぎます<br>\n";}
	if (length($text) > $mes_cnt) {$er .= "本文が長過ぎます<br>\n";}
	if ($er ne '') {
		echo $er;
		submit_ret();
		footer();
	}
	html_spchar(\$mail);
	html_spchar(\$text);
	my $name = "$member{'name'}</b> @ $member{'cap'} ".enc_str('★')."<b>";
	my $id = ($id_ck ? " ID:$member{'id'}" : '');
	my $cnt = 0;
	my $last = read_file("../$bbs/last.txt");
	if ($last eq '') {read_file("../ifo/last.txt");}
	if ($last eq '') {$last = enc_str("終了<><>Over Limit Thread<>このスレッドは書き込み限界を超えました。<br>新しいスレッドを立ててください。<>\n");}
	foreach $data(@list) {
		$cnt += write_res($data,\$name,\$mail,\$id,\$text,\$last);
	}
	echo $cnt,"件の投稿をしました";
	require "$admcmd/z_indexhtml.pl";
	rewrite_index_html($bbs);
	submit_ret();
}

sub show_thread {
	my $board = shift;
	@list = read_tbl("../$board/subject.txt");
	my $cnt = @list;
	if ($cnt == 0) {
		echo "<td>この板にはスレッドが無いか、スレッド一覧の読み込みに失敗しています<br>";
		return(0);
	}
	my $max = int($cnt / 30 + 0.99);
	if ($max > 3) {$max = 3;}
	$max = int($cnt / $max + 0.99);
	$cnt = 1;
	foreach $data(@list) {
		my ($key,$name) = split('.dat<>',$data);
		my $count = substr($name,rindex($name,'('));
		$name = trim($name);
		$count =~ s/[^0-9]//g;
		$count += 0;
		my $check = ($count < $ifo{'max_res'} ? '' : ' disabled');
		if (($cnt -1) % $max == 0) {print ($cnt == 1 ? "<td valign=\"top\">\n" : "</td><td valign=\"top\">\n");}
		print "<input type='checkbox' name='key' value='$key'$check>$cnt:$name<br>\n";
		$cnt++;
	}
	return(1);
}

sub setting_get {
	my %setting = get_setting_txt($bbs);
	my $id = ($setting{'FORCE_ID'} eq 'checked' ? 1 : 0);
	return($setting{'MAIL_COUNT'},$setting{'MESSAGE_COUNT'},$id);
}

sub write_res {
	my $key = shift;
	my $name = shift;
	my $mail = shift;
	my $id = shift;
	my $text = shift;
	my $last = shift;
	my $info = get_datetime() . $$id;
	$$text =~ s/(&gt;&gt;)(\d+-?\d*)/<a href="..\/test\/read.cgi\/$bbs\/$key\/$2" target="_blank">$1$2<\/a>/g;
	$$text =~ s/(&gt;&gt;)(-\d+)/<a href="..\/test\/read.cgi\/$bbs\/$key\/$2" target="_blank">$1$2<\/a>/g;
	my $line = $$name.'<>'.$$mail.'<>'.$info.'<>'.$$text."<>\n";
	my $ifline = "$info|_|$call|_|level=$member{'level'}|_|admin|_|admin|_|admin\n";
	open(LOG,">> ../$bbs/dat/$key.dat") or return(0);
	flock(LOG,2);
	unless (open(IDX,"+<../$bbs/idx/$key.idx")) {
		close(LOG);
		return(0);
	}
	flock(IDX,2);
	binmode(IDX);
	seek(IDX,0,0);
	my $buf;
	read(IDX,$buf,4);
	my $max = unpack("l",$buf);
	my $sgn = ($max < 0 ? -1 : 1);
	$max = abs($max);
	if ($max > $ifo{'max_res'}) {
		close(IDX);
		close(LOG);
		return(0);
	}
	unless (open(IFO,">> ../$bbs/ifo/$key.cgi")) {
		close(IDX);
		close(LOG);
		return(0);
	}
	flock(IFO,2);
	my $fpt = tell(LOG);
	if ($fpt >= $ifo{'max_dat_size'} * 1024) {
		close(IFO);
		close(IDX);
		close(LOG);
		return(0);
	}
	my $length = length($$last);
	my $er = 0;
	if($max == $ifo{'max_res'} || $fpt + $length >= ($ifo{'max_dat_size'} * 1024)) {	#datファイルサイズ上限を超える
		$er = 1;
		$line = $$last;
		$sgn = -1;
	}
	$fpt = pack("l",$fpt);
	seek(IDX,0,2);
	print IDX $fpt;
	print LOG $line;
	print IFO $ifline;
	$max++;
	if ($max >= $ifo{'max_res'} && $er !=1) {
		$max++;
		$sgn = -1;
		$fpt = tell(LOG);
		$fpt = pack("l",$fpt);
		print IDX $fpt;
		print LOG $last;
		print IFO "END|_|END|_|END|_|END|_|END|_|END\n";
	}
	$max *= $sgn;
	seek(IDX,0,0);
	$fpt = pack("l",$max);
	print IDX $fpt;
	close(IDX);
	close(IFO);
	sbj_rewrite($key,$mail,abs($max));
	$er = ($er ? 0 : 1);
	return ($er);
}

sub sbj_rewrite {
	my $key = shift;
	my $mail = shift;
	my $max = shift;
	my @list;
	my $line;
	open(SBJ,"+< ../$bbs/subject.txt") or return(0);
	flock(SBJ, 2);
	seek(SBJ, 0, 0);
	while(<SBJ>) {
		if (index($_,"$key.dat") == 0) {
			$line = substr($_,0,rindex($_,'('))."($max)\n";
			if ($$mail eq 'sage') {push(@list,$line);}
		} else {
			push(@list,$_);
		}
	}
	if ($$mail ne 'sage') {unshift(@list,$line);}
	seek(SBJ, 0, 0);
	print SBJ @list;
	truncate(SBJ,tell(SBJ));
	close(SBJ);
	return(0);
}
1;
use utf8;
$admcmd = '../test/admin';	#コマンドファイルのディレクトリ
$subcmd = '../test/sub';	#サブルーチンのディレクトリ
$call = 'board';

require "$subcmd/admin.pl";	#管理者用サブルーチン

$bbs = substr($url,0,rindex($url,'/'));
$bbs = substr($bbs,rindex($bbs,'/') + 1);
$page_title = "$bbs 管理者";
$mem_file = "./ifo/member.cgi"	;#メンバーファイル

get_cookie() or login();
open(CMD,"<$admcmd/list.cgi") or error_exit('コマンドファイルのオープンに失敗しました');
while (<CMD>) {
	my ($c_id,$c_name,$c_level) = split('<>',$_);
	$c_id =~ s/\s//g;
	Encode::from_to($c_name,'utf-8',$ifo{'outchr'});
	if ($c_id eq 'thread_move') {next;}
	if ($c_id eq 'member_board' && ($member{'level'} & 4) == 0) {$c_name = enc_str('パスワード変更');}
	if ($member{level} < 4 && $c_id eq 'line') {last;}
	if ($member{level} & $c_level && (index($c_id,'kako') < 0 || $type)) {
	if ($c_id eq 'line') {last;}
		push(@menu_id,$c_id);
		$cmd_name{$c_id} = $c_name;
		$cmd_level{$c_id} = $c_level;
	}
}
close(CMD);
if ($cmd_level{$cmd} eq '') {
	show_menu();
} else {
	require "$admcmd/$cmd.pl";
	footer();
}

sub echo {
    my @text = @_;
    foreach my $echo ( @text ) {
        print enc_str($echo);
    }
}

sub show_menu {
	header('メニュー '.dec_str($member{'name'}));
	print "<td valign='top'>\n";
	print "<input type='hidden' name='bbs' value='$bbs'>\n";
	if ($type) {
		print "<select name='type' size='1' style='width:100%'>\n";
		print "<option value='board'";
		if ($type eq 'board') {print ' selected';}
		echo ">投稿用ボード</option>\n";
		print "<option value='kako'";
		if ($type eq 'kako') {print ' selected';}
		echo ">過去ログ倉庫</option>\n</select><br>\n";
	}
	my @cmd;
	foreach $id(@menu_id) {
		push(@cmd,$id);
	}
	$cnt = @cmd;
	if ($cnt > 14) {$cnt = 14;}
	while ($cnt > 0) {
		my $data = shift(@cmd);
		my $check = ($data eq 'no_work' ? ' checked' : '');
		print "<input type=\"radio\" name=\"cmd\" value=\"$data\"$check>$cmd_name{$data}<br>\n";
		$cnt--;
	}
	$cnt = @cmd;
	if ($cnt) {
		echo '</td><td valign="top">';
		foreach $id(@cmd) {
			print "<input type=\"radio\" name=\"cmd\" value=\"$id\">$cmd_name{$id}<br>\n";
		}
	}
	echo '</td></tr><tr><td  colspan="3" align="center"><input type="submit" name="submit" value="実行"><br>',"\n";
	print '</td></tr>';
	print "</center>\n";
	print "</form>\n";
	print "</body></html>\n";
	exit(0);
}

sub get_cookie {
	my $id_num = $cgi->cookie('id');
	my $password = $cgi->cookie('pw');
	my $flg = 0;
	open(MEM,"<$mem_file") or login();
	flock(MEM,1);
	while(<MEM>) {
		$_ = trim($_);
		my ($nm,$id,$pw,$lv,$cap,$tid,$ct) = split(/<>/,$_);
		if ($id eq $id_num && $password eq $pw) {
			$member{'id_num'} = $id;
			$member{'name'} = $nm;
			$member{'level'} = $lv + 8;
			$member{'cap'} = $cap;
			$member{'id'} = $tid;
			$member{'pass'} = $pw;
			$flg = 1;
		}
	}
	close(MEM);
	return ($flg);
}

1;
use utf8;
$admcmd = './admin';		#コマンドファイルのディレクトリ
$subcmd = './sub';		#サブルーチンのディレクトリ
$call = 'master';
$page_title = 'マスター管理';
$mem_file = '../ifo/master.cgi';#メンバーファイル

require "$subcmd/admin.pl";	#管理者用サブルーチン

if (category_count() == 0) {$category = 0;}
if ($category eq '') {$category = $category_all;}

get_cookie() or login();
open(CMD,"<$admcmd/list.cgi") or error_exit('コマンドファイルのオープンに失敗しました');
while (<CMD>) {
	my ($c_id,$c_name,$c_level) = split('<>',$_);
	$c_id =~ s/\s//g;
	Encode::from_to($c_name,'utf-8',$ifo{'outchr'});
	if ($c_id eq 'member_board' && ($member{'level'} & 4) == 0) {$c_name = enc_str('パスワード変更');}
	if ($member{level} < 4 && $c_id eq 'line') {last;}
	if ($member{level} & $c_level && (index($c_id,'kako') < 0 || $type)) {
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
	echo '<td valign="top" width="150"><select name="bbs" size="',($type ? 18 : 19),'" style="width:100%">',"\n";
	my @list = board_list();
	if ($bbs ne '') {
		my $flg = 1;
		foreach $data(@list) {
			my ($dir) = split(/<>/,$data);
			if ($bbs eq $dir) {
				$flg = 0;
				last;
			}
		}
		if ($flg) {$bbs = '';}
	}
	foreach $data(@list) {
		my ($dir,$label) = split(/<>/,$data);
		my $check = '';
		if ($dir eq '') {
			$dir = '-';
			$label = "$label";
			$check = ' disabled';
		} else {
			if ($bbs eq '') {$bbs = $dir;}
			$label = "$dir:$label";
		}
		$check = ($bbs eq $dir ? ' selected' : $check);
		print "<option value='$dir'$check>$label</option>\n";
	}
	print "</select><br>\n";
	if ($type) {
		print "<select name='type' size='1' style='width:100%'>\n";
		print "<option value='board'";
		if ($type eq 'board') {print ' selected';}
		echo ">投稿用ボード</option>\n";
		print "<option value='kako'";
		if ($type eq 'kako') {print ' selected';}
		echo ">過去ログ倉庫</option>\n</select><br>\n";
	}
	if ($category) {
		my $text = "$category_all\n$category_non\n";
		@list = read_tbl('../ifo/category.cgi');
		foreach $data(@list) {
			if (index($data,'http') >= 0) {next;}
			$text .= $data;
		}
		@list = split(/\n/,trim($text));
		print "<select name='category' size='1' style='width:100%'>\n";
		foreach $data(@list) {
			print "<option value='$data'";
			if ($data eq $category) {print ' selected';}
			print ">$data</option>\n";
		}
		print "</select>\n";
	}
	print "</td><td valign='top'>\n";
	my @cmd;
	my @adm;
	my $flg = 1;
	foreach $id(@menu_id) {
		if ($id eq 'line') {
			$flg = 0;
			next;
		}
		if ($flg) {
			push(@cmd,$id);
		} else {
			push(@adm,$id);
		}
	}
	$cnt = @cmd;
	if ($cnt > 15) {$cnt = 15;}
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
	$cnt = @adm;
	if ($cnt) {
		$cnt = int($cnt / 3 + 0.7);
		print "</td></tr><tr><td valign='top'>\n";
		my $num = 1;
		foreach $id(@adm) {
			if ($num > $cnt) {
				print "</td><td valign='top'>\n";
				$num = 1;
			}
			print "<input type=\"radio\" name=\"cmd\" value=\"$id\">$cmd_name{$id}<br>\n";
			$num++;
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
		my ($nm,$id,$pw,$lv,$cap,$tid) = split(/<>/,$_);
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

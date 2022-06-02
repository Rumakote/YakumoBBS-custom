#!/usr/bin/perl --

use utf8;
$admcmd = './admin';		#コマンドファイルのディレクトリ
$subcmd = './sub';		#サブルーチンのディレクトリ
$call = 'owner';
$page_title = 'オーナー管理';
$mem_file = '../ifo/owner.cgi';	#メンバーファイル

require "$subcmd/admin.pl";	#管理者用サブルーチン

if (category_count() == 0) {$category = 0;}
if ($category eq '') {$category = $category_all;}

get_cookie() or login();
open(CMD,"<$admcmd/list.cgi") or error_exit('コマンドファイルのオープンに失敗しました');
while (<CMD>) {
	my ($c_id,$c_name,$c_level) = split('<>',$_);
	$c_id =~ s/\s//g;
	Encode::from_to($c_name,'utf-8',$ifo{'outchr'});
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
	echo '<td valign="top" width="150"><select name="bbs" size="',($type ? 17 : 18),'" style="width:100%">',"\n";
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
	$cnt = 14;
	while ($cnt > 0) {
		my $data = shift(@cmd);
		my $check = ($data eq 'no_work' ? ' checked' : '');
		print "<input type=\"radio\" name=\"cmd\" value=\"$data\"$check>$cmd_name{$data}<br>\n";
		$cnt--;
	}
	echo '</td><td valign="top">';
	foreach $id(@cmd) {
		print "<input type=\"radio\" name=\"cmd\" value=\"$id\">$cmd_name{$id}<br>\n";
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

sub make_admin {
	my $name = trim($cgi->param('name'));
	my $admin = trim($cgi->param('admin'));
	my $cap = trim($cgi->param('cap'));
	my $id = trim($cgi->param('id'));
	my $pass1 = val_sjis(trim($cgi->param('pass1')));
	my $pass2 = val_sjis(trim($cgi->param('pass2')));
	my $submit = $cgi->param('submit');
	my $er = 'true';
	if (trim($cgi->param('make_admin')) eq 'true') {
		$er = '';
		if ($name eq '') {$er = '名前は１文字以上入力して下さい<br>';}
		if ($name =~ /[<>]/) {$er .= '不等号は名前に使えません<br>';}
		if ($admin =~ /[^\x21-\x7E]/) {$er .= '全角文字はログインIDに使えません<br>';}
		if ($admin =~ /[<>]/) {$er .= '不等号はログインIDに使えません<br>';}
		if (length($admin) < 4) {$er .= 'ログインIDは４文字以上にして下さい<br>';}
		if ($cap =~ /[<>]/) {$er .="半角不等号はキャップに使えません<br>";}
		if ($cap eq '') {$er .= "キャップは１文字以上設定して下さい<br>";}
		if ($id =~ /[^\x21-\x7E]/) {$er .= '全角文字は表示IDに使えません<br>';}
		if ($id eq '') {$er .= '表示IDは１文字以上に設定して下さい<br>';}
		if ($id =~ /[<>]/) {$er .= '不等号は表示IDに使えません<br>';}
		if (length($pass1) < 4) {$er .= 'パスワードは４文字以上にして下さい<br>';}
		if ($pass1 ne $pass2) {$er .= 'パスワードの確認が間違っています<br>';}
	}
	if ($er eq '' ) {
		$pass2 = substr(crypt($pass1, $salt),2);
		my $text = "$name<>$admin<>$pass2<>31<>$cap<>$id<>\n";
		unless (write_file($mem_file,\$text,1)) {error_exit('管理者ファイルが作成できません');}
		set_cookie($admin,$pass2);
	} else {
		header('最高管理者登録');
		if ($er ne 'true') {echo '<td><font color="#FF0000">',$er,"</font></td></tr><tr>\n";}
		echo '<td><center>';
		echo '管理者名（全角半角）<br>';
		print '<input type="text" name="name" size="25" maxlength="20" value="',$name,"\"><hr>\n";
		echo 'ログインID（半角文字）<br>';
		print '<input type="text" name="admin" size="25" maxlength="20" value="',$admin,"\"><hr>\n";
		echo 'キャップ名称（半角全角）<br>';
		print '<input type="text" name="cap" size="25" maxlength="20" value="',$cap,"\"><hr>\n";
		echo '表示ID（半角文字）<br>';
		print '<input type="text" name="id" size="25" maxlength="20" value="',$id,"\"><hr>\n";
		echo "パスワード<BR>\n";
		echo '<input type="password" name="pass1" size="8" maxlength="8"><br>',"\n";
		echo "確認の為もう一度<BR>\n";
		echo '<input type="password" name="pass2" size="8" maxlength="8"><br>',"\n";
		echo '</td></tr><tr align="center"><td>';
		echo '<input type="submit" name="submit" value="登録する">',"\n";
		print "<input type='hidden' name='make_admin' value='true'>\n";
		footer();
	}
}

sub get_cookie {
	my $id_num = $cgi->cookie('id');
	my $password = $cgi->cookie('pw');
	my $flg = 0;
	open(MEM,"<$mem_file") or make_admin();
	flock(MEM,1);
	while(<MEM>) {
		$_ = trim($_);
		my ($nm,$id,$pw,$lv,$cap,$tid) = split(/<>/,$_);
		if ($id eq $id_num && $password eq $pw) {
			$member{'id_num'} = $id;
			$member{'name'} = $nm;
			$member{'level'} = $lv + 0;
			$member{'cap'} = $cap;
			$member{'id'} = $tid;
			$member{'pass'} = $pw;
			$flg = 1;
		}
	}
	close(MEM);
	return ($flg);
}

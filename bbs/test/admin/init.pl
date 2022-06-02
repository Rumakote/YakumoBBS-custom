use utf8;
use File::Path;

$opt = $cgi->param('opt');
my $submit = $cgi->param('submit');
$cmd_str = '<input type="hidden" name="cmd" value="init">'."\n";

if ($opt eq 'modoru') {
	init_select();
	footer();
} elsif ($opt eq 'last_exe') {
	require "$admcmd/z_last_txt.pl";
	last_exe($submit);
} elsif ($opt eq 'last_edit') {
	require "$admcmd/z_last_txt.pl";
	last_edit($submit);
} elsif ($opt eq 'set_code') {
	set_code($submit);
} elsif ($opt eq 'exe_server') {
	require "$admcmd/z_htaccess.pl";
	exe_server($submit);
} elsif ($opt eq 'del_kako') {
	del_kako($submit);
} elsif ($opt eq 'set_server') {
	set_server($submit);
} elsif ($opt eq 'exe_code') {
	exe_code($submit);
} elsif ($opt eq 'set_perm') {
	set_perm($submit);
} elsif ($opt eq 'exe_perm') {
	require "$admcmd/z_permission.pl";
	exe_perm($submit);
} elsif ($opt eq 'init_script') {
	require "$admcmd/z_permission.pl";
	init_script($submit);
} elsif ($opt eq 'rule_ed') {
	require "$admcmd/z_rule.pl";
	rule_ed($submit);
} elsif ($opt eq 'rule_exe') {
	require "$admcmd/z_rule.pl";
	rule_exe($submit);
} elsif ($opt eq 'banner_ed') {
	require "$admcmd/z_banner.pl";
	banner_ed($submit);
} elsif ($opt eq 'banner_exe') {
	require "$admcmd/z_banner.pl";
	banner_exe($submit);
} elsif ($opt eq 'setting_edit') {
	require "$admcmd/z_setting.pl";
	setting_ed($submit);
} elsif ($opt eq 'setting_exe') {
	require "$admcmd/z_setting.pl";
	setting_exe($submit);
} elsif ($opt eq 'cushion_ed') {
	require "$admcmd/z_banner.pl";
	cushion_ed($submit);
} elsif ($opt eq 'cushion_exe') {
	require "$admcmd/z_banner.pl";
	cushion_exe($submit);
} elsif ($opt eq 'cookie_edit') {
	cookie_edit($submit);
} elsif ($opt eq 'cookie_exe') {
	cookie_exe($submit);
	#headタグ追加・編集
} elsif ($opt eq 'header_edit') {
	require "$admcmd/z_header_edit.pl";
	header_edit($submit);
} elsif ($opt eq 'header_edit_exe') {
	require "$admcmd/z_header_edit.pl";
	header_edit_exe($submit);
} else {
	init_select($submit);
}

sub init_select {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header ('初期設定');
	print "<td>";
	print "<input type='radio' name='opt' value='set_perm'>\n";
	echo "パーミッション設定<br>\n";
	print "<input type='radio' name='opt' value='init_script'>\n";
	echo "スクリプト初期化<br>\n";
	if (trim(read_file('../ifo/board.cgi')) eq '') {
		print "<input type='radio' name='opt' value='set_code'>\n";
		echo "文字コード設定<br>\n";
	}
	print "<input type='radio' name='opt' value='set_server'>\n";
	echo "掲示板設定<br>\n";
	print "<input type='radio' name='opt' value='cookie_edit'>\n";
	echo "クッキー設定<br>\n";
	print "<input type='radio' name='opt' value='setting_edit'>\n";
	echo "ボード初期設定<br>\n";
	print "<input type='radio' name='opt' value='rule_ed'>\n";
	echo "ローカルルール初期設定<br>\n";
	print "<input type='radio' name='opt' value='last_edit'>\n";
	echo "終了レス初期設定<br>\n";
	print "<input type='radio' name='opt' value='banner_ed'>\n";
	echo "バナー初期設定<br>\n";
	print "<input type='radio' name='opt' value='cushion_ed'>\n";
	echo "リンククッション編集<br>\n";
	#headタグ追加・編集
	print "<input type='radio' name='opt' value='header_edit'>\n";
	echo "HEAD内初期設定<br>\n";
	print $cmd_str;
	submit_select();
}

sub last_edit {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("終了レス初期設定");
	show_last_txt('../ifo/last.txt');
	print $cmd_str;
	print "<input type='hidden' name='opt' value='last_exe'>\n";
}

sub last_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		init_select();
		footer();
	}
	header("終了レス更新");
	print '<td>';
	write_last_txt('../ifo/last.txt');
	print "<input type='hidden' name='opt' value='modoru'>\n";
	print $cmd_str;
	submit_ret();
}

sub set_server {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("掲示板設定");
	echo "<td>掲示板トップのアドレス</td><td><input type='text' name='site_top' value='$ifo{'site_top'}' size='60'><br></td></tr>\n";
	echo "<tr><td>投稿後の移動先</td><td>\n";
	my $check = ($ifo{'next'} ? ' checked' : '');
	echo "<input type='radio' name='next' value='1'$check>ボードトップ\n";
	$check = ($ifo{'next'} ? '' : ' checked');
	echo "<input type='radio' name='next' value='0'$check>投稿スレッド\n";
	echo "<tr><td>スレッドのレス数上限</td><td><input type='text' name='max_res' value='$ifo{'max_res'}' size='10'><br></td></tr>\n";
	echo "<tr><td>スレッドサイズの上限</td><td><input type='text' name='max_dat' value='$ifo{'max_dat_size'}' size='10'> KB<br></td></tr>\n";
	echo "<tr><td>ボードのスレッド数上限</td><td><input type='text' name='max_thread' value='$ifo{'max_thread'}' size='10'> 0以下で無制限<br></td></tr>\n";
	echo "<tr><td>ボードのスレッド数下限</td><td><input type='text' name='min_thread' value='$ifo{'min_thread'}' size='10'><br></td></tr>\n";
	echo "<tr><td>スレッド落ち条件</td><td><input type='text' name='down_res' value='$ifo{'down_res'}' size='5'> レス以上 ";
	echo "<input type='text' name='down_time' value='$ifo{'down_time'}' size='3'> 時間以内無投稿<br></td></tr>\n";
	echo "<tr><td>ボードのスレッド圧縮</td><td>\n";
	$check = ($ifo{'comp'} == 0 ? ' checked' : '');
	echo "<input type='radio' name='comp' value='0'$check>cronのみ\n";
	$check = ($ifo{'comp'} == 1 ? ' checked': '' );
	echo "<input type='radio' name='comp' value='1'$check>投稿時\n";
	echo "<tr><td>cron１回の圧縮ボード数</td><td><input type='text' name='comp_count' value='$ifo{'comp_count'}'size='10'> 個<br></td></tr>\n";
	echo "<tr><td>過去ログ倉庫スレッド数上限</td><td><input type='text' name='max_kako' value='$ifo{'max_kako'}'size='10'> 0で倉庫無し -1で無制限<br></td></tr>\n";
	echo "<tr><td>背景や板タイトルの画像パス</td><td><input type='text' name='images' value='$ifo{'images'}' size='60'><br></td></tr>\n";
	echo "<tr><td>掲示板一覧の有無</td><td> \n";
	$check = ($ifo{'bbslist'} ? '' : ' checked');
	echo "<input type='radio' name='bbslist' value='0'$check>無し\n";
	$check = ($ifo{'bbslist'} ? ' checked' : '');
	echo "<input type='radio' name='bbslist' value='1'$check>有り\n";
	echo "<tr><td>urlリンクにクッションページ</td><td>\n";
	$check = ($ifo{'jump'} ? '' : ' checked');
	echo "<input type='radio' name='jump' value='0'$check>無し\n";
	$check = ($ifo{'jump'} ? ' checked' : '');
	echo "<input type='radio' name='jump' value='1'$check>有り\n";
	echo "<tr><td>ID生成等に使う文字列</td><td><input type='text' name='twenty' value='$ifo{'twenty'}' size='40'> 英数で20桁以上<br></td></tr>\n";
	echo "<tr><td>時間補正</td><td><input type='text' name='time' value='$ifo{'time'}' size='10'> 秒<br></td></tr>\n";
	echo "<tr><td>秒の小数点以下桁数</td><td><input type='text' name='sec' value='$ifo{'sec'}' size='10'> 0から6<br></td></tr>\n";
	echo "<tr><td>画像処理モジュール</td><td>\n";
	$check = ($ifo{'img_lib'} == 0 ? ' checked' : '');
	echo "<input type='radio' name='img_lib' value='0'$check>使わない\n";
	$check = ($ifo{'img_lib'} == 1 ? ' checked' : '');
	print "<input type='radio' name='img_lib' value='1'$check>Image::Magick\n";
	$check = ($ifo{'img_lib'} == 2 ? ' checked' : '');
	print "<input type='radio' name='img_lib' value='2'$check>GD::Image\n";
	echo "<tr><td>文字+画像の投稿サイズ上限</td><td><input type='text' name='post_max' value='$ifo{'post_max'}'> Byte<br></td></tr>\n";
	echo "<tr><td>アスキーアートビューアー</td><td>\n";
	$check = ($ifo{'aa_mode'} == 0 ? ' checked' : '');
	echo "<input type='radio' name='aa_mode' value='0'$check>無し\n";
	$check = ($ifo{'aa_mode'} eq 'AA'  ? ' checked' : '');
	print "<input type='radio' name='aa_mode' value='AA'$check>AA\n";
	$check = ($ifo{'aa_mode'} eq 'AAS'  ? ' checked' : '');
	print "<input type='radio' name='aa_mode' value='AAS'$check>AAS\n</td></tr>\n";
	echo "<tr><td>AAモードで自動判定</td><td>\n";
	$check = ($ifo{'aa_auto'} ? ' checked' : '');
	echo "<input type='radio' name='aa_auto' value='1'$check>する\n";
	$check = ($ifo{'aa_auto'} ? '' : ' checked');
	echo "<input type='radio' name='aa_auto' value='0'$check>しない\n";
	print "</td></tr>\n";
	echo "<tr><td>AA用フォントファイルパス</td><td><input type='text' name='fontfile' value='$ifo{'fontfile'}' size='60'><br></td></tr>\n";
	echo "<tr><td>リファラ規制</td><td>\n";
	$check = ($ifo{'referer'} ? ' checked' : '');
	echo "<input type='radio' name='referer' value='1'$check>する\n";
	$check = ($ifo{'referer'} ? '' : ' checked');
	echo "<input type='radio' name='referer' value='0'$check>しない\n";
	echo "</td></tr><tr><td>エラーログの記録</td><td>\n";
	$check = ($ifo{'err_log'} ? ' checked' : '');
	echo "<input type='radio' name='err_log' value='1'$check>する\n";
	$check = ($ifo{'err_log'} ? '' : ' checked');
	echo "<input type='radio' name='err_log' value='0'$check>しない\n";	
	echo "</td></tr><tr><td bgcolor='#eeeeee'>.htaccessの利用</td><td>\n";
	$check = ($ifo{'ht_use'} ? ' checked' : '');
	echo "<input type='radio' name='ht_use' value='1'$check>する\n";
	$check = ($ifo{'ht_use'} ? '' : ' checked');
	echo "<input type='radio' name='ht_use' value='0'$check>しない\n";
	echo "</td></tr><tr><td bgcolor='#eeeeee'>自動アクセス制限</td><td>";
	$check = ($ifo{'ht_mode'} & 1 ? ' checked' : '');
	echo "<input type='checkbox' name='ht_mode' value='1'$check>投稿ボタン文字送信不備<br>";
	$check = ($ifo{'ht_mode'} & 2 ? ' checked' : '');
	echo "<input type='checkbox' name='ht_mode' value='2'$check>スレッド番号スレッドタイトル送信不備<br>";
	$check = ($ifo{'ht_mode'} & 4 ? ' checked' : '');
	echo "<input type='checkbox' name='ht_mode' value='4'$check>IPからリモートホストが取得できない<br>";
	$check = ($ifo{'ht_mode'} & 8 ? ' checked' : '');
	echo "<input type='checkbox' name='ht_mode' value='8'$check>リモートホストからIPが取得できない<br>";
	$check = ($ifo{'ht_mode'} & 16 ? ' checked' : '');
	echo "<input type='checkbox' name='ht_mode' value='16'$check>プロキシ特有の環境変数が有るサーバー<br>";
	$check = ($ifo{'ht_mode'} & 32 ? ' checked' : '');
	echo "<input type='checkbox' name='ht_mode' value='32'$check>サーバーを経由するブラウザ<br>";
	$check = ($ifo{'ht_mode'} & 64 ? ' checked' : '');
	echo "<input type='checkbox' name='ht_mode' value='64'$check>外部サイトを利用した規制<br>";
	$check = ($ifo{'ht_mode'} & 128 ? ' checked' : '');
	echo "<input type='checkbox' name='ht_mode' value='128'$check>リファラ規制<br>";
	$check = ($ifo{'ht_mode'} & 256 ? ' checked' : '');
	echo "<input type='checkbox' name='ht_mode' value='256'$check>リモートホスト規制<br>";
	$check = ($ifo{'ht_mode'} & 512 ? ' checked' : '');
	echo "<input type='checkbox' name='ht_mode' value='512'$check>IPアドレス規制<br>";
	my @list = read_tbl('../ifo/htaccess.cgi');
	echo "</td></tr><tr><td bgcolor='#eeeeee'>利用しないドメイン</td><td>\n";
	$check = trim(shift(@list));
	print "<input type='text' name='rewrite_nouse' size='60' value='$check'><br></td></tr>\n";
	echo "</td></tr><tr><td bgcolor='#eeeeee'>リダイレクトディレクトリ</td><td>\n";
	$check = trim(shift(@list));
	print "<input type='text' name='rewrite_dir' size='60' value='$check'><br></td></tr>\n";
	echo "</td></tr><tr><td bgcolor='#eeeeee'>統一URL</td><td>\n";
	$check = trim(shift(@list));
	print "<input type='text' name='rewrite_url' size='60' value='$check'><br></td></tr>\n";
	$check = trim(join('',@list));
	if ($check eq '') {$check = "Options -Indexes\norder deny,allow";}
	$check .= "\n";
	echo "</td></tr><tr><td bgcolor='#eeeeee'>その他.htaccess設定</td><td>\n";
	print "<textarea name='ht_text' cols=42 rows=5>$check";
	print "</textarea>";
	print "<input type='hidden' name='old_kako' value='$ifo{'max_kako'}'>\n";
	print "<input type='hidden' name='opt' value='exe_server'>\n";
	print $cmd_str;
	submit_exe();
}

sub exe_server {
	my $submit = shift;
	if ($submit eq $modoru) {
		init_select();
		footer();
	}
	header("掲示板設定更新");
	print "<td>\n";
	$ifo{'site_top'} = $cgi->param('site_top');
	my $tmp = $cgi->param('max_res');
	if ($tmp =~ /[^0-9]/) {
		echo "レス数上限に数字以外が設定されています<br>\n";
	} elsif ($tmp < 5) {
		echo "レス数上限は５以上に設定して下さい<br>\n";
	} else {
		$ifo{'max_res'} = $tmp;
	}
	$tmp = $cgi->param('max_dat');
	if ($tmp =~ /[^0-9]/) {
		echo "スレッドサイズ上限に数字以外が設定されています<br>\n";
	} elsif ($tmp < 10) {
		echo "スレッドサイズ上限上限は10KB以上に設定して下さい<br>\n";
	} elsif ($tmp > 2097142) {
		echo "スレッドサイズ上限は2097142KB(2GB弱)以下にして下さい<br>\n";
	} else {
		$ifo{'max_dat_size'} = $tmp;
	}
	$tmp = $cgi->param('max_thread');
	if ($tmp =~ /[^0-9-]/) {
		echo "スレッド数上限に数字以外が設定されています<br>\n";
	} else {
		$ifo{'max_thread'} = $tmp;
 	}
	$tmp = $cgi->param('min_thread');
	if ($tmp =~ /[^0-9]/) {
		echo "スレッド数下限に数字以外が設定されています<br>\n";
	} else {
		$ifo{'min_thread'} = $tmp;
	}
	if ($ifo{'min_thread'} > $ifo{'max_thread'}) {$ifo{'min_thread'} = $ifo{'max_thread'};}
	unless($ifo{'min_thread'}) {$ifo{'min_thread'} = $ifo{'max_thread'};}
	$tmp = $cgi->param('down_res');
	if ($tmp =~ /[^0-9]/) {
		echo "スレッド落ちレス数に数字以外が設定されています<br>\n";
	} else {
		$ifo{'down_res'} = $tmp;
	}
	if ($ifo{'down_res'} > $ifo{'max_res'}) {$ifo{'down_res'} = $ifo{'max_res'};}
	unless($ifo{'down_res'}) {$ifo{'down_res'} = $ifo{'max_res'};}
	$tmp = $cgi->param('down_time');
	if ($tmp =~ /[^0-9]/) {
		echo "スレッド落ち時間に数字以外が設定されています<br>\n";
	} else {
		$ifo{'down_time'} = $tmp;
	}
	unless($ifo{'down_time'}) {$ifo{'down_time'} = 0;}
	$ifo{'comp'} = $cgi->param('comp');
	$tmp = $cgi->param('comp_count');
	if ($tmp =~ /[^0-9]/) {
		echo "スレッド圧縮ボード数に数字以外が設定されています<br>\n";
	} else {
		$ifo{'comp_count'} = $tmp;
	}
	unless($ifo{'comp_count'}) {$ifo{'comp_count'} = 1;}
	my $kako = 0;
	$tmp = $cgi->param('max_kako');
	my $old_kako = $cgi->param('old_kako');
	if ($tmp =~ /[^0-9-]/) {
		echo "過去ログ数上限に数字以外が設定されています<br>\n";
	} elsif ($tmp == 0 && $old_kako != 0 && count_board()) {
		$kako = 1;		#過去ログ倉庫削除
	} elsif ($old_kako == 0 && $tmp != 0) {
		$ifo{'max_kako'} = $tmp;
		make_kako();		#過去ログ倉庫作成
	} else {
		$ifo{'max_kako'} = $tmp;
	}
	$ifo{'images'} = $cgi->param('images');
	$ifo{'bbslist'} = $cgi->param('bbslist');
	$ifo{'jump'} = $cgi->param('jump');
	$ifo{'next'} = $cgi->param('next');
	$ifo{'referer'} = $cgi->param('referer');
	$ifo{'err_log'} = $cgi->param('err_log');
	$tmp = $cgi->param('twenty');
	my $double = check_double($tmp);
	if ($double) {echo "ID生成等に使う文字列で" . $double . "が重複しています(非推奨)<br>\n";}
	if ($tmp =~ /[^A-Za-z0-9]/) {
		echo "ID生成等に使う文字列には半角英数以外は使えません<br>\n";
	} elsif (length($tmp) < 20) {
		echo "ID生成等に使う文字列は20桁以上設定して下さい<br>\n";
	} else {
		$ifo{'twenty'} = $tmp;
	}
	$tmp = $cgi->param('time');
	if ($tmp =~ /^-?[0-9]+/) {
		$ifo{'time'} = $tmp;
	} else {
		echo "時間補正に設定出来ない文字が含まれています<br>\n";
	}
	$tmp = $cgi->param('sec');
	if ($tmp =~ /^[0-6]/ && $tmp <= 6) {
		$ifo{'sec'} = $tmp;
	} else {
		echo "小数点以下桁数が設定できません<br>\n";
	}
	$ifo{'img_lib'} = $cgi->param('img_lib');
	$ifo{'post_max'} = $cgi->param('post_max');
	$ifo{'aa_mode'} = $cgi->param('aa_mode');
	$ifo{'aa_auto'} = $cgi->param('aa_auto');
	$ifo{'fontfile'} = $cgi->param('fontfile');
	$ifo{'ht_use'} = $cgi->param('ht_use');
	my @list = $cgi->param('ht_mode');
	$ifo{'ht_mode'} = 0;
	foreach $tmp (@list) {$ifo{'ht_mode'} += $tmp;}
	@list = ();
	$tmp = $cgi->param('rewrite_nouse') . "\n";
	$tmp .= $cgi->param('rewrite_dir') . "\n";
	$tmp .= $cgi->param('rewrite_url') . "\n";
	$tmp .= trim($cgi->param('ht_text')) . "\n";
	if (write_file('../ifo/htaccess.cgi',\$tmp,1) && $ifo{'ht_use'}) {write_htaccess();}
	if (write_ifo()) {
		echo "設定を変更しました";
	} else {
		echo "設定の変更に失敗しました";
	}
	if ($kako) {
		echo "</td></tr><tr><td>過去ログ倉庫が無しに変更されました<br>\n";
		echo "過去ログ倉庫を削除しますか？<br>\n";
		submit_exe();
		print "<input type='hidden' name='opt' value='del_kako'>\n";
	} else {
		submit_ret();
		print "<input type='hidden' name='opt' value='modoru'>\n";
	}
	print $cmd_str;
}

sub make_kako {
	my @list = read_tbl('../ifo/board.cgi');
	foreach $data(@list) {
		my ($kako) = split('<>',$data);
		my %set =get_setting_txt($kako);
		$kako .= '_kako';
		mkdir "../$kako" or echo "$kako ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$kako/dat" or echo "$kako/dat ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$kako/idx" or echo "$bbs/idx ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$kako/img" or echo "$kako/img ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$kako/smn" or echo "$kako/smn ディレクトリの作成に失敗しました<br>\n";
		mkdir "../$kako/ifo" or echo "$kako/ifo ディレクトリの作成に失敗しました<br>\n";
		if ($ifo{perm_dir}) {chmod(oct($ifo{'perm_dir'}) , "../$kako/ifo") or echo "$kako/$ifo のパーミッションの設定に失敗しました<br>\n";}
		unless (-e "../$kako/subject.txt") {
			open(FN,">../$kako/subject.txt");
			close(FN);
		}
		open(FN,">../$kako/index.html");
		print FN "<html>\n<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=$ifo{'outchr'}\">\n";
		print FN "<title>".$set{'TITLE'}.enc_str(" 過去ログ倉庫")."</title></head><body>\n";
		print FN $set{'TITLE'}.enc_str("の過去ログ倉庫は");
		print FN "<a href=\"../test/kako.cgi/$bbs/\">".enc_str("こちら")."</a>".enc_str("です\n");
		print FN "</body>\n</html>\n";
		close(FN);
	}
	echo "過去ログ倉庫を作成しました<br>\n";
}

sub del_kako {
	my $submit = shift;
	if ($submit eq $modoru) {
		init_select();
		footer();
	}
	$ifo{'max_kako'} = 0;
	write_ifo();
	header("過去ログ倉庫削除");
	my @list = read_tbl('../ifo/board.cgi');
	foreach $data(@list) {
		my ($kako) = split('<>',$data);
		$kako .= '_kako';
		rmtree("../$kako") or echo "$kakoの削除に失敗しました<br>\n";
	}
	echo "<td>過去ログ倉庫を削除しました";
	submit_ret();
	print $cmd_str;
	print "<input type='hidden' name='opt' value='modoru'>\n";
}

sub count_board {
	my @list = read_tbl('../ifo/board.cgi');
	my $cnt = @list;
	return($cnt);
}

sub set_code {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("文字コード設定");
	print "<input type='hidden' name='old' value='$ifo{'outchr'}'>\n";
	print "<td><select name='code' size='1'>\n";
	my $check = ($ifo{'outchr'} eq 'shift_jis' ? " selected" : '');
	echo "<option value='shift_jis'$check>shift_jis</option>\n";
	$check = ($ifo{'outchr'} eq 'utf-8' ? " selected" : '');
	echo "<option value='utf-8'$check>utf-8</option>\n";
	$check = ($ifo{'outchr'} eq 'euc-jp' ? " selected" : '');
	echo "<option value='euc-jp'$check>euc-jp</option>\n";
	print "<input type='hidden' name='opt' value='exe_code'>\n";
	print $cmd_str;
	submit_exe();
}

sub exe_code {
	my $submit = shift;
	if ($submit eq $modoru) {
		init_select();
		footer();
	}
	header("文字コード変更");
	my $old_code = $cgi->param('old');
	my $new_code = $cgi->param('code');
	print "<td>\n";
	if ($old_code ne $new_code) {
		my @list;
		push(@list,'../ifo/owner.cgi');
		if (-e '../ifo/master.cgi') {push(@list,'../ifo/master.cgi');}
		if (-e '../ifo/member.cgi') {push(@list,'../ifo/member.cgi');}
		if (-e '../ifo/ngword.cgi') {push(@list,'../ifo/ngword.cgi');}
		foreach $file(@list) {
			my $text = read_file($file);
			Encode::from_to($text,$old_code,$new_code);
			write_file($file,\$text,1);
			echo "$file の文字コードを変換しました<br>\n";
		}
		@list = glob("../ifo/*.txt");
		if (-e '../ifo/SETTING.TXT') {
			my $flg = 1;
			foreach $data(@list) {
				if ($data eq '../ifo/SETTING.TXT') {
					$flg = 0;
					last;
				}
			}
			if ($flg) {push(@list,'../ifo/SETTING.TXT');}
		}
		foreach $file(@list) {
			my $text = read_file($file);
			Encode::from_to($text,$old_code,$new_code);
			write_file($file,\$text,0);
			echo "$file の文字コードを変換しました<br>\n";
		}
		echo "文字コードの設定を変更しました<br>\n";
		$ifo{'outchr'} = $new_code;
		write_ifo();
	} else {
		echo "文字コードの変更はしませんでした";
	}
	print "<input type='hidden' name='opt' value='modoru'>\n";
	print $cmd_str;
	submit_ret($old_code);
}

sub set_perm {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("パーミッション設定");
	echo "<td>極秘ディレクトリ</td>";
	echo "<td><select name='perm_dir' size='1'>\n";
	my $check = ($ifo{'perm_dir'} == 0 ? " selected" : '');
	echo "<option value='0'$check>サーバーデフォルト</option>\n";
	$check = ($ifo{'perm_dir'} == 700 ? " selected" : '');
	echo "<option value='700'$check>700:推奨</option >\n";
	$check = ($ifo{'perm_dir'} == 705 ? " selected" : '');
	echo "<option value='705'$check>705:妥協</option>\n";
	$check = ($ifo{'perm_dir'} == 755 ? " selected" : '');
	echo "<option value='755'$check>755:妥協</option>\n";
	$check = ($ifo{'perm_dir'} == 775 ? " selected" : '');
	echo "<option value='775'$check>775:特殊</option>\n";
	echo "</td>";
	echo "</tr><tr><td>極秘ファイル</td>";
	echo "<td><select name='perm_file' size='1'>\n";
	$check = ($ifo{'perm_file'} == 0 ? " selected" : '');
	echo "<option value='0'$check>サーバーデフォルト</option>\n";
	$check = ($ifo{'perm_file'} == 700 ? " selected" : '');
	echo "<option value='700'$check>700:完全</option>\n";
	$check = ($ifo{'perm_file'} == 705 ? " selected" : '');
	echo "<option value='705'$check>705:安全</option>\n";
	$check = ($ifo{'perm_file'} == 755 ? " selected" : '');
	echo "<option value='755'$check>755:安全</option>\n";
	$check = ($ifo{'perm_file'} == 775 ? " selected" : '');
	echo "<option value='775'$check>775:特殊</option>\n";
	echo "</td>";
	print "<input type='hidden' name='opt' value='exe_perm'>\n";
	print $cmd_str;
	submit_exe();
}

sub exe_perm {
	my $submit = shift;
	if ($submit eq $modoru) {
		init_select();
		footer();
	}
	header("パーミッション設定＆変更");
	my $perm_dir = $cgi->param('perm_dir');
	my $perm_file = $cgi->param('perm_file');
	my @dname = ('../ifo','./sub','./admin');
	my $perm;
	if ($perm_dir) {
		$perm = $perm_dir;
	} else {
		mkdir './dummy_dir';
		$perm = get_perm('./dummy_dir');
		rmdir './dummy_dir';
	}
	my $cnt = chmod(oct($perm) , @dname);
	echo "<td>$cnt 個のディレクトリを変更しました<br>\n";
	my @list = glob "../ifo/*.cgi";
	if ($perm_file) {
		$perm = $perm_file;
	} else {
		open(DM,"> ./dummy_file.cgi") or echo "失敗";
		close(DM);
		$perm = get_perm('./dummy_file.cgi');
		unlink('./dummy_file.cgi');
	}
	$cnt = chmod(oct($perm) , @list);
	@list = glob "./admin/*";
	$cnt += chmod(oct($perm) , @list);
	@list = glob "./sub/*";
	$cnt += chmod(oct($perm) , @list);
	echo "$cnt 個のファイルを変更しました<br>\n";
	$ifo{'perm_dir'} = $perm_dir;
	$ifo{'perm_file'} = $perm_file;
	write_ifo();
	echo "設定を保存しました";
	print "<input type='hidden' name='opt' value='modoru'>\n";
	print $cmd_str;
	submit_ret();
}

sub init_script {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("スクリプトの初期化");
	print "<td>\n";
	
	my @list =glob "*.cgi";
	push(@list,'../index.cgi');
	my $uri = substr($url,rindex($url,'/') + 1);
	my $set;
	my $permission = get_perm($uri);
	open (FN,"<./$uri") or error_exit("$uriが読み込めませんでした");
	$set = <FN>;
	close (FN);
	my $cnt = 0;
	my $pcnt = 0;
	foreach $file(@list) {
		next if $file eq $uri;
		my $er = 0;
		if (chmod (oct($permission) , $file)) {
			$pcnt++;
		} else {
			echo "$file のパーミッション設定失敗<br>";
		}
		if(open(FN,"+<./$file")) {
			flock(FN,2);
			my $line = <FN>;
			if (substr($line,0,2) ne '#!' || $line eq $set) {
				close (FN);
				next;
			}
			my $tmpfile = time()."tmp";
			if (open(TMP,"+>$tmpfile")) {
				flock(TMP,2);
				print TMP $set;
				while(<FN>) {
					print TMP $_;
				}
				seek(FN,0,0);
				seek(TMP,0,0);
				while(<TMP>) {
					print FN $_;
				}
				truncate(FN,tell(FN));
				close(FN);
				close(TMP);
				unlink $tmpfile;
				$cnt++;
			} else {
				close(FN);
				echo "$file の書き換えに失敗しました<br>";
			}
		} else {
			echo "$file がオープンできませんでした<br>";
		}
	}
	echo "$cnt ファイルのヘッダを書き換えました。<br>";
	echo "$pcnt ファイルのパーミッションを設定しました。";
	
	print "<input type='hidden' name='opt' value='modoru'>\n";
	print $cmd_str;
	submit_ret();
}

sub cookie_edit {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("クッキー設定");
	my ($hihumi,$server,$max_level,$res_level,$thread_level) = split('<>',trim(read_file('../ifo/enigma.cgi')));
	my $domain = $ifo{'domain'};
	my $path = $ifo{'dir'};
	my $c_name = $ifo{'c_name'};
	my $c_val = $ifo{'c_val'};
	unless ($hihumi) {$hihumi = 'BsIxGzeO4r2Zmb1wE7Lu9pSkAyiU3DcP6tFfoH0YdCgR5nvWqNjTaKQ8hlVMJX';}
	unless ($server) {$server = 1;}
	unless ($max_level) {$max_level = 40;}
	unless ($res_level) {$res_level = 15;}
	unless ($thread_level) {$thread_level = 30;}
	unless ($c_name) {$c_name = 'IZUMO';}
	unless ($c_val) {$c_val = 'TAISHA';}
	unless ($path) {
		$path = $cgi->url;
		$path =~ s/^.+?:\/\///;
		$path =~ s/(.+?)\///;
		my $tmp = $1;
		$path =~ s/\/test\/.*$//;
		$path = '/' . $path . '/';
		unless ($domain) {$domain = $tmp;}
	}
	echo "<td>暗号用文字列（半角英数20桁以上）</td><td>";
	print "<input type='text' name='hihumi' value='$hihumi' size='60'></td></tr>\n";
	echo "<tr><td>サーバー番号</td><td>";
	print "<input type='text' name='server' value='$server' size='5'></td></tr>\n";
	echo "<tr><td>クッキー記録ドメイン</td><td>";
	print "<input type='text' name='domain' value='$domain' size='30'></td></tr>\n";
	echo "<tr><td>クッキー記録ディレクトリ</td><td>";
	print "<input type='text' name='path' value='$path' size='30'></td></tr>\n";
	echo "<tr><td>確認用クッキー名（半角英字）</td><td>";
	print "<input type='text' name='c_name' value='$c_name' size='20'></td></tr>\n";
	echo "<tr><td>確認用クッキー値（半角英数）</td><td>";
	print "<input type='text' name='c_val' value='$c_val' size='20'></td></tr>\n";
	echo "<tr><td>レベルの最大値</td><td>";
	print "<input type='text' name='max_level' value='$max_level' size='3'></td></tr>\n";
	echo "<tr><td>レス削除投票権取得レベル</td><td>";
	print "<input type='text' name='res_level' value='$res_level' size='3'></td></tr>\n";
	echo "<tr><td>スレッド削除投票権取得レベル</td><td>";
	print "<input type='text' name='thread_level' value='$thread_level' size='3'></td></tr>\n";
	print "<input type='hidden' name='old_hihumi' value='$hihumi'>\n";
	print "<input type='hidden' name='opt' value='cookie_exe'>\n";
	print $cmd_str;
	submit_exe();
}

sub cookie_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		init_select();
		footer();
	}
	my $hihumi = trim($cgi->param('hihumi'));
	my $old_hihumi = trim($cgi->param('old_hihumi'));
	my $server = trim($cgi->param('server'));
	my $max_level = trim($cgi->param('max_level'));
	my $res_level = trim($cgi->param('res_level'));
	my $thread_level = trim($cgi->param('thread_level'));
	my $domain = trim($cgi->param('domain'));
	my $path = trim($cgi->param('path'));
	my $c_name = trim($cgi->param('c_name'));
	my $c_val = trim($cgi->param('c_val'));
	header('クッキー設定');
	print '<td>';
	my $double = check_double($hihumi);
	if ($hihumi =~ /[^A-Za-z0-9]/) {
		echo "暗号用文字列には半角英数以外は使えません<br>\n";
	} elsif (length($hihumi) < 20) {
		echo "暗号用文字列は20桁以上に設定して下さい<br>\n";
	} elsif ($double) {
		echo "暗号用文字列に" . $double . "が重複しています<br>\n";
	} elsif (!$server) {
		echo "サーバー番号に１以上の数値を設定して下さい<br>\n";
	} elsif ($server =~ /[^0-9]/) {
		echo "サーバー番号には半角英数以外は使えません<br>\n";
	} elsif ($server >= length($hihumi)) {
		echo "サーバー番号は暗号用文字列の桁数-1までの値にして下さい<br>\n";
	} elsif ($max_level =~ /[^0-9]/) {
		echo "レベルの最大値には半角数字以外は使えません<br>\n";
	} elsif (!$max_level) {
		echo "レベル最大値に１以上の数値を設定して下さい<br>\n";
	} elsif ($max_level >= length($hihumi)) {
		echo "レベル最大値は暗号用文字列の桁数-1までの値にして下さい<br>\n";
	} elsif ($thread_level =~ /[^0-9]/) {
		echo "スレッド削除投票権取得レベルには半角数字以外は使えません<br>\n";
	} elsif (!$thread_level) {
		echo "スレッド削除投票権取得レベルに１以上の数値を設定して下さい<br>\n";
	} elsif ($thread_level > $max_level) {
		echo "スレッド削除投票権取得レベルはレベル最大値以下にして下さい<br>\n";
	} elsif ($res_level =~ /[^0-9]/) {
		echo "レス削除投票権取得レベルには半角数字以外は使えません<br>\n";
	} elsif (!$res_level) {
		echo "レス削除投票権取得レベルに１以上の数値を設定して下さい<br>\n";
	} elsif ($res_level > $thread_level) {
		echo "レス削除投票権取得レベルはスレッド削除投票権取得レベル以下にして下さい<br>\n";
	} else {
		my $tmp = "$hihumi<>$server<>$max_level<>$res_level<>$thread_level";
		if (write_file('../ifo/enigma.cgi',\$tmp,1)) {
			echo "クッキー設定更新<br>\n";
			if ($hihumi ne $old_hihumi) {unlink '../ifo/hihumi.cgi';}
		} else {
			echo "クッキー設定更新失敗<br>\n";
		}
	}
	if ($path eq '') {
		echo "クッキー記録ディレクトリは１文字以上設定して下さい<br>\n";
	} elsif (index($path,'/') !=0) {
		echo "クッキー記録ディレクトリは/で始まる文字列を設定して下さい<br>\n";
	} elsif ($c_name =~ /[^a-zA-Z]/ || !$c_name) {
		echo "確認用クッキー名は１文字以上の英字で設定して下さい<br>\n";
	} elsif ($c_name =~ /^NAME$|^MAIL$|^HAP$|^PREN$|^PON$|^KAN$|^HIHUMI$/) {
		echo "確認用クッキー名に使えない文字列です<br>\n";
	} elsif ($c_val =~ /[^0-9a-zA-Z]/) {
		echo "確認用クッキー値は１文字以上の英数で設定して下さい<br>\n";
	} else {
		$ifo{'domain'} = $domain;
		$ifo{'dir'} = $path;
		$ifo{'c_name'} = $c_name;
		$ifo{'c_val'} = $c_val;
		if (write_ifo()) {
			echo "設定ファイル更新<br>\n";
		} else {
			echo "設定ファイル更新失敗<br>\n";
		}
		$domain = read_file('./sub/index.js');
		$domain =~ s/IZUMO=TAISHA/$c_name=$c_val/g;
		$domain =~ s/DOMAIN/$ifo{'domain'}/g;
		$domain =~ s/PATH/$ifo{'dir'}/g;
		if (write_file('./index.js',\$domain)) {
			echo "JavaScript更新<br>\n";
		} else {
			echo "JavaScript更新失敗<br>\n";
		}
	}
	print "<input type='hidden' name='opt' value='cookie_exe'>\n";
	print $cmd_str;
	submit_ret();
}

sub rule_ed {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("ローカルルール初期設定");
	show_rule('ifo');
	print $cmd_str;
	print "<input type='hidden' name='opt' value='rule_exe'>\n";
}

sub rule_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		init_select();
		footer();
	}
	header('ローカルルール書き換え');
	print "<td>\n";
	write_rule('ifo');
	print "<input type='hidden' name='opt' value='modoru'>\n";
	print $cmd_str;
	submit_ret();
}

sub banner_ed {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("バナーの初期設定");
	show_banner('ifo');
	print $cmd_str;
	print "<input type='hidden' name='opt' value='banner_exe'>\n";
}

sub banner_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		init_select();
		footer();
	}
	header('バナー書き換え');
	print "<td>\n";
	write_banner('ifo');
	print "<input type='hidden' name='opt' value='modoru'>\n";
	print $cmd_str;
	submit_ret();
}

sub cushion_ed {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("リンククッション編集");
	show_banner('ifo','cushion');
	print $cmd_str;
	print "<input type='hidden' name='opt' value='cushion_exe'>\n";
}

sub cushion_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		init_select();
		footer();
	}
	header('リンククッション更新');
	print "<td>\n";
	write_banner('ifo','cushion');
	print "<input type='hidden' name='opt' value='modoru'>\n";
	print $cmd_str;
	submit_ret();
}

sub setting_ed {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header('掲示板初期設定編集');
	show_setting('ifo');
	print $cmd_str;
	print "<input type='hidden' name='opt' value='setting_exe'>\n";
}

sub setting_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		init_select();
		footer();
	}
	header("初期設定変更");
	print "<td>\n";
	$submit = dec_str($submit);
	my %setting = init_setting();
	if ($submit eq '実行') {
		my @names = names_setting();
		foreach $name(@names) {
			$setting{$name} = $cgi->param($name);
		}
	}
	put_setting('ifo',%setting);
	print "<input type='hidden' name='opt' value='modoru'>\n";
	print $cmd_str;
	submit_ret();
}

sub header_edit {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header('HEADタグ内初期設定編集');
	show_header_edit('ifo');
	print $cmd_str;
	print "<input type='hidden' name='opt' value='header_edit_exe'>\n";
}
sub header_edit_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		init_select();
		footer();
	}
	header('HEADタグ初期設定変更');
	print "<td>\n";
	write_header_edit('ifo');
	print "<input type='hidden' name='opt' value='modoru'>\n";
	print $cmd_str;
	submit_ret();
}
1;
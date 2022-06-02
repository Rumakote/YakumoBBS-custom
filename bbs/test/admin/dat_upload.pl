use utf8;

my $opt = $cgi->param('opt');

if ($opt eq 'upform') {
	up_form();
} elsif ($opt eq 'upload') {
	require "$admcmd/z_thread.pl";
	require "$admcmd/z_upload.pl";
	if ($ifo{'img_lib'}) {
		require "$dir/test/sub/smn".$ifo{'img_lib'}.'.pl';
	} else {
		require "$dir/test/sub/smn.pl";
	}
	require "$subcmd/page.pl";
	require "$subcmd/mobile.pl";
	require "$subcmd/move.pl";
	dat_up();
} else {
	require "$admcmd/z_thread.pl";
	select_pos();
}

sub select_pos {
	if ($type eq 'kako') {
		header("過去ログ倉庫アップロード位置選択");
	} elsif($type eq 'board') {
		header("投稿ボードアップロード位置選択");
	} else {
		header("アップロード位置選択");
	}
	echo "選択したスレッドの後ろにアップします<br>\n";
	my $kako = ($type eq 'kako' ? '_kako' : '');
	out_thread(0,$bbs.$kako,"一番最初");
	submit_select();
	echo '<input type="hidden" name="cmd" value="dat_upload">',"\n";
	echo '<input type="hidden" name="opt" value="upform">',"\n";
}

sub up_form {
	if ($cgi->param('submit') eq $modoru) {
		show_menu();
	}
	my($pos,$posname) = split(/<>/,$cgi->param('dat_name'));
	if ($pos ne 'age') {$posname .= enc_str('の後');}
	my $url = get_url();
	$url = '.' . substr($url,rindex($url,'/'));
	echo "Content-type: text/html\n\n";
	echo "<html>\n";
	echo "<head>\n";
	echo '<meta http-equiv="Content-Type" content="text/html; charset=',$ifo{'outchr'},'">',"\n";
	echo "<title>$page_title</title>\n";
	echo "<body>\n";
	echo "<form action='$url' method='POST' ENCTYPE='multipart/form-data'>\n";
	echo "<center><br>\n";
	echo "<font size=+1><b>datファイルアップロード</b></font><br><br>\n";
	echo '<table border=2>';
	echo "<tr><td>\n";
	echo $bbs,'板';
	if ($type eq 'kako') {echo '過去ログ倉庫';}
	print $posname;
	echo "へアップロードします。<br><br>\n";
	echo 'ファイル選択： <input type="file" name="upload_file" size="60">',"\n";
	echo '<input type="hidden" name="cmd" value="dat_upload">',"\n";
	echo '<input type="hidden" name="opt" value="upload">',"\n";
	echo '<input type="hidden" name="pos" value="',$pos,"\">\n";
	submit_exe();
	footer();
}

sub dat_up {
	if ($cgi->param('submit') eq $modoru) {
		select_pos();
		footer();
	}
	my $board = ($type eq 'kako' ? $bbs.'_kako' : $bbs);
	$pos = $cgi->param('pos');
	header("過去ログアップロード");
	echo "<td>\n";
	my $key = up_load('dat','dat');
	$key = substr($key,rindex($key,'/') +1 );
	$key = substr($key,0,index($key,'.dat'));
	echo makeindex($board,$key,-1),"<br>\n";
	my $max = abs(get_index(1,$board,$key));
	echo dummy_ifo($board,$key,$max);
	my @del_list = up_subject($board,$key,$max,$pos);
	if ($type eq 'kako') {
		del_thread($board,@del_list);
	}
	if ($type eq 'board' || count_kako($bbs) == 1) {
		get_setting($bbs);
		get_subject();
		put_pc();
		put_subback();
		put_mobile();
	}
	submit_ret();
	footer();
}
1;

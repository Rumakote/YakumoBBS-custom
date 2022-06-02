use utf8;

my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');
$cmd_str = '<input type="hidden" name="cmd" value="pic_up">',"\n";


if ($opt eq 'exe') {
	require "$admcmd/z_upload.pl";
	up_exe($submit);
} else {
	up_form();
}

sub up_form {
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
	echo "<font size=+1><b>画像ファイルアップロード</b></font><br><br>\n";
	echo '<table border=2>';
	echo "<tr><td>\n";
	echo "背景やタイトル画像をアップロードします。<br><br>\n";
	echo 'ファイル選択： <input type="file" name="upload_file" size="60">',"\n";
	echo '<input type="hidden" name="opt" value="exe">',"\n";
	print $cmd_str;
	submit_exe();
	footer();
}

sub up_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("画像ファイルアップロード");
	echo "<td>\n";
	up_load('jpeg','jpg','gif','png','bmp');
	submit_ret();
}
1;
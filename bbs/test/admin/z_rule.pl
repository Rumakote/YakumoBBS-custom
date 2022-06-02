use utf8;
$CGI::LIST_CONTEXT_WARN = 0;

sub show_rule {
	my $bbs = shift;
	echo "<td>\n";
	echo "ローカルルールヘッダ<br>";
	my $fname = "../$bbs/head.txt";
	my $head;
	if (-e $fname) {
		$head = read_file($fname);
	} else {
		$head = enc_str("<br>\n<ul type=\"square\">\n<li>投稿内容の著作権に注意しましょう<br>\n<li>掲示板であっても世間一般のマナーは守りましょう<br>\n楽しく利用しましょうね<br>\n</ul>\n");
	}
	print '<textarea name=head cols=90 rows=30>';
	print $head;
	print "</textarea><br>\n";
	echo "</td></tr><tr><td>ローカルルールフッタ<br>";
	my $foot;
	$fname = "../$bbs/foot.txt";
	if (-e $fname) {
		$foot = read_file($fname);
	} else {
		$foot = enc_str("<font color=#FFFFFF><b>予告なしに削除する場合があります</b></font>\n");
	}
	print '<textarea name=foot cols=90 rows=10>';
	print $foot;
	print "</textarea><br>\n";
	submit_exe();
}

sub write_rule {
	my $bbs = shift;
	my $fname = "../$bbs/head.txt";
	write_rule_exe($fname,$cgi->param('head'));
	$fname = "../$bbs/foot.txt";
	write_rule_exe($fname,$cgi->param('foot'));
}

sub write_rule_exe {
	my $fname = shift;
	my $text = shift;
	echo $fname,(write_file($fname,\$text,0) ? "更新" : "失敗"),"<br>\n";
}
1;

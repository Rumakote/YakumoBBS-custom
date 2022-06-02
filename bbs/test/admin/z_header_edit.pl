use utf8;
$CGI::LIST_CONTEXT_WARN = 0;

sub show_header_edit {
	my $bbs = shift;
	my $fname = shift;
	if ($fname eq '') {$fname = 'header';}
	echo "<td>\n";
	echo "Headタグ内編集（html記法）<br>";
	my $header = read_file("../$bbs/header.txt");
	print '<textarea name=header cols=80 rows=10>';
	print $header;
	print "</textarea><br>\n";
	submit_exe();
}

sub write_header_edit {
	my $bbs = shift;
	my $file = shift;
	if ($file eq '') {$file = 'header';}
	my $fname = "../$bbs/header.txt";
	write_header_edit_exe($fname,$cgi->param('header'));
}

sub write_header_edit_exe {
	my $fname = shift;
	my $text = shift;
	if (trim($text) ne '') {
		echo $fname,(write_file($fname,\$text,0) ? "更新" : "失敗"),"<br>\n";
	} else {
		echo $fname,(delete_file($fname) ? "削除" : "削除失敗"),"<br>\n";
	}
}
1;

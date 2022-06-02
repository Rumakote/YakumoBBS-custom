use utf8;
$CGI::LIST_CONTEXT_WARN = 0;

sub show_banner {
	my $bbs = shift;
	my $fname = shift;
	if ($fname eq '') {$fname = 'banner';}
	echo "<td>\n";
	echo "パソコン用上部<br>";
	my $p_banner1 = read_file("../$bbs/$fname"."1.txt");
	print '<textarea name=p_1 cols=80 rows=10>';
	print $p_banner1;
	print "</textarea><br>\n";
	echo "</td></tr><tr><td>パソコン用下部<br>";
	my $p_banner2 = read_file("../$bbs/$fname"."2.txt");
	if ($fname eq 'cushion' && trim($p_banner2) eq '') {$p_banner2 = $msg;}
	print '<textarea name=p_2 cols=80 rows=10>';
	print $p_banner2;
	print "</textarea><br>\n";
	echo "</td></tr><tr><td>携帯用上部<br>";
	my $m_banner1 = read_file("../$bbs/m/$fname"."1.txt");
	print '<textarea name=m_1 cols=80 rows=10>';
	print $m_banner1;
	print "</textarea><br>\n";
	echo "</td></tr><tr><td>携帯用下部<br>";
	my $m_banner2 = read_file("../$bbs/m/$fname"."2.txt");
	if ($fname eq 'cushion' && trim($m_banner2) eq '') {$m_banner2 = $msg;}
	print '<textarea name=m_2 cols=80 rows=10>';
	print $m_banner2;
	print "</textarea><br>\n";
	submit_exe();
}

sub write_banner {
	my $bbs = shift;
	my $file = shift;
	if ($file eq '') {$file = 'banner';}
	my $fname = "../$bbs/$file"."1.txt";
	write_banner_exe($fname,$cgi->param('p_1'));
	my $fname = "../$bbs/$file"."2.txt";
	write_banner_exe($fname,$cgi->param('p_2'));
	my $fname = "../$bbs/m/$file"."1.txt";
	write_banner_exe($fname,$cgi->param('m_1'));
	my $fname = "../$bbs/m/$file"."2.txt";
	write_banner_exe($fname,$cgi->param('m_2'));
}

sub write_banner_exe {
	my $fname = shift;
	my $text = shift;
	if (trim($text) ne '') {
		echo $fname,(write_file($fname,\$text,0) ? "更新" : "失敗"),"<br>\n";
	} else {
		echo $fname,(delete_file($fname) ? "削除" : "削除失敗"),"<br>\n";
	}
}
1;

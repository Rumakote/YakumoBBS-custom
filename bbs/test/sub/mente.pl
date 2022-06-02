use utf8;

sub show_mente {
	my $text = read_file('../ifo/maintenance.txt');
	my $title = trim(substr($text,0,index($text,"\n")));
	if ($title eq '') {$title = enc_str("メンテナンスのお知らせ");}
	$text = rtrim(substr($text,index($text,"\n")));
	if ($text eq '') {$text = enc_str("掲示板のメンテナンス中です。\n");}

	my $html = "Content-type: text/html\n\n";
	if (index($call,'.cgi') < 0 || length($call) > 6) {
		$html .= '<html><head><meta http-equiv="Content-Type" content="text/html; charset='.$ifo{'outchr'}.'">';
		$html .= "\n<title>".$title."</title>\n<body>\n<center>\n<table border=2 width=70%><tr><td>".$text."</td></tr></table>\n</center>\n";
		$html .= "</body>\n</html>\n";
	} else {
		$html .= '<html><head><meta http-equiv="Content-Type" content="text/html; charset=shift_jis"><title>';
		$html .= val_sjis($title).'</title><body>'.val_sjis($text).'</body></html>';
	}
	print $html;
}
1;
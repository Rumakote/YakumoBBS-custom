use utf8;

sub show_smn {
	my $num = shift;
	my $message = shift;
	my $width = shift;
	my $height = shift;
	my $link = shift;
	my $ret = ($link ? '' : '<br>');
	my $pos = index($$message,'<br>');
	if ($pos < 7) {
		$$message .= $ret;
		return(0);
	}
	my $type = substr($$message,0,$pos);
	if ($type =~ s/^s?https?:\/\/[^ ]+?$bbs\/img\/$key\/$num\.//) {
		$type = substr($type,0,3);
	} else {
		$$message .= $ret;
		return(0);
	}
	unless (-e "$dir/$bbs/img/$key/$num.$type") {
		$$message .= $ret;
		return(0);
	}
	my $file = '';
	if (-e "$dir/$bbs/smn/$key/$num.jpg") {
		$file = "<img border='0' align='left' src=\"$link"."smn/$key/$num.jpg\">";
		$$message .= "<br clear='all'>"
	} elsif ($link) {
	 	$file = enc_str('&lt;画像&gt;');
	} else {
		$file = "<img border='0' width='$width' align='left' src='$link"."img/$key/$num.$type'>";
		$$message .= "<br clear='all'>"
	}
	$pos = ($link ? '' : ' target="_blank"');
	$file = "<a href=\"$link"."img/$key/$num.$type\"$pos>$file</a> ";
	$$message =~ s/^.+? /$file/;
	return(0);
}
1;

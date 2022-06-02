use utf8;
use GD::Image;

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
	my $flg;
	my $fname = "$dir/$bbs/smn/$key/$num.jpg";
	my $file = '';
	if (!(-e $fname) && $width ne '' && $height ne '') {
		if (-d "$dir/$bbs/smn/$key" || mkdir("$dir/$bbs/smn/$key")) {
			my $image = GD::Image->new("$dir/$bbs/img/$key/$num.$type");
			my ($x,$y) = $image->getBounds();
			my $new_height = int($width / $x * $y + 0.5);
			if ($new_height > $height) {
				$width = int($height / $y * $x + 0.5);
			} else {
				$height = $new_height;
			}
			my $jpeg = new GD::Image($width,$height,1);
			$jpeg->copyResized($image,0,0,0,0,$width,$height,$x,$y);
			my $text = $jpeg->jpeg($setting{'IMG_SMN_QLT'});
			write_file($fname,\$text,0);
			unless (-s $fname) {unlink $fname;}
		}
	}
	if (-e $fname) {
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

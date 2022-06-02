use utf8;
use Image::Magick;

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
			my $image = Image::Magick->new;
			$image->Read(filename=>"$dir/$bbs/img/$key/$num.$type");
			my $x = $image->Get('width');
			my $y = $image->Get('height');
			my $new_height = int($width / $x * $y + 0.5);
			if ($new_height > $height) {
				$width = int($height / $y * $x + 0.5);
			}
			$image->Scale(geometry=>$width);
			$image->Set(quality=>$setting{'IMG_SMN_QLT'});
			$image->Write($fname);
			unless (-s $fname) {
				unlink $fname;
				if (-e "$dir/$bbs/smn/$key/$num".'-0.jpg') {
					rename "$dir/$bbs/smn/$key/$num".'-0.jpg',$fname;
					unlink glob("$dir/$bbs/smn/$key/$num".'-*.jpg');
				}
			}
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

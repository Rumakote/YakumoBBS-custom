use Image::Magick;

sub img_cnv {
	my $infile = shift;
	my $num = shift;
	my $image = Image::Magick->new;
	my $outfile = "../$bbs/img/$key/$num.jpg";
	$image->Read(filename=>$infile);
	$image->AutoOrient();
	$image->Set(quality=>$setting{'IMG_JPG_QLT'});
	$image->Write($outfile);
	unlink $infile;
	unless(-e $outfile) {return(0);}
	unless (-s $outfile) {
		unlink $outfile;
		return (0);
	}
	return (1);
}

sub img_smn {
	my $infile = shift;
	my $num = shift;
	my $outfile = "../$bbs/smn/$key/$num.jpg";
	my $out_width = $setting{'IMG_THUMBNAIL_X'};
	my $out_height = $setting{'IMG_THUMBNAIL_Y'};
	if ($out_width eq '' || $out_height eq '') {return(0);}
	unless (-d "../$bbs/smn/$key") {
		mkdir("../$bbs/smn/$key") or return(0);
	}
	my $image = Image::Magick->new;
	$image->Read(filename=>$infile);
	my $width = $image->Get('width');
	my $height = $image->Get('height');
	my $new_height = int($out_width / $width * $height + 0.5);
	if ($new_height > $out_height) {
		$out_width = int($out_height / $height * $width + 0.5);
	}
	$image->Scale(geometry=>$out_width);
	$image->Set(quality=>$setting{'IMG_SMN_QLT'});
	$image->Write($outfile);
	unless (-s $outfile) {
		unlink $outfile;
		if (-e "../$bbs/smn/$key/$num".'-0.jpg') {
			rename "../$bbs/smn/$key/$num".'-0.jpg',$outfile;
			unlink glob("../$bbs/smn/$key/$num".'-*.jpg');
		} else {
			return (0);
		}
	}
	return (1);
}
1;

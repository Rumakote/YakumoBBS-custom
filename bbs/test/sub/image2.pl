use GD::Image;

sub img_cnv {
	my $infile = shift;
	my $num = shift;
	my $image = GD::Image->new($infile);
	my $jpgf = $image->jpeg($setting{'IMG_JPG_QLT'});
	my $outfile = "../$bbs/img/$key/$num.jpg";
	write_file($outfile,\$jpgf,0);
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
	my $image = GD::Image->new($infile);
	my ($width,$height) = $image->getBounds;
	my $new_height = int($out_width / $width * $height + 0.5);
	if ($new_height > $out_height) {
		$out_width = int($out_height / $height * $width + 0.5);
	} else {
		$out_height = $new_height;
	}
	my $jpeg = new GD::Image($out_width,$out_height,1);
	$jpeg->copyResized($image,0,0,0,0,$out_width,$out_height,$width,$height);
	my $text = $jpeg->jpeg($setting{'IMG_SMN_QLT'});
	write_file($outfile,\$text,0);
	unless (-s $outfile) {
		unlink $outfile;
		return (0);
	}
	return (1);
}
1;

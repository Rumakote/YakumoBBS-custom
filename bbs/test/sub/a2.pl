use GD::image;

sub img_init {
	my $width = shift;
	my $height = shift;
	$image = new GD::Image($width,$height);
	$bk = $image->colorAllocate(0,0,0);
	$bg = $image->colorAllocate(255,255,255);
	$image ->filledRectangle(0,0,$width-1,$height-1,$bg);
}

sub img_del {
	my $width = shift;
	my $height = shift;
	undef $img;
	$image = new GD::Image($width,$height);
	$bk = $image->colorAllocate(0,0,0);
	$bg = $image->colorAllocate(255,255,255);
	$image ->filledRectangle(0,0,$width-1,$height-1,$bg);
}

sub img_str {
	my $size = shift;	#1=6pt 2=12pt
	my $width = shift;
	my $height = shift;
	my @text = @_;
	my $y = $size * 8;
	my $yadd = $y + $size;
	$size *= 6;
	foreach $data(@text) {
		$image->stringFT($bk,$ifo{'fontfile'},$size,0,0,$y,$data);
		$y += $yadd;
	}
	my $st_x = -1;
	for (my $x = 0;$x < $width;$x++) {
		for (my $y =0;$y < $height;$y++) {
			if ($image->getPixel($x,$y) != $bg) {
				$st_x = $x;
				last;
			}
		}
		if ($st_x >= 0) {last;}
	}
	my $ed_x = $width;
	for (my $x = $width-1;$x >= 0;$x--) {
		for (my $y =0;$y < $height;$y++) {
			if ($image->getPixel($x,$y) != $bg) {
				$ed_x = $x;
				last;
			}
		}
		if ($ed_x < $width) {last;}
	}
	my $n_width = $ed_x - $st_x + 1;
	$img = new GD::Image->new($n_width,$height);
	$img ->copy($image,0,0,$st_x,0,$n_width,$height);
	undef $image;
	return($n_width,$height);
}

sub img_resize {
	my $size = shift;
	my $width = shift;
	my $height = shift;
	my $o_height = $height;
	$size *= 240;
	$height = int( $size / $width * $height + 0.5);
	if ($height > $size * 2) {
		$height = $size * 2;
		my $ritu = $height / $o_height;
		$size = $ritu * $width;
	}
	$image = new GD::Image->new($size,$height);
	$image->copyResized($img,0,0,0,0,$size,$height,$width,$o_height);
	undef $img;
}

sub img_print {
	print "Content-type: image/gif\n\n";
	binmode STDOUT;				# Winの時のおまじない 
	print $image->gif();			# gifで書き出し
	undef $image;
}
1;

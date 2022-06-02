use Image::Magick;

sub img_init {
	my $x = shift;
	my $y = shift;
	$image = Image::Magick->new;
	$image->Set(size=>$x.'x'.$y);	# カンバスサイズ 
	$image->ReadImage('xc:white');	# バック白
}

sub img_del {
	undef $image;
	my $x = shift;
	my $y = shift;
	img_init($x,$y);
}

sub img_str {
	my $size = shift;	#1=6pt 2=12pt
	my $width = shift;
	my $height = shift;
	my @text = @_;
	my $y = $size * 8;
	my $yadd = $y + $size;
	$size *= 8;
	foreach $data(@text) {
		$image->Annotate(
			text=>$data,
			fill=>'black',
			font=>$ifo{'fontfile'},
			pointsize=>$size,
			x=>'0',
			y=>$y
		);
		$y += $yadd;
	}
	$image->Trim();
	$image->Frame(geometry=>'8x4', color=>white);
	my ($width, $height) = $image->Get('width', 'height');
	return($width,$height);
}

sub img_resize {
	my $size = shift;
	my $width = shift;
	my $height = shift;
	$size *= 240;
	$height = int($height / $width * $size + 0.5);
	if ($height > $size * 2) {
		my $ritu = $size * 2 / $height;
		$height = $size * 2;
		$size *= $ritu;
	}
	$image->Resize(width=>$size,height=>$height);
	$image->Set(page=>$size.'x'."$height");
}

sub img_print {
	$image->Posterize(levels=>4);		#4色モード変換
	print "Content-type: image/gif\n\n";
	binmode STDOUT;				# Winの時のおまじない 
	$image->Write('gif:-');			# gifで書き出し 
}
1;

sub img_up {
	my $fname = shift;
	my $num = shift;
	my $buffer;
	my $outfile = "../$bbs/img/$key/$num.$img_type";
	if (open(HN,$fname)) {$fname = HN;}
	unless (-d "../$bbs/img/$key") {
		unless(mkdir("../$bbs/img/$key")) {
			close $fname;
			return ('');
		}
	}
	binmode($fname);
	if (open(WR,">$outfile")) {
		binmode(WR);
		if ($img_type eq 'jpg') {
			my $JPEG_MARKER = "\xFF\xD8";
			my $SOI_MARKER  = "\xFF\xDA";
			my ($length,$marker);
			read($fname, $marker, 2);
			if($marker ne $JPEG_MARKER){
				close($fname);
				close(WR);
				unlink $outfile;
				return ('');
			}
			print WR $JPEG_MARKER;
			while(1){
				read($fname, $marker, 2);
				if($marker eq $SOI_MARKER){
					 print WR $marker;
					  last;
				}
				read($fname, $length, 2);
				my $len = vec($length, 0, 16);
				read($fname, $buffer, $len - 2);
				if(not($marker ge "\xFF\xE1" && $marker le "\xFF\xE9") && $marker ne "\xFF\xFE"){
					print WR $marker;
					print WR $length;
					print WR $buffer;
				}
			}
		}
		while(read($fname,$buffer,2048)) {
			print WR $buffer;
		}
		close($fname);
		close(WR);
		unless (-s $outfile) {
			unlink $outfile;
			return ('');
		}
	} else {			#書き込み用オープン失敗
		close($fnamr);
		return ('');
	}
	if ($img_type ne 'jpg' && $img_type ne 'gif') {
		img_cnv($outfile,$num) or return ('');
		$img_type = 'jpg';
	}
	if ($ifo{'img_lib'}) {
		$outfile = "../$bbs/img/$key/$num.$img_type";
		img_smn($outfile,$num);
	}
	$fname = $cgi->url;
	$fname = substr($fname,0,index($fname,'/test/'));
	$fname .= "/$bbs/img/$key/$num.$img_type (". int((-s $outfile)/1024 + 0.9).'KB)';
	return($fname);
}

sub img_cut {
my ($fh_in, $fh_out);
my ($marker, $length, $buffer);

my $JPEG_MARKER = "\xFF\xD8";
my $SOI_MARKER  = "\xFF\xDA";

print "in : $ARGV[0]\n";
print "out: $ARGV[1]\n";

open($fh_in, '<', $ARGV[0]) || die 'cant open file';
read($fh_in, $marker, 2);
if($marker ne $JPEG_MARKER){
	die 'not jpeg file';
}
open($fh_out, '>', $ARGV[1]) || die 'cant open file';


binmode($fh_in);
binmode($fh_out);

print $fh_out "$JPEG_MARKER";

while(1){
	# read Marker
	read($fh_in, $marker, 2) || die 'error file';
	if($marker eq $SOI_MARKER){ print $fh_out "$marker"; last; }
	
	#read Length
	read($fh_in, $length, 2);
	my $len = vec($length, 0, 16);
	
	printf("MARKER:%s, LENGTH:%04X\n", uc(unpack("H*", $marker)), $len);
	
	#read Data (datasize = length - lengthdata(2byte))
	read($fh_in, $buffer, $len - 2);
	
	# no output APP1-15, COMMENT
	if(not($marker ge "\xFF\xE1" && $marker le "\xFF\xE9") || $marker ne "\xFF\xFE"){
		print $fh_out "$marker";
		print $fh_out "$length";
		print $fh_out "$buffer";
	}else{
		print "DELETE!!\n";
	}
}

while(read($fh_in, $buffer, 4096)){
	print $fh_out "$buffer";
}

close($fh_in);
close($fh_out);
}
1;

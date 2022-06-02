sub get_perm {
	my $fname = shift;
	my @status = stat($fname);
	return(substr((sprintf "%03o", $status[2]), -3));
}

sub copy_login {
	my $board = shift;
	my @list = glob("../$board/*.cgi");
	foreach $data(@list) {
		my $text = read_file($data);
		if (index($text,"require '../test/sub/login_board.pl';") >= 0) {
			unlink($data);
		}
	}
	@list = glob("../test/*.cgi");
	foreach $data(@list) {
		my $text = read_file($data);
		if (index($text,"require '../test/sub/login_board.pl';") >= 0) {
			my $perm = get_perm($data);
			substr($data,index($data,'/test/'),length('/test/'),"/$board/");
			write_file($data,\$text,0);
			chmod(oct($perm),$data);
		}
	}
}
1;

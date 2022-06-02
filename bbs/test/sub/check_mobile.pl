#
#携帯かパソコンか判定
#	返り値 
#	携帯=1
#	パソコン=0
#	スマホ=2
sub check_mobile {
	my $host = $ENV{'REMOTE_HOST'};
	my $addr = $ENV{'REMOTE_ADDR'};
	if ($host eq "" || $host eq $addr) {
		$host = gethostbyaddr(pack("C4",split(/\./,$addr)),2) || $addr;
	}
	if ($host =~ /.+docomo\.ne\.jp$/ && $ENV{'HTTP_X_DCMBearer'} eq '') {return(1);}	#ドコモ
	if ($host =~ /.+jp-.\.ne\.jp$/ && $ENV{'HTTP_X_S_BEARER'} eq '') {return(1);}		#ソフトバンク
	if ($host =~ /.+ezweb\.ne\.jp$/ && !$ENV{'HTTP_X_UP_DEVCAP_SELECTEDNETWORK'} 		#au
		&& $ENV{'HTTP_X_SELECTEDNETWORK'} eq '') {return(1);}
	if ($host =~ /.+pool\.e-mobile\.ne\.jp$/ && $ENV{'HTTP_X_EM_UID'}) {return(1);}		#イーモバイル
	if ($host =~ /.+pool\.emobile\.ad\.jp$/ && $ENV{'HTTP_X_EM_UID'}) {return(1);}		#イーモバイル
	if ($host =~ /.+ppp\.prin\.ne\.jp$/) {return(1);}					#Willcom
	my $agent = $ENV{'HTTP_USER_AGENT'};
	if ($agent =~ /iPad/) {return(0);}
	if ($agent =~ /iPhone|iPod|Android.*Mobile|dream|blackberry|CUPCAKE|webOS|incognito|webmate/) {return(2);}
	return(0);
}
1;

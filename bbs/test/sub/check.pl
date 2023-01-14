use utf8;
use CGI;
$CGI::LIST_CONTEXT_WARN = 0;

sub get_data {
	$CGI::POST_MAX = $ifo{'post_max'};	#↓POSTされた変数の受信
	($info) = get_datetime();
	$info_er = $info;
	$agent =$ENV{'HTTP_USER_AGENT'};	#環境変数取得

	# https://github.com/PrefKarafuto/New_0ch_Plus/blob/main/test/module/peregrin.pl
	# を参考にCloudFlare対応にしてみた。
	$remote_addr = (($ENV{HTTP_CF_CONNECTING_IP}) ? $ENV{HTTP_CF_CONNECTING_IP} : $ENV{REMOTE_ADDR});
	if ($remote_addr eq '::1' || $remote_addr eq '127.0.0.1') {
		$remote_addr = '127.0.0.1';
		$remote_host = 'localhost';
	} else {
		$remote_host = gethostbyaddr(pack("C4",split(/\./,$remote_addr)),2) || 'noname_host';
	}
	if ($remote_host =~ /p2\.2ch\.net$/) {$remote_host .= ";$ENV{'HTTP_X_P2_CLIENT_HOST'}";}
	$mobile_id = '';			#携帯判定&ID取得
	if ($remote_host =~ /.+docomo\.ne\.jp$/) {				#ドコモ
		$mobile_id = 'do' . $ENV{'HTTP_X_DCMGUID'};
		if ($mobile_id eq 'do' && $ENV{'HTTP_X_DCMBearer'} ne '') {$mobile_id = 'pc';}
	} elsif ($remote_host =~ /.+jp-.\.ne\.jp$|pcsitebrowser\.ne\.jp$/) { 	#ソフトバンク
		($mobile_id) = $agent =~ /\/SN([A-Za-z0-9]+)\ /;
		$mobile_id = 'sb' . $mobile_id;
		if ($mobile_id eq 'sb' && $ENV{'HTTP_X_S_BEARER'} ne '') {$mobile_id = 'pc';}
	} elsif ($remote_host =~ /.+ezweb\.ne\.jp$/) {			#AU
		$mobile_id = 'au' . $ENV{'HTTP_X_UP_SUBNO'};
		$mobile_id =~ s/\.ezweb\.ne\.jp$//;
		if ($ENV{'HTTP_X_UP_DEVCAP_SELECTEDNETWORK'} || $ENV{'HTTP_X_SELECTEDNETWORK'} ne '') {$mobile_id = 'pc';}
	} elsif ($remote_host =~ /.+pool\.e-mobile\.ne\.jp$/ ||
		$remote_host =~ /.+pool\.emobile\.ad\.jp$/) {		#イーモバイル
			$mobile_id = 'em' . $ENV{'HTTP_X_EM_UID'};
		if ($mobile_id eq 'em') {$mobile_id = 'pc';}
	} elsif ($remote_host =~ /.+ppp\.prin\.ne\.jp$/) {		#ウィルコム
		$mobile_id = 'wi';
	}
	if (length($mobile_id) == 2 && $mobile_id ne 'pc' && $mobile_id ne 'wi') {
		$mobile_id = ($ENV{'HTTP_X_P2_MOBILE_SERIAL_BBM'} ne "" ? $mobile_id.$ENV{'HTTP_X_P2_MOBILE_SERIAL_BBM'} : 'non_id_' . $mobile_id);
		$mobile_id =~ s/\.ezweb\.ne\.jp$//;
	}
	$proxy = '';				#プロキシ情報
	unless ($mobile_id) {
		if ($ENV{'HTTP_PROXY_CONNECTION'}) {$proxy .= "CONNECTION=$ENV{'HTTP_PROXY_CONNECTION'}" ;}
		if ($ENV{'HTTP_VIA'}) {$proxy .= "VIA=$ENV{'HTTP_VIA'}" ;}
		if ($ENV{'HTTP_CLIENT_IP'}) {$proxy .= "IP=$ENV{'HTTP_CLIENT_IP'} ";}
		if ($ENV{'HTTP_SP_HOST'}) {$proxy .= "HOST=$ENV{'HTTP_SP_HOST'} " ;}
		if ($ENV{'HTTP_FROM'}) {$proxy .= "FROM=$ENV{'HTTP_FROM'} " ;}
		if ($ENV{'HTTP_IF_MODIFIED_SINCE'}) {$proxy .= "SINCE=$ENV{'HTTP_IF_MODIFIED_SINCE'} " ;}
		if ($ENV{'HTTP_CACHE_INFO'}) {$proxy .= "CACHE_INFO=$ENV{'CACHE_INFO'} " ;}
		if ($ENV{'HTTP_X_LOCKING'}) {$proxy .= "X_LOCKING=$ENV{'_X_LOCKING'} " ;}
		if ($ENV{'HTTP_FORWARDED'}) {$proxy .= "FORWARDED=$ENV{'HTTP_FORWARDED'} " ;}
		if ($ENV{'HTTP_X_FORWARDED_FOR'} && $ENV{'HTTP_X_FORWARDED_FOR'} ne $remote_addr) {$proxy .= "X_FORWARDED=$ENV{'HTTP_X_FORWARDED_FOR'} " ;}
		if ($proxy) {$proxy = "proxy $proxy";}
		if ($remote_host =~ /\.au-net\.ne\.jp$|p2\.2ch\.net/) {
			$proxy = '';
		} elsif($remote_host ne 'noname_host') {
			$mobile_id = (gethostbyname($remote_host))[4];	#ホストからIPアドレス取得
			$mobile_id = sprintf("%u.%u.%u.%u", unpack("C*", $mobile_id));
			$mobile_id = ($mobile_id eq $remote_addr ? '' : "x$mobile_id");
		}
		$mobile_id = ($proxy ? 'pcp' : 'pc').$mobile_id;
	}
	$ifo{'max_dat_size'} *= 1024;		#KBをByteへ変換
	$cgi = new CGI;
	$bbs = $cgi->param('bbs');
	if ($cgi->cgi_error) {error_exit(900);}
	$key = $cgi->param('key');
	$name = $cgi->param('FROM');
	$mail = $cgi->param('mail');
	$img_name = $cgi->param('file');
	$message = $cgi->param('MESSAGE');
	$submit = $cgi->param('submit');
	$subject = join('',$cgi->param('subject'));
	change_code();				#文字コードを$ifo{'outchr'}の内容に変換
	$referer = "$call!$ENV{'HTTP_REFERER'}";
	unless (-d "../$bbs") {error_exit(502);}
	%setting = get_setting_txt($bbs);
	$c_ip = $cgi->cookie('KAN');
	$c_host = $cgi->cookie('PON');
	return (0);
}

sub check_data {
	$er_flg = 0;
	$level = 0;
	$nanja = '';
	my @hihumi;
	my %yoimu;
	my $mona;
	my $mobile = index($mobile_id,'pc') < 0 && $mobile_id ne 'wi';
	($mona,$ifo{'server'},$ifo{'max_level'},$ifo{'res_level'},$ifo{'thread_level'}) = split('<>',trim(read_file('../ifo/enigma.cgi')));
	my $cookie = length($mona) >= 20 && $ifo{'dir'};
	my $cookie_ck = 0;
	my $domain = $ifo{'domain'};
	my ($c_id,$l_time,$c_level);
	@hihumi = split('',$mona);
	$mona = 0;
	foreach my $data (@hihumi) {
		$yoimu{$data} = $mona;
		$mona++;
	}
	$mona = $agent =~ /Monazilla|Jane|Hotzonu|BB2C/;
	my $upms = '';
	my $enigma = '';
	if ($cookie) {
		if ($name) {
			write_cookie('NAME',val_utf($name),2);
		} else {
			write_cookie('NAME',' ',-1);
		}
		if ($mail) {
			write_cookie('MAIL',val_utf($mail),2);
		} else {
			write_cookie('MAIL',' ',-1);
		}
		unless ($domain) {$domain = get_domain();}
		$enigma = get_cookie($domain,$ifo{'dir'},$mona);
		($c_id,$l_time,$c_level) = get_enigma(\%yoimu,$enigma,$mobile);
		$level = $c_level;
		$cookie_ck = $cgi->cookie($ifo{'c_name'}) eq $ifo{'c_val'};
		if ($c_id) {
			$mobile_id .= ",ys$c_id!";
		} elsif ($cookie_ck) {
			if ($c_ip && $c_host) {
				unless ($mobile) {
					$c_id = add_id(\@hihumi,\%yoimu);
					$mobile_id .= ",ys$c_id!";
				}
			} else {
				$mobile_id .= ',non_id_cookie';
			}
		} elsif ($mobile && index($mobile_id,'non_id') < 0) {
			$level = $ifo{'res_level'};	#クッキー未対応ガラケー
		} elsif ($mobile_id eq 'wi') {
			$mobile_id = 'non_id_wi';	#クッキーオフウィルコム
		} elsif ($mona) {
			$mobile_id .= ',Monazilla';	#専ブラ
		} else {
			$mobile_id .= ',non_id_not_form';
		}
		if ($c_ip && $c_host && index($mobile_id,'non_id') < 0 && index($mobile_id,'Monazilla') < 0) {
			($level,$enigma) = encode_cookie(\@hihumi,$c_id,$l_time,$c_level);
			if ($level > $c_level) {$upms = "<br>!levelup:$level:";}
		}
	}
	unless ($c_ip) {$c_ip = $remote_addr;}
	unless ($c_host) {$c_host = $remote_host;}
	make_trip();
	make_cap();
	my $tripcap = !check_trip() or $cap;
	if (!$tripcap && $ifo{'ht_use'}) {
		$er_flg = 1;
		if ($ifo{'ht_mode'} & 4 && $remote_host eq 'noname_host') {
			error_exit(803,'noname_host');
		} elsif ($ifo{'ht_mode'} & 8 && index($mobile_id,'x0.0.0.0') >= 0) {
			error_exit(805,'can not get IPaddress by remote host');
		} elsif ($ifo{'ht_mode'} & 16 && $proxy) {
			error_exit(803,'proxy');
		} else {
			$er_flg = 0;
		}
		if (check_referer()) {
			if ($ifo{'ht_mode'} & 128) {$er_flg = 1;}
			error_exit(804);
		}
	}
	if ($ENV{'REQUEST_METHOD'} eq "GET") {error_exit(901);}
	if (!$subjext && $key) {		#スレ立てかレス書きかチェック
		$act = 1;			#レス書き
	} elsif ($subject && !$key) {
		$act = 0;			#スレ立て
		if (check_title($bbs,$subject)) {error_exit(622);}
	} else {
		if ($ifo{'ht_use'} && $ifo{'ht_mode'} & 2) {$er_flg = 1;}
		error_exit(902);
	}
	if (!$mona && (($act && $submit ne enc_str('書き込む')) || (!$act && $submit ne enc_str('新規スレッド作成')))) {
		if ($submit ne enc_str('かきこむ'))  {
			if ($ifo{'ht_use'} && $ifo{'ht_mode'} & 1) {$er_flg = 1;}
			error_exit(903);
		}
	}
	$img_type = check_img($img_name);		#0無し それ以外は拡張子
	if ($setting{'READONLY'} eq 'checked') {error_exit(601);}
	if ($setting{'READONLY'} eq 'caps' && $cap eq '') {error_exit(601);}
	if ($setting{'READONLY'} eq 'trip' && !$tripcap) {error_exit(601);}
	if ($setting{'READONLY'} && $level < $setting{'READONLY'} && !$tripcap) {error_exit(620);}
	unless ($message) {error_exit(602);}
	if ($setting{'MESSAGE_LINE'}) {
		my @ent = split(/\n/,$message);
		my $cnt = @ent;
		if ($cnt > $setting{'MESSAGE_LINE'}) {error_exit(603);}
	}
	if ($act) {
		if (!(-e "../$bbs/idx/$key.idx")) {error_exit(501);}
		if (!(-e "../$bbs/dat/$key.dat")) {error_exit(501);}
		if (get_index(1) < 1) {error_exit(604);}
	} else {
		if ($setting{'THREAD_MAKE'} eq 'checked') {error_exit(605);}
		if ($setting{'THREAD_MAKE'} eq 'caps' && !$cap) {error_exit(605);}
		if ($setting{'THREAD_MAKE'} eq 'trip' && !$tripcap) {error_exit(605);}
		if ($setting{'THREAD_MAKE'} && $level < $setting{'THREAD_MAKE'} && !$tripcap) {error_exit(621);}
	}
	check_size();	#名前やメール欄、本文の長さチェック
	if ($setting{'NANASHI_CHECK'} == 1) {
		if ($name eq '') {error_exit(606);}
	} elsif ($setting{'NANASHI_CHECK'} == 2) {
		if ($name eq '' || $trip eq '') {error_exit(607);}
	} elsif ($setting{'NANASHI_CHECK'} == 3) {
		$name = '';
		$trip = '';
		$nanja = '';
	} elsif ($setting{'NANASHI_CHECK'} == 4) {
		unless ($nanja) {$nanja = get_nanja();}
	}
	html_spchar(\$subject);
	html_spchar(\$name);
	html_spchar(\$cap);
	html_spchar(\$mail);
	html_spchar(\$message);
	$message .= $upms;
	if ($setting{'FORCE_ID'} eq 'checked') {$info .= get_id();}
	html_spchar(\$info);
	html_spchar(\$trip);
	if ($trip) {$name .= ' </b>'.enc_str('◆').$trip.'<b>';}
	$name = trim($name);
	unless ($name) {
		$name = $setting{'NONAME_NAME'};
		html_spchar(\$name);
	}
	if ($cap) {
		unless ($name =~ s/<b>\s*$//) {$name .= '</b>';}
		$name .= " \@ $cap ".enc_str('★').'<b>';
	}
	if ($nanja) {
		unless ($name =~ s/<b>\s*$//) {$name .= '</b>';}
		$name .= enc_str(' ◆').$nanja.'<b>';
	}
	my ($err,$result) = check_kisei('../ifo/nogood.cgi',$tripcap);
	if ($err) {error_exit($err,$result);}
	($err,$result) = check_kisei("../$bbs/ifo/nogood.cgi",$tripcap);
	if ($err) {error_exit($err,$result);}
	if($upms) {$message =~ s/$upms//;}
	($err,$result) = check_samba($tripcap);
	if ($err) {error_exit($err,$result);}
	ent_clr(\$subject);
	ent_clr(\$name);
	ent_clr(\$mail);
	ent_clr(\$message);
	if ($cookie) {
		write_cookie($ifo{'c_name'},$ifo{'c_val'},12);
		write_cookie('PON',$remote_host,24);
		write_cookie('KAN',$remote_addr,24);
		if ($level) {write_cookie('HIHUMI',"$domain/$ifo{'dir'} $enigma",24);}
	}
	return(0);
}

sub check_samba {
	my $tripcap = shift;
	unless ($setting{'timecount'}) {return(0,0);}
	my $msg = substr($message,0,20);
	my $size = length($message);
	my $id = $mobile_id;
	$id =~ s/^pc.*,//;
	unless ($setting{'SAMBATIME'}) {$setting{'SAMBATIME'} = 0;}
	if (open(TC,"+< ../$bbs/ifo/timecount.cgi")) {
		flock(TC,2);
		my $count = 0;
		my $thread = 0;
		my @list = ();
		my $err = 0;
		my $result = '';
		@list = <TC>;
		splice(@list,$setting{'timecount'});
		foreach my $line (@list) {
			my ($ip1,$ip2,$id1,$time1,$count1,$act1,$size1,$msg1) = split('<>',$line);
			if ($ip1 eq $remote_addr ||$ip1 eq $c_ip || ip2 eq $remote_addr || $ip2 eq $c_ip || $id1 eq $id) {
				if (!$count && $size == $size1 && $msg eq $msg1) {
					$err = 613;
					last;
				} elsif (!$count && $count1 == 0 && ($time1 + $setting{'SAMBATIME'}) > $time) {
					$err = 614;
					$result = $time1 + $setting{'SAMBATIME'} - $time;
					$line = "$ip1<>$ip2<>$id1<>$time1<>1<>$act1<>$size1<>$msg1<>\n";
					last;
				} elsif (!$count && $count1 == 1 && ($time1 + $setting{'SAMBATIME'}) > $time) {
					$err = 615;
					$time1 = $time;
					$result = $time1 + $setting{'SAMBATIME'} - time();
					$line = "$ip1<>$ip2<>$id1<>$time1<>2<>$act1<>$size1<>$msg1<>\n";
					last;
				} elsif (!$count && $count1 == 2 && ($time1 + $setting{'SAMBATIME'}) > $time) {
					$err = 616;
					$time1 = $time + $setting{'SAMBATIME'} * 2;
					$result = $time1 + $setting{'SAMBATIME'} - time();
					$line = "$ip1<>$ip2<>$id1<>$time1<>3<>$act1<>$size1<>$msg1<>\n";
					last;
				} elsif (!$count && $count1 >= 3 && ($time1 + $setting{'SAMBATIME'}) > $time) {
					$err = 617;
					$time1 += $setting{'SAMBATIME'} * $count1;
					$result = $time1 + $setting{'SAMBATIME'} - time();
					$count1 ++;
					$line = "$ip1<>$ip2<>$id1<>$time1<>$count1<>$act1<>$size1<>$msg1<>\n";
					last;
				} else {
					$count++;
					unless ($act1) {$thread++;}
				}
			}
		}
		if ($setting{'timeclose'} && $count >= $setting{'timeclose'}) {$err = 618;}
		if (!$act && $setting{'THREAD_TATESUGI'} && $thread >= $setting{'THREAD_TATESUGI'}) {$err = 619;}
		unless ($err) {
			unshift(@list,"$remote_addr<>$c_ip<>$id<>$time<>0<>$act<>$size<>$msg<>\n");
			splice(@list,$setting{'timecount'});
		}
		seek(TC,0,0);
		print TC @list;
		truncate(TC,tell(TC));
		close (TC);
		return($err,$result);
	} else {
		open(TC,"> ../$bbs/ifo/timecount.cgi") or return(904,'can not open timecount.cgi');
		flock(TC,2);
		print TC "$remote_addr<>$c_ip<>$id<>$time<>0<>$act<>$size<>$msg<>\n";
		close (TC);
		if ($ifo{'perm_file'}) {chmod(oct($ifo{'perm_file'}),"../$bbs/ifo/timecount.cgi");}
		return(0,0);
	}
}

sub change{		#スクリプト内の日本語を、表示する文字コードに変換
	my $text = shift;
	if ($call ne 'b.cgi') {return(enc_str($text));}
	return(enc_sjis($text));
}

sub change_code{	#POST受信した文字を格納するコードに変換
	if ($call eq 'b.cgi' || $agent =~ /Emanon/) {
		$subject = sjis_val($subject);
		$name = sjis_val($name);
		$mail = sjis_val($mail);
		$message = sjis_val($message);
		$submit = sjis_val($submit);
	}
	$name = trim($name);
	$name =~ s/\n|\r//g;
	$mail = trim($mail);
	$mail =~ s/\n|\r//g;
	$subject = trim($subject);
	$subject =~ s/\n|\r//g;
	$message = rtrim($message);
	$submit = trim($submit);
}

sub get_nanja {
	my $nanja = $mobile_id;
	if (index($nanja,'non_') >= 0 || index($nanja,',Monazilla') >= 0) {$nanja = $remote_addr;}
	$nanja .= substr($ifo{'twenty'},5,8);
	$nanja = long_trip($nanja);
	html_spchar(\$nanja);
	return ($nanja);
}

sub get_cookie {
	my $addr = shift . '/' . shift;
	my $mona = shift;
	my $cookie = $cgi->cookie('HIHUMI');
	unless($cookie) {return('');}
	my ($adr,$data) = split(' ',$cookie);
	if ($adr ne $addr) {
		if ($mona) {
			$data = -1;
		} else {	
			$adr =~ s/(^.+?)\///;
			my $domain = $1;
			write_cookie('NAME','',-1,$domain,$adr);
			write_cookie('MAIL','',-1,$domain,$adr);
			write_cookie($ifo{'c_name'},$ifo{'c_val'},-1,$domain,$adr);
			write_cookie('PON',$remote_host,-1,$domain,$adr);
			write_cookie('KAN',$remote_addr,-1,$domain,$adr);
			write_cookie('HIHUMI',$cookie,-1,$domain,$adr);
		}
	}
	return($data);
}

sub get_enigma {
	my $hihumi = shift;
	my $enigma = shift;
	my $mobile = shift;
	if ($enigma < 0) {return('',0,0);}
	unless ($enigma) {return('',0,0);}
	my $c_id = '';
	my $n = length($enigma);
	my $size = int($n / 2);
	$enigma = substr($enigma,$size * -1) . substr($enigma,0,$n - $size);
	$n = keys %$hihumi;
	unless($mobile) {
		$size = $$hihumi{substr($enigma,0,1)};
		if ($size eq '') {return('',0,0);}
		$enigma = substr($enigma,1);
		my $tmp = substr($enigma,0,$size);
		if ($size != length($tmp)) {return('',0,0);}
		my @list = split('',$tmp);
		my $check = 0;
		my $dig = $$hihumi{pop(@list)};
		foreach my $data (@list) {$check += $$hihumi{$data};}
		@list = ();
		if (($check % $n) != $dig)  {return('',0,0);}
		$c_id = $tmp;
		$enigma = substr($enigma,$size);
	}
	$size = $$hihumi{substr($enigma,0,1)};
	if ($size eq '') {return('',0,0);}
	$enigma = substr($enigma,1);
	$size++;
	if (length($enigma) != $size) {return('',0,0);}
	my @num = split('',$enigma);
	my $dig = 0;
	my $mul;
	my $l_time = 0;
	my $check = $$hihumi{pop(@num)};
	if ($check eq '') {return('',0,0);}
	my $c_level = $$hihumi{pop(@num)};
	if ($c_level eq '') {return('',0,0);}
	foreach my $data (@num) {
		$mul = $$hihumi{$data};
		if ($mul eq '') {return('',0,0);}
		$dig += $mul;
		$l_time = $l_time * $n + $mul;
	}
	if ($check != ($dig % $n)) {return('',0,0);}
	return($c_id,$l_time,$c_level);
}

sub encode_cookie {
	my $hihumi = shift;
	my $c_id = shift;
	my $l_time = shift;
	my $c_level = shift;
	if (($time - $l_time) >= 82800 && $cap eq '') {
		$c_level++;
		$l_time = $time;
		if ($c_level > $ifo{'max_level'}) {$c_level = $ifo{'max_level'};}
	}
	my $tmp = '';
	if ($c_id) {$tmp .= $$hihumi[length($c_id)] . $c_id;}
	$tmp .= encode_hihumi($hihumi,$l_time,$c_level);
	$c_id = length($tmp);
	$l_time = int($c_id /2);
	$tmp = substr($tmp,$l_time - $c_id) . substr($tmp,0,$l_time);
	return($c_level,$tmp);
}

sub encode_hihumi {
	my $hihumi = shift;
	my $num = shift;
	my $count = shift;
	my $n = @$hihumi;
	my $ret = '';
	my $dig = 0;
	my $mod;
	while($num) {
		$mod = $num % $n;
		$ret = $$hihumi[$mod] . $ret;
		$num = int($num / $n);
		$dig += $mod;
	}
	if (length($ret) >= ($n -2)) {$ret = substr($ret,($n -2 ) * -1);}
	$ret .= $$hihumi[$count];
	$ret .= $$hihumi[$dig % $n];
	$ret = $$hihumi[length($ret) - 1] . $ret;
	return($ret);
}

sub add_id {
	my $hihumi = shift;
	my $yoimu = shift;
	my $fname = '../ifo/hihumi.cgi';
	my $n = @$hihumi;
	my $id = $$hihumi[3].$$hihumi[2].$$hihumi[1].$$hihumi[$ifo{'server'}].$$hihumi[(6 + $ifo{'server'}) % $n];
	my $flg = 0;
	if (-e $fname) {
		open(FN,"+<$fname") or error_exit(904);
		flock(FN,2);
		my $tmp = <FN>;
		$tmp = trim($tmp);
		seek(FN,0,0);
		if ($tmp) {$id = inc_id($hihumi,$yoimu,$tmp);}
	} else {
		open (FN,">$fname") or error_exit(904);
		flock(FN,2);
		$flg = 1;
	}
	print FN "$id\n";
	close(FN);
	if ($ifo{'perm_file'} && $flg) {chmod(oct($ifo{'perm_file'}),$fname);}
	return($id);
}

sub inc_id {
	my $hihumi = shift;
	my $yoimu = shift;
	my @num = split('',shift);
	my $n = @$hihumi;
	my $ov = 1;
	my $ret = '';
	my $char;
	pop(@num);
	my $c_server = pop(@num);
	$c_server = $$hihumi[$ifo{'server'}];
	my $dig = $ifo{'server'};
	while (($char = pop(@num)) ne '') {
		$char = $$yoimu{$char} + $ov;
		$dig += $char;
		$ov = int($char / $n);
		$char = $$hihumi[$char % $n];
		$ret = $char . $ret;
	}
	$ret = ($ov ? $$hihumi[$ov] : '') . $ret . $c_server . $$hihumi[($dig + $ov) % $n];
	return($ret);
}

sub check_img {
	my $fname = shift;
	my $type;
	if ($setting{'IMG_MODE'} ne 'checked') {return(0);}
	if ($fname eq '') {return(0);}
	$type = rindex($fname,'.');
	if ($type < 1) {error_exit(503);}
	$type = lc substr($fname,$type + 1);
	if ($type eq 'jpeg') {return('jpg');}
	if ($ifo{'img_lib'} == 0 && $type ne 'gif' && $type ne 'jpg') {error_exit(504);}
	unless ($ifo{'img_lib'}) {return($type);}
	if (index($img_support,".$type.") < 0) {error_exit(504);}
	return ($type);
}

sub check_trip {	#端末やサーバー規制を受けないトリップか？
	if ($trip || $nanja) {
		my $text = read_file("../$bbs/ifo/through.cgi");
	} else {
		return(1);
	}
	if ($trip && index($text,$trip) >= 0) {return (0);}
	if ($nanja && index($text,$nanja) >= 0) {return (0);}
	$text = read_file("../ifo/through.cgi");
	if ($trip && index($text,$trip) >= 0) {return (0);}
	if ($nanja && index($text,$nanja) >= 0) {return (0);}
	return (1);
}

sub check_size {	#名前、メール、本文の長さチェック
	if (length($subject) > $setting{'SUBJECT_COUNT'}) {error_exit(608);}
	if (length($name) > $setting{'NAME_COUNT'}) {error_exit(609);}
	if (length($mail) > $setting{'MAIL_COUNT'}) {error_exit(610);}
	if (length($message) > $setting{'MESSAGE_COUNT'}) {error_exit(611);}
}

sub check_kisei {
	my $fname = shift;
	my $tripcap = shift;
	my @list = read_tbl($fname);
	my $result = 0;
	my $err = 0;
	foreach my $tmp (@list) {
		($err,$result) = check_ng($tmp,$tripcap);
		if ($result) {return ($err,$result);}
	}
	return (0,0);
}

sub check_ng {
	my $line = trim(shift);
	my $tripcap = shift;
	my $err = 0;
	my $result = 0;
	$line =~ s/( and | not )/<>$1<>/ig;
	my @list = split('<> ',$line);
	my $word = shift(@list);
	my $reg = $word =~ s/<>reg:/<>/i;
	foreach my $tmp (@list) {	#除外設定チェック
		my ($kind,$ngset) = split(' <>',$tmp);
		my $flg =check_word($ngset,$reg);
		if ($flg && $kind =~ /not/i) {return (0,0);}
		if (!$flg && $kind =~ /and/i) {return (0,0);}
	}
	if ($word =~ s/^rw<>//) {	#リライトワード
		my $type = 0;
		($word,$type) = word_type($word);
		my ($tmp1,$tmp2) = split(' = ',"$word ");
		@from = split(' or ',trim($tmp1));
		@to = split(' or ',trim($tmp2));
		my $count = @to;
		foreach my $tmp (@from) {
			unless ($tmp) {next;}
			my $rewrite = $to[int(rand($count))];
			$rewrite =~ s/!ipaddress/$remote_addr/g;
			$rewrite =~ s/!remotehost/$remote_host/g;
			if ($rewrite =~ /!useragent/) {
				my $tmp = $agent;
				if ($mobile_id =~ /^sb/) {$tmp =~ s/\/SN[A-Za-z0-9]+//;}
				$rewrite =~ s/!useragent/$tmp/g;
			}
			$rewrite =~ s/!level/$level/g;
			if ($rewrite =~ /!Level/){
				my $lv = $level;
				if ($setting{'THREAD_MAKE'} && $setting{'THREAD_MAKE'} =~ /^\d+$/ 
					&& $level >= $setting{'THREAD_MAKE'}) {$lv .= 't';}
				if ($level >= $ifo{'res_level'}) {$lv .= ',R';}
				if ($level >= $ifo{'thread_level'}) {$lv .= 'T';}
				if ($level >= $ifo{'max_level'}) {$lv .= 'M';}
				$rewrite =~ s/!Level/$lv/g;
			}
			if ($rewrite =~ /!termTrip/) {
				my $trtrip = get_nanja();
				html_spchar(\$trtrip);
				$trtrip = enc_str('◆').$trtrip;
				$rewrite =~ s/!termTrip/$trtrip/g;
			}
			if ($rewrite =~ /!rnd/) {
				my @random = split('!rnd',$rewrite);
				foreach my $rnd (@random) {
					$rnd =~ /(^\d+)/;
					my $num = $1;
					if ($num) {
						my $ransu = int(rand($num));
						$rnd =~ s/^\d+/$ransu/;
					}
				}
				$rewrite = join('',@random);
			}
			if ($type & 1) {replace(\$subject,$tmp,$rewrite,$reg)}
			if ($type & 2) {replace(\$name,$tmp,$rewrite,$reg);}
			if ($type & 4) {replace(\$mail,$tmp,$rewrite,$reg);}
			if ($type & 8) {replace(\$message,$tmp,$rewrite,$reg);}
			if ($type & 16) {replace(\$info,$tmp,$rewrite,$reg);}
		}
		return(0,0);
	}
	if ($word =~ s/^wd<>//) {	#ＮＧワード
		my $type = 0;
		($word,$type) = word_type($word);
		if ($type & 1 && ($result = check_ngword($word,\$subject,$reg))) {return(801,"subject=$result");}
		if ($type & 2 && ($result = check_ngword($word,\$name,$reg))) {return(801,"name=$result");}
		if ($type & 4 && ($result = check_ngword($word,\$mail,$reg))) {return(801,"mail=$result");}
		if ($type & 8 && ($result = check_ngword($word,\$message,$reg))) {return(801,"message=$result");}
		return(0,0);
	}
	my $cflg = 0;
	if($word =~ s/^th<>//) {	#スレ立て禁止ＩＰＩＤ
		if ($act || $tripcap) {return (0,0);}
		unless ($result = check_word("ip=$word",$reg)) {return (0,0);}
		unless ($result = check_word("id=$word",$reg)) {return (0,0);}
		$result = "make_thread_$result";
		$err = 806;
	} elsif($word =~ s/^ip<>//) {	#ＩＰまたはＩＤ
		if ($tripcap) {return (0,0);}
		$result = check_word("id=$word",$reg);
		if ($result) {
			$cflg = 1;
		} else  {
			($result,$cflg) = check_word("ip=$word",$reg);
		}
		unless ($result) {return (0,0);}
		if ($cflg && $ifo{'ht_use'} && $ifo{'ht_mode'} & 512) {$er_flg = 1;}
		$err = 805;
	} elsif($word =~ s/^rh<>//) {	#リモートホスト
		if ($tripcap) {return (0,0);}
		($result,$cflg) = check_word("rh=$word",$reg);
		unless ($result) {return (0,0);}
		if ($cflg && $ifo{'ht_use'} && $ifo{'ht_mode'} & 256) {$er_flg = 1;}
		$err = 803;
	} elsif($word =~ s/^ua<>//) {	#ユーザーエージェント
		if ($tripcap) {return (0,0);}
		unless ($result = check_word("ua=$word",$reg)) {return (0,0)}
		$err = 807;
	} elsif($word =~ s/^bl<>//) {	#外部サイト規制
		if ($tripcap) {return (0,0);}
		unless (check_proxy($word)) {return (0,0);}
		if ($ifo{'ht_use'} && $ifo{'ht_mode'} & 64) {$er_flg = 1;}
		$err = 802;
	} else {
		return (0,0);
	}
	return ($err,$result);
}

sub word_type {
	my $line = shift;
	my $ret = 0;
	if ($line =~ s/title=//i) {$ret += 1;}
	if ($line =~ s/name=//i) {$ret += 2;}
	if ($line =~ s/mail=//i) {$ret += 4;}
	if ($line =~ s/mess=//i) {$ret += 8;}
	if ($line =~ s/all=//i) {$ret = 15;}
	unless ($ret) {$ret = 8;}
	if ($act) {$ret = $ret & 14;}
	if ($line =~ s/info=//i) {$ret += 16;}
	return ($line,$ret);
}

sub check_ngword {
	my $word = shift;
	my $contents = shift;
	my $reg = shift;
	if ($reg) {
		my $ret = eval('$$contents =~ /$word/');
		if (eval('$$contents =~ /$word/')) {return $word;}
		return 0;
	} elsif (index($$contents,$word) >= 0) {
		return $word;
	}
	return 0;
}

sub check_word {
	my $line = shift;
	my $reg = shift;
	my $src = '';
	if ($line =~ s/^rh=//i) {
		if (check_ngword($line,\$remote_host,$reg)) {return ($line,1);}
		$src = $c_host;
	} elsif ($line =~ s/^ua=//i) {
		$src = $agent;
	} elsif ($line =~ s/^info=//i) {
		$src = $info;
	} elsif ($line =~ s/^board=//i) {
		$src = $bbs;
	} elsif ($line =~ s/^title=//i) {
		$src = $subject;
	} elsif ($line =~ s/^name=//i) {
		$src = $name;
	} elsif ($line =~ s/^mail=//i) {
		$src = $mail;
	} elsif ($line =~ s/^mess=//i) {
		$src = $message;
	} elsif ($line =~ s/^level=(\d+)//i) {
		return ($level == $1);
	} elsif ($line =~ s/^level>=\s*(\d+)//i) {
		return ($level >= $1);
	} elsif ($line =~ s/^level<=\s*(\d+)//i) {
		return ($level <= $1);
	} elsif ($line =~ s/^level!=\s*(\d+)//i) {
		return ($level != $1);
	} elsif ($line =~ s/^level>\s*(\d+)//i) {
		return ($level > $1);
	} elsif ($line =~ s/^level<\s*(\d+)//i) {
		return ($level < $1);
	} elsif($line =~ s/^id=//i) {
		if ($reg && index($line,',') !=0) {
			$line = ",$line";
			$src = ",$mobile_id";
		} else {
			$src = $mobile_id;
		}
	} elsif ($line =~ s/^ip=//i) {
		if ($line =~ /^\d+\.\d+\.\d+\.\d+\/\d+/) {
			my ($ip , $mask) = split('/',$line);
			if (mask_ip($ip,$mask) eq mask_ip($remote_addr,$mask)) {return ($line,1);}
			if (mask_ip($ip,$mask) eq mask_ip($c_ip,$mask)) {return $line;}
			return 0;
		} elsif ($line =~ /^[0-9a-fA-F]+$/) {
			my $iphex = ip_hex($remote_addr);
			if (index($iphex,$line) == 0) {return ($line,1);}
			$iphex = ip_hex($c_ip);
			if (index($iphex,$line) == 0) {return $line;}
			return 0;
		} else {
			if (check_ngword($line,\$remote_addr,$reg)) {return ($line,1);}
			$src = $c_ip;
		}
	}
	if ($src && check_ngword($line,\$src,$reg)) {return $line;}
	return 0;
}

sub replace {
	my $string = shift;
	my $check = shift;
	my $word = shift;
	my $reg = shift;
	if ($reg) {
		unless (eval('$$string =~ /$check/')) {return 0;}
		$$string =~ s/$check/$word/g;
	} else {
		my $ln = length($check);
		my $point = index($$string,$check);
		my $wl = length($word);
		while ($point >= 0) {
			substr($$string,$point,$ln,$word);
			$point = index($$string,$check,$point + $wl);
		}
	}
	return 0;
}

sub mask_ip {
	my $ip = shift;
	my $mask = shift;
	$ip = pack("C4",split(/\./,$ip));
	$mask = pack("N",oct('0b' . '1' x $mask . '0' x (32 - $mask)));
	return ($ip & $mask);
}

sub check_referer {
	if ($ifo{'referer'} == 0) {return(0)};
	my $page = get_top();
	if (index($ENV{'HTTP_REFERER'},$page) != 0) {
		if ($remote_host =~ /.+docomo\.ne\.jp$/) {return(0);}
		save_ng('referer',$ENV{'HTTP_REFERER'},'../ifo/nglog.cgi');
		return(1);
	}
	return(0);	
}

sub check_proxy {
	my $DNSBL_host = shift;
	$remote_addr =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/;
	my $query_addr = "$4.$3.$2.$1.$DNSBL_host";
	my $result = join('.', unpack('C*', gethostbyname($query_addr)));
	if ($result =~ /^127\.0\.0\./){return(1);}
	return(0);
}

sub error_exit {
	my $code = shift;
	my $spot = shift;
	my $charout = ($call ne 'b.cgi' && $call ne 'm.cgi' && $call ne 'r.cgi' ? $ifo{'outchr'} : 'shift_jis');
	my $text = '';
	my $msg = '';
	if (open(ERR,'<./sub/error.cgi')) {
		while(<ERR>) {
			my ($ercode,$erlog,$ermsg) = split('<>',$_);
			if ($code eq $ercode) {
				$msg = $ermsg;
				$text = $erlog;
				last;
			}
		}
	}
	unless ($msg) {
		$msg = "$code error";
		$text = $msg;
	}
	if ($text) {
		Encode::from_to($text,'utf-8',$charout);
		if ($ifo{'err_log'}) {
			if ($er_flg) {
				save_ng(enc_str("【アクセス規制】") . $text,$spot,'../ifo/nglog.cgi');
			} else {
				save_ng($text,$spot,'../ifo/nglog.cgi');
			}
		}
		if ($setting{'ERROR_LOG'} eq 'checked') {
			save_ng($text,$spot,"../$bbs/ifo/nglog.cgi");
		}
	}
	if ($spot && $spot =~ /^\d+$/) {$msg =~ s/!num/$spot/;}
	Encode::from_to($msg,'utf-8',$ifo{'outchr'});
	print "Content-type: text/html\n\n";
	print '<html>';
	print '<head>';
	print '<meta http-equiv="Content-Type" content="text/html; charset=',$charout,'">';
	print '<title>',encode($charout,'ＥＲＲＯＲ！'),'</title>';
	print '<body>';
	print "<br>$msg";
	if ($er_flg) {print enc_str("<br>アクセスを規制します\n");}
	print '</body></html>';
	if ($er_flg) {
		open(HT,'>> ../.htaccess') or exit(0);
		flock(HT,2);
		print HT "deny from $remote_addr\n";
		close(HT);
		open(HT,'>> ../ifo/deny.cgi') or exit(0);
		flock(HT,2);
		print HT "$remote_addr<>$remote_host<>$text $spot\n";
		close(HT);
	}
	exit(0);
}

sub save_ng {
	my $error = shift;
	my $fname = shift;
	my $outfile = shift;
	my $iphex = ip_hex($remote_addr);
	my $fflg = 0;
	unless (-e $outfile) {$fflg = 1;}
	if (open(NG,">> $outfile")) {
		flock(NG,2);
		print NG "$info_er\n";
		print NG "error=$error $fname\n";
		print NG "method=$ENV{'REQUEST_METHOD'}\n";
		$name = $name . $trip;
		if ($bbs) {print NG "board=$bbs\n";}
		if ($subject) {print NG "thread title=$subject\n";}
		if ($key) {print NG "threadID=$key\n";}
		print NG "submit=$submit\n";
		if ($name) {print NG "name=$name ";}
		if ($mail) {print NG "mail=$mail";}
		if ($name or $mail) {print NG "\n";}
		print NG "ID=$mobile_id remote_address=$iphex=$remote_addr\n";
		print NG "remote_host=$remote_host\n";
		if ($proxy) {print NG "$proxy\n";}
		print NG "referer=$referer\n";
		print NG 'agent=',$agent,"\nmessage:\n";
		print NG $message,"\n\n";
		close(NG);
		if ($fflg && $ifo{'perm_file'}) {chmod(oct($ifo{'perm_file'}),$outfile);}
	}
}

sub ip_hex {
	my $ip = shift;
	$ip =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)/;
	my $ret = sprintf("%02x%02x%02x%02x",$1,$2,$3,$4);
	return ($ret eq '00000000' ? $ip : $ret);
}
1;

use utf8;
#use Digest::SHA qw(sha1_base64);
use Digest::SHA1 qw(sha1_base64);

sub get_datetime {
	my $t = $time;
	my $msec = ' ';
	if ($ifo{'sec'}) {$msec = '.'.substr(substr('a000000'.$micro,-6),0,$ifo{'sec'}).' ';}
	$t += $ifo{'time'} + 32400;
	my @youbi = ('日', '月', '火', '水', '木', '金', '土');
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($t);
	$year += 1900;
	$mon += 1;
	my $ret = sprintf("%04d/%02d/%02d(",$year,$mon,$mday);
	$ret .= enc_str($youbi[$wday]);
	$ret .= sprintf(") %02d:%02d:%02d",$hour,$min,$sec).$msec;
	return($ret);
}

sub get_date {
	my $t = time;
	my $msec;
	$t += $ifo{'time'} + 32400;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($t);
	$mon += 1;
	$year %= 100;
	my $ret = sprintf("%02d/%02d/%02d",$year,$mon,$mday);
	return($ret);
}

sub get_id {
	if ($capid) {return('ID:'.$capid);}
	my $id;
	my $word = ip_hex($remote_addr);
	if (index($mobile_id,'pc') == 0) {
		$id = '0';
		if ($agent =~ /mobile|iphone|ipod|ipad|android|windows.*phone|2chmate|bb2c/i) {$id = 's';}
		if ($remote_host =~ /\.panda-world\.ne\.jp$|\.au-net\.ne\.jp$|\.spmode\.ne\.jp$|\.openmobile\.ne\.jp$/) {$id = 's';}
		if (index($mobile_id,'pcx') == 0) {$id = 1;}
		if (index($mobile_id,'pcx0.0.0.0') == 0) {$id = 2;}
		if (index($mobile_id,'pcp') == 0) {$id = 3;}
		if ($remote_host eq 'noname_host') {$id = 4;}
		if ($remote_host =~ /p2\.2ch\.net/) {$id = 'P';}
		if ($remote_host =~ /\.au-net\.ne.jp$/ && $level) {$word = $mobile_id;}
	} elsif (index($mobile_id,'non_id') == 0) {
		$id = 'R';
		$word = 'MB'.substr($word,0,6);
	} else {
		$id = 'O';
		if ($remote_host =~ /p2\.2ch\.net/) {$id = 'P';}
		$word = $mobile_id;
	}
	if ($setting{'SLIP'} ne 'checked') {$id = '';}
	if ($setting{'DISP_IP'} eq 'checked') {$id = '('.$remote_addr.') '.$id;}
	if ($setting{'DISP_HOST'} eq 'checked') {$id = $remote_host.' '.$id;}
	if (length($id) <= 1) {
		my $mod;
		my $tmp = '';
		my $t = int(($time + $ifo{'time'} + 32400) / 86400);
		my $n = length($ifo{'twenty'});
		while ($t) {
			$mod = $t % $n;
			$tmp = substr($ifo{'twenty'},$mod,1) . $tmp;
			$t = int($t / $n);
		}
		$word = sha1_base64($tmp . $word);
		$id = substr($word,10,8) . $id;
	}
	return('ID:'.$id);
}

sub check_title {
	my $board = shift;
	my $sbj_name = shift;
	my $result = 0;
	open(SB,"< ../$board/subject.txt") or return 0;
	while (<SB>) {
		my ($dat,$title) = split('.dat<>',$_);
		$title =~ s/\(\d+?\)\s*?$//;
		$title = trim($title);
		if ($sbj_name eq $title) {
			$result = 1;
			last;
		}
	}
	close(SB);
	return $result;
}

sub make_trip {		#トリップの作成
	$trip = index($name,'#');
	if ($trip < 0) {
		$trip = '';
	} else {
		my $tripkey = substr($name,$trip + 1);
		$name = substr($name,0,$trip);
		$tripkey = val_sjis($tripkey);
		if (length($tripkey) < 12) {
			my $salt = substr($tripkey.'H.', 1, 2);
			$salt =~ tr/:;<=>?\@[\\]^_`/ABCDEFGabcdef/;
			$salt =~ s/[^\.\/0-9A-Za-z]/\./g;
			$trip = substr(crypt($tripkey, $salt), -10);
		} else {
			$trip = long_trip($tripkey);
		}
	}
	my $dia1=enc_str('◆');
	my $dia2=enc_str('◇');
	my $star1 = enc_str('★');
	my $star2 = enc_str('☆');
	$name =~ s/$dia1/$dia2/g;
	$name =~ s/$star1/$star2/g;
}

sub long_trip {
	my $tripkey = shift;
	my $ret;
	my $mark = substr($tripkey, 0, 1);
	if ($mark eq '#' || $mark eq '$') {
		if ($tripkey =~ m|^#([[:xdigit:]]{16})([./0-9A-Za-z]{0,2})$|) {
			$ret = substr(crypt(pack('H*', $1), "$2.."), -10);
		} else {
			$ret = '???';
		}
	} else {
		$ret = substr(sha1_base64($tripkey), 0, 12);
		$ret =~ tr/+/./;
	}
	return ($ret);
}

sub make_cap {
	$cap = '';
	if ($setting{'READONLY'} eq 'checked') {return;}
	if (($setting{'READONLY'} eq 'caps' || $setting{'READONLY'} eq 'trip')
		&& $setting{'MOBILE_CAP'} eq 'checked' && index($mail,'#') < 0
		&& index($mobile_id,'pc') !=0) {$mail .= '#'.$mobile_id;}
	$cap = index($mail,'#');
	if ($cap < 0) {
		$cap = '';
		return;
	} else {
		my $capkey = substr($mail,$cap + 1);
		$mail = substr($mail,0,$cap);
		$cap = '';
		get_cap($capkey,"../$bbs/ifo/cap.cgi");
		unless($cap) {get_cap($capkey,"../ifo/cap.cgi");}
	}
}

sub get_cap {
	my $fname = shift;
	my $capkey = shift;
	my @caplist = read_tbl($fname);
	foreach $capdata(@caplist) {
		my ($word,$str,$idstr) = split(/<>/,$capdata);
		if ($word eq $capkey) {
			$cap = trim($str);
			$capid = trim($idstr);
			last;
		}
	}
}

sub html_spchar {	#&と'の変換はしない
	my $text = shift;
	$$text =~ s/"/&quot;/g;	#"の変換
	$$text =~ s/</&lt;/g;	#<の変換
	$$text =~ s/>/&gt;/g;	#>の変換
	$$text =~ s/\n|\r\n|\r/<br>/g;	#改行の変換
}

sub ent_clr {
	my $text = shift;
	$$text =~ s/\n|\r//g;
}

1;

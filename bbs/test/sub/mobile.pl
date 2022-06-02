use utf8;

sub put_mobile {
	if ($ifo{'maintenance'}) {return(0);}
	if (-e "$dir/$bbs/m/index.html") {
		open(WR,"+<$dir/$bbs/m/index.html") or return(1);
	} else {
		open(WR,">$dir/$bbs/m/index.html") or return(1);
	}
	flock(WR, 2);
	seek(WR, 0, 0);
	print WR get_page(1,0,'','','');
	truncate(WR,tell(WR));
	close(WR);
	return(0);
}

sub get_page {
	my $dat = $key;
	my $num = shift;	#開始スレタイ番号
	my $copy = shift;	#コピペモード=1 通常=0
	my $hit = shift;	#検索にヒットした件数
	my $dir1 = shift;	#m.cgiからなら'../'
	my $dir2 = '';
	my $kako = shift;	#過去ログ倉庫ならk
	my $kkm = '過';
	unless ($ifo{'max_kako'} && count_kako($bbs)) {
		$kkm = '';
		$kako = '';
	}
	my $board = $bbs;
	if ($kako) {
		$board .= '_kako';
		$kkm = '現';
	}
	my $cp = 'c';		#コピペモード用
	my $cpm = '写';		#コピペモード用
	if ($dir1 eq '') {$dir2 = "../../test/m.cgi/$bbs/";}
	$mburl = get_top();
	my $text .= '<html><head>';

	#headerタグ
	open(FH, "$dir/$bbs/header.txt");
		while ($header = <FH>) {
		$text .= "$header\n";
		}
	close(FH);

	$text .= '<meta http-equiv="Content-Type" content="text/html; charset=shift_jis">';
	$text .= '<title>';
	$text .= val_sjis($setting{'TITLE'});
	if ($kako ne '') {$text .= enc_sjis('過去ログ');}
	$text .= '</title><body><a name=u></a>';
	my $banner = rtrim(read_file("../$bbs/m/banner1.txt"));
	if ($banner ne '') {
		$banner = val_sjis($banner).'<hr>';
		$text .= $banner;
	}
	$text .= '<form action='.$dir2.$kako.'p method=POST>';
	$text .= '<input type=txt name=w size=11>';
	$text .= enc_sjis('<input type=submit value=索> <a href=#b accesskey=8>下</a></form>');
	if ($copy) {
		$text .= '<form action=a><textarea cols=60 rows=3>';
		$text .= val_sjis($setting{'TITLE'});
		if ($kako ne '') {
			$text .= enc_sjis('過去ログ');
			$text .= "\n$mburl/test/kako.cgi/$bbs/</textarea>";
		} else {
			$text .= "\n$mburl$bbs/</textarea>";
		}
		$cp='';
		$cpm='通';
	} else {
		$text .= val_sjis($setting{'TITLE'});
		if ($kako ne '') {$text .= enc_sjis('過去ログ');}
	}
	if ($dir1 eq '../') {
		$text .= "<a href=../../h.cgi/$bbs>";
	} else {
		$text .= "<a href=../../test/h.cgi/$bbs>";
	}
	$text .= enc_sjis('規</a><hr>');
	my $end = @sbj_txt;
	if ($end > $num + 29) {$end = $num + 29;}
	if ($hit ne '') {$end = @sbj_txt;}
	my $cnt = $num;
	while($cnt <= $end) {
		my ($key,$sbj,$word) = split(/\.dat<>/,$sbj_txt[$cnt - 1]);
		$sbj = val_sjis(substr($sbj,0,rindex($sbj,')')) . ')');
		if ($copy) {
			$text .= "<textarea cols=60 rows=3>$cnt:$sbj\n";
			$text .= $mburl . "test/read.cgi/$board/$key/</textarea><br>";
		} else {
			if ($word eq '') {
				my $tmp = ($kako ? '1-' : '');
				$text .= "$cnt:<a href=".$dir1."../../test/r.cgi/$board/$key/$tmp>$sbj</a><br>";
			}
		}
		$cnt++;
	}
	if ($hit ne '') {$text .= "$hit thread hit!<br>";}
	if ($copy) {$text .= '</form>';}
	$text .= '<hr><a name=b></a>';
	$banner = rtrim(read_file("$dir/$bbs/m/banner2.txt"));
	if ($banner ne '') {
		$banner = val_sjis($banner).'<br>';
		$text .= $banner;
	}
	$text .= enc_sjis('<a href=#u accesskey=2>上</a>');
	if ($num != 1 && $hit eq '') {$text .= '<a href='.$kako.($num - 30 < 1 ? 1 : $num - 30) . enc_sjis(' accesskey=7>前</a>');}
	if ($cnt <= @sbj_txt && $hit eq '') {$text .= '<a href='.$dir2.$kako.$cnt.enc_sjis(' accesskey=9>次</a>');}
	if ($num != 1 or $hit ne '') {$text .= enc_sjis('<a href='.$kako.'1 accesskey=3>新</a>');}
	unless ($kako) {
		$text .= '<a href='.$dir2.enc_sjis("w accesskey=4>立</a>");
	}
	if ($hit eq '') {$text .= '<a href='.$dir2.$kako.$num.enc_sjis("$cp accesskey=5>$cpm</a>");}
	if ($mburl eq $ifo{'site_top'}) {
		$text .= '<a href='.$dir1.enc_sjis("../../mobile.html accesskey=6>覧</a>");
	} else {
		$text .= '<a href='.$ifo{'site_top'}.enc_sjis("mobile.html accesskey=6>覧</a>");
	}
	if ($kkm) {
		$kako = ($kako ? '' : 'k');
		$text .= '<a href='.$dir2.$kako.$num.enc_sjis(" accesskey=0>$kkm</a>");
	}
	if ($setting{'MOBILE_LINK'} ne '' && $ifo{'site_top'} ne $setting{'MOBILE_LINK'} && get_top() ne $setting{'MOBILE_LINK'}) {
		$text .= enc_sjis("<a href=$setting{'MOBILE_LINK'}>主</a>");
	}
	$text .= '</body></html>';
	$key = $dat;
	return($text);
}

1;
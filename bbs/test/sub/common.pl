use utf8;
use CGI;
use Encode;

unless($dir) {$dir = '..';}

init_ifo();
get_ifo();

if ($ifo{'maintenance'} && $call ne 'owner') {
	require '../test/sub/mente.pl';
	show_mente();
	exit(0);
}

$url = $ENV{"SCRIPT_NAME"};
$script = 'Yakumo BBS Script';
$version = ' Ver 1.01g';
$copyright = 'Kobayashi Yukiharu';

if ($ifo{'img_lib'} == 0 && $ifo{'aa_mode'} eq 'AA') {$ifo{'aa_mode'} = 'AAS';}
if ($ifo{'img_lib'} == 0) {				#サポートする画像形式
	$img_support = '.gif.jpg.';
} elsif ($ifo{'img_lib'} == 1) {			#ImageMagick
	$img_support = '.gif.jpg.png.bmp.';
} else {						#GD
	$img_support = '.gif.jpg.png.';
}

sub init_ifo{
	$ifo{'outchr'} = 'shift_jis';
	$ifo{'site_top'} = 'http://';
	$ifo{'max_res'} = 1000;
	$ifo{'down_res'} = 1000;
	$ifo{'down_time'} = 24;
	$ifo{'comp'} = 0;
	$ifo{'comp_count'} = 1;
	$ifo{'max_dat_size'} = 1024;
	$ifo{'max_thread'} = 500;
	$ifo{'min_thread'} = 450;
	$ifo{'max_kako'} = 2000;
	$ifo{'images'} = '../images/';
	$ifo{'twenty'} = 'aSdQeMcgPfhijKLbNORT';
	$ifo{'time'} = 0;
	$ifo{'sec'} = 2;
	$ifo{'img_lib'} = '1';
	$ifo{'post_max'} = '207800';
	$ifo{'aa_mode'} = 'AA';
	$ifo{'aa_auto'} = 1;
	$ifo{'fontfile'} = '../ipagp-mona.ttf';
	$ifo{'bbskey'} = '';
	$ifo{'maintenance'} = 0;
	$ifo{'perm_dir'} = 0;
	$ifo{'perm_file'} = 0;
	$ifo{'bbslist'} = 0;
	$ifo{'jump'} = 1;
	$ifo{'next'} = 1;
	$ifo{'referer'} = 0;
	$ifo{'proxy'} = '';
	$ifo{'err_log'} = 1;
	$ifo{'ht_use'} = 0;
	$ifo{'ht_mode'} = 63;
}

sub write_ifo {
	my $text = '';
	foreach my $key (keys(%ifo)) {$text .= "$key=$ifo{$key}\n";}
	return(write_file("$dir/ifo/setting.cgi",\$text,1));
}

sub get_ifo {
	if (open(FN,"< $dir/ifo/setting.cgi")) {
		flock(FN,1);
		my $vname,$val;
		while (<FN>) {
			$_ = trim($_);
			($vname, $val) = split('=', $_);
			if ($vname ne '') {
				$vname = trim($vname);
				$ifo{$vname} = trim($val);
			}
		}
		close(FN);
		if ($ifo{'down_res'} > $ifo{'max_res'}) {$ifo{'down_res'} = $ifo{'max_res'};}
		if ($ifo{'min_thread'} > $ifo{'max_thread'}) {$ifo{'min_thread'} = $ifo{'max_thread'};}
	} else {
		unless (-d "$dir/ifo") {mkdir "$dir/ifo";}
		unless (-d "$dir/ifo/m") {mkdir "$dir/ifo/m";}
		unless (-d "$dir/ifo/s") {mkdir "$dir/ifo/s";}
		$ifo{'site_top'} = get_top();
		write_ifo();
	}
}

sub get_url {
	my $q = CGI->new();
	return ($q->url);
}

sub get_top {
	my $ret = get_url();
	my $str = ($call eq 'board' ? "/$bbs/" : '/test/');
	return(substr($ret,0,index($ret,$str) + 1));
}

sub url_encode {
	my $str = shift;
	$str =~ s/([^\w ])/'%'.unpack('H2', $1)/eg;
	$str =~ tr/ /+/;
	return $str;
}

sub write_cookie {
	my $c_name = shift;
	my $c_val = shift;
	my $c_day = shift;
	my $domain = shift;
	my $path = shift;
	unless ($domain) {$domain = $ifo{'domain'};};
	unless ($path) {$path = $ifo{'dir'};}
	unless ($path) {return(0);}
	unless ($domain) {$domain = get_domain();}
	if ($c_day < 0) {
		$c_day .= 'M';
	} elsif ($c_day > 0) {
		$c_day = '+'.$c_day.'M';
	} else {
		$c_day = '';
	}
	my $string = '';
	if ($c_day) {
		$string = $cgi->cookie(-name => $c_name,-value => $c_val,-domain => $domain,-path => $path,-expires => $c_day);
	} else {
		$string = $cgi->cookie(-name => $c_name,-value => $c_val,-domain => $domain,-path => $path);
	}
	print "Set-Cookie: $string\n";
}

sub get_domain {
	my $path = $cgi->url;
	$path =~ s/^.+?:\/\///;
	$path =~ s/(.+?)\///;
	my $domain = $1;
	return($domain);
}

sub trim {
	my $text = shift;
	my $sp = enc_str('　');
	$text =~ s/(\s|$sp)*$//;
	$text =~ s/^(\s|$sp)*//;
	return($text);
}

sub rtrim {
	my $text = shift;
	my $sp = enc_str('　');
	$text =~ s/(?:\s|$sp)*$//;
	return($text);
}

sub enc_str {
	my $text = shift;
	$text = encode($ifo{'outchr'},$text);
	return ($text);
}

sub enc_sjis {
	my $text = shift;
	$text = encode('shift_jis',$text);
	return ($text);
}

sub val_sjis {
	my $text = shift;
	if ($ifo{'outchr'} ne 'shift_jis') {
		Encode::from_to($text,$ifo{'outchr'},'shift_jis');
	}
	return ($text);
}

sub val_utf {
	my $text = shift;
	if ($ifo{'outchr'} ne 'utf-8') {
		Encode::from_to($text,$ifo{'outchr'},'utf-8');
	}
	return ($text);
}

sub sjis_val {
	my $text = shift;
	if ($ifo{'outchr'} ne 'shift_jis') {
		Encode::from_to($text,'cp932',$ifo{'outchr'});
	}
	return ($text);
}

sub dec_str {
	my $text = shift;
	$text = decode(($ifo{'outchr'} eq 'shift_jis' ? 'cp932' : $ifo{'outchr'}),$text);
	return ($text);
}

sub read_file {
	my $fname = shift;
	return (join('',read_tbl($fname)));
}

sub read_tbl {
	my $fname = shift;
	my @file;
	if (open(IN,"<$fname")) {
		flock(IN,1);
		@file = <IN>;
		close(IN);
	}
	return (@file);
}

sub write_file {
	my $fname = shift;
	my $text = shift;
	my $permission = shift;
	if (-e $fname) {
		open(FH,"+<$fname") or return(0);
		flock(FH,2);
		binmode(FH);
		seek(FH,0,0);
		print FH $$text;
		truncate(FH,tell(FH));
		close(FH);
	} else {
		open (FH,">$fname") or return(0);
		flock(FH,2);
		binmode(FH);
		print FH $$text;
		close(FH);
		if ($permission && $ifo{'perm_file'}) {
			chmod(oct($ifo{'perm_file'}),$fname);
		}
	}
	return(1);
}

sub delete_file {
	my $fname = shift;
	if (-e $fname) {
		return(unlink $fname);
	}
	return(1);
}

sub get_index{			#索引取得関数
	my $ptr = shift;
	my $board = shift;
	my $dat = shift;
	if ($board eq '') {$board = $bbs;}
	if ($dat eq '') {$dat = $key;}
	$ptr = ($ptr - 1) * 4;
	open(IDX,"< $dir/$board/idx/$dat.idx") or return(0);	#索引オープン
	flock(IDX,1);
	binmode(IDX);
	if (seek(IDX,$ptr,0)) {
		my $buf;
		read(IDX,$buf,4);
		close(IDX);
		return(unpack("l",$buf));
	} else {
		close(IDX);
		return(0);
	}
}

sub get_setting_txt {
	my $board = shift;
	my %setting = init_setting();
	%setting = read_setting('ifo',%setting);
	if ($board ne 'ifo') {
		%setting = read_setting($board,%setting);
	}
	if ($setting{'SUBTITLE'} eq '') {$setting{'SUBTITLE'} = $setting{'TITLE'};}
	if ($ifo{'max_thread'} > 0 && $setting{'MAX_THREAD'} > $ifo{'max_thread'}) {
		$setting{'MAX_THREAD'} = $ifo{'max_thread'};
	}
	if ($setting{'MIN_THREAD'} > $setting{'MAX_THREAD'}) {$setting{'MIN_THREAD'} = $setting{'MAX_THREAD'};}
	return(%setting);
}

sub init_setting {
	my %setting;
	$setting{'TITLE'} = enc_str('掲示板');
	$setting{'SUBTITLE'} = enc_str('掲示板')."@".enc_str($script);
	$setting{'TITLE_PICTURE'} = $ifo{'images'}.'bbs.gif';
	$setting{'TITLE_COLOR'} = '#000000';
	$setting{'TITLE_LINK'} = $ifo{'site_top'};
	$setting{'MOBILE_LINK'} = $ifo{'site_top'};
	$setting{'BG_COLOR'} = '#FFFFFF';
	$setting{'BG_PICTURE'} = $ifo{'images'}.'back.jpg';
	$setting{'NONAME_NAME'} = enc_str('名無しさん');
	$setting{'DELETE_NAME'} = enc_str('あぼーん');
	$setting{'MAKETHREAD_COLOR'} = '#CCFFCC';
	$setting{'MENU_COLOR'} = '#CCFFCC';
	$setting{'THREAD_COLOR'} = '#EFEFEF';
	$setting{'TEXT_COLOR'} = '#000000';
	$setting{'NAME_COLOR'} = '#008000';
	$setting{'LINK_COLOR'} = '#0000FF';
	$setting{'ALINK_COLOR'} = '#FF0000';
	$setting{'VLINK_COLOR'} = '#660099';
	$setting{'THREAD_NUMBER'} = 10;
	$setting{'CONTENTS_NUMBER'} = 15;
	$setting{'LINE_NUMBER'} = 16;
	$setting{'MAX_MENU_THREAD'} = 30;
	$setting{'SUBJECT_COLOR'} = '#FF0000';
	$setting{'SUBJECT_COUNT'} = 48;
	$setting{'NAME_COUNT'} = 64;
	$setting{'MAIL_COUNT'} = 64;
	$setting{'MESSAGE_COUNT'} = 2048;
	$setting{'MESSAGE_LINE'} = 0;
	$setting{'MAX_THREAD'} = 0;
	$setting{'MIN_THREAD'} = 0;
	$setting{'FORCE_ID'} = 'checked';
	$setting{'SLIP'} = 'checked';
	$setting{'PASSWORD_CHECK'} = 'checked';
	$setting{'IMG_THUMBNAIL_X'} = 120;
	$setting{'IMG_THUMBNAIL_Y'} = 120;
	$setting{'IMG_JPG_QLT'} = 70;
	$setting{'IMG_SMN_QLT'} = 30;
	return(%setting);
}

sub read_setting {
	my $board = shift;
	my %setting = @_;
	open(SET,"< $dir/$board/SETTING.TXT") or return(%setting);
	flock(SET,1);
	my $vname,$val;
	while (<SET>) {
		$_ = trim($_);
		($vname, $val) = split('=', $_);
		if ($vname ne '') {
			$vname =~ s/^BBS_//;
			$setting{$vname} = $val;
		}
	}
	close(SET);
	return(%setting);
}

sub count_kako {
	my $board = shift;
	my $count = trim(read_file("$dir/$board"."_kako/ifo/count.txt"));
	if ($count eq '') {
		my @list = read_tbl("$dir/$board"."_kako/subject.txt");
		$count = @list;
		write_file("$dir/$board"."_kako/ifo/count.txt",\$count);
	}
	return($count);
}

sub thread_mode {		#スレッドの書き込み可否を設定
	my $fname = shift;	#インデックスのファイル名
	my $mode = shift;	#0で書き込み禁止に、1で書き込み可に
	open(IDX,"+<$fname") or return (0);
	flock(IDX,2);
	binmode(IDX);
	seek(IDX,0,0);
	my $buf;
	read(IDX,$buf,4);
	my $num = abs(unpack("l",$buf));
	$num = ($mode ? $num : $num * -1);
	seek(IDX,0,0);
	$buf = pack("l",$num);
	print IDX $buf;
	close(IDX);
	return(1);
}
1;
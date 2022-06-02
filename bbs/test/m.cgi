#!/usr/bin/perl --

use utf8;
$call = 'm.cgi';
require './sub/common.pl';	#初期設定と共通サブルーチン
require './sub/mobile.pl';	#携帯用サブルーチン読み込み

cgi_main();
exit(0);

sub cgi_main {
	($opt,$bbs,$opt) = split( /\//, $ENV{'PATH_INFO'});	#引数の取得
	get_setting();		#SETTING.TXTの変数化
	my ($num) = $opt =~ /(\d+)/;
	if ($num eq '') {$num = 1;}
	my $board = $bbs;
	my $kako = '';
	if ($opt =~ /k/) {
		$board .= '_kako';
		$opt =~ s/k//g;
		$kako = 'k';
	}
	my $copy = 0;
	my $hit = '';
	open(SBJ,"< ../$board/subject.txt") or error_exit('<br>板が見つかりませんよ<br>');
	flock(SBJ,1);
	@sbj_txt = <SBJ>;		#配列へ読み込み
	close(SBJ);
	if ($opt eq 'w') {		#スレ立て
		show_write();		#フォーム表示
		exit(0);
	}
	if ($opt eq 'p') {		#post受信検索word
		my $q = CGI->new();
		my $word = $q->param('w');
		my $cnt;
		my $end = @sbj_txt;
		$hit = 0;
		if ($word ne '') {
			for ($cnt = 1;$cnt <= $end;$cnt++) {
				my $text = val_sjis($sbj_txt[$cnt - 1]);
				$text = substr($text,index($text,'.dat<>') + 6);
				$text = substr($text,0,rindex($text,'('));
				if(index($text,$word) < 0) {
					$sbj_txt[$cnt - 1] .= '.dat<>1';
				} else {
					$hit++;
				}
			}
		}
	} elsif ($opt =~ /\d+c/) 	{	#コピペモード
		$opt =~ s/c//g;
		$copy = 1;
	}
	if ($num > @sbj_txt) {$num = @sbj_txt - 29;}
	if ($num < 1) {$num = 1;}
	print "Content-type: text/html\n\n";
	print get_page($num,$copy,$hit,'../',$kako);
}

sub show_write {
	$cgi = CGI->new();
	my $c_name = $cgi->cookie('NAME');
	Encode::from_to($c_name,'utf-8','shift_jis');
	$c_name =~ s/"/&quot;/g;
	$c_name =~ s/\n|\r//g;
	my $c_mail = $cgi->cookie('MAIL');
	Encode::from_to($c_mail,'utf-8','shift_jis');
	$c_mail =~ s/"/&quot;/g;
	$c_mail =~ s/\n|\r//g;
	write_cookie($ifo{'c_name'},$ifo{'c_val'},0);
	if ($c_name) {$c_name = " value=\"$c_name\"";}
	if ($c_mail) {$c_mail = " value=\"$c_mail\"";}
	if ($setting{'IMG_MODE'}) {
		my $remote_host = gethostbyaddr(pack("C4",split(/\./,$ENV{'REMOTE_ADDR'})),2);
		if ($remote_host =~ /.+ezweb\.ne\.jp$/ && !$ENV{'HTTP_X_UP_DEVCAP_SELECTEDNETWORK'} 		#au
			&& $ENV{'HTTP_X_SELECTEDNETWORK'} eq '') {$setting{'IMG_MODE'}='';}
	}
	print "Content-type: text/html\n\n";
	print '<html><head>';

	#headerタグ
	open(FH, "$dir/$bbs/header.txt");
		while ($header = <FH>) {
		print "$header\n";
		}
	close(FH);

	#reCaptcha
	if($setting{'SITE_KEY'} ne '' && $setting{'SECRET_KEY'} ne ''){
	print '<script src="https://www.google.com/recaptcha/api.js"></script>';
	}
	#hCaptcha
	if($setting{'SITE_KEY'} ne '' && $setting{'H_SECRET_KEY'} ne ''){
	print '<script src="https://www.hCaptcha.com/1/api.js" async defer></script>';
	}
	print '<meta http-equiv="Content-Type" content="text/html; charset=shift_jis">';
	print '<title>',enc_sjis("スレ立て"),'</title></head><body>';
	print '<form method=POST action="../../b.cgi?guid=ON"'.($setting{'IMG_MODE'} eq 'checked' ? ' ENCTYPE="multipart/form-data">' : '>');
	print enc_sjis('題名<input name=subject size=14><br>');
	print enc_sjis('名前<input name=FROM size=14'),$c_name,'><br>';
	print ' mail<input name=mail size=14',$c_mail,'><br>';
	if ($setting{'IMG_MODE'}) {
		print enc_sjis('画像<input type =file name =file size=14><br>');
	}
		#サイトキー
		if($setting{'SITE_KEY'} ne '' && $setting{'SECRET_KEY'} ne ''){
		print '<div class="g-recaptcha" data-sitekey=';
		print "$setting{'SITE_KEY'}".'></div>';
		}
		if($setting{'SITE_KEY'} ne '' && $setting{'H_SECRET_KEY'} ne ''){
		print '<div class="h-captcha" data-sitekey=';
		print "$setting{'SITE_KEY'}".'></div>';
		}
	print '<textarea rows=5 cols=60 name=MESSAGE></textarea><br>';
	print enc_sjis('<input type=submit value=新規スレッド作成 name=submit>');
	print "<input type=hidden name=bbs value=$bbs>";
	my $time = time();
	print "<input type=hidden name=time value=$time>";
	print '</form>';
	print '</body></html>';
}

sub get_setting {
	my %set_txt = get_setting_txt($bbs);
	$setting{'TITLE'} = $set_txt{'TITLE'};
	$setting{'IMG_MODE'} = $set_txt{'IMG_MODE'};
	$setting{'MOBILE_LINK'} = $set_txt{'MOBILE_LINK'};

	#ここを設定しないと新しい設定が適用できない
	$setting{'SITE_KEY'} = $set_txt{'SITE_KEY'};
	$setting{'SECRET_KEY'} = $set_txt{'SECRET_KEY'};
	$setting{'H_SECRET_KEY'} = $set_txt{'H_SECRET_KEY'}
}

sub error_exit {
	my $text = shift;
	print "Content-type: text/html\n\n";
	print '<html>';
	print '<head>';
	print '<meta http-equiv="Content-Type" content="text/html; charset=shift_jis">';
	print '<title>',tchange('ＥＲＲＯＲ！'),'</title>';
	print '<body>';
	print '<br>',tchange($text),'<br>';
	print '</body></html>';
	exit(0);
}

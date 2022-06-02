#!/usr/bin/perl --

use utf8;
$call = 'r.cgi';
require './sub/common.pl';	#初期設定と共通サブルーチン

get_parm();
if ($img_mode) {
	if ($ifo{'img_lib'}) {
		require './sub/smn'.$ifo{'img_lib'}.'.pl';
	} else {
		require './sub/smn.pl';
	}
}
show_thread();
exit(0);

sub get_parm {
	$head = 1;		#header関数が呼ばれたら0
	$copy='';		#コピペモードなら'c'違ったら''
	$aa = '';		#AAモードなら'a'違ったら''
	$text_all = '';		#全文表示モードなら't'違ったら''
	($opt,$bbs,$key,$opt) = split( /\//, $ENV{'PATH_INFO'});	#引数の取得
	$board = $bbs;
	$cgi = new CGI;
	$ret = $cgi->param('re');
	if (index($board,'_kako') > 0) {$board = substr($bbs,0,index($bbs,'_kako'));}
	get_setting();		#SETTING.TXTの変数化
	if ($ifo{'aa_mode'} eq 'AAS') {
		$aa_path = get_url();
		$aa_path = substr($aa_path,index($aa_path,'://') + 3);
		$aa_path = substr($aa_path,0,index($aa_path,'/test/'));
		$aa_path =~ s/\//+/g;
		$aa_pic = "<img src=http://aas.ula.cc/image.cgi/-/$aa_path";
		$aa_path = "<a href=http://aas.ula.cc/u.cgi/$aa_path";
	} else {
		$aa_path = '<a href=../../../a.cgi';
		$aa_pic = '<img src=../../../aa.cgi';
	}
}

sub show_thread {
	my $max;
	if (!($max = get_index(1))) {	#索引から総レス数取得
		error_exit("ごめんなさい、索引が読めないので表示できないですよ");
	}
	my $mode = 1;
	if ($max < 0) {
		$mode = 0;
		$max = abs($max);
	}
	my $all = 0;
	my $first = 0;
	my ($start,$count);
	if ($opt =~ /w/) {		#書き込みモード
		if ($mode) {
			show_write();	#書き込みフォーム表示
			exit(0);
		} else {
			error_exit("このスレッドには書き込めません");
		}
	}
	if ($opt =~ s/c//g) {$copy = 'c';}	#cオプション
	if ($opt =~ s/a//g) {$aa = 'a';}	#aオプション
	if ($opt =~ s/t//g) {$text_all = 't';}	#tオプション
	if ($opt eq 'g') {		#GET受信処理
		$opt=$ENV{'QUERY_STRING'};
		($opt) = $opt =~ /([0-9]+)/g;
		$opt = $opt . '-';
	} elsif (index($opt,'l')>=0) {	#lオプション
		$opt = '';
		$first = 1;
	} elsif (index($opt,'n')>=0) {	#nオプション
		$opt = '';
	} elsif ($opt !~ /([0-9]+)/) {	#無効なオプション
		$opt = '';
		$first = 1;
	}
	if ($opt eq '') {
		$start = $max -9;
		if ($start <=1) {
			$start = 2;
			$first = 1;
		}
		$count = $max - $start + 1;
	} else {
		if (index($opt,'-') >=0) {				#-オプション
			($start,$count) = split(/-/,$opt);
			($start) = $start =~ /([0-9]+)/g;
			($count) = $count =~ /([0-9]+)/g;
			if ($start eq '') {				#-数字
				if ($count > $max) {$count = $max;}
				$start = $count - 9;
				if ($start < 1) {$start = 1;}
			} else {					#数字-か数字-数字
				if ($start > $max) {$start = $max;}
				if ($count eq '') {$count = $max;}
				if ($start > $count) {($start,$count) = ($count,$start);}
				if ($count > ($start + 9)) {$count = $start +9;}
				if ($count > $max) {$count = $max;}
			}
			$count = $count - $start + 1;
			if ($start == 1) {
				$first = 1;
				$start = 2;
				$count--;
			}
		} else {						#数字単体
			($start) = $opt =~ /([0-9]+)/g;
			if ($start > $max) {$start = $max;}
			if ($start == 1) {
				$start = 2;
				$first = 1;
				$count = 0;
			} else {
				$first = 0;
				$count = 1;
			}
			$all = 1;
		}
	}
	unless ($text_all) {$all = 1;}
	open(LOG,"< ../$bbs/dat/$key.dat") or error_exit('<br>いやですよー　そんなスレッド無いでしょー<br>');
#	flock(LOG,1);
	my ($name,$mail,$info,$message,$title) = split( /<>/,<LOG>) or (close(LOG) and error_exit("ファイルが壊れています"));
	$head = header($title);
	if ($first) {	#レス１表示
		view($all,1,\$name,\$mail,\$info,\$message);
	}
	if ($max != 1) {
		my $fpt = get_index($start) or (close(LOG) and error_exit("索引が壊れています"));
		seek(LOG,$fpt,0) or (close(LOG) and error_exit("索引が壊れています"));
	}
	my $cnt = $count;
	my $num = $start;
	while($cnt--) {					#レス２以降の表示
		($name,$mail,$info,$message) = split( /<>/,<LOG>) or (close(LOG) and error_exit("ファイルが壊れています"));
		view($all,$num,\$name,\$mail,\$info,\$message);
		$num++;
	}
	close(LOG);
	footer($mode,$start,$count,$max,$title);	#フッタ出力
}

sub get_setting {
	my %setting = get_setting_txt($board);
	@nonames = read_tbl("../$board/nonames.txt");
	unshift (@nonames,$setting{'NONAME_NAME'});
	$img_mode = ($setting{'IMG_MODE'} eq 'checked' ? 1 : 0);
	$img_x = $setting{'IMG_THUMBNAIL_X'};
	$img_y = $setting{'IMG_THUMBNAIL_Y'};
	$jump = $setting{'MOBILE_LINK'};

	#ここを設定しないと新設定が反映されない
	$site_key_if = ($setting{'SITE_KEY'} ne '' ? 1 : 0);
	$site_key = $setting{'SITE_KEY'};
	$secret_key = ($setting{'SECRET_KEY'} ne '' ? 1 : 0);
	$h_secret_key = ($setting{'H_SECRET_KEY'} ne '' ? 1 : 0);
}

sub view {
	my $all = shift;
	my $num = shift;
	my $name = shift;
	my $mail = shift;
	my $info = shift;
	my $message = shift;
	my $tm = 0;
	if (!$aa && $ifo{'aa_auto'}) {
		my $sp = enc_str('　');
		if (index($$message,"$sp ") >= 0 || index($$message," $sp") >= 0) {$tm = 1;}
	}
	$$name =~ s/ ?<\/?b>//g;		# <b> </b>の削除
	if ($copy) {
		$$message =~ s/<br>/\n/g;	#改行の変換
		$$message =~ s/<.*?>//g;	#htmlタグ消去
		$$message =~ s/&quot;/"/g;	#引用記号の変換
		$$message =~ s/&lt;/</g;	#<の変換
		$$message =~ s/&gt;/>/g;	#>の変換
		print '<textarea cols=60 rows=3>';
	} else {
		foreach my $text (@nonames) {
			$text = trim($text);
			if ($text eq $$name) {	#名無しの消去
				$$name = '';
				last;
			}
		}
		if ($$name ne '') {$$name .= ' ';}
		$$info =~ s/^\d+?\///;		#年の削除
		$$info =~ s/:\d\d[^:]\d* *//;	#秒の削除
		$$info =~ s/ID:/ /;		#'ID:'の削除
		if ($tm) {
			$$message = "$aa_pic/$bbs/$key/$num border=0>";
		} else {
			$$message =~ s/(<a href=\")\.\.\/test\/read\.cgi\/[^\/]+?\/[^\/]+?\//$1$aa$text_all/g;
			$$message =~ s/ target=\"_blank\"(>)/$1/g;
			if ($img_mode) {
				show_smn($num,$message,$img_x,$img_y,"../../../../$bbs/");
			}
			if ($ifo{'jump'}) {
				my $jump = '../../../j.cgi?j=';
				my $h = 'h';
				$$message =~ s/(s?https?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/"<a href=\"$jump".url_encode($1)."\">$1<\/a>"/eg;
				$$message =~ s/([^h])(ttps?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/"$1<a href=\"$jump".url_encode($h.$2)."\">$2<\/a>"/eg;
				$$message =~ s/^(ttps?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/"<a href=\"$jump".url_encode($h.$1)."\">$1<\/a>"/eg;
			} else {
				my $h = 'h';
				$$message =~ s/(s?https?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/<a href="$1">$1<\/a>/g;
				$$message =~ s/([^h])(ttps?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/$1<a href="$h$2">$2<\/a>/g;
				$$message =~ s/^(ttps?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+$,%#]+)/<a href="$h$1">$1<\/a>/g;
			}
		}
	}
	print $num,':';
	print val_sjis($$name);
	print val_sjis($$info);
	if ($$mail ne '') {
		$$mail = ' [' . $$mail . ']';
		print val_sjis($$mail);
	}
	if ($copy) {
		print "\n";
	} else {
		if($tm) {
			print enc_sjis("<a href=a$num?re=k$text_all$opt>字</a>");
		}
		if(!$aa) {
			print "$aa_path/$bbs/$key/$num";
			if ($ifo{'aa_mode'} eq 'AA') {
				print ($tm ? 'w' : '');
				print "?re=$opt$text_all";
			} elsif($tm) {
				print "?480";
			}
			print ">$ifo{'aa_mode'}</a>";
		}
		print '<br>';
		if($all == 0) {
			my $end,$ent=0,$cnt = 1;
			while($ent >= 0){
				$cnt++;
				$ent = index($$message,'<br>',$ent);
				if ($ent >= 0) {
					if ($cnt <= 7) {$end = $ent;}
					$ent += 4;
				}
			}
			if ($cnt > 7) {
				$$message = substr($$message,0,$end);
				$$message .= "<a href=\"$num$aa\">" . enc_str('省') . "$cnt</a>";
			}
		}
	}
	print val_sjis($$message);
	print ($copy ? '</textarea><br>' : '<hr>');
}

#htmlヘッダ出力
sub header{
	my $title = shift;
	$title = trim($title);
	print "Content-type: text/html\n\n";
	print '<html>';
	print '<head>';
	print '<meta http-equiv="Content-Type" content="text/html; charset=shift_jis">';
	print '<title>';
	print val_sjis($title);
	print '</title>';
	#headerタグ
	open(FH, "$dir/$bbs/header.txt");
		while ($header = <FH>) {
		print "$header\n";
		}
	close(FH);
	print '</head>';
	print '<body>';
	print '<a name=u></a>';
	my $banner = rtrim(read_file("../$board/m/banner1.txt"));
	if ($banner ne '') {
		$banner .= '<br>';
		print val_sjis($banner);
	}
	print enc_sjis('<a href=#b accesskey=8>下</a><br>');
	print val_sjis($title);
	print '<hr>';
	if ($copy) {print '<form action=z>';}
	return(0);
}

#フッタ出力
sub footer{
	my $mode = shift;
	my $start = shift;
	my $count = shift;
	my $max = shift;
	my $title = shift;
	my $cp = "$aa$text_all";
	my $cpm = '写';
	if ($copy) {
		print '</form>';
		$cp .= 'c';
		if ($opt eq '') {$opt = 'l';}
		$cpm ='通';
	} else {
		$opt .= 'c';
	}
	print '<a name=b></a>';
	my $banner = rtrim(read_file("../$board/m/banner2.txt"));
	if ($banner) {
		$banner .= '<br>';
		print val_sjis($banner);
	}
	if ($ret) {
		print enc_sjis("<center><a href=$ret>戻る</a></center>");
	} else {
	print enc_sjis('<a href=#u accesskey=2>上</a>');
	my $page = $start - 1;
	$page = ($page < 10 ? '1-' : '-' . $page );
	print enc_sjis("<a href=$page$cp accesskey=7>前</a>");
	$page = ($start + $count) . '-';
	print enc_sjis("<a href=$page$cp accesskey=9>次</a>");
	print "<a href=1-$cp accesskey=1>1-</a>";
	print enc_sjis("<a href=n$cp accesskey=3>新</a>");
	if ($mode) { print enc_sjis('<a href=w accesskey=4>書</a>'); }
	print enc_sjis("<a href=$opt$aa$text_all accesskey=5>$cpm</a>");
	if ($bbs eq $board) {
		print enc_sjis("<a href=../../../../$bbs/m/ accesskey=6>板</a>");
	} else {
		print enc_sjis("<a href=../../../../test/m.cgi/$board/k1 accesskey=6>板</a>");
	}
	if ($ifo{'site_top'} eq get_top()) {
		print enc_sjis("<a href=../../../../mobile.html accesskey=0>覧</a>");
	} else {
		print enc_sjis("<a href=$ifo{'site_top'}mobile.html accesskey=0>覧</a>");
	}
	if ($jump ne '' && $ifo{'site_top'} ne $jump && get_top() ne $jump) {
		print enc_sjis("<a href=$jump>主</a>");
	}
	if ($ifo{'aa_mode'}) {
		$opt =~ s/c//g;
		if ($aa) {
			print "<a href=$text_all$opt>AA</a>";
		} else {
			print "<a href=a$text_all$opt>AA</a>";
		}
	}
	if ($text_all) {
		print enc_sjis("<a href=$aa$opt>全</a>");
	} else {
		print enc_sjis("<a href=t$aa$opt>省</a>");
	}}
	$url = get_url();
	$url =~ s/r\.cgi/read.cgi/g;
	print '<form action=n><textarea cols=60 rows=3>';
	print val_sjis($title);
	print "$url/$bbs/$key/</textarea></form>";
	print "<form action=\"g$text_all$aa\" method=GET>";
	print '<input maxlength=4 size=4 name=g istyle=4 accesskey=#>';
	print '<input type=submit value=GO></form>';
	print '</body>';
	print '</html>';
}

#書き込みページ
sub show_write{
	my $c_name = $cgi->cookie('NAME');
	Encode::from_to($c_name,'utf-8','shift_jis');
	$c_name =~ s/"/&quot;/g;
	$c_name =~ s/\n|\r//g;
	my $c_mail = $cgi->cookie('MAIL');
	Encode::from_to($c_mail,'utf-8','shift_jis');
	$c_mail =~ s/"/&quot;/g;
	$c_mail =~ s/\n|\r//g;
	if ($c_name) {$c_name = " value=$c_name";}
	if ($c_mail) {$c_mail = " value=$c_mail";}
	write_cookie($ifo{'c_name'},$ifo{'c_val'},0);
	if ($img_mode) {
		my $remote_host = gethostbyaddr(pack("C4",split(/\./,$ENV{'REMOTE_ADDR'})),2);
		if ($remote_host =~ /.+ezweb\.ne\.jp$/ && !$ENV{'HTTP_X_UP_DEVCAP_SELECTEDNETWORK'} 		#au
			&& $ENV{'HTTP_X_SELECTEDNETWORK'} eq '') {$img_mode = 0;}
	}
	print "Content-type: text/html\n\n";
	print '<html><head>';
	print '<meta http-equiv="Content-Type" content="text/html; charset=shift_jis">';

	#headerタグ
	open(FH, "$dir/$bbs/header.txt");
		while ($header = <FH>) {
		print "$header\n";
		}
	close(FH);

	if($site_key_if && $secret_key){
	print '<script src="https://www.google.com/recaptcha/api.js"></script>';
	}
	#hCaptcha
	if($site_key_if && $h_secret_key){
	print '<script src="https://www.hCaptcha.com/1/api.js" async defer></script>';
	}

	print '<title>',enc_sjis("書き込み"),'</title><body>';
	print '<form method=POST action="../../../b.cgi?guid=ON"'.($img_mode ? ' ENCTYPE=multipart/form-data>' : '>');
	print enc_sjis("名前<input name=FROM size=14")."$c_name><br>";
	print " mail<input name=mail size=14$c_mail><br>";
	if ($img_mode) {
		print enc_sjis('画像<input type =file name =file size=14><br>');
	}
	print '<textarea rows=5 cols=60 name=MESSAGE></textarea><br>';

	#サイトキー
	if($site_key_if){

		if($secret_key){
		print '<div class="g-recaptcha" data-sitekey=';
		print "$site_key".'></div>';
		}elsif($h_secret_key){
		print '<div class="h-captcha" data-sitekey=';
		print "$site_key".'></div>';
		}

	}

	print enc_sjis('<input type=submit value="書き込む" name=submit>');
	print "<input type=hidden name=bbs value=$bbs>";
	print "<input type=hidden name=key value=$key>";
	my $time = time();
	print "<input type=hidden name=time value=$time>";
	print '</form>';
	print '</body></html>';
}

sub error_exit {
	my $text = shift;
	if ($head) {
		print "Content-type: text/html\n\n";
		print '<html>';
		print '<head>';
		print '<meta http-equiv="Content-Type" content="text/html; charset=shift_jis">';
		print '<title>',enc_sjis("エラーですよ"),'</title>';
		print '<body>';
	}
	print '<br>',enc_sjis($text),'<br></body></html>';
	exit(0);
}

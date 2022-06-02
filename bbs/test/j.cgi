#!/usr/bin/perl

use utf8;
use LWP::Simple;

$call = 'j.cgi';
require './sub/common.pl';	#初期設定と共通サブルーチン

main_cgi();
exit(0);

sub main_cgi {
	$cgi = new CGI;
	my $path = "../ifo";
	my $link;
	my $type;
	if ($link = $cgi->param('jmp')) {	#パソコンから
		$type = 0;
	} elsif($link = $cgi->param('jp')) {	#スマホから
		$path = "../ifo/s";
		$type = 1;
	} elsif($link = $cgi->param('j')) {	#携帯から
		$path = "../ifo/m";
		$type = 2;
	} else {
		error_exit();
	}
	my $referer = $ENV{'HTTP_REFERER'};
	if ($referer eq '') {
		my $remote_host = $ENV{'REMOTE_HOST'};
		if ($remote_host eq '' || $remote_host eq $ENV{'REMOTE_ADDR'}) {
			$remote_host = gethostbyaddr(pack("C4",split(/\./,$ENV{'REMOTE_ADDR'})),2) || $ENV{'REMOTE_ADDR'};
		}
		if ($remote_host !~ /.+docomo\.ne\.jp$/) {error_exit();}
	} elsif(index($referer,get_top()) != 0) {
		error_exit();
	}
	my ($site) = check_url($link);
	if ($site) {
		if ($type == 0) {
			$link =~ s|/m/$|/|;
			$link =~ s|/s/$|/|;
			$link =~ s|/r\.cgi|/read.cgi|;
			$link =~ s|mread\.cgi|read.cgi|;
		} elsif($type == 1) {
			if ($link ne $site && $link !~ /\.cgi/ && $link !~ /\/[sm]\/$/) {$link =~ s|/$|/s/|;}
			$link =~ s|/m/$|/s/|;
			$link =~ s|/r\.cgi|/mread.cgi|;
			$link =~ s|/read\.cgi|/mread.cgi|;
		} elsif($type == 2) {
			if ($link ne $site && $link !~ /\.cgi/ && $link !~ /\/[sm]\/$/) {$link =~ s|/$|/m/|;}
			$link =~ s|/s/$|/m/|;
			$link =~ s|/mread\.cgi|/r.cgi|;
			$link =~ s|/read\.cgi|/r.cgi|;
		}
		if ($link =~ '/r.cgi|read.cgi') {	#スレッドビューアーの場合
			my ($bbs,$key) = $link =~ 'cgi/([^/]+)/(\d+)/';
			if (!head("$site/$bbs/dat/$key.dat") && head("$site/$bbs"."_kako/dat/$key.dat")) {
				my $b ='_kako';
				$link =~ s|cgi/[^/]+/\d+/|cgi/$bbs$b/$key/|;	#過去ログ倉庫を表示
			}
		}
		print "Location: $link\n\n";
	} else {
		my $safe = 1;
		my $google = get("http://www.google.co.jp/safebrowsing/diagnostic?site=$link");
		if ($google) {
			my $hikaku = '疑わしくないと認識されています';
			if (index($google,$hikaku) >= 0) {
				$safe = 0;
			} elsif (index($google,encode('Shift_Jis',$hikaku)) >= 0) {
				$safe = 0;
			} elsif (index($google,encode('euc-jp',$hikaku)) >= 0) {
				$safe = 0;
			} elsif (index($google,encode('utf-8',$hikaku)) >= 0) {
				$safe = 0;
			}
		}
		my $text1 = rtrim(read_file("$path/cushion1.txt"));
		my $text2 = rtrim(read_file("$path/cushion2.txt"));
		if ($text1 eq '' && $text2 eq '') {$text2 = enc_str("別のサイトにジャンプしようとしています。宜しければ上記のリンクをクリックしてください。<br><br><a href=\"http://yakumotatu.com/yakumobbs/\">$script</a> $version");}
		if ($safe) {$text2 = enc_str("<font color='ff0000'>危険なサイトの可能性が有ります。</font><br><br>\n") . $text2;}
		print "Content-type: text/html\n\n";
		print "<html>\n";
		print "<head>\n";
		print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=";
		if ($type == 2) {
			print "shift_jis\">\n";
			$text1 = val_sjis($text1);
			$text2 = val_sjis($text2);
			$link = "<form action=n style='margin:0px;'><textarea cols=60 rows=3>$link</textarea></form>\n" .
			enc_sjis("<a href=\"$link\">$link</a><br>\n" .
				"<a href=\"http://m.jword.jp/jw.php?jmb_u=".url_encode($link)."\">JWord経由携帯変換</a><br>\n" .
				"<a href=\"http://www.google.co.jp/gwt/x?guid=ON&u=$link\">GoogleWT経由携帯変換</a><br>\n" .
				"<a href=\"mailto:?subject=Site URL&body=$link\">URLメール送信</a><br>\n");
		} else {
			print "$ifo{'outchr'}\">\n";
			$link = "<a href=\"$link\">$link</a><br>\n";
		}
		print "<title>jump</title>\n";
		print '<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1">',"\n";
		print "</head>\n";
		print "<body>\n";
		print $text1;
		print $link;
		print $text2;
		print "</body>\n</html>\n";
	}
}

sub check_url {
	my $link = shift;
	my $page = get_top();
	if (index($link,$page) == 0) {return($page);}
	$page = trim(get($ifo{'site_top'}.'bbs.txt'));
	if ($page eq '') {return(0);}
	my @list = split(/\n/,$page);
	shift(@list);
	$page = shift(@list);
	$page = split(/<>/,$page);
	$page .= 'bbs/<>bbs';
	unshift(@list,$page);
	foreach $data (@list) {
		$page = substr($data,0,index($data,'<>'));
		$page =~s|/[^/]+?/$|/|;
		if (index($link,$page) == 0) {return($page);}
	}
	return(0);
}

sub error_exit {
	print "Status: 404 Not Found\n\n"; 
	exit(1);
}
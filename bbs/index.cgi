#!/usr/bin/perl

$file1 = 'bbsmenu.html';
$file2 = 'mobile.html';
$file3 = 'bbsmenu.html';

require './test/sub/check_mobile.pl';	#携帯判定サブルーチン

use CGI;
$cgi = CGI->new();
$parm = $cgi->param('mode');

if ($parm eq 'p') {		#パソコン
	$fname = $file1;
} elsif($parm eq 'm') {		#携帯
	$fname = $file2;
} elsif($parm eq 's') {		#スマートフォン
	$fname = $file3;
} else {			#自動判定
	my $term = check_mobile();
	if ($term == 1) {
		$fname = $file2;	#携帯用
	} elsif ($term == 2) {
		$fname = $file3;	#スマホ用
	} else {
		$fname = $file1;	#パソコン用
	}
}

open(TOP,"<$fname") or error_exit();
flock(TOP,1);
print "Content-type: text/html\n\n";
print <TOP>;
close(TOP);
exit(0);

sub error_exit {
	print "Status: 404 Not Found\n\n";
	exit;
}

#!/usr/bin/perl --

use FindBin;

if ($ENV{'REMOTE_ADDR'} ne '') {exit(0);}
$dir = substr($FindBin::Bin,0,-5);
$call = 'comp.cgi';
require "$dir/test/sub/common.pl";
if ($ifo{'maintenance'}) {return(0);}
if ($ifo{'img_lib'}) {
	require "$dir/test/sub/smn".$ifo{'img_lib'}.'.pl';
} else {
	require "$dir/test/sub/smn.pl";
}
require "$dir/test/sub/move.pl";
require "$dir/test/sub/page.pl";
require "$dir/test/sub/mobile.pl";

cgi_main();
exit(0);

sub cgi_main {
	my $cnt = @ARGV;
	my @list = ();
	if ($cnt) {
		comp_exe(\@ARGV);
	} else {
		@list = get_board();
		comp_exe(\@list);
	}
}

sub get_board {
	my %comp;
	my @list = read_tbl("$dir/ifo/board.cgi");
	foreach my $data (@list) {
		($data) = $data =~ /(.+?)<>/;
		$comp{$data} = read_file("$dir/$data/ifo/comp.txt");
		unless($comp{$data}) {$comp{$data} = 0;}
	}
	@list = sort {$comp{$a} <=> $comp{$b}} @list;
	splice(@list,$ifo{'comp_count'});
	return (@list);
}

sub comp_exe {
	$list = shift;
	my $tmp = '';
	foreach my $data (@$list) {
		$bbs = $data;
		if (comp_board($data)) {
			put_page($data);
		}
	}
}

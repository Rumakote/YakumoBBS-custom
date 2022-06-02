use utf8;

if ($ifo{'img_lib'}) {
	require "$dir/test/sub/smn".$ifo{'img_lib'}.'.pl';
} else {
	require "$dir/test/sub/smn.pl";
}
require "$subcmd/page.pl";
require "$subcmd/mobile.pl";

sub rewrite_index_html {
	my $boad = shift;
	my $tmp = $bbs;
	$bbs = $boad;
	get_setting($bbs);
	get_subject();
	put_pc();
	put_subback();
	put_mobile();
	$bbs = $tmp;
}
1;

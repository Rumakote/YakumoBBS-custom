use utf8;

my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');
$cmd_str = '<input type="hidden" name="cmd" value="setting_edit">'."\n";
require "$admcmd/z_setting.pl";

if ($opt eq 'exe') {
	setting_exe($submit);
} else {
	setting_ed();
}

sub setting_ed {
	header("$bbs ボード設定編集");
	show_setting($bbs);
	print $cmd_str;
	print "<input type='hidden' name='opt' value='exe'>\n";
}

sub setting_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("$bbs ボード設定変更");
	print "<td>\n";
	$submit = dec_str($submit);
	my %setting;
	if ($submit eq '実行') {
		my @names = names_setting();
		foreach $name(@names) {
			$setting{$name} = $cgi->param($name);
		}
		my $old_name = $cgi->param('OLD_TITLE');
		if ($setting{'TITLE'} ne $old_name) {
			board_rename("../ifo/board.cgi",$setting{'TITLE'});
			board_rename("../category.txt",$setting{'TITLE'});
		}
		$old_name = $cgi->param('OLD_NONAME');
		if ($setting{'NONAME_NAME'} ne $old_name) {
			add_nonames($old_name);
		}
	} else {
		%setting = read_setting($bbs,%setting);
		my $title = $setting{'TITLE'};
		my $subtitle = $setting{'SUBTITLE'};
		my $titlepic = $setting{'TITLE_PICTURE'};
		%setting = init_setting();
		%setting = read_setting('ifo',%setting);
		$setting{'TITLE'} = $title;
		$setting{'SUBTITLE'} = $subtitle;
		$setting{'TITLE_PICTURE'} = $titlepic;
	}
	put_setting($bbs,%setting);
	submit_ret();
}

sub board_rename {
	my $fname = shift;
	my $new_name = shift;
	my @list;
	open (IN,"+<$fname") or return(0);
	flock(IN,2);
	while (<IN>) {
		my ($dir,$name) = split('<>',$_);
		if ($dir eq $bbs) {
			push(@list,"$dir<>$new_name<>\n");
		} else {
			push(@list,$_);
		}
	}
	seek(IN,0,0);
	foreach $data(@list) {
		print IN $data;
	}
	truncate(IN,tell(IN));
	close(IN);
	return(1);
}

sub add_nonames {
	my $add_name = shift;
	my @list = read_tbl("../$bbs/nonames.txt");
	my $text = '';
	my $flg = 1;
	foreach $data(@list) {
		$data = trim($data);
		if ($add_name eq $data) {$flg = 0;}
		$text .= "$data\n";
	}
	if ($flg) {$text = "$add_name\n" . $text;}
	write_file("../$bbs/nonames.txt",\$text,0);
}
1;
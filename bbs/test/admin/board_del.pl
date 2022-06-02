use utf8;
use File::Path;

my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'exe') {
	del_exe($submit);
} else {
	del_conf();
}

sub del_conf {
	if ($bbs eq '') {
		show_menu();
		footer();
	}
	my %setting = get_setting_txt($bbs);
	header("ボード削除確認");
	echo "削除しますか？<td>ディレクトリ</td><td>$bbs</td></tr>\n";
	echo "<tr><td>ボードタイトル</td>";
	print "<td>$setting{'TITLE'}</td></tr>\n";
	echo "<tr><td>サブタイトル</td>";
	print "<td>$setting{'SUBTITLE'}</td></tr>\n";
	submit_exe();
	echo '<input type="hidden" name="cmd" value="board_del">',"\n";
	echo '<input type="hidden" name="opt" value="exe">',"\n";
}

sub del_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my $kako = $bbs . '_kako';
	header("ボード削除");
	print "<td>\n";
	if (rmtree("../$bbs")) {
		echo "$bbs を削除<br>";
	} else {
		echo "$bbs 削除失敗<br>";
	}
	if (-d "../$kako") {
		if (rmtree("../$kako")) {
			echo "$kako を削除<br>";
		} else {
			echo "$kako 削除失敗<br>";
		}
	}
	my $text = '';
	if (open(IN,'+<../ifo/board.cgi')) {
		flock(IN,2);
		my @board = <IN>;
		foreach $data(@board) {
			my ($dir,$name) = split(/<>/,$data);
			if ($dir ne $bbs) {$text .= $data;}
		}
		seek(IN,0,0);
		print IN $text;
		truncate(IN,tell(IN));
		close(IN);
		if ($ifo{'perm_file'}) {chmod(oct($ifo{'perm_file'}),'../ifo/board.cgi');}
	}
	my $text = '';
	my @list = read_tbl('../category.txt');
	foreach $data(@list) {
		my ($dir,$name) = split(/<>/,$data);
		if ($dir ne $bbs) {$text .= $data;}
	}
	write_file('../category.txt',\$text,0);
	submit_ret();
}
1;
use utf8;

require "$admcmd/z_thread.pl";

my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');
$cmd_str = '<input type="hidden" name="cmd" value="thread_rename">'."\n";

if ($opt eq 'exe') {
	rename_exe($submit);
} elsif ($opt eq 'select') {
	rename_select($submit);
} else {
	rename_menu($submit);
}

sub rename_menu {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	header("どのスレッドタイトルを変更しますか？");
	if (out_thread(0,$board)) {
		submit_select();
	} else {
		submit_ret();
	}
	print $cmd_str;
	print '<input type="hidden" name="opt" value="select">',"\n";
}

sub rename_select {
	my $submit = shift;
	my $dat_name = $cgi->param('dat_name');
	if ($submit eq $modoru) {
		show_menu();
	}
	if ($dat_name eq '') {
		rename_menu();
		footer();
	}
	my ($dat,$name) = split('<>',$dat_name);
	$name = trim(substr($name,0,rindex($name,'(')));
	header('スレッドタイトル変更');
	echo "<td>スレッド名</td>\n";
	print "<td><input type='text' name='name' size='50' value='$name'>\n";
	submit_exe();
	print $cmd_str;
	print "<input type='hidden' name='old_name' value='$name'>\n";
	print "<input type='hidden' name='dat' value='$dat'>\n";
	echo '<input type="hidden" name="opt" value="exe">',"\n";
}

sub rename_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		rename_menu();
		footer();
	}
	my $name = $cgi->param('name');
	my $old_name = $cgi->param('old_name');
	my $dat = $cgi->param('dat');
	my $board = ($type eq 'kako' ? $bbs.'_kako' :$bbs);
	if ($name eq $old_name) {show_menu();}
	my $key = substr($dat,0,index($dat,'.dat'));
	my $sig = (get_index(1,$board,$key) < 0 ? -1 : 1);
	header("スレッドタイトル変更");
	print "<td>$old_name<br>\n";
	echo "から<br>\n";
	print "$name<br>\n";
	unless (open(DAT,"+<../$board/dat/$dat")) {
		echo "への変更に失敗しました";
		submit_ret();
	}
	flock(DAT,2);
	unless (open(SBJ,"+<../$board/subject.txt")) {
		close(LOG);
		echo "への変更に失敗しました";
		submit_ret();
	}
	flock(SBJ,2);
	$fname = "../$board/dat/".time().'.tmp';
	unless (open(TMP,"+>$fname")) {
		close(SBJ);
		close(LOG);
		echo "への変更に失敗しました";
		submit_ret();
	}
	my $line = <DAT>;
	$line = substr($line,0,rindex($line,'<>')) . "<>$name\n";
	print TMP $line;
	while (<DAT>) {
		print TMP $_;
	}
	seek(DAT,0,0);
	seek(TMP,0,0);
	while (<TMP>) {
		print DAT $_;
	}
	close(TMP);
	unlink $fname;
	my @list;
	my $flg = 0;
	while(<SBJ>) {
		if (index($_,$dat) == 0) {
			substr($_,index($_,$old_name),length($old_name),$name);
			$flg = 1;
		}
		push(@list,$_);
	}
	seek(SBJ,0,0);
	print SBJ @list;
	truncate(SBJ,tell(SBJ));
	truncate(DAT,tell(DAT));
	close(SBJ);
	close(DAT);
	echo "へ変更しました<br>";
	echo makeindex($board,$key,$sig),"<br>\n";
	if ($type ne 'kako') {
		if ($ifo{'img_lib'}) {
			require "$dir/test/sub/smn".$ifo{'img_lib'}.'.pl';
		} else {
			require "$dir/test/sub/smn.pl";
		}
		require "$subcmd/page.pl";
		require "$subcmd/mobile.pl";
		get_setting($bbs);
		get_subject();
		put_pc();
		put_subback();
		put_mobile();
	}
	submit_ret();
}
1;
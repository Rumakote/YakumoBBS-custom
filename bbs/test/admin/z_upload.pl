use utf8;

sub up_load {
	my @ext_ok = @_;
	my $fname = $cgi->param('upload_file');
	my $board = ($type eq 'kako' ? $bbs.'_kako' : $bbs);
	my $ext = substr($fname,rindex($fname,'.')+1);
	my $outfile = $fname;
	$outfile =~ s#\\#/#g;
	my $buffer;
	my $ok = rindex($outfile,'/');
	$ok = ($ok < 0 ? 0 : $ok +1);
	if ($ext_ok[0] eq 'dat') {	#過去ログアップ
		$outfile = "../$board/dat/".substr($outfile,$ok);
	} else {		#画像アップ
		$outfile = $ifo{'images'}.substr($outfile,$ok);
	}
	$ok = 0;
	foreach $ex (@ext_ok){
		if($ext eq $ex) {
			$ok = 1;
			last;
		}
	}
	unless ($ok) {
		error_ret('アップロードできないタイプのファイルです。');
	}
	if (-e $outfile) {
		if ($ext_ok[0] eq 'dat') {
			error_ret('アップロード済みのファイルですので中止します。');
		} else {
			echo "同名のファイルをファイルを上書きします。\n";
		}
	}
	if (open(IN,"<$fname")) {$fname = IN;}
	binmode($fname);
	open (UPL,">$outfile");
	flock(UPL,2);
	binmode(UPL);
	while(read($fname,$buffer,1024)) {
	print UPL $buffer;
	}
	close($fname);
	close(UPL);
	if (-s $outfile == 0) {
		unlink $outfile;
		error_ret("$outfile がアップロードできませんでした。");
	}
	echo "$outfile アップロード<br>";
	return($outfile);
}

sub dummy_ifo {
	my $bbs = shift;
	my $key = shift;
	my $max = shift;
	my $cnt;
	my $fname = "../$bbs/ifo/$key.cgi";
	if (-e $fname) {return("$fname は既に存在するので作成しませんでした。");}
	open (IFO,">$fname") or return("$fname の作成に失敗しました。");
	for($cnt = 1;$cnt <= $max;$cnt++) {
		print IFO "dummy|_|dummy|_|dummy|_|dummy|_|dummy|_|dummy\n";
	}
	close(IFO);
	if ($ifo{'perm_file'}) {
		chmod(oct($ifo{'perm_file'}),$fname);
	}
	return("$fname を作成しました。");
}

sub up_subject {
	my $bbs = shift;
	my $key = shift;
	my $max = shift;
	my $pos = shift;
	print "$pos <br>";
	open (DAT,"<../$bbs/dat/$key.dat") or error_ret("datファイルがオープンできませんでした。");
	flock(DAT,1);
	my $title = <DAT>;
	close(DAT);
	$title = trim(substr($title,rindex($title,'<>') +2 ));
	my $subject = "$key.dat<>$title ($max)\n";
	my @sbj_txt = ();
	open (SBJ,"+<../$bbs/subject.txt") or error_ret("subject.txtの書き換えに失敗しました。");
	flock(SBJ,2);
	if ($pos eq 'age') {
		push(@sbj_txt,$subject);
	}
	while(<SBJ>) {
		push(@sbj_txt,$_);
		if (index($_,$pos) == 0) {
			push(@sbj_txt,$subject);
		}
	}
	my $cnt = @sbj_txt;
	if ($type eq 'kako') {
		$cnt = ($ifo{'max_kako'} > 0 ? $cnt - $ifo{'max_kako'} : 0);
	}
	my @ret = ();
	while($cnt > 0) {
		my $tmp = pop(@sbj_txt);
		unshift(@ret,$tmp);
		$cnt--;
	}
	seek(SBJ,0,0);
	print SBJ @sbj_txt;
	truncate(SBJ,tell(SBJ));
	close(SBJ);
	$cnt = @sbj_txt;
	write_file("../$bbs/ifo/count.txt",\$cnt);
	return(@ret);
}

sub error_ret {
	my $text = shift;
	echo "$text<br>\n";
	submit_ret();
	footer();
}

1;

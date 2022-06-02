use utf8;
use File::Path;
use File::Copy;

sub move_kako_th {
	my $from = shift;
	my $to = shift;
	my @del_list = @_;
	@_ = ();
	my @kako_list;
	my $to_kako = 0;
	my $cnt = 0;
	if (index($from,'_kako') < 0) {
		foreach my $data(@del_list) {
			my ($key,$name) = split('.dat<>',$data);
			thread_mode("$dir/$from/idx/$key.idx",0);
		}
	}
	if ($ifo{'max_kako'} || index($to,'_kako') < 0) {	#ボード間移動
		unless ($cmp_flg) {@del_list = del_subject($from,@del_list);}
		$cnt = move_thread($from,$to,@del_list);
		@del_list = add_subject($to,@del_list);
		del_thread($to,@del_list);
	} else {	#過去ログ倉庫が無いから削除
		del_thread($from,@del_list);
	}
	return($cnt);
}

sub del_subject {
	my $board = shift;
	my @dat_name = @_;
	@_ = ();
	my $end = @dat_name;
	my $cnt = 0;
	my @list = ();
	unless ($end) {return(@list);}
	open (SBJ,"+<$dir/$board/subject.txt") or return(@list);
	flock(SBJ,2);
	my $tmp = "$dir/$board/ifo/".time().".sbj";
	unless(open(TMP,"+>$tmp")) {
		close(SBJ);
		return(@list);
	}
	my $dat;
	my $flg;
	my $line;
	while($line = <SBJ>) {
		($dat) = split('<>',$line);
		$flg = 1;
		foreach my $data (@dat_name) {
			if (index($data,$dat) == 0) {
				$flg = 0;
				push(@list,$line);
				last;
			}
		}
		if ($flg) {
			print TMP $line;
			$cnt++;
		}
	}
	seek(SBJ,0,0);
	seek(TMP,0,0);
	print SBJ <TMP>;
	truncate(SBJ,tell(SBJ));
	close(SBJ);
	close(TMP);
	unlink $tmp;
	write_file("$dir/$board/ifo/count.txt",\$cnt);
	return(@list);
}

sub add_subject {
	my $board = shift;
	my @dat_name = @_;
	@_ = ();
	my @ret = ();
	my $kako = (index($board,'_kako') >= 0 ? 1 : 0);
	my $cnt = @dat_name;
	unless($cnt) {return(@ret);}
	my $max = ($kako ? $ifo{'max_kako'} : 0);
	if ($max < 0) {$max = 0;}
	open(SBJ,"+<$dir/$board/subject.txt") or return(@ret);
	flock(SBJ,2);
	if ($max && $cnt > $max) {
		@ret = splice(@dat_name,$max);
	}
	my $tmp = "$dir/$board/ifo/".time().".sbj";
	unless(open(TMP,"+>$tmp")) {
		close(SBJ);
		return(@ret);
	}
	if ($cnt) {print TMP @dat_name;}
	my $dat;
	my $flg;
	while(<SBJ>) {
		($dat) = split('<>',$_);
		$flg = 1;
		foreach my $data(@dat_name) {
			if (index($data,$dat) == 0) {
				$flg = 0;
				last;
			}
		}
		if ($flg) {
			$cnt++;
			if ($max && $cnt > $max) {
				push(@ret,$_);
			} else {
				print TMP $_;
			}
		}
	}
	seek(SBJ,0,0);
	seek(TMP,0,0);
	print SBJ <TMP>;
	truncate(SBJ,tell(SBJ));
	close(SBJ);
	close(TMP);
	unlink $tmp;
	if ($max && $cnt > $max) {
		write_file("$dir/$board/ifo/count.txt",\$max);
	} else {
		write_file("$dir/$board/ifo/count.txt",\$cnt);
	}
	return(@ret);
}

sub del_thread {
	my $board = shift;
	my @key = dat_to_key(@_);
	@_ = ();
	my $cnt = 0;
	foreach my $data(@key) {
		unlink("$dir/$board/dat/$data.dat");
		unlink("$dir/$board/idx/$data.idx");
		unlink("$dir/$board/ifo/$data.cgi");
		if (-d "$dir/$board/img/$data") {rmtree("$dir/$board/img/$data");}
		if (-d "$dir/$board/smn/$data") {rmtree("$dir/$board/smn/$data");}
		$cnt++;
	}
	return($cnt);
}

sub move_thread {
	my $from = shift;
	my $to = shift;
	my @key = dat_to_key(@_);
	@_ = ();
	my $cnt = 0;
	foreach my $data(@key) {
		move_dat($from,$to,$data);
		move("$dir/$from/ifo/$data.cgi","$dir/$to/ifo/$data.cgi");
		if (-d "$dir/$from/img/$data") {move("$dir/$from/img/$data","$dir/$to/img/$data");}
		if (-d "$dir/$from/smn/$data") {move("$dir/$from/smn/$data","$dir/$to/smn/$data");}
		$cnt++;
	}
	return($cnt);
}

sub move_dat {
	my $from = shift;
	my $to = shift;
	my $key = shift;
	open(IN,"< $dir/$from/dat/$key.dat") or return(0);
	flock(IN,1);
	unless (open(OUT,"> $dir/$to/dat/$key.dat")) {
		close(IN);
		return(0);
	}
	flock(OUT,2);
	while(<IN>) {
		my $num = $.;
		my ($name,$mail,$info,$message,$title) = split('<>',$_);
		my $pic_str = "$from/img/$key/$num";
		my $pos = index($message,$pic_str);
		if ($pos > 0) {
			if (-e "$dir/$pic_str.jpg" || -e "$dir/$pic_str.gif") {
				substr($message,$pos,length($pic_str),"$to/img/$key/$num");
			}
		}
		$message =~ s/(<a href=\"\.\.\/test\/read\.cgi\/)$from\//$1$to\//g;
		print OUT "$name<>$mail<>$info<>$message<>$title";
	}
	close(OUT);
	close(IN);
	unlink("$dir/$from/idx/$key.idx","$dir/$from/dat/$key.dat");
	write_idx($to,$key);
}

sub write_idx {
	my $board = shift;
	my $dat = shift;
	my $sgn = 1;
	if (index($board,'_kako') >= 0) {$sgn = -1;}
	open(LOG,"<$dir/$board/dat/$dat.dat") or return(0);
	flock(LOG,1);
	unless (open(IDX,">$dir/$board/idx/$dat.idx")) {
		close(LOG);
		return(0);
	}
	flock(IDX,2);
	binmode(IDX);
	my $count = 0;
	my $buf = pack("l",0);
	print IDX $buf;
	while(<LOG>) {
		$buf = pack("l",tell(LOG));
		print IDX $buf;
		$count++;
	}
	seek(IDX,0,0);
	truncate(IDX, $count * 4);
	if (tell(LOG) >= ($ifo{'max_dat_size'} * 1024)) {$sgn = -1;}
	if ($count >= $ifo{'max_res'}) {$sgn = -1;}
	$buf = pack("l",$count * $sgn);
	print IDX $buf;
	close(LOG);
	close(IDX);
}

sub dat_to_key {
	my @dat_name = @_;
	@_ = ();
	my @list = ();
	foreach my $data(@dat_name) {
		my $tmp = substr($data,0,index($data,'.dat'));
		push(@list,$tmp);
	}
	return(@list);
}

sub comp_board {
	my $board = shift;
	%setting = get_setting_txt($board);
	$now = time();
	open (SBJ,"+< $dir/$board/subject.txt") or return(0);
	flock(SBJ,2);
	@sbj_txt = <SBJ>;
	my @down = comp($board);
	my $cnt = @down;
	if ($cnt) {
		seek(SBJ,0,0);
		print SBJ @sbj_txt;
		truncate(SBJ,tell(SBJ));
	}
	close(SBJ);
	if ($cnt) {
		$cmp_flg = 1;
		move_kako_th($board,$board.'_kako',@down);
	}
	return ($cnt);
}

sub comp {
	my $board = shift;
	my $max_thread = $setting{'MAX_THREAD'};
	my $min_thread = $setting{'MIN_THREAD'};
	if ($max_thread <= 0) {$max_thread = $ifo{'max_thread'};}
	if ($min_thread <= 0) {$min_thread = $ifo{'min_thread'};}
	if ($max_thread <= 0) {$max_thread = 0;}
	if ($min_thread > $max_thread) {$min_thread = $max_thread;}
	if ($min_thread <= 0) {$min_thread = $max_thread;}
	my @del_list;
	my @inf_list;
	my %time;
	my %subje;
	my @dat_name;
	my @down_thread;
	while (my $line = shift(@sbj_txt)) {
		my ($fname,$sbj_name) = split('<>',$line);
		my ($res) = $sbj_name =~ /\((\d+?)\)\n$/;
		$subje{$fname} = $sbj_name;
		my $write = (stat "$dir/$board/dat/$fname")[9];
		if (!$write) {
			push(@down_thread,$fname);
		} elsif (($res >= $ifo{'down_res'} || (-s "$dir/$board/dat/$fname") >= $ifo{'max_dat_size'} * 1024)
			&& $write <= ($now - $ifo{'down_time'} * 3600)) {
			push(@down_thread,$fname);
		} else {
			push(@dat_name,$fname);
			$time{$fname} = $write;
		}
	}
	my $count = @dat_name;
	my @list = ();
	if ($count > $max_thread && $max_thread) {
		$count = $count - $min_thread;
		@list = sort {$time{$a} <=> $time{$b}} @dat_name;
		splice(@list,$count);
	}
	foreach my $data (@dat_name) {
		my $flg = 1;
		foreach my $del (@list) {
			if ($data eq $del) {
				$flg = 0;
				last;
			}
		}
		if ($flg) {push(@sbj_txt,"$data<>$subje{$data}");}
	}
	@list = sort {$time{$b} <=> $time{$a}} @list;
	push(@down_thread,@list);
	foreach my $data (@down_thread) {
		$data = "$data<>$subje{$data}";
	}
	write_file("$dir/$board/ifo/comp.txt",\$now);
	return(@down_thread);
}
1;
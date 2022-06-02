use utf8;
use File::Path;

require "$admcmd/z_setting.pl";
require "$admcmd/z_permission.pl";

rebuild_exe();

sub rebuild_exe {
	header("掲示板再構築");
	print "<td>\n";
	my @list = get_dir();
	add_board(@list);
	foreach $data(@list) {
		unless (-d "../$data/m") {mkdir("../$data/m");}
		unless (-d "../$data/idx") {mkdir("../$data/idx");}
		unless (-d "../$data/img") {mkdir("../$data/img");}
		unless (-d "../$data/smn") {mkdir("../$data/smn");}
		unless (-d "../$data/ifo") {mkdir("../$data/ifo");}
		reset_perm("../$data/ifo",'dir');
		copy_login($data);
		if ($ifo{'max_kako'}) {
			my $dat = $data.'_kako';
			unless (-d "../$dat/dat") {mkdir("../$dat/dat");}
			unless (-d "../$dat/idx") {mkdir("../$dat/idx");}
			unless (-d "../$dat/img") {mkdir("../$dat/img");}
			unless (-d "../$dat/smn") {mkdir("../$dat/smn");}
			unless (-d "../$dat/ifo") {mkdir("../$dat/ifo");}
			reset_perm("../$dat/ifo",'dir');
		}
	}
	foreach $dir(@list) {
		my @tmp = glob("../$dir/dat/*.dat");
		foreach $data(@tmp) {
			my $key = substr($data,length("../$dir/dat/"));
			my $key = substr($key,0,index($key,'.dat'));
			unless (-e "../$dir/idx/$key.idx") {add_index($dir,$key);}
			if (-e "../$dir/ifo/$key.cgi") {
				reset_perm("../$dir/ifo/$key.cgi",'file');
			} else {
				add_ifo($dir,$key);
			}
		}
		flash_subject($dir,@tmp);
	}
	if ($ifo{'max_kako'}) {
		foreach $direc(@list) {
			my $dir = $direc.'_kako';
			my @tmp = glob("../$dir/dat/*.dat");
			foreach $data(@tmp) {
				my $key = substr($data,length("../$dir/dat/"));
				my $key = substr($key,0,index($key,'.dat'));
				unless (-e "../$dir/idx/$key.idx") {add_index($dir,$key);}
				if (-e "../$dir/ifo/$key.cgi") {
					reset_perm("../$dir/ifo/$key.cgi",'file');
				} else {
					add_ifo($dir,$key);
				}
			}
			flash_subject($dir,@tmp);
		}
	}
	echo "掲示板の再構築をしました<br>\n";
	submit_ret();
}

sub get_dir {
	my @list = glob("../*");
	my @ret;
	foreach $data(@list) {
		if ($data eq '../ifo') {next;}
		if ("$data/" eq $ifo{'images'}) {next;}
		if ($data eq '../test') {next;}
		if ($data eq "../$ifo{'bbskey'}") {next;}
		if (rindex($data,'.') > 2) {next;}
		if (index($data,'_') >= 0) {next;}
		unless (-d "$data/dat") {next;}
		$data = substr($data,3);
		push(@ret,$data);
	}
	return(@ret);
}

sub add_board {
	my @list = read_tbl('../ifo/board.cgi');
	my $cnt = 1;
	foreach $data(@_) {
		my $flg = 1;
		my $name;
		my $dir;
		my %set;
		foreach $tmp(@list) {
			($dir,$name) = split('<>',$tmp);
			if ($dir eq $data) {
				$flg = 0;
				last;
			}
		}
		if (-e "../$data/SETTING.TXT") {
			%set = get_setting_txt($data);
			if ($set{'SUBTITLE'} eq '') {$set{'SUBTITLE'} = $set{'TITLE'};}
			if ($flg) {push(@list,"$data<>$set{'TITLE'}<>\n");}
		} else {
			%set = get_setting_txt('ifo');
			if ($flg) {
				$name = "board$cnt";
				$cnt++;
				push(@list,"$data<>$name<>\n");
			}
			$set{'TITLE'} = $name;
			$set{'SUBTITLE'} = $name;
		}
		put_setting($data,%set);
		if ($ifo{'max_kako'}) {
			my $kako = $data."_kako";
			unless (-d "../$kako") {mkdir("../$kako");}
			unless (-e "../$kako/index.html") {
				open(FN,">../$kako/index.html");
				print FN "<html>\n<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=$ifo{'outchr'}\">\n";
				print FN "<title>".$set{'TITLE'}.enc_str('@過去ログ倉庫')."</title></head><body>\n";
				print FN $set{'TITLE'}.enc_str("の過去ログ倉庫は");
				print FN "<a href=\"../test/kako.cgi/$data/\">".enc_str("こちら")."</a>".enc_str("です\n");
				print FN "</body>\n</html>\n";
				close(FN);
			}
		} elsif (-d "../$data".'_kako') {
			rmtree("../$data".'_kako');
		}
	}
	my $text = '';
	foreach $data(@list) {
		$text .= $data;
	}
	write_file('../ifo/board.cgi',\$text,1);
}

sub reset_perm {
	my $fname = shift;
	my $type = shift;
	my $perm;
	if ($type eq 'dir') {
		if ($ifo{'perm_dir'}) {
			$perm = $ifo{'perm_dir'};
		} else {
			mkdir './dummy_dir' or return(0);
			$perm = get_perm('./dummy_dir');
			rmdir './dummy_dir';
		}
		return(chmod (oct($perm),$fname));
	} elsif ($type eq 'file') {
		if ($ifo{'perm_file'}) {
			$perm = $ifo{'perm_file'};
		} else {
			open(DM,'> ./dummy_file.cgi') or return(0);
			close(DM);
			$perm = get_perm('./dummy_file.cgi');
			unlink('./dummy_file.cgi');
		}
		return(chmod (oct($perm),$fname));
	} else {
		return(0);
	}
}

sub add_index {
	my $board = shift;
	my $key = shift;
	$sgn = (-s "../$board/dat/$key.dat" >= $ifo{'max_dat_size'} * 1024 ? -1 : 1);
	if (index($board,'_kako') >= 0) {$sgn = -1;}
	makeindex($board,$key,$sgn);
	if (get_index(1,$board,$key) >= $ifo{'max_res'}) {
		thread_mode("../$board/idx/$key.idx",0);
	}
}

sub add_ifo {
	my $board = shift;
	my $key = shift;
	my $max = abs(get_index(1,$board,$key));
	my $fname = "../$board/ifo/$key.cgi";
	open (IFO,">$fname") or return(0);
	flock(IFO,2);
	my $cnt;
	for($cnt = 1;$cnt <= $max;$cnt++) {
		print IFO "dummy|_|dummy|_|dummy|_|dummy|_|dummy|_|dummy\n";
	}
	close(IFO);
	if ($ifo{'perm_file'}) {
		chmod(oct($ifo{'perm_file'}),$fname);
	}
	return(1);
}

sub flash_subject {
	my $board = shift;
	my @list = @_;
	my $fname = "../$board/subject.txt";
	if (-e $fname) {
		open(FH,"+< $fname") or return(0);
	} else {
		open(FH,"+> $fname") or return(0);
	}
	flock(FH,2);
	my @sbj;
	while (<FH>) {
		my $line = $_;
		foreach $data(@list) {
			my $dat = substr($data,index($data,"/dat/") + 5);
			if (index($line,"$dat<>") == 0) {
				push(@sbj,$line);
				last;
			}
		}
	}
	my @add;
	foreach $data(@list) {
		my $dat = substr($data,index($data,"/dat/") + 5);
		my $flg = 1;
		foreach $line(@sbj) {
			if (index($line,"$dat<>") == 0) {
				$flg = 0;
				last;
			}
		}
		if ($flg) {
			my $count = abs(get_index(1,$board,substr($dat,0,index($dat,'.dat'))));
			my $name = enc_str("<>スレッド");
			if (open(IN,"< $data")) {
				flock(IN,1);
				$name = <IN>;
				close(IN);
			}
			$name = trim(substr($name,rindex($name,'<>') + 2));
			push(@add,"$dat<>$name ($count)\n");
		}
	}
	seek(FH,0,0);
	foreach $data(@sbj) {
		print FH $data;
	}
	foreach $data(@add) {
		print FH $data;
	}
	truncate(FH,tell(FH));
	close(FH);
	return(1);
}
1;
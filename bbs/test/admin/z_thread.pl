use utf8;

sub out_thread {
	my $button = shift;	#radio=0 checkbox=1
	my $bbs = shift;
	my $first = shift;
	my (@key,@th_name);
	my $age = 0;
	my $cnt = 0;
	if (open(SBJ,"<../$bbs/subject.txt")) {
		flock(SBJ,1);
		while(<SBJ>) {
			$_ = trim($_);
			($key[$cnt],$th_name[$cnt]) = split(/<>/,$_);
			$key[$cnt] .= "<>$th_name[$cnt]";
			$cnt ++;
		}
		close(SBJ);
	}
	if ($first ne '') {
		$first = enc_str($first);
		unshift(@key,"age<>$first\" checked \"");
		unshift(@th_name,$first);
		$age = 1;
	}
	my $cnt = @key;
	if ($cnt == 0) {
		echo "<td>この板にはスレッドが無いか、スレッド一覧の読み込みに失敗しています<br>";
		return(0);
	}
	my $line = int($cnt / 30 + 0.99);
	if ($line > 3) {$line = 3;}
	 $line = int($cnt / $line + 0.99);
	my $end = $cnt;
	for ($cnt = 1;$cnt <= $end;$cnt++) {
		if (($cnt - 1) % $line == 0) {print ($cnt == 1 ? "<td valign=\"top\">\n" : "</td><td valign=\"top\">\n");}
		print '<input type="',($button ? 'checkbox' : 'radio');
		print '" name="dat_name" value="',$key[$cnt-1],'">',$cnt-$age,":$th_name[$cnt-1]<br>\n";
	}
	return(1);
}

sub threst_view {
	my $mode = shift;	#0ストップ 1投稿可能を表示
	my $board = shift;
	my @dat;
	my @name;
	my @check;
	my @sbj = read_tbl("../$board/subject.txt");
	foreach $data(@sbj) {
		my ($key,$title) = split('.dat<>',trim($data));
		my $idx = get_index(1,$board,$key);
		if ($mode) {$idx *= -1}
		if ($idx >= 0) {
			push(@check,0);
		} elsif (abs($idx) >= $ifo{'max_res'}) {
			push(@check,0);
		} else {
			push(@check,1);
		}
		push(@dat,$key);
		push(@name,$title);
	}
	my $cnt = @name;
	if ($cnt == 0) {
		echo "<td>この板にはスレッドが無いか、スレッド一覧の読み込みに失敗しています<br>";
		return(0);
	}
	my $max = int($cnt / 30 + 0.99);
	if ($max > 3) {$max = 3;}
	$max = int($cnt / $max + 0.99);
	$cnt = 1;
	foreach $key(@dat) {
		$thname = shift(@name);
		$ck = shift(@check);
		$ck = ($ck ? '' : ' disabled');
		if (($cnt -1) % $max == 0) {print ($cnt == 1 ? "<td valign=\"top\">\n" : "</td><td valign=\"top\">\n");}
		print "<input type='checkbox' name='dat_name' value='$key.dat<>$thname'$ck>\n";
		print "$cnt:$thname<br>\n";
		$cnt++;
	}
	return(1);
}

sub res_view {
	my $text = shift;
	my $num = shift;
	my $name = shift;
	my $mail = shift;
	my $info1 = shift;
	my $message = shift;
	my $ifo = shift;
	my $admin = shift;
	my ($info2,$host,$ipad,$id,$agent,$referer,$proxy,$level) = split(/\|_\|/,$$ifo);
	print "<td bgcolor=\"#cceecc\">\n";
	print "$num:<b>$$name</b>[$$mail]$$info1</td></tr>\n";
	print "<tr><td>\n";
	echo '<input type="checkbox" name="num" value="',$num,"\">$text\n";
	my ($img_path) = $$message =~ /^(s?http[^ ]+)/o;
	my $path = get_top();
	if (index($img_path,$path) == 0) {
		substr($img_path,0,length($path),'../');
		substr($img_path,-3,3,'jpg');
		substr($img_path,index($img_path,'img'),3,'smn');
	}
	if (-e $img_path) {
		$$message =~ s/^[^ ]+//g;
		$$message .= '<br clear="all">';
		$img_path = "<img src='$img_path' align='left' border='0'>";
	} else {
		$img_path = '';
	}
	print "<hr>$img_path$$message";
	if ($member{'level'} & 4) {
		if ($proxy) {$proxy .= "<br>";}
		print '<hr>',($info2 eq $$info1 ? '' : '<font color="#FF0000">'.$info2.'</font> ');
		print "$ipad $host $id $level<br>$proxy$agent<br>$referer<br>$admin\n";
	}
	print '</td></tr><tr>';
}
1;
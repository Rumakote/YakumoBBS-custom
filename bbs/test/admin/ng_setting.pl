use utf8;

require "$admcmd/z_ng_sub.pl";
$cmd_str = '<input type="hidden" name="cmd" value="ng_setting">'."\n";
my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'term_exe') {
	term_exe($submit,'ifo');
} elsif ($opt eq 'word_exe') {
	word_exe($submit,'ifo');
} elsif ($opt eq 'access_exe') {
	require "$admcmd/z_htaccess.pl";
	access_exe($submit);
} elsif ($opt eq 'log_exe') {
	log_exe($submit,'ifo');
} elsif ($opt eq 'term_ed') {
	term_ed($submit,'ifo');
} elsif ($opt eq 'word_ed') {
	word_ed($submit,'ifo');
} elsif ($opt eq 'access_ed') {
	access_ed($submit);
} elsif ($opt eq 'log_ed') {
	log_ed($submit,'ifo');
} elsif ($opt eq 'trip_ed') {
	trip_ed($submit,'ifo');
} elsif ($opt eq 'trip_exe') {
	trip_exe($submit,'ifo');
} elsif ($opt eq 'cap_ed') {
	cap_ed($submit,'ifo');
} elsif ($opt eq 'cap_exe') {
	cap_exe($submit,'ifo');
} else {
	ng_select($submit,'ifo');
}

sub access_ed {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header('アクセス制限設定');
	echo "<td>削除</td><td>IP</td><td>リモートホスト</td><td>備考</td></tr><tr>\n";
	if (open(FH,'< ../ifo/deny.cgi')) {
		my @list = ();
		my %deny = ();
		flock(FH,1);
		while(<FH>) {
			my ($ip,$host,$info) = split('<>',$_);
			my ($key,$line) = ip_line($ip,$host,$info);
			if ($key) {
				push(@list,$key);
				$deny{$key} = $line;
			}
		}
		close(FH);
		@list = sort {$a cmp $b} @list;
		my $tmp = 'aa';
		foreach my $tmp1 (@list) {
			if ($tmp ne $tmp1) {
				my ($ip,$host,$info) = split('<>',$deny{$tmp1});
				print "<td><input type='checkbox' name='del' value='$ip'></td>\n";
				print "<input type='hidden' name='oldip' value='$ip'>";
				print "<td><input type='text' name='ip' value='$ip' size='18'></td>\n";
				print "<td><input type='text' name='host' value='$host' size='60'></td>\n";
				print "<td><input type='text' name='info' value='$info' size='40'></td>\n";
				print "</tr><tr>";
			}
			$tmp = $tmp1;
		}
	}
	echo "<td>　</td><td><input type='text' name='ip' size='18'></td>\n";
	print "<td><input type='text' name='host' size='60'></td>\n";
	print "<td><input type='text' name='info' size='40'></td>\n";
	print "<input type='hidden' name='oldip' value='new'>";
	print "<input type='hidden' name='opt' value='access_exe'>\n";
	print $cmd_str;
	submit_exe();
}

sub access_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		ng_select('','ifo');
		footer();
	}
	header('アクセス制限設定');
	my @del = $cgi->param('del');
	my @oldip = $cgi->param('oldip');
	my @ip = $cgi->param('ip');
	my @host = $cgi->param('host');
	my @info = $cgi->param('info');
	my @list = ();
	my %deny = ();
	my $delip = shift(@del);
	foreach my $tmp1 (@ip) {
		my $tmp2 = shift(@host);
		my $tmp3 = shift(@info);
		my $tmp4 = shift(@oldip);
		if ($tmp4 eq $delip) {
			$delip = shift(@del);
			next;
		}
		unless ($tmp1 =~ /^\d+\.\d+\.\d+\.\d+\/?\d*$/) {$tmp1 = $tmp4;}
		my ($key,$line) = ip_line($tmp1,$tmp2,$tmp3);
		if ($key) {
			push(@list,$key);
			$deny{$key} = $line;
		}
	}
	@list = sort {$a cmp $b} @list;
	if (open(FH,'> ../ifo/deny.cgi')) {
		flock(FH,2);
		my $tmp = 'aa';
		foreach my $tmp1 (@list) {
			if ($tmp ne $tmp1) {
				print FH "$deny{$tmp1}\n";
			}
		}
		close(FH);
		echo "<td>アクセス制限設定ファイルを更新しました<br>";
		if ($ifo{'ht_use'}) {
		write_htaccess();
		}
	} else {
		echo "<td>アクセス制限設定ファイルの更新に失敗しました";
	}
	print $cmd_str;
	submit_ret();
}

sub ip_line {
	my $ip = shift;
	my $host = shift;
	my $info = shift;
	unless ($ip =~ /^\d+\.\d+\.\d+\.\d+\/?\d*$/) {return('','');}	#ipv4以外無視
	my ($ip1,$ip2,$ip3,$ip4) = split(/\./,$ip);
	my $ip1= 'a' . substr('000'.$ip1,-3) . substr('000'.$ip2,-3) . substr('000'.$ip3,-3);
	($ip3,$ip4) = split('/',$ip4);
	$ip1 .= substr('000'.$ip3,-3) . substr('00'.$ip4,-2);
	return($ip1,"$ip<>$host<>$info");
}
1;

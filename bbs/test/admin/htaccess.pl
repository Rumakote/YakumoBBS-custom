use utf8;

$cmd_str = '<input type="hidden" name="cmd" value="htaccess">'."\n";
my $opt = $cgi->param('opt');
my $submit = $cgi->param('submit');

if ($opt eq 'exe') {
	require "$admcmd/z_htaccess.pl";
	htaccess_exe($submit);
} else {
	htaccess_ed($submit);
}

sub htaccess_ed {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header('アクセス制限設定');
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
		echo "<td>IP</td><td>リモートホスト</td><td>備考</td>\n";
		foreach my $tmp1 (@list) {
			if ($tmp ne $tmp1) {
				my ($ip,$host,$info) = split('<>',$deny{$tmp1});
				print "</tr><tr>";
				print "<td><input type='text' name='ip' value='$ip' size='18'></td>\n";
				print "<td><input type='text' name='host' value='$host' size='80'></td>\n";
				print "<td><input type='text' name='info' value='$info' size='40'></td>\n";
			}
			$tmp = $tmp1;
		}
		print "</tr><tr>";
		print "<td><input type='text' name='ip' size='18'></td>\n";
		print "<td><input type='text' name='host' size='80'></td>\n";
		print "<td><input type='text' name='info' size='40'></td>\n";
		print "<input type='hidden' name='opt' value='exe'>\n";
		submit_exe();
	} else {
		echo "deny.cgiが読み込めませんでした";
		submit_ret();
	}
	print $cmd_str;
}
sub htaccess_exe {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header('アクセス制限設定');
	my @ip = $cgi->param('ip');
	my @host = $cgi->param('host');
	my @info = $cgi->param('info');
	my @list = ();
	my %deny = ();
	foreach my $tmp1 (@ip) {
		my $tmp2 = shift(@host);
		my $tmp3 = shift(@info);
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

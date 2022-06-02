use utf8;

sub write_htaccess {
	my @list = read_tbl('../ifo/htaccess.cgi');
	my $rewrite_nouse = trim(shift(@list));
	my $rewrite_dir = trim(shift(@list));
	my $rewrite_url = trim(shift(@list));
	my $ht_text = trim(join('',@list)) . "\n";
	if (open(FH,"> ../.htaccess")) {
		flock(FH,2);
		print FH "<Files ~ \"^\\.(htaccess|htpasswd)\$\">\ndeny from all\n</Files>\n";
		if ($rewrite_url && ($rewrite_nouse || $rewrite_dir)) {
			print FH "<IfModule mod_rewrite.c>\n";
			my $tmp = $rewrite_nouse;
			if ($tmp) {
				$tmp =~ s/^http:\/\///;
				$tmp =~ s/\/.*$//;
				$tmp =~ s/\./\\./g;
				print FH "RewriteEngine on\nRewriteCond %{HTTP_HOST} ^($tmp)(:80)?\n";
				$tmp = $rewrite_url;
				print FH "RewriteRule ^(.*) $tmp\$1 [R=301,L]\n";
			}
			$tmp = $rewrite_dir;
			if ($tmp =~ /^\/.+\/$/) {
				print FH "Redirect permanent $tmp ";
				print FH $rewrite_url;
				print FH "\n";
			}
			print FH "</IfModule>\n";
		}
		print FH $ht_text;
		@list = read_tbl('../ifo/deny.cgi');
		foreach my $tmp (@list) {
			my ($ip,$host,$info) = split('<>',$tmp);
			print FH "deny from $ip\n";
		}
		close(FH);
		echo ".htaccessを更新しました<br>\n";
	} else {
		echo ".htaccessの更新に失敗しました<br>\n";
	}
}
1

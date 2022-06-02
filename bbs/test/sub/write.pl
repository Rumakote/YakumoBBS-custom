use utf8;
use warnings;
use LWP::UserAgent;
use JSON::Parse 'parse_json';

sub put_data {

if($setting{'SECRET_KEY'} ne ''){
	#シークレットキー
	my $secret_key = $setting{'SECRET_KEY'};
	my $url = 'https://www.google.com/recaptcha/api/siteverify';

	my $cgi = CGI->new();
	my $ua = LWP::UserAgent->new();
	#my $recaptcha_response = $form->Get('g-recaptcha-response');
	my $recaptcha_response = $cgi->param('g-recaptcha-response');
	my $remote_ip = $ENV{REMOTE_ADDR};
	my $response = $ua->post(
	    $url,
	    {
	        remoteip => $remote_ip,
	        response => $recaptcha_response,
	        secret => $secret_key,
	    },
	);
	if ( $response->is_success() ) {
	    my $json = $response->decoded_content();
	    my $out = parse_json($json);
	    if ( $out->{success} ) {

		}else{
				close(LOG);
				error_exit(404);
		}
	}
}
if($setting{'H_SECRET_KEY'} ne ''){
	#hCaptchaのシークレットキー
	my $secret_key = $setting{'H_SECRET_KEY'};
	my $url = 'https://hcaptcha.com/siteverify';

	my $cgi = CGI->new();
	my $ua = LWP::UserAgent->new();
	my $recaptcha_response = $cgi->param('g-recaptcha-response');
	my $remote_ip = $ENV{REMOTE_ADDR};
	my $response = $ua->post(
	    $url,
	    {
	        remoteip => $remote_ip,
	        response => $recaptcha_response,
	        secret => $secret_key,
	    },
	);
	if ( $response->is_success() ) {
	    my $json = $response->decoded_content();
	    my $out = parse_json($json);
	    if ( $out->{success} ) {

		}else{
				close(LOG);
				error_exit(404);
		}
	}
}

	$message =~ s/(&gt;&gt;)(\d+-?\d*)/<a href="..\/test\/read.cgi\/$bbs\/$key\/$2" target="_blank">$1$2<\/a>/g;
	$message =~ s/(&gt;&gt;)(-\d+)/<a href="..\/test\/read.cgi\/$bbs\/$key\/$2" target="_blank">$1$2<\/a>/g;
	my $line = $name.'<>'.$mail.'<>'.$info.'<>'.$message.'<>'.$subject."\n";
	my $word = ip_hex($remote_addr);
	my $inform = "$info|_|HOST=$remote_host|_|IPADR=$word=$remote_addr|_|ID=$mobile_id|_|AGENT=$agent|_|REFERER=$referer|_|$proxy|_|Lv=$level\n";
	my $last;
	my $fpt;
	my $max;
	my $er=0;
	my $img_num;
	my $img_url = $cgi->url;
	$img_url = substr($img_url,0,index($img_url,'/test/')) . "/$bbs/";
	if ($act) {
		unless ($last = read_file("../$bbs/last.txt") or $last = read_file("../ifo/last.txt")) {
			$last=enc_str("終了<><>Over Limit Thread<>このスレッドは書き込み限界を超えました。<br>新しいスレッドを立ててください。<>\n");
		}
		open(LOG,"+< ../$bbs/dat/$key.dat") or error_exit(401);
		flock(LOG,2);
		unless (open(IDX,"+<../$bbs/idx/$key.idx")) {
			close(LOG);
			error_exit(401);
		}
		flock(IDX,2);
		binmode(IDX);
		seek(IDX,0,0);
		my $buf;
		read(IDX,$buf,4);
		$max = unpack("l",$buf);
		$img_num = $max + 1;
		seek(LOG,0,0);
		$subject = <LOG>;
		$subject = trim(substr($subject,rindex($subject,'>')+1));
		seek(LOG,0,2);
	} else {
		$key = time();
		if (-e "../$bbs/dat/$key.dat") {error_exit(402);}
		open(LOG,">> ../$bbs/dat/$key.dat") or error_exit(402);
		flock(LOG,2);
		unless (open(IDX,">../$bbs/idx/$key.idx")) {
			close(LOG);
			error_exit(402);
		}
		flock(IDX,2);
		binmode(IDX);
		$img_num = 1;
		$max = 1;
	}
	unless (open(IFO,">> ../$bbs/ifo/$key.cgi")) {
		close(IDX);
		close(LOG);
		error_exit(401);
	}
	flock(IFO,2);
	if ($act) {
		my $length = length($line.$last);
		if ($img_type) {
			$length += length($img_url.$img_num.$img_type) + 9;
		}
		$fpt = tell(LOG);
		if($fpt + $length > ($ifo{'max_dat_size'} * 1024)) {	#datファイルサイズ上限を超える
			$er = 1;
			$line = $last;
		}
		$fpt = pack("l",$fpt);
	} else {		#スレ立て
		$fpt = pack("l",1);
	}
	seek(IDX,0,2);
	print IDX $fpt;
	if ($img_type) {
		$img_name = img_up($img_name,$img_num);
		if ($img_name) {
			$line = $name.'<>'.$mail.'<>'.$info.'<>'.$img_name.'<br>'.$message.'<>'.($act ? '' : $subject)."\n";
		}
	}
	print LOG $line;
	print IFO $inform;
	if ($act) {
		$max++;
		if ($max >= $ifo{'max_res'} && $er !=1) {
			$max++;
			$max = abs($max) * (-1);
			$fpt = tell(LOG);
			$fpt = pack("l",$fpt);
			print IDX $fpt;
			print LOG $last;
			print IFO "END|_|END|_|END|_|END|_|END|_|END\n";
		}
		if ($er) {$max = abs($max) * (-1);}
		seek(IDX,0,0);
		$fpt = pack("l",$max);
		print IDX $fpt;
	}
	close(IDX);
	close(IFO);
	if ($act == 0 && $ifo{'perm_file'}) {
		chmod(oct($ifo{'perm_file'}),"../$bbs/ifo/$key.cgi");
	}
	close(LOG);
	unless (rewrite_subject(abs($max))) {error_exit(403);}
	if ($er == 1) {error_exit(612);}
	return(0);
}

sub rewrite_subject {
	my $max = shift;
	my $fname = "$key.dat";
	my $line = "$fname<>$subject ($max)\n";
	my $flg = 1;
	@sbj_txt = ();
	if ($max == 1 || $mail ne 'sage') {
		push(@sbj_txt,$line);
		$flg = 0;
	}
	open(SBJ,"+< ../$bbs/subject.txt") or return(0);
	flock(SBJ,2);
	while(<SBJ>) {
		if (index($_,$fname) == 0) {
			if ($mail eq 'sage') {
				push(@sbj_txt,$line);
				$flg = 0;
			}
		} else {
			push(@sbj_txt,$_);
		}
	}
	if ($flg) {
		push(@sbj_txt,$line);
	}
	my @down;
	if ($cmp_flg) {
		@down = comp($bbs);
	}
	seek(SBJ,0,0);
	print SBJ @sbj_txt;
	truncate(SBJ,tell(SBJ));
	close(SBJ);
	my $cnt = @down;
	if ($cnt) {
		move_kako_th($bbs,$bbs.'_kako',@down);
	}
	$cnt = @sbj_txt;
	write_file("../$bbs/ifo/count.txt",\$cnt);
	return($cnt);
}

sub go_next{
	my $fname = get_top();
	if ($call eq 'b.cgi') {
		$fname .= "test/r.cgi/$bbs/$key/";
	} elsif ($ifo{'next'}) {
		$fname .= "$bbs/?t=$time";
	} else {
		$fname .= "test/read.cgi/$bbs/$key/l50";
	}
	print "Content-type: text/html\n\n";
	print "<html>\n";
	print "<head>\n";
	print '<meta http-equiv="Content-Type" content="text/html; charset=';
	print ($call eq 'b.cgi' ? 'shift_jis' : $ifo{'outchr'});
	print "\">\n";
	print '<META HTTP-EQUIV="Refresh" CONTENT="1;URL=',$fname,'">',"\n";
	print '<title>',change('書きこみました。'),'</title>';
	print "</head>\n";
	print "<body>\n";
	print '<br>',change('書きこみが終わりました。'),"<br><br>\n";
	print change('自動でページが移動しない場合は');
	print '<a href="',$fname,'">',change('こちら'),'</a>';
	print change('をクリックして下さい');
	if ($etime) {print "<br>($etime sec)\n";}
	print "</body>\n</html>\n";
}
1;

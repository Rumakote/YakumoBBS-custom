use utf8;

require "$subcmd/common.pl";		#初期設定と共通サブルーチン
require "$subcmd/check_mobile.pl";	#携帯判定サブルーチン

$category_all = enc_str('全てのカテゴリ');
$category_non = enc_str('カテゴリ未登録');
$salt = 'ab';				#a-z A-Z 0-9 . / の内の適当な２文字に変更
$modoru = enc_str('戻る');
if (check_mobile() == 1) {error_exit("携帯からはアクセスできません");}
$CGI::POST_MAX = 1024 * 1024; 		#up load max = 1MB
$cgi = CGI->new();
$cmd = $cgi->param('cmd');
$category = $cgi->param('category');
$bbs = $cgi->param('bbs');
$type = $cgi->param('type');
if ($ifo{'max_kako'} == 0) {
	$type = 0;
} elsif ($type ne 'kako') {
	$type = 'board';
}
if ($cgi->cgi_error) {error_exit($cgi->cgi_error);}

sub board_list {
	my @list;
	if ($category eq $category_all) {
		my $text = read_file('../category.txt');
		my $tmp = trim(category_nothing());
		if ($text ne '') {$text .= "<>$category_non\n$tmp";}
		@list = split(/\n/,trim($text));
	} elsif ($category eq $category_non) {
		@list = split(/\n/,trim(category_nothing()));
	} elsif ($category) {
		@list = split(/\n/,trim(get_board($category)));
	} else {
		@list = split(/\n/,trim(read_file('../ifo/board.cgi')));
	}
	return(@list);
}

sub submit_select {
	echo '</td></tr><tr><td align="center" colspan="3"><input type="submit" name="submit" value="選択">  ',"\n";
	echo '<input type="submit" name="submit" value="戻る"><br>',"\n";
}

sub submit_exe {
	my $text = shift;
	echo '</td></tr><tr><td align="center" colspan="4">',$text,'<input type="submit" name="submit" value="実行">  ',"\n";
	echo '<input type="submit" name="submit" value="戻る"><br>',"\n";
}

sub submit_ret {
	my $code = shift;
	my $modoru = '戻る';
	if ($code ne '') {
		$modoru = encode($code,$modoru);
	} else {
		$modoru = enc_str($modoru);
	}
	echo '</td></tr><tr><td align="center" colspan="3">';
	print "<input type='submit' name='submit' value='$modoru'>";
}

sub get_subject {
	open(SBJ,"< ../$bbs/subject.txt") or error_exit('<br>板が見つかりませんよ<br>');
	flock(SBJ,1);
	@sbj_txt = <SBJ>;	#配列へ読み込み
	close(SBJ);
}

sub get_setting {	#SETTING.TXTを連想配列へ格納
	my $bbs = shift;
	%setting = get_setting_txt($bbs);
}

sub category_count {
	my @list = read_tbl('../ifo/category.cgi');
	my $cnt = 0;
	foreach $data(@list) {
		$data = trim($data);
		if ($data eq '') {next;}
		if (index($data,'http') >= 0) {next;}
		$cnt++;
	}
	return($cnt);
}

sub category_nothing {
	my @board = read_tbl('../ifo/board.cgi');
	my $text = '';
	my @list = read_tbl('../category.txt');
	foreach $data(@board) {
		my ($name) = split(/<>/,$data);
		$name .= '<>';
		foreach $tmp(@list) {
			if (index($tmp,$name) == 0) {
				$data = '';
				last;
			}
		}
		$text .= $data;
	}
	return ($text);
}

sub get_board {
	my $name = shift;
	$name = "<>$name<>";
	my $text = '';
	if (-e '../category.txt') {
		my @list = read_tbl('../category.txt');
		my $flg = 0;
		foreach $data(@list) {
			$data = trim($data);
			if ($data eq $name) {
				$flg = 1;
				next;
			}
			if ($flg && index($data,'<>') == 0) {last;}
			if ($flg) {
				my ($dir) = split(/<>/,$data);
				my $board = check_board($dir);
				if ($board) {
					$text .= "$dir<>$board<>\n";
				}
			}
		}
	}
	return($text);
}

sub put_board {
	my $name = shift;
	my @list = @_;
	my @category = read_tbl('../ifo/category.cgi');
	my $text = '';
	foreach $data(@category) {
		$data = trim($data);
		if ($data eq '') {next;}
		if (index($data,'http://') >= 0) {next;}
		if ($data eq $name) {
			$text .= "<>$data<>\n";
			$text .= board_to_text(@list);
		} else {
			$text .= "<>$data<>\n";
			$text .= other_to_text($data,@list);
		}
	}
	if (write_file('../category.txt',\$text,0)) {
		echo "カテゴリファイルを更新しました<br>\n";
	} else {
		echo "カテゴリファイルが更新できませんでした<br>\n";
	}
}

sub board_to_text {
	my @list = @_;
	my $text = '';
	foreach $data(@list) {
		my ($dir) = split(/<>/,$data);
		my $name = check_board($dir); 
		if ($name) {$text .= "$dir<>$name<>\n";}
	}
	return($text);
}

sub other_to_text {
	my $cat_name = shift;
	my @list = @_;
	my @board = split(/\n/,get_board($cat_name));
	my $text = '';
	foreach $tmp(@board) {
		if (trim($tmp) eq '') {next;}
		my ($dir) = split(/<>/,$tmp);
		my $flg = 1;
		foreach $data(@list) {
			if (index($data,"$dir<>") == 0) {
				$flg = 0;
				last;
			}
		}
		if ($flg) {
			my $name = check_board($dir);
			if ($name) {$text .= "$dir<>$name<>\n";}
		}
	}
	return($text);
}

sub check_board {
	my $name = shift;
	my @list = read_tbl('../ifo/board.cgi');
	$name = $name . '<>';
	foreach $data(@list) {
		if (index($data,$name) == 0) {
		my ($dir,$board) = split(/<>/,$data);
		return($board);
		}
	}
	return(0);
}

sub bbs_to_category {
	$board = shift;
	@list = read_tbl('../category.txt');
	my $text = $category_non;
	my $tmp;
	foreach $data(@list) {
		my ($dir,$name) = split(/<>/,$data);
		if ($dir eq '') {
			$tmp = $name;
			next;
		}
		if ($board eq $dir) {
			$text = $tmp;
			last;
		}
	}
	return($text);
}

sub set_cookie {
	my $id = shift;
	my $pw = shift;
	print "Set-Cookie: id=$id;\n";
	print "Set-Cookie: pw=$pw;\n";
	$url = get_url();
	print "Location: $url\n\n";
}

sub login {
	unless (check_pass()) {
		header("ログイン");
		echo '<td><center><br>';
		echo '管理者ID（半角文字）<br>';
		print '<input type="text" name="login_id" size="25" maxlength="20" value="',$id,"\"><hr>\n";
		echo "パスワード<BR>\n";
		echo '<input type="password" name="pw" size="8" maxlength="8"><br>',"\n";
		echo '</td></tr><tr align="center"><td>';
		echo '<input type="submit" name="submit" value="送信">',"\n";
		echo '</center>';
		footer();
	}
}

sub check_pass {
	my $id = $cgi->param('login_id');
	my $pw = $cgi->param('pw');
	$pw = substr(crypt($pw, $salt),2);
	if ($id eq '') {return(0);}
	my $flg = 0;
	open(MEM,"<$mem_file") or return(0);
	flock(MEM,1);
	while(<MEM>) {
		my ($nm,$ad_id,$ad_pw) = split(/<>/,$_);
		if ($id eq $ad_id && $pw eq $ad_pw) {
			$flg = 1;
			last;
		}
	}
	close(MEM);
	if ($flg) {set_cookie($id,$pw);}
	return($flg);
}

sub header {
	$url = get_url();
	$url = '.' . substr($url,rindex($url,'/'));
	my $text = shift;
	echo "Content-type: text/html\n\n";
	echo "<html>\n";
	echo "<head>\n";
	echo '<meta http-equiv="Content-Type" content="text/html; charset=',$ifo{'outchr'},'">',"\n";
	print '<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1">',"\n";
	echo "<title>$page_title</title>\n";
	echo "<style type='text/css'>\n";
	echo "body {font-family:'ＭＳ Ｐゴシック','IPA モナー Pゴシック',sans-serif;\n";
	echo "font-size:16px;line-height:18px;\n";
	print "word-break:break-all;}\n";
	echo "</style>\n";
	echo "</head>\n";
	echo "<body>\n";
	echo "<form action=\"$url\" method=\"POST\">\n";
	echo "<center><br>\n";
	echo '<font size=+1><b>',$text,"</b></font><br><br>\n";
	echo '<table border=2>';
	echo "<tr>\n";
}

sub footer {
	echo '</td></tr>';
	echo "</center>\n";
	print "<input type='hidden' name='bbs' value='$bbs'>\n";
	print "<input type='hidden' name='category' value='$category'>\n";
	print "<input type='hidden' name='type' value='$type'>\n";
	echo "</form>\n";
	echo "</body></html>\n";
	exit(0);
}

#索引作成関数
sub makeindex {
	my $bbs = shift;
	my $key = shift;
	my $mode = shift;	#1=書き込み可 -1=書き込み不可
	($mode == 1 or $mode==-1) or return("makeindex:引数が間違っています<br>\n");
	my $fname = "../$bbs/dat/$key.dat";		#datファイル
	open(LOG,"< $fname") or return("$fname が開けませんでした");
	flock(LOG,1);
	$fname = "../$bbs/idx/$key.idx";		#索引ファイル
	if (-e $fname) {
		if (!open(IDX,"+< $fname")) {
			close(LOG);
			return("$fname が開けませんでした<br>\n");
		}
	} else {
		if (!open(IDX,"> $fname")) {
			close(LOG);
			return("$fname が開けませんでした<br>\n");
		}
	}
	flock(IDX,2);
	binmode(IDX);
	seek(LOG,0,0);
	seek(IDX,0,0);
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
	$buf = pack("l",$count * $mode);
	print IDX $buf;
	close(LOG);
	close(IDX);
	return("索引 $fname を作成しました<br>\n");
}

sub error_exit {
	my $text = shift;
	echo "Content-type: text/html\n\n";
	echo '<html>';
	echo '<head>';
	echo '<meta http-equiv="Content-Type" content="text/html; charset=',$ifo{'outchr'},'">';
	echo '<title>$page_title</title>';
	echo '<body>';
	echo '<br><center><b><font color="#FF0000">',$text,'</font></b></center><br>';
	echo '</body></html>';
	exit(0);
}

sub check_double {
	my $text = shift;
	my @list = split('',$text);
	my $double = '';
	my %check;
	foreach my $tmp (@list) {
		if ($check{$tmp}) {
			$check{$tmp} += 1;
			$double .= $tmp;
		} else {
			$check{$tmp} = 1;
		}
	}
	return ($double);
}
1;
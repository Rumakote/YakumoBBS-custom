use utf8;
use LWP::Simple;

sub edit_title {
	my $submit = shift;
	if ($submit eq $modoru) {
		show_menu();
	}
	header("掲示板タイトル編集");
	my @list = read_tbl('../bbs.txt');
	my ($top,$title,$subtitle) = split('<>',$list[1]);
	echo "<td align='center'>掲示板タイトル<br>";
	print "<input type='text' name='title' value='$title'><br>\n";
	echo "掲示板サブタイトル<br>\n";
	print "<input type='text' name='subtitle' value='$subtitle'>\n";
	submit_exe();
	print "<input type='hidden' name='opt' value='title_exe'>\n";
}

sub exe_title {
	my $submit = shift;
	if ($submit eq $modoru) {
		menu_bbs();
		footer();
	}
	header("掲示板タイトル登録");
	my $title = $cgi->param('title');
	my $subtitle = $cgi->param('subtitle');
	my $er = '';
	if ($title eq '') {
		$er = "タイトルは１文字以上指定して下さい<br>\n";
	} else {
		if ($title =~ /[<>]/) {$er = "タイトルに半角不等号は使えません<br>\n";}
	}
	if ($er eq '') {
		if ($subtitle eq '') {$subtitle = $title;}
		my @list = read_tbl('../bbs.txt');
		$list[0] = "$ifo{'outchr'}<>$ifo{bbskey}\n";
		$list[1] = "$ifo{'site_top'}<>$title<>$subtitle\n";
		my $text = '';
		foreach $data(@list) {
			$text .= $data;
		}
		if (write_file('../bbs.txt',\$text,0)) {
			echo "<td>掲示板タイトルを登録しました\n";
		} else {
			echo "<td>掲示板タイトルの登録に失敗しました\n";
		}
	} else {
		echo "<td>$er";
	}
	submit_ret();
	print "<input type='hidden' name='opt' value='modoru'>\n";
}

sub get_bbs_title {
	my @list = read_tbl('../bbs.txt');
	my ($tmp,$title,$subtitle) = split('<>',$list[1]);
	return($title,trim($subtitle));
}

sub rewrite_bbstxt {
	my ($title,$subtitle) = get_bbs_title();
	my $text = trim(read_file('../ifo/category.cgi'));
	my $top = get_top();
	if ($text eq '') {
		my @list = read_tbl('../ifo/board.cgi');
		foreach $data(@list) {
			my ($dir,$name) = split('<>',$data);
			$text .= "$top$dir/<>$name\n";
		}
	} else {
		my @list = split("\n",$text);
		$text = '';
		my @cat_list;
		my @board_list = read_tbl('../category.txt');
		@board_list = board_full(@board_list);
		foreach $data(@list) {
			if (index($data,'http://') >= 0) {
				my $tmp = get($data.'category.txt');
				my @site = split("\n",trim($tmp));
				foreach $tmp(@site) {
					if ($tmp eq '') {next;}
					my ($dir,$name) = split('<>',$tmp);
					if ($dir eq '') {
						if (cat_check($name,@cat_list)) {push(@cat_list,$name);}
						push(@board_list,$tmp);
					} else {
						push(@board_list,"$data$tmp");
					}
				}
				next;
			}
			if (cat_check($data,@cat_list)) {
				push(@cat_list,$data);
			}
		}
		foreach $data(@cat_list) {
			my $tmp = "category<>$data\n";
			my $flg = 0;
			foreach $board(@board_list) {
				my ($dir,$name) = split('<>',$board);
				if ($dir eq '') {
					if ($data eq $name) {
						$flg = 1;
					} else {
						$flg = 0;
					}
					next;
				}
				if ($flg) {
					$tmp .= "$dir/<>$name\n";
				}
			}
			if ($tmp ne "category<>$data\n") {$text .= $tmp;}
		}
	}
	$text = "$ifo{'outchr'}<>$ifo{'bbskey'}\n$ifo{'site_top'}<>$title<>$subtitle\n" . $text;
	if (write_file('../bbs.txt',\$text,0)) {
		return('');
	} else {
		return("掲示板情報の更新に失敗しました<br>\n");
	}
}

sub cat_check {		#同じ物が有れば0 無ければ1
	$name = shift;
	foreach $data(@_) {
		if ($data eq $name) {return(0);}
	}
	return(1);
}

sub board_full {
	my $top = get_top();
	my @ret;
	foreach $data(@_) {
		my ($dir,$name) = split('<>',$data);
		if ($dir eq '') {
			push(@ret,$data);
		} else {
			push(@ret,"$top$data");
		}
	}
	return(@ret);
}

sub get_bbs_list {
	my $kind = shift;
	my $br = shift;
	my $target = shift;
	my $text = '';
	if ($br eq 'tate') {
		$br = "<br>\n";
	} else {
		$br = " \n";
	}
	my $mode = '';
	if ($target eq '') {
		$mode = 'm/';
	} elsif (trim($target) eq '') {
		$target = '';
	}
	my @list = read_tbl('../bbs.txt');
	shift(@list);
	my $text = shift(@list);
	my ($bbs_title,$bbs_title,$bbs_subtitle) = split('<>',trim($text));
	$text = '';
	if ($kind eq 'category_bbs') {	#カテゴリ名とボード名
		my $hbr = '';
		foreach $data(@list) {
			my ($url,$name) = split('<>',trim($data));
			if ($url eq 'category') {
				$text .= "$hbr<b>$name</b>$br";
				$hbr = trim($br);
			} else {
				$text .= "<a href=\"$url$mode\"$target>$name</a>$br";
			}
		}
	} elsif ($kind eq 'bbs') {	#ボード名のみ
		foreach $data(@list) {
			my ($url,$name) = split('<>',trim($data));
			if ($url eq 'category') {next;}
			$text .= "<a href=\"$url$mode\"$target>$name</a>$br";
		}
	} else {			#カテゴリ名のみ
		my $cat_name = '';
		my $cnt = 1;
		my $page;
		my $page_w;
		my $mb;
		if ($mode eq 'm/') {
			$mb = '_mb';
			$page = read_file('../tmp_category_mb.html');
		} else {
			$mb = '_';
			$page = read_file('../tmp_category.html');
			$mb='';
			if (trim($target) eq '') {$target = '';}
			$bbs_title = val_sjis($bbs_title);
			$bbs_subtitle = val_sjis($bbs_subtitle);
		}
		my $cat_text = '';
		my $tmp;
		foreach $data(@list) {
			my ($url,$name) = split('<>',trim($data));
			if ($url eq 'category') {
				if ($cat_name ne '') {
					$page_w = $page;
					$tmp = ($mb eq '_mb' ?  val_sjis($cat_name) : $cat_name);
					$page_w =~ s/CATEGORY_NAME/$tmp/g;
					$page_w =~ s/BBS_TITLE/$bbs_title/g;
					$page_w =~ s/BBS_SUBTITLE/$bbs_subtitle/g;
					$page_w =~ s/tmp_//g;
					$tmp = ($mb eq '_mb' ?  val_sjis($cat_text) : $cat_text);
					substr($page_w,index($page_w,'BBS_LIST'),length('BBS_LIST'),$tmp);
					write_file("../category$mb$cnt.html",\$page_w,0);
					$cat_text = '';
					$cnt++;
				}
				$cat_name = $name;
				$text .= "<a href=\"./category$mb$cnt.html\"$target>$name</a>$br\n";
			} else {
				$cat_text .= "<a href=\"$url$mode\">$name</a>$br\n";
			}
		}
		if ($cat_name ne '') {
			$page_w = $page;
			$tmp = ($mb eq '_mb' ?  val_sjis($cat_name) : $cat_name);
			$page_w =~ s/CATEGORY_NAME/$tmp/g;
			$page_w =~ s/BBS_TITLE/$bbs_title/g;
			$page_w =~ s/BBS_SUBTITLE/$bbs_subtitle/g;
			$page_w =~ s/tmp_//g;
			$tmp = ($mb eq '_mb' ?  val_sjis($cat_text) : $cat_text);
			substr($page_w,index($page_w,'BBS_LIST'),length('BBS_LIST'),$tmp);
			write_file("../category$mb$cnt.html",\$page_w,0);
		}
	}
	return($text);
}
1;
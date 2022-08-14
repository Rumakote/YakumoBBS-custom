use utf8;

sub show_setting {
	my $bbs = shift;
	my $size = 19;
	my %setting = get_setting_txt($bbs);
	my @info = info_setting();
	echo "<td align='center'><input type=submit name=submit value='初期設定に戻す'></td></tr>\n";
	foreach $data(@info) {
	my ($id,$name,$width,@opt) = split(/<>/,$data);
		echo "<tr><td>$name";
		echo "</td>\n";
		my $span = ($width == 2 ? 2 : 1);
		echo "<td colspan='$span'>";
		if (@opt) {
			print "<select name='$id' size='1' style='width:100%'>\n";
			my $cnt = 0;
			my $check = 0;
			while ($cnt < @opt) {
				if ($opt[$cnt] eq $setting{$id}) { $check = $cnt;}
				$cnt++;
			}
			$cnt = 0;
			while ($cnt < @opt) {
				print "<option value='$opt[$cnt]'",($cnt == $check ? " selected='selected'" : ''),'>';
				print (@opt[$cnt] eq '' ? 'none' : $opt[$cnt]),"</option>\n";
				$cnt++;
			}
			print "</select>\n";
		} else {
			print "<input type='text' name='$id' value='$setting{$id}' ";
			print 'size=',$size * $span,'>';
		}
		print "</td>\n";
		if ($width == 1) {echo "<td bgcolor='$setting{$id}'>",'&nbsp;' x $size,"</td></tr>\n";}
	}
	submit_exe();
	print "<input type='hidden' name='OLD_NONAME' value='$setting{'NONAME_NAME'}'>\n";
	print "<input type='hidden' name='OLD_TITLE' value='$setting{'TITLE'}'>\n";
}

sub names_setting {
	my @names = info_setting();
	my $cnt = 0;
	while ($cnt < @names) {
		$names[$cnt] = substr($names[$cnt],0,index($names[$cnt],'<>'));
		$cnt++;
	}
	return (@names);
}

sub put_setting {
	my $bbs = shift;
	my %setting = @_;
	@_ =();
	@names = names_setting();
	my $cnt = 0;
	while ($cnt < @names) {
		if ($names[$cnt] =~ /^NANASHI_CHECK$|^timecount$|^timeclose$|^SAMBATIME$/) {
			$names[$cnt] = "$names[$cnt]=$setting{$names[$cnt]}\n";
		} else {
			$names[$cnt] = "BBS_$names[$cnt]=$setting{$names[$cnt]}\n";
		}
		$cnt++;
	}
	my $text = '';
	foreach $data(@names) {
		$text .= $data;
	}
	if ($setting{'IMG_MODE'} eq 'checked') {
		$text .= "BBS_MODE=picture\n";
		$text .= "BBS_IMG_MAX_SIZE=$ifo{'post_max'}\n";
	}
	my $fname = "../$bbs/SETTING.TXT";
	echo (write_file($fname,\$text,0) ? "$fname を更新しました<br>" : "$fname の更新失敗<br>");
	$text = "body {\n\tfont-family:'ＭＳ Ｐゴシック','IPA モナー Pゴシック',sans-serif;\n\tfont-size:16px;\n\t";
	$text .="line-height:18px;\n\tword-break:break-all;\n\tbackground-color:$setting{'BG_COLOR'}\n\t";
	$text .="color:$setting{'TEXT_COLOR'};\n\tbackground-image:url($setting{'BG_PICTURE'});\n}\n";
	$text .="a:link {color:$setting{'LINK_COLOR'};}\na:active\t{color:$setting{'ALINK_COLOR'};}\n";
	$text .="a:visited\t{color:$setting{'VLINK_COLOR'};}\n";
	$fname = "../$bbs/color.css";
	echo (write_file($fname,\$text,0) ? "$fname を更新しました<br>" : "$fname の更新失敗<br>");
}

sub info_setting {
	my @pic = glob("$ifo{'images'}*");
	my $files = '';
	foreach $data(@pic) {
		$files .= "<>$data";
	}
	if ($files ne '') { $files = "<>$files";}
	my $cnt;
	my $str = '';
	($cnt,$cnt,$cnt) = split('<>',trim(read_file('../ifo/enigma.cgi')));
	if ($cnt =~ /^\d+$/) {
		my $cn;
		for ($cn = 0;$cn <= $cnt;$cn++) {
			$str .= "<>$cn";
		}
	}
	my @set_info = (
	'TITLE<>ボードタイトル（携帯とタイトルタグ）<>2',
	'SUBTITLE<>ボードサブタイトル（パソコン画面）<>2',
	"TITLE_PICTURE<>ボードタイトル画像<>2$files",
	'TITLE_COLOR<>ボード名称の色<>1',
	'TITLE_LINK<>タイトル画像クリック時の行き先url<>2',
	'MOBILE_LINK<>携帯で「主」クリック時の行き先url<>2',
	'BG_COLOR<>背景画像無しの時の背景色<>1',
	"BG_PICTURE<>トップページの背景画像<>2$files",
	'NONAME_NAME<>名前欄を空欄にした時の名前<>2',
	'DELETE_NAME<>削除レスに表示する文字<>0',
	'MAKETHREAD_COLOR<>スレ立て欄の背景色<>1',
	'MENU_COLOR<>スレッド一覧の背景色<>1',
	'THREAD_COLOR<>スレッドの背景色<>1',
	'TEXT_COLOR<>文字の色<>1',
	'NAME_COLOR<>名前欄の色<>1',
	'LINK_COLOR<>リンクの色<>1',
	'ALINK_COLOR<>選択中のリンクの色<>1',
	'VLINK_COLOR<>表示済みリンクの色<>1',
	'THREAD_NUMBER<>index.htmlに表示するスレッド数<>0',
	'CONTENTS_NUMBER<>index.htmlに表示するレス数<>0',
	'LINE_NUMBER<>index.htmlで省略しないレス行数<>0',
	'MAX_MENU_THREAD<>index.htmlに表示するスレッド名の数<>0',
	'SUBJECT_COLOR<>スレッドタイトルの色<>1',
	'SUBJECT_COUNT<>スレッドタイトル最大長<>0',
	'NAME_COUNT<>名前欄の最大長<>0',
	'MAIL_COUNT<>メール欄の最大長<>0',
	'MESSAGE_COUNT<>投稿本文の最大長<>0',
	'MESSAGE_LINE<>投稿本文の最大行数<>0',
	'MAX_THREAD<>スレッド数上限<>0',
	'timecount<>投稿記録保持件数<>0',
	'timeclose<>投稿可能件数<>0',
	'THREAD_TATESUGI<>スレ立て可能件数<>0',
	'SAMBATIME<>連続投稿禁止時間（秒）<>0',
	'NANASHI_CHECK<>名前欄の設定<>0<><>1<>2<>3<>4',
	'FORCE_ID<>ID番号の表示<>0<><>checked',
	'SLIP<>ID番号の末尾の端末判定<>0<><>checked',
	'DISP_HOST<>IDにリモートホストを表示<>0<><>checked',
	'DISP_IP<>IDにIPアドレスを表示<>0<><>checked',
	
	"READONLY<>板の書き込み制限<>0<><>checked<>caps<>trip$str",
	"THREAD_MAKE<>スレ立て制限<>0<><>checked<>caps<>trip$str",
	
	'MOBILE_CAP<>携帯IDをキャップ設定<>0<><>checked',
	'PASSWORD_CHECK<>新規スレッド作成を別画面にする<>0<><>checked',
	'IMG_MODE<>画像投稿対応<>0<><>checked',
	'IMG_THUMBNAIL_X<>サムネール最大横幅<>0',
	'IMG_THUMBNAIL_Y<>サムネール最大縦幅<>0',
	'IMG_SMN_QLT<>サムネール画質<>0',
	'IMG_JPG_QLT<>Jpeg変換画質<>0',
	'ERROR_LOG<>エラーログの記録<>0<><>checked',

	'KEYWORDS<>掲示板のkeywords（内容をカンマで区切る）<>2',
	'DESCRIPTION<>掲示板のdescription（概要）<>2',
	'SITE_KEY<>Captchaのサイトキー（空欄で無効）<>2',
	'SECRET_KEY<>ReCaptchaのシークレットキー（空欄で無効）<>2',
	'H_SECRET_KEY<>hCaptchaのシークレットキー（空欄で無効）<>2',
	'PICTURE_PREVIEW<>Imgerなどの画像URLのプレビュー表示<>0<><>checked',
	'YOUTUBE_PREVIEW<>Youtubeの動画URLのプレビュー表示<>0<><>checked',
	);
	return(@set_info);
}

1;
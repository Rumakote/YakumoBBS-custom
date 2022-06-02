#!/usr/bin/perl

use utf8;
use Time::HiRes qw(gettimeofday);

$call = 'b.cgi';
($time,$micro) = gettimeofday;
require './sub/common.pl';			#初期設定と共通サブルーチン
require './sub/info.pl';			#時間と文字変換＆エラー処理
require './sub/check.pl';			#データ受信とチェックサブルーチン
get_data();
check_data();					#規制チェック、変数のセット
if ($img_type) {
	if($ifo{'img_lib'}) {
		require './sub/image'.$ifo{'img_lib'}.'.pl';	#画像変換サブルーチン
	}
	require './sub/image.pl';		#画像アップロードサブルーチン
}
require './sub/write.pl';			#書き込み関係サブルーチン
$cmp_flg = 0;
if ($ifo{'comp'}) {
	$now = time();
	my $count = read_file("../$bbs/ifo/comp.txt");
	unless($count) {$count = 0;}
	if ($count <= ($now - $ifo{'down_time'} * 1800)) {	#時間 / 2 * 60 * 60 = 時間 * 1800
		require './sub/move.pl';	#スレッド数圧縮サブルーチン
		$cmp_flg = 1;
	}
}
put_data();					#レス追加、スレ立て、subject.txtの更新
#課題index.htmlを更新しなくて良い場合の判定
if ($setting{'IMG_MODE'} eq 'checked') {
	if ($ifo{'img_lib'}) {
		require "$dir/test/sub/smn".$ifo{'img_lib'}.'.pl';
	} else {
		require "$dir/test/sub/smn.pl";
	}
}
require './sub/page.pl';			#index.html書き換えサブルーチン
require './sub/mobile.pl';			#携帯用index.htmlのサブルーチン
put_page($bbs);					#index.html、スレタイ一覧ページ作成
($etime,$emicro) = gettimeofday;
$etime = $etime - $time + ($emicro - $micro) / 1000000;
go_next();					#書き込み完了を表示して次ページへジャンプ
exit(0);

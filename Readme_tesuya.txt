必要なPerlモジュール

・BBS本体より
UNIX系サーバー（Windowsではローカルサーバーでの動作テスト以外はむずかしいと思われます）
perl 5.8以上
perl標準ライブラリの内utf8/CGI/Encode/File::Path/File::Copy/LWP::Simpleモジュールが必要
cgiスクリプトからパーミッションの変更が出来る（cgiが設置者権限で動作する）こと
flock/truncate/tellの命令が正常動作すること
（古いＯＳを使ったサーバーでなければ大丈夫のはずです）
cgi、html、画像ファイルを同じサーバースペースに置けること
サーバースペース10MB以上


・推奨動作環境

Linux
Apache
サーバースペース1GB以上

・無くても動作するけど有ると良い物

Image::MagickまたはGD::Image画像処理モジュール
IPAモナーフォント（携帯用アスキーアートビューアーで使用）
cron設定機能（現バージョンでは使いません）


（私の独自調べ）
あと独自に調べてみたらDigest/SHA1.pmが要りました。


・このプログラムより
CGI
LWP::UserAgent
JSON::Parse（これのインストールがやや難しいので、できなかったらsubフォルダのwrite.plの4行目をコメントアウトしてください。captcha機能は使えなくなりますが...）



必要なら適宜インストールしてください。
できればcPanel付きの共有ホスティングかVPSが良いでしょう。
XREAのサーバとかは多分ダメです。

.cgiファイルでエラーが出たら該当ファイルを開いて
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
を追記して足りないPerlモジュールを洗い出すと良いでしょう。

これは小林幸治様が開発したYakumoBBSのVer1.01gを私が独自に改良したものです。
http://yakumotatu.com/yakumobbs/


DLしたこれらのファイルをtestフォルダの中に放り込んで上書きしてください。
そうすれば使えます。

追加した機能
・掲示板トップで背景が表示されない不具合を解消
・ReCaptcha・hCaptchaを実装（ボード設定から設定できます）
・ボード設定から掲示板のmeta要素（タグと概要）を設定できるようにしました
・<head>から</head>間の設定ができるようにしました（header.txt）で保存されます
・「CGI::param called in list context from」のエラーが出ないように修正
・JavaScriptが有効な時に限り、Youtubeの動画のURLを載せるとサムネが表示されるように


reCaptchaもしくはhCaptcha認証のキーは下記から入手できます。
https://www.google.com/recaptcha/about
https://www.hcaptcha.com


2021/11/28 ◆2/KVgIo.4uKh（◆zbu3opyYuk）より


2022/9/12
画像プレビューありで画像を表示すると余分なURLがついてきたのを修正


2022/9/3
したらばにならってスレッドの閲覧ページに入るとFacebookとTwitterとLINEのSNSシェアボタンが表示されるように設定
これもボード設定で表示するか否かを設定できます
下記のページを参考にしました
http://stooorm.com/memo/2020/10/16/post-342/


2022/8/14
imgurなどの画像サイトから画像URLを書き込んだ際にプレビューが表示されるように改良
ボード設定でプレビュー表示の有無を変更できます


2022/4/20
画像を除いたOGP設定が自動で行われるように設定しました
画像もOGPが設定できるようにしたかったのですが、絶対パスで設定しないといけません
上手く設定できるようにできませんでした・・・
Headタグ追加で当面は上手く設定してください


2022/3/31
JavaScriptが有効な時に限り、Youtubeの動画のURLを載せるとサムネが表示されるようにしました
参考にしたサイト様
https://myscreate.com/youtube-defer/
https://qiita.com/niwasawa/items/bb1243c65b7b2eaa224f
https://follmy.com/ruby-youtube-embeded/


2022/1/5
追記：
YakumoBBSの作者様より改造とそれを行った改造版の再配布の許可を頂きました。具体的には
「改造版の配布に関しては、YakumoBBSscriptとは全く別の名称にし、
YakumoBBSのどのバージョンを元にしたか分かる表記をしておけば良いとします。
フリーソフトとして配布しても、有料でも、再配布禁止としても構いません。」
との事です。代わりの名前で良いものが見つからないので現段階では名称は未定とします。
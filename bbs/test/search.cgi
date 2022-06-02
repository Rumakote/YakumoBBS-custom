#!/usr/bin/perl --

use utf8;
$subcmd = './sub';		#サブルーチンのディレクトリ
require "$subcmd/admin.pl";	#管理者用サブルーチン
require "$subcmd/common.pl";
my %setting = init_setting();

#require "$subcmd/page.pl";

sub echo {
    my @text = @_;
    foreach my $echo ( @text ) {
        print enc_str($echo);
    }
}

use CGI;
use Data::Dumper;

my $page_title = "検索ページ";

my $q = CGI->new;
my $search = $q->param('search');

my @list = board_list();
my @dat_list;
my $url = get_top();

foreach $data(@list){
    my ($dir, $board_title) = split(/<>/, $data);

    $bbs = $dir;
    get_subject();
    foreach $subject(@sbj_txt){
	my ($dat, $thread_title) = split(/<>/, $subject);
	$thread_title =~ s/(.*)\(\d+\)$/\1/;
	@dat_list = (@dat_list, [$dir, $dat, $board_title, $thread_title]);
    }
}


if($search eq ""){
    search_header();

    my $submit = enc_str("検索");
    my $reset = enc_str("リセット");
    
    print "<form action=\"./search.cgi\" method=\"post\">\n";
    print "<div class=\"flexbox\">\n";
    ul_boardlist();
    print "<div class=\"searchform\">\n";
    print "<input type=\"text\" name=\"search\">\n";
    print "<input type=\"submit\" value=\"$submit\">\n";
    print "<input type=\"reset\" value=\"$reset\"><br/>\n";
    echo "<input type=\"radio\" name=\"searchtype\" value=\"andsearch\" checked>AND検索\n";
    echo "<input type=\"radio\" name=\"searchtype\" value=\"orsearch\">OR検索<br/>\n";
    print "</div></div></form>\n";
    echo "<div><a href=\"$url\">掲示板トップページ</a></div>\n";
} else {
    search_header();
    echo "検索ワード: ";
    print $search . "<br/>";
    my $searchtype = $q->param('searchtype');
    my @searchthread = $q->multi_param('thread');

    if($searchtype eq "andsearch"){
	echo "AND検索<br/>\n";
    } else {
	echo "OR検索<br/>\n";
    }
    
    my @result_list;

    my $sp = enc_str('　'); # 全角空白
    my @search_words=split(/[\s$sp]+/,$search);
    
    foreach $fdat(@dat_list){
	my $dir=$fdat->[0];
	my $dat=$fdat->[1];
	my $board_title=$fdat->[2];
	my $thread_title=$fdat->[3];

	foreach $thread(@searchthread){
	    if($thread eq "$dir:$dat"){
		open(FDAT, "<", "../$dir/dat/$dat") or die("Error");
		my $num=1;
		while(<FDAT>){
		    my @list =split(/<>/);
		    $comment = $list[3];
		    #		print "$comment<br/>";
		    my $flag=0;
		    foreach $s(@search_words){
			if ($comment =~ /$s/){
			    $flag=1;
			    if($searchtype eq "orsearch"){
				last;
			    }
			} else {
			    $flag=0;
			    if($searchtype eq "andsearch"){
				last;
			    }
			}
		    }
		    if ($flag == 1){
			@result_list = (@result_list, [$dir, $dat, $board_title, $thread_title, $num, $_]);
		    }
		    $num++;
		}
		close(FDAT);
	    }
	}
	
    }

    echo "検索結果: ";
    print $#result_list+1;
    echo "件<br/>";

    print "<div>\n";
    foreach $result(@result_list){
	my $dir = $result->[0];
	my $dat = $result->[1];
	my $thread_num = substr($dat,0,length($dat)-4);
	my $board_title = $result->[2];
	my $thread_title = $result->[3];
	my $num= $result->[4];
	my $dat_line = $result->[5];

	my ($name,$mail,$ifo,$message) = split(/<>/,$dat_line);
	print "<div class=\"searchresult\"><div>$num <font color =\"$setting{'NAME_COLOR'}\">";
	if ($mail) {
	    print "<a href=\"mailto:$mail\">";
	}
	print "<b>$name </b>";
	if ($mail) {
	    print '</a>';
	}
	print enc_str('</font>：').$ifo."</div>\n";
	print "<div class=\"searchmessage\">$message<br/>\n";
	
	print "<a href=\"./read.cgi/$dir/$thread_num/$num\" target=\"new\">$board_title -- $thread_title</a></div></div>";

    }
    print "</div>\n";
}
print $q->end_html();


sub search_header()
{
    print "Content-type: text/html\n\n";
    print "<!DOCTYPE html>\n";
    print "<html lang=\"ja\">\n";
    print "<head>\n";
    print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=$ifo{'outchr'}\">\n";
    print "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,maximum-scale=1\">\n";
    echo "<title>$page_title</title>\n";
    print "<script src=\"./search.js\"></script>\n";
    print "<link rel=\"stylesheet\" href=\"./search.css\">\n";
    print "</head>\n";
    print "<body>\n";
}

sub ul_boardlist()
{
    my $select_all = enc_str("すべて選択");
    my $previous_board_title;
    print <<"END";
    <div class=\"boardlist\">
    <div>
    <input type="checkbox" id="select-all" name="select-all" value="select-all" checked>
    <label for="select-all">$select_all</label>
    </div>
END

    print "<div><ul>\n";
    foreach $fdat(@dat_list){
	my $dir = $fdat->[0];
	my $dat = $fdat->[1];
	my $board_title = $fdat->[2];
	my $thread_title = $fdat->[3];
	if($previous_board_title eq ""){
	    print_li_input($dir, $board_title, "board");
	    print "<ul>\n";
	    print_li_input($dir.":".$dat, $thread_title, "thread");
	} elsif ($previous_board_title eq $board_title){
	    print_li_input($dir.":".$dat, $thread_title, "thread");
	    print "</li>\n";
	} else {
	    print "</ul></li>\n";
	    print_li_input($dir, $board_title, "board");
	    print "<ul>\n";
	    print_li_input($dir.":".$dat, $thread_title, "thread");
	    print "</li>\n";
	}
	$previous_board_title = $board_title;
    }
    print "</ul></ul></div></div>\n";
}

sub print_li_input()
{
    print "<li><input type=\"checkbox\" id=\"$_[0]\" name=\"$_[2]\" value=\"$_[0]\" checked><label for=\"$_[0]\">$_[1]</label>";
}


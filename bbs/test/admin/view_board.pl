use utf8;

view_board();

sub view_board {
	if ($bbs eq '') {show_menu();}
	header('ボードを見る');
	my $uri = get_top();
	my $name = check_board($bbs);
	print "<td>$bbs<br>$name</td></tr><tr><td>\n";
	echo "<a href='$uri$bbs/' target='_blank'>ボード（ＰＣ）確認</a><br>";
	echo "<a href='$uri$bbs/m/' target='_blank'>ボード(携帯)確認</a>";
	submit_ret();
}
1;
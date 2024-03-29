﻿use utf8;

sub html_txt {
	my $str = shift;
	$str = dec_str($str);
	$str = str_cnv($str);
	my @tmp = split(/<br>/,$str);
	my @text;
	my $len;
	my $width = 0;

	foreach $data(@tmp) {
		$data =~ s/^ +//;			#行頭の半角スペース削除
		$data =~ s/ +/ /g;			#２個以上の半角スペースは１個に
		$data =~ s/<.*?>//g;			#htmlタグ削除
		$data =~ s/&nbsp;|&#160;|&#xA0/ /g;	#半角スペース変換
		$len = length(enc_sjis($data));
		if ($width < $len) {$width = $len;}
		$data =~ s/\\/\\\\/g;			#円記号変換
		push(@text,$data);
	}
	return ($width , @text);
}

sub str_cnv {
	my $text = shift;
	my @src = (
	'&quot;|&#34;|&#x22;',
	'&amp;|&#38;|&#x26;',
	'&lt;|&#60;|&#x3C;',
	'&gt;|&#62;|&#x3E;',
	'&iexcl;|&#161;|&#xA1;',
	'&cent;|&#162;|&#xA2;',
	'&pound;|&#163;|&#xA3;',
	'&curren;|&#164;|&#xA4;',
	'&yen;|&#165;|&#xA5;',
	'&brvbar;|&#166;|&#xA6;',
	'&sect;|&#167;|&#xA7;',
	'&uml;|&#168;|&#xA8;',
	'&copy;|&#169;|&#xA9;',
	'&ordf;|&#170;|&#xAA;',
	'&laquo;|&#171;|&#xAB;',
	'&not;|&#172;|&#xAC;',
	'&shy;|&#173;|&#xAD;',
	'&reg;|&#174;|&#xAE;',
	'&macr;|&#175;|&#xAF;',
	'&deg;|&#176;|&#xB0;',
	'&plusmn;|&#177;|&#xB1;',
	'&sup2;|&#178;|&#xB2;',
	'&sup3;|&#179;|&#xB3;',
	'&acute;|&#180;|&#xB4;',
	'&micro;|&#181;|&#xB5;',
	'&para;|&#182;|&#xB6;',
	'&middot;|&#183;|&#xB7;',
	'&cedil;|&#184;|&#xB8;',
	'&sup1;|&#185;|&#xB9;',
	'&ordm;|&#186;|&#xBA;',
	'&raquo;|&#187;|&#xBB;',
	'&frac14;|&#188;|&#xBC;',
	'&frac12;|&#189;|&#xBD;',
	'&frac34;|&#190;|&#xBE;',
	'&iquest;|&#191;|&#xBF;',
	'&Agrave;|&#192;|&#xC0;',
	'&Aacute;|&#193;|&#xC1;',
	'&Acirc;|&#194;|&#xC2;',
	'&Atilde;|&#195;|&#xC3;',
	'&Auml;|&#196;|&#xC4;',
	'&Aring;|&#197;|&#xC5;',
	'&AElig;|&#198;|&#xC6;',
	'&Ccedil;|&#199;|&#xC7;',
	'&Egrave;|&#200;|&#xC8;',
	'&Eacute;|&#201;|&#xC9;',
	'&Ecirc;|&#202;|&#xCA;',
	'&Euml;|&#203;|&#xCB;',
	'&Igrave;|&#204;|&#xCC;',
	'&Iacute;|&#205;|&#xCD;',
	'&Icirc;|&#206;|&#xCE;',
	'&Iuml;|&#207;|&#xCF;',
	'&ETH;|&#208;|&#xD0;',
	'&Ntilde;|&#209;|&#xD1;',
	'&Ograve;|&#210;|&#xD2;',
	'&Oacute;|&#211;|&#xD3;',
	'&Ocirc;|&#212;|&#xD4;',
	'&Otilde;|&#213;|&#xD5;',
	'&Ouml;|&#214;|&#xD6;',
	'&times;|&#215;|&#xD7;',
	'&Oslash;|&#216;|&#xD8;',
	'&Ugrave;|&#217;|&#xD9;',
	'&Uacute;|&#218;|&#xDA;',
	'&Ucirc;|&#219;|&#xDB;',
	'&Uuml;|&#220;|&#xDC;',
	'&Yacute;|&#221;|&#xDD;',
	'&THORN;|&#222;|&#xDE;',
	'&szlig;|&#223;|&#xDF;',
	'&agrave;|&#224;|&#xE0;',
	'&aacute;|&#225;|&#xE1;',
	'&acirc;|&#226;|&#xE2;',
	'&atilde;|&#227;|&#xE3;',
	'&auml;|&#228;|&#xE4;',
	'&aring;|&#229;|&#xE5;',
	'&aelig;|&#230;|&#xE6;',
	'&ccedil;|&#231;|&#xE7;',
	'&egrave;|&#232;|&#xE8;',
	'&eacute;|&#233;|&#xE9;',
	'&ecirc;|&#234;|&#xEA;',
	'&euml;|&#235;|&#xEB;',
	'&igrave;|&#236;|&#xEC;',
	'&iacute;|&#237;|&#xED;',
	'&icirc;|&#238;|&#xEE;',
	'&iuml;|&#239;|&#xEF;',
	'&eth;|&#240;|&#xF0;',
	'&ntilde;|&#241;|&#xF1;',
	'&ograve;|&#242;|&#xF2;',
	'&oacute;|&#243;|&#xF3;',
	'&ocirc;|&#244;|&#xF4;',
	'&otilde;|&#245;|&#xF5;',
	'&ouml;|&#246;|&#xF6;',
	'&divide;|&#247;|&#xF7;',
	'&oslash;|&#248;|&#xF8;',
	'&ugrave;|&#249;|&#xF9;',
	'&uacute;|&#250;|&#xFA;',
	'&ucirc;|&#251;|&#xFB;',
	'&uuml;|&#252;|&#xFC;',
	'&yacute;|&#253;|&#xFD;',
	'&thorn;|&#254;|&#xFE;',
	'&yuml;|&#255;|&#xFF;',
	'&OElig;|&#338;|&#x0152;',
	'&oelig;|&#339;|&#x0153;',
	'&Scaron;|&#352;|&#x0160;',
	'&scaron;|&#353;|&#x0161;',
	'&Yuml;|&#376;|&#x0178;',
	'&fnof;|&#402;|&#x00;',
	'&circ;|&#710;|&#x02C6;',
	'&tilde;|&#732;|&#x02DC;',
	'&Alpha;|&#913;|&#x391;',
	'&Beta;|&#914;|&#x392;',
	'&Gamma;|&#915;|&#x393;',
	'&Delta;|&#916;|&#x394;',
	'&Epsilon;|&#917;|&#x395;',
	'&Zeta;|&#918;|&#x396;',
	'&Eta;|&#919;|&#x397;',
	'&Theta;|&#920;|&#x398;',
	'&Iota;|&#921;|&#x399;',
	'&Kappa;|&#922;|&#x39A;',
	'&Lambda;|&#923;|&#x39B;',
	'&Mu;|&#924;|&#x39C;',
	'&Nu;|&#925;|&#x39D;',
	'&#xi;|&#926;|&#x39E;',
	'&Omicron;|&#927;|&#x39F;',
	'&Pi;|&#928;|&#x3A0;',
	'&Rho;|&#929;|&#x3A1;',
	'&Sigma;|&#931;|&#x3A3;',
	'&Tau;|&#932;|&#x3A4;',
	'&Upsilon;|&#933;|&#x3A5;',
	'&Phi;|&#934;|&#x3A6;',
	'&Chi;|&#935;|&#x3A7;',
	'&Psi;|&#936;|&#x3A8;', 
	'&Omega;|&#937;|&#x3A9;',
	'&alpha;|&#945;|&#x3B1;',
	'&beta;|&#946;|&#x3B2;',
	'&gamma;|&#947;|&#x3B3;',
	'&delta;|&#948;|&#x3B4;',
	'&epsilon;|&#949;|&#x3B5;',
	'&zeta;|&#950;|&#x3B6;',
	'&eta;|&#951;|&#x3B7;',
	'&theta;|&#952;|&#x3B8;',
	'&iota;|&#953;|&#x3B9;',
	'&kappa;|&#954;|&#x3BA;',
	'&lambda;|&#955;|&#x3BB;',
	'&mu;|&#956;|&#x3BC;',
	'&nu;|&#957;|&#x3BD;',
	'&#xi;|&#958;|&#x3BE;',
	'&omicron;|&#959;|&#x3BF;',
	'&pi;|&#960;|&#x3C0;',
	'&rho;|&#961;|&#x3C1;',
	'&sigmaf;|&#962;|&#x3C2;',
	'&sigma;|&#963;|&#x3C3;',
	'&tau;|&#964;|&#x3C4;',
	'&upsilon;|&#965;|&#x3C5;',
	'&phi;|&#966;|&#x3C6;',
	'&chi;|&#967;|&#x3C7;',
	'&psi;|&#968;|&#x3C8;',
	'&omega;|&#969;|&#x3C9;',
	'&thetasym;|&#977;|&#x3D1;',
	'&upsih;|&#978;|&#x3D2;',
	'&piv;|&#982;|&#x3D6;',
	'&bull;|&#8226;|&#x2022;',
	'&hellip;|&#8230;|&#x2026;',
	'&prime;|&#8242;|&#x2032;',
	'&Prime;|&#8243;|&#x2033;',
	'&oline;|&#8254;|&#x203E;',
	'&frasl;|&#8260;|&#x2044;',
	'&weierp;|&#8472;|&#x2118;',
	'&image;|&#8465;|&#x2111;',
	'&real;|&#8476;|&#x211C;',
	'&trade;|&#8482;|&#x2122;',
	'&alefsym;|&#8501;|&#x2135;',
	'&larr;|&#8592;|&#x2190;',
	'&uarr;|&#8593;|&#x2191;',
	'&rarr;|&#8594;|&#x2192;',
	'&darr;|&#8595;|&#x2193;',
	'&harr;|&#8596;|&#x2194;',
	'&crarr;|&#8629;|&#x21B5;',
	'&lArr;|&#8656;|&#x21D0;',
	'&uArr;|&#8657;|&#x21D1;',
	'&rArr;|&#8658;|&#x21D2;',
	'&dArr;|&#8659;|&#x21D3;',
	'&hArr;|&#8660;|&#x21D4;', 
	'&forall;|&#8704;|&#x2200;',
	'&part;|&#8706;|&#x2202;',
	'&exist;|&#8707;|&#x2203;',
	'&empty;|&#8709;|&#x2205;',
	'&nabla;|&#8711;|&#x2207;',
	'&isin;|&#8712;|&#x2208;', 
	'&notin;|&#8713;|&#x2209;',
	'&ni;|&#8715;|&#x220B;',
	'&prod;|&#8719;|&#x220F;',
	'&sum;|&#8721;|&#x2211;', 
	'&minus;|&#8722;|&#x2212;',
	'&lowast;|&#8727;|&#x2217;',
	'&radic;|&#8730;|&#x221A;',
	'&prop;|&#8733;|&#x221D;',
	'&infin;|&#8734;|&#x221E;',
	'&ang;|&#8736;|&#x2220;',
	'&and;|&#8743;|&#x2227;',
	'&or;|&#8744;|&#x2228;',
	'&cap;|&#8745;|&#x2229;',
	'&cup;|&#8746;|&#x222A;',
	'&int;|&#8747;|&#x222B;',
	'&there4;|&#8756;|&#x2234;',
	'&sim;|&#8764;|&#x223C;',
	'&cong;|&#8773;|&#x2245;',
	'&asymp;|&#8776;|&#x2248;',
	'&ne;|&#8800;|&#x2260;',
	'&equiv;|&#8801;|&#x2261;',
	'&le;|&#8804;|&#x2264;',
	'&ge;|&#8805;|&#x2265;',
	'&sub;|&#8834;|&#x2282;',
	'&sup;|&#8835;|&#x2283;',
	'&nsub;|&#8836;|&#x2284;',
	'&sube;|&#8838;|&#x2286;',
	'&supe;|&#8839;|&#x2287;',
	'&oplus;|&#8853;|&#x2295;',
	'&otimes;|&#8855;|&#x2297;',
	'&perp;|&#8869;|&#x22A5;',
	'&sdot;|&#8901;|&#x22C5;',
	'&lceil;|&#8968;|&#x2308;',
	'&rceil;|&#8969;|&#x2309;',
	'&lfloor;|&#8970;|&#x230A;',
	'&rfloor;|&#8971;|&#x230B;',
	'&lang;|&#9001;|&#x2329;',
	'&rang;|&#9002;|&#x232A;',
	'&loz;|&#9674;|&#x25CA;',
	'&spades;|&#9824;|&#x2660;',
	'&clubs;|&#9827;|&#x2663;',
	'&hearts;|&#9829;|&#x2665;',
	'&diams;|&#9830;|&#x2666;',
	'&ensp;|&#8194;|&#x2002;',
	'&emsp;|&#8195;|&#x2003;',
	'&thinsp;|&#8201;|&#x2009;',
	'&zwnj;|&#8204;|&#x200C;',
	'&zwj;|&#8205;|&#x200D;',
	'&lrm;|&#8206;|&#x200E;',
	'&rlm;|&#8207;|&#x200F;',
	'&ndash;|&#8211;|&#x2013;',
	'&mdash;|&#8212;|&#x2014;',
	'&lsquo;|&#8216;|&#x2018;',
	'&rsquo;|&#8217;|&#x2019;',
	'&sbquo;|&#8218;|&#x201A;',
	'&ldquo;|&#8220;|&#x201C;',
	'&rdquo;|&#8221;|&#x201D;',
	'&bdquo;|&#8222;|&#x201E;',
	'&dagger;|&#8224;|&#x2020;',
	'&Dagger;|&#8225;|&#x2021;',
	'&permil;|&#8240;|&#x2030;',
	'&lsaquo;|&#8249;|&#x2039;'
	);
	my @dst = (
		'"','&','<','>','¡','¢','£','¤','¥',
		'¦','§','¨','©','ª','«','¬','­','®','¯',
		'°','±','²','³','´','µ','¶','·','¸','¹',
		'º','»','¼','½','¾','¿','À','Á','Â','Ã',
		'Ä','Å','Æ','Ç','È','É','Ê','Ë','Ì','Í',		#50
		'Î','Ï','Ð','Ñ','Ò','Ó','Ô','Õ','Ö','×',
		'Ø','Ù','Ú','Û','Ü','Ý','Þ','ß','à','á',
		'â','ã','ä','å','æ','ç','è','é','ê','ë',
		'ì','í','î','ï','ð','ñ','ò','ó','ô','õ',
		'ö','÷','ø','ù','ú','û','ü','ý','þ','ÿ',		#100
		' C','e','S','s','y','ｆ','^','~','Α','Β',
		'Γ','Δ','Ε','Ζ','Η','Θ','Ι','Κ','Λ','Μ',
		'Ν','Ξ','Ο','Π','Ρ','Σ','Τ','Υ','Φ','Χ',
		'Ψ','Ω','α','β','γ','δ','ε','ζ','η','θ',
		'ι','κ','λ','μ','ν','ξ','ο','π','ρ','s',	#150
		'σ','τ','υ','φ','χ','ψ','ω','u','Y','w',
		'・','…','′','″','~','/','℘','ℑ','R','~',
		'x','←','↑','→','↓','↔','↲','⇐','⇑','⇒',		#
		'⇓','⇔','∀','∂','∃','∅','∇','∈','∉','∋',
		'∏','∑','−','∗','√','∝','∞','∠','∧','∨',		#200
		'∩','∪','∫','∴','∼','≅','≈','≠','≡','≤',
		'≥','⊂','⊃','⊄','⊆','⊇','⊕','⊗','⊥','⋅',
		'⌈','⌉','⌊','⌋','〈','〉','◊','♠','♣','♥',
		'♦',' ',' ',' ','','','','','–','—',
		'‘','’','‚','“','”','„','†','‡','‰','‹'		#250
	);
	my $j=@src;
	for(my $i=0;$i<$j;$i++) {
		$text =~ s/$src[$i]/$dst[$i]/g;
	}
	return($text);
}
1;

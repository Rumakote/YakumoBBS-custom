function getCookie (name) {
	var regexp = new RegExp('; ' + name + '(=([^;]*))?;');
	var match  = ('; ' + document.cookie + ';').match(regexp);
	return match ? decodeURIComponent(match[2]) : "";
}

function page () {
	var domain = "DOMAIN", path = "PATH";
	if (domain) {
		document.cookie = 'IZUMO=TAISHA; domain=' + domain + '; path=' + path;
	} else {
		document.cookie = 'IZUMO=TAISHA; path=' + path;
	}
	var N = getCookie("NAME"), M = getCookie("MAIL");
	if (N || M) {
		for (var i = 0;i < document.forms.length ; i++){
			if (document.forms[i].FROM && document.forms[i].mail) {
				if (N) {document.forms[i].FROM.value = N;}
				if (M) {document.forms[i].mail.value = M;}
			}
		}
	}
}

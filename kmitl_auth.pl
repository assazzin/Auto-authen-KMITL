use LWP::UserAgent;
use HTTP::Cookies;

$username=shift;
$password=shift;
system("clear");

print "[+] ------------------------------------------------------ [+]\n";
print "[ ]                Script By Ohm CSAG 2016                 [ ]\n";
print "[ ]               Create date: 26 July 2016                [ ]\n";
print "[ ]                                                        [ ]\n";
print "[ ]   Usage: perl kmitl_auth.pl username password          [ ]\n";
print "[ ]          Can use only Generation1                      [ ]\n";
print "[ ]                                                        [ ]\n";
print "[+] ------------------------------------------------------ [+]\n\n";
exit unless($username && $password);

%ssl_opts=(
	verify_hostname => 0,
	SSL_verify_mode => 0x00,
);
$cookie_jar=HTTP::Cookies->new(autosave=>1, hide_cookie2=>1);
$agent=LWP::UserAgent->new(
	agent => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:47.0) Gecko/20100101 Firefox/47.0',
	ssl_opts => {%ssl_opts},
	timeout => 30,
	cookie_jar => $cookie_jar
);

login(1);

while(1) {
	$time=localtime;
	print "[$time] Waiting 3 minutes..\n";
	sleep 180;
	heartbeat();
}






sub checkHTTPStatus {
	my $content=$_[0];
	my $http_code=$_[1];
	$content=~s/\r//g;
	if($content =~ /^HTTP\/1\.1 $http_code /) {
		return 1;
	} else { return 0; }
}
sub getLocation {
	my $content=$_[0];
	$content=~s/\r//g;
	($content)=$content =~ /Location: (.*?)\n/;
	return $content;
}
sub login {
	my $force=$_[0];
	$content=$agent->post('https://161.246.254.213/dana-na/auth/url_default/login.cgi',[
		'username' => $username,
		'password' => $password,
		'realm' => 'adminTestGroup',
		'tz_offset' => '420',
		'btnSubmit' => 'Sign in',
		'realm' => '%E0%B8%A3%E0%B8%B0%E0%B8%9A%E0%B8%9A%E0%B9%81%E0%B8%AD%E0%B8%84%E0%B9%80%E0%B8%84%E0%B8%B2%E0%B8%97%E0%B9%8C%E0%B9%80%E0%B8%81%E0%B9%88%E0%B8%B2+%28Generation1%29'#ระบบแอคเคาท์เก่า (Generation1)'
	])->as_string;

	while(1) {
		if(checkHTTPStatus($content,302)) {
			$location=getLocation($content);
			print " [+] 302 => $location\n";
			$content=$agent->get($location)->as_string;
		} else {
			if($content=~/You have the maximum number of sessions running/i && $force==1) {
				($SessionToEnd)=$content=~/SessionToEnd" value="(.*?)"/;
				($FormDataStr)=$content=~/FormDataStr" value="(.*?)"/;
				$content=$agent->post('https://161.246.254.213/dana-na/auth/url_default/login.cgi',[
					'SessionToEnd' => $SessionToEnd,
					'btnContinueSessionsToEnd' => 'Continue',
					'FormDataStr' => $FormDataStr
				])->as_string;
				print " You have the maximum number of session running.\n";
				redo;
			}
			elsif($content=~/You have the maximum number of sessions running/i) {
				print " You have the maximum number of session running. But script do not force login.\n";
			}
			last;
		}
	}
	print " Finish Sign in\n\n";
}
sub heartbeat {
	print " Sending heartbeat..\n";
	$agent->post('https://nac.kmitl.ac.th/dana/home/infranet.cgi?',[
		'heartbeat' => 1,
		'clientlessEnabled' => 1,
		'sessionExtension' => 0,
		'notification_originalmsg' => '%3Cfont%20color%3D%26%2334%3B%23FF0000%26%2334%3B%20size%20%3D4%3E%u0E1B%u0E23%u0E30%u0E01%u0E32%u0E28%3A%20%u0E40%u0E23%u0E35%u0E22%u0E19%u0E1C%u0E39%u0E49%u0E43%u0E0A%u0E49%u0E07%u0E32%u0E19%u0E23%u0E30%u0E1A%u0E1A%20Internet%20%u0E02%u0E2D%u0E07%u0E2A%u0E16%u0E32%u0E1A%u0E31%u0E19%20%u0E2F%20%20%20%u0E17%u0E35%u0E48%u0E43%u0E0A%u0E49%20Web%20Browser%20%u0E17%u0E35%u0E48%u0E23%u0E30%u0E1A%u0E1A%20Authen%20%u0E02%u0E2D%u0E07%u0E2A%u0E16%u0E32%u0E1A%u0E31%u0E19%u0E2F%u0E23%u0E2D%u0E07%u0E23%u0E31%u0E1A%u0E04%u0E37%u0E2D%20IE10%20%u0E2B%u0E23%u0E37%u0E2D%u0E15%u0E48%u0E33%u0E01%u0E27%u0E48%u0E32%20%3CBR%3E%20%20Mozilla%2C%20Firefox%2C%20Chrome%20%u0E17%u0E32%u0E07%u0E2A%u0E33%u0E19%u0E31%u0E01%u0E1A%u0E23%u0E34%u0E01%u0E32%u0E23%u0E04%u0E2D%u0E21%u0E1E%u0E34%u0E27%u0E40%u0E15%u0E2D%u0E23%u0E4C%u0E02%u0E2D%u0E07%u0E2D%u0E20%u0E31%u0E22%u0E43%u0E19%u0E04%u0E27%u0E32%u0E21%u0E44%u0E21%u0E48%u0E2A%u0E30%u0E14%u0E27%u0E01%20%20%3C/FONT%3E%3CBR%3E%3CBR%3E%20%20%20%20%3Cfont%20size%3D4%3E%20%3CBR%3E%u0E2B%u0E19%u0E49%u0E32%20Page%20%u0E19%u0E35%u0E49%20%u0E23%u0E30%u0E1A%u0E1A%u0E22%u0E37%u0E19%u0E22%u0E31%u0E19%u0E15%u0E31%u0E27%u0E15%u0E19%u0E02%u0E2D%u0E07%u0E2A%u0E16%u0E32%u0E1A%u0E31%u0E19%u0E2F%20%u0E43%u0E0A%u0E49%u0E43%u0E19%u0E01%u0E32%u0E23%u0E15%u0E23%u0E27%u0E08%u0E2A%u0E2D%u0E1A%u0E2A%u0E16%u0E32%u0E19%u0E30%u0E02%u0E2D%u0E07%u0E40%u0E04%u0E23%u0E37%u0E48%u0E2D%u0E07%u0E17%u0E35%u0E48%u0E17%u0E33%u0E01%u0E32%u0E23%20Login%20%u0E14%u0E31%u0E07%u0E19%u0E31%u0E49%u0E19%u0E43%u0E19%u0E01%u0E32%u0E23%u0E43%u0E0A%u0E49%u0E07%u0E32%u0E19%u0E2D%u0E34%u0E19%u0E40%u0E15%u0E2D%u0E23%u0E4C%u0E40%u0E19%u0E47%u0E15%3CBR%3E%u0E15%u0E49%u0E2D%u0E07%u0E40%u0E1B%u0E34%u0E14%u0E2B%u0E19%u0E49%u0E32%20Page%20%u0E19%u0E35%u0E49%u0E44%u0E27%u0E49%20%u0E21%u0E34%u0E09%u0E30%u0E19%u0E31%u0E49%u0E19%u0E17%u0E48%u0E32%u0E19%u0E08%u0E30%u0E44%u0E21%u0E48%u0E2A%u0E32%u0E21%u0E32%u0E23%u0E16%u0E43%u0E0A%u0E49%u0E07%u0E32%u0E19%u0E2D%u0E34%u0E19%u0E40%u0E15%u0E2D%u0E23%u0E4C%u0E40%u0E19%u0E47%u0E15%u0E44%u0E14%u0E49%20%20%20%u0E40%u0E1E%u0E37%u0E48%u0E2D%u0E1B%u0E49%u0E2D%u0E07%u0E01%u0E31%u0E19%u0E01%u0E32%u0E23%u0E19%u0E33%u0E40%u0E04%u0E23%u0E37%u0E48%u0E2D%u0E07%u0E17%u0E35%u0E48%20Login%20%u0E14%u0E49%u0E27%u0E22%20User%20%u0E02%u0E2D%u0E07%u0E17%u0E48%u0E32%u0E19%3CBR%3E%u0E44%u0E1B%u0E43%u0E0A%u0E49%u0E07%u0E32%u0E19%20%u0E40%u0E21%u0E37%u0E48%u0E2D%u0E43%u0E0A%u0E49%u0E07%u0E32%u0E19%u0E40%u0E2A%u0E23%u0E47%u0E08%u0E41%u0E25%u0E49%u0E27%u0E01%u0E23%u0E38%u0E13%u0E32%20Logout%20%28%u0E2D%u0E2D%u0E01%u0E08%u0E32%u0E01%u0E23%u0E30%u0E1A%u0E1A%u0E17%u0E31%u0E19%u0E17%u0E35%29%20%u0E2B%u0E23%u0E37%u0E2D%20%u0E1B%u0E34%u0E14%u0E2B%u0E19%u0E49%u0E32%20page%20%u0E19%u0E35%u0E49%u0E40%u0E04%u0E23%u0E37%u0E48%u0E2D%u0E07%u0E02%u0E2D%u0E07%u0E17%u0E48%u0E32%u0E19%u0E08%u0E30%u0E2A%u0E32%u0E21%u0E32%u0E23%u0E16%u0E43%u0E0A%u0E49%u0E07%u0E32%u0E19%u0E44%u0E14%u0E49%u0E2D%u0E35%u0E01%205%20%u0E19%u0E32%u0E17%u0E35%20%20%20%3C/FONT%3E%3CBR%3E%3CBR%3E%20%20%20%20%3Cfont%20size%3D4%3E%20%u0E40%u0E1E%u0E37%u0E48%u0E2D%u0E43%u0E2B%u0E49%u0E01%u0E32%u0E23%u0E43%u0E0A%u0E49%u0E07%u0E32%u0E19%u0E40%u0E04%u0E23%u0E37%u0E48%u0E2D%u0E07%u0E02%u0E2D%u0E17%u0E48%u0E32%u0E19%u0E44%u0E21%u0E48%u0E23%u0E1A%u0E01%u0E27%u0E19%u0E01%u0E32%u0E23%u0E43%u0E0A%u0E49%u0E07%u0E32%u0E19%u0E40%u0E04%u0E23%u0E37%u0E2D%u0E02%u0E48%u0E32%u0E22%u0E02%u0E2D%u0E07%u0E1C%u0E39%u0E49%u0E2D%u0E37%u0E48%u0E19%20%20%u0E02%u0E2D%u0E43%u0E2B%u0E49%u0E17%u0E48%u0E32%u0E19%u0E15%u0E23%u0E27%u0E08%u0E2A%u0E2D%u0E1A%u0E42%u0E1B%u0E23%u0E41%u0E01%u0E23%u0E21%u0E15%u0E48%u0E32%u0E07%20%u0E46%20%u0E17%u0E35%u0E48%u0E15%u0E34%u0E14%u0E15%u0E31%u0E49%u0E07%u0E1A%u0E19%u0E40%u0E04%u0E23%u0E37%u0E48%u0E2D%u0E07%u0E02%u0E2D%u0E07%u0E17%u0E48%u0E32%u0E19%3CBR%3E%u0E04%u0E27%u0E23%u0E16%u0E39%u0E01%u0E15%u0E49%u0E2D%u0E07%u0E25%u0E34%u0E02%u0E2A%u0E34%u0E17%u0E18%u0E34%20%u0E04%u0E27%u0E23%u0E15%u0E34%u0E14%u0E15%u0E31%u0E49%u0E07%u0E23%u0E30%u0E1A%u0E1A%u0E1B%u0E49%u0E2D%u0E07%u0E44%u0E27%u0E23%u0E31%u0E2A%u0E41%u0E25%u0E30%20firewall%20%20%u0E41%u0E25%u0E30%u0E44%u0E21%u0E48%u0E04%u0E27%u0E23%u0E25%u0E07%u0E42%u0E1B%u0E23%u0E41%u0E01%u0E23%u0E21%u0E17%u0E35%u0E48%u0E40%u0E2A%u0E35%u0E48%u0E22%u0E07%u0E15%u0E48%u0E2D%u0E01%u0E32%u0E23%u0E17%u0E33%u0E43%u0E2B%u0E49%u0E23%u0E30%u0E1A%u0E1A%u0E40%u0E04%u0E23%u0E37%u0E2D%u0E02%u0E48%u0E32%u0E22%u0E2A%u0E48%u0E27%u0E19%u0E01%u0E25%u0E32%u0E07%u0E40%u0E01%u0E34%u0E14%u0E1B%u0E31%u0E0D%u0E2B%u0E32%3CBR%3E%20%u0E44%u0E21%u0E48%u0E01%u0E23%u0E30%u0E17%u0E33%u0E1C%u0E34%u0E14%u0E15%u0E32%u0E21%u0E1E%u0E23%u0E30%u0E23%u0E32%u0E0A%u0E1A%u0E31%u0E0D%u0E0D%u0E31%u0E15%u0E34%u0E27%u0E48%u0E32%u0E14%u0E49%u0E27%u0E22%u0E01%u0E32%u0E23%u0E01%u0E23%u0E30%u0E17%u0E33%u0E04%u0E27%u0E32%u0E21%u0E1C%u0E34%u0E14%u0E40%u0E01%u0E35%u0E48%u0E22%u0E27%u0E01%u0E31%u0E1A%u0E04%u0E2D%u0E21%u0E1E%u0E34%u0E27%u0E40%u0E15%u0E2D%u0E23%u0E4C%20%3CBR%3E%20%20%3Cbr%3E%3Cbr%3E',
		'instruction_originalmsg' => 'f3b9cc645ef4244c3add378418459f1e'
	])->as_string;

	$content=$agent->get('https://nac.kmitl.ac.th/dana/home/infranet.cgi')->as_string;
	while(1) {
		if(checkHTTPStatus($content,302)) {
			$location=getLocation($content);
			print " [+] 302 => $location\n";
			$content=$agent->get($location)->as_string;
		} else {
			unless($content=~/Logged-in as/) {
				login(0);
			}
			last;
		}
	}
}
sub saveLog {
	my $name=$_[0];
	open FILE ,">debug$name.html";
	print FILE $content;
	close FILE;
}

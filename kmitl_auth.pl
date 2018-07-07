use LWP::UserAgent;
use HTTP::Cookies;

#########################################
#Edit these setting as default

#Edit your username
$username='';
#Edit your password
$password='';
#Change value to '1' to create log.txt file or '0' to not.
$log=1;

#########################################


$^O=~/^MS/ ? system("cls") : system("clear");

print "[+] ------------------------------------------------------ [+]\n";
print "[ ]                                                        [ ]\n";
print "[ ]             ██████╗███████╗ █████╗  ██████╗            [ ]\n";
print "[ ]            ██╔════╝██╔════╝██╔══██╗██╔════╝            [ ]\n";
print "[ ]            ██║     ███████╗███████║██║  ███╗           [ ]\n";
print "[ ]            ██║     ╚════██║██╔══██║██║   ██║           [ ]\n";
print "[ ]            ╚██████╗███████║██║  ██║╚██████╔╝           [ ]\n";
print "[ ]             ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝            [ ]\n";
print "[ ]                                                        [ ]\n";
print "[ ]               Create date: 15 May 2017                 [ ]\n";
print "[ ]              Lasted modified: 1 Mar 2018                [ ]\n";
print "[ ]                                                        [ ]\n";
print "[ ]   Usage: perl kmitl_auth.pl username password          [ ]\n";
print "[ ]                                                        [ ]\n";
print "[+] ------------------------------------------------------ [+]\n\n";
if(scalar(@ARGV) > 0) { $username=$ARGV[0]; }
if(scalar(@ARGV) > 1) { $password=$ARGV[1]; }

unless($username && $password) {
	print " Username or Password not found !!\n\n";
	print " Usage : perl $0 [username] [password]\n";
	print " You can also embed your Username,Password by edit few lines of this script.\n\n";
	exit;
}

%ssl_opts=(
	verify_hostname => 0,
	SSL_verify_mode => 0x00,
);
$cookie_jar=HTTP::Cookies->new(autosave=>1, hide_cookie2=>1);
$agent=LWP::UserAgent->new(
	agent => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:47.0) Gecko/20100101 Firefox/47.0',
	ssl_opts => {%ssl_opts},
	timeout => 15,
	max_redirect => 0,
	cookie_jar => $cookie_jar
);

START_OVER:
login();
$resetTimer=time+(8*60*60);	#8 Hours
while(1) {
	$remainTimeToReset = $resetTimer - time;
	goto START_OVER if($remainTimeToReset <= 480); #8 minutes
	$time=localtime;
	$checkConnection = checkConnection();

	# Connection fine
	if($checkConnection == 1) {
		print "[$time] Connection OK. Wait for $heartbeatInterval seconds. ",int($remainTimeToReset/60)," mins to start over.\n";
		select undef,undef,undef,$heartbeatInterval;
		heatbeat();
	}

	# Require to login
	elsif($checkConnection eq 'mylogin.kmitl.ac.th') {
		if($log) {
			print " [$time] Require mylogin.kmitl.ac.th\n";
			open FILE,">>log.txt";
			print FILE "$time login iam\n";
			close FILE;
		}
		login();
		redo;
	}

	# Unexpect result
	else {
		print "[$time] Connection down!!!\n";
		print "$checkConnection";
		sleep 1;
	}

}






sub checkConnection {
	my $content = $agent->get('http://detectportal.firefox.com/success.txt')->as_string;
	if($content=~/mylogin\.kmitl\.ac\.th/) {
		return 'mylogin.kmitl.ac.th';
	}
	elsif($content=~/success\n/) {
		return 1;
	}
	return $content;
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
	# Send authen request
	$content=$agent->post('https://mylogin.kmitl.ac.th:8445/PortalServer/Webauth/webAuthAction!login.action',[
		"userName" => $username,
		"password" => $password,
		"validCode" => "",
		"authLan" => "en",
		"hasValidateNextUpdatePassword" => "true",
		"rememberPwd" => "false",
		"browserFlag" => "en",
		"hasCheckCode" => "false",
		"checkcode" => "",
		"saveTime" => "14",
		"autoLogin" => "false",
		"userMac" => "",
		"isBoardPage" => "false",
		"disablePortalMac" => "false",
		"overdueHour" => "0",
		"overdueMinute" => "0",
		"isAccountMsgAuth" => "",
		"validCodeForAuth" => "",
		"clientIp" => ""
	])->as_string;
	($token) = $content =~ /"token":"token=(.*?)"/;
	($ip) = $content =~ /"ip":"(.*?)"/;
	($account) = $content =~ /"account":"(.*?)"/;
#	while(1) {
#		if(checkHTTPStatus($content,302)) {
#			$location=getLocation($content);
#			print " [+] 302 => $location\n";
#			$content=$agent->get($location)->as_string;
#		} else {
#			last;
#		}
#	}
	
	# Sync authen result
	my $content=$agent->post('https://mylogin.kmitl.ac.th:8445/PortalServer/Webauth/webAuthAction!syncPortalAuthResult.action',[
		"browserFlag" => "en",
		"clientIp" => $ip
	])->as_string;
	($accessStatus) = $content =~ /"accessStatus":(\d+)/;
	($webHeatbeatPeriod) = $content =~ /"webHeatbeatPeriod":(\d+)/;
	$heartbeatInterval = $webHeatbeatPeriod/1000;
	if($accessStatus == 200) {
		print " [+] Trying to sign in and get token $token\n";
		print " [+] Your IP address is $ip\n\n";
	}
}
sub heatbeat {
	my $content=$agent->post('https://mylogin.kmitl.ac.th:8445/PortalServer/Webauth/webAuthAction!hearbeat.action',[
		"userName" => $account,
		"clientIp" => $ip
	],"X-XSRF-TOKEN" => $token)->as_string;
	(my $data) = $content =~ /"data":(.*?),/;
	if ($data eq "\"ONLINE\"") {
		print " [+] Heatbeat OK...\n\n";
		$heartbeatInterval = $webHeatbeatPeriod/1000;
	}
	else {
		print " [+] Heatbeat failed with $data response\n\n";
		goto START_OVER;
	}

}

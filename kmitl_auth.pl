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

system("clear");

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
print "[ ]                                                        [ ]\n";
print "[ ]   Usage: perl kmitl_auth.pl username password          [ ]\n";
print "[ ]   This script can maintain both gen1 and gen2          [ ]\n";
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

$count = 1;
while(1) {

	$time=localtime;
	$checkConnection = checkConnection();
	if($checkConnection == 1) {
		print "[$time] Connection OK...\n";
	}
	elsif($checkConnection eq 'nac.kmitl.ac.th') {
		if($log) {
			print "[$time] Require nac.kmitl.ac.th\n";
			open FILE,">>log.txt";
			print FILE "$time login nac\n";
			close FILE;
		}
		login(1);
		$count = 1;
		redo;
	}
	else {
		print "[$time] Connection down!!!\n";
		print "$checkConnection";
	}
	if($count >= 15) {
		heartbeat();
		$count = 1;
		redo;
	}
	sleep 60;
	$count++;

}






sub checkConnection {
	$content = $agent->get('http://detectportal.firefox.com/success.txt')->as_string;
	if($content=~/nac\.kmitl\.ac\.th/) {
		return 'nac.kmitl.ac.th';
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
	my $force=$_[0];
	$content=$agent->post('https://161.246.254.213/dana-na/auth/url_default/login.cgi',[
		'username' => $username,
		'password' => $password,
		'realm' => 'adminTestGroup',
		'tz_offset' => '420',
		'btnSubmit' => 'Sign in',
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

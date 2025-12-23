use Test;

use lib <lib t/lib>;

use WebDriver2::Test::PO-Test;
use WebDriver2::SUT::Service;

my Str:D $url = 'https://www.google.com';
my Str:D $title = 'Google';

class Base-Service does WebDriver2::SUT::Service {
	method nav-and-title {
		$!session.navigate: $url;
		$!session.title;
	}
}

class Base-Service-Test does WebDriver2::Test::PO-Test {
	has Int:D $.plan = 1;
	has Str:D $.name = 'base service test';
	has Str:D $.description = 'test service not backed by a page';
	has Str:D $.sut-name = 'test';
	has Base-Service $!base-service;
	
	method services {
		$!base-service, \( :$!browser, :$!debug-level )
	}
	
	method test {
		self.is: 'nav and title', $title, $!base-service.nav-and-title;
	}
}

constant &MAIN = po-test Base-Service-Test;

use lib <lib t/lib>;

use Test;
use WebDriver2::Test::Adapter;

class Adapter-Test does WebDriver2::Test::Adapter {
	has Str:D $.sut-name = 'adapter-sut-name';
	has Int:D $.plan = 2;
	has Str:D $.name = 'adapter-name';
	has Str:D $.description = 'adapter test';
	
	method test {
		self.nok: 'PASS BECAUSE FALSE', False;
	}
	
	method handle-test-failure ( Str $description ) {
	
	}
}

sub MAIN(
		Int:D :$debug = 0
) {
	.test with Adapter-Test.new: :$debug, test-root => 'xt'.IO;
}

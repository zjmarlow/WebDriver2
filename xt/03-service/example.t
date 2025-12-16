use Test;
use MIME::Base64;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Test::Config-From-File;

use WebDriver2::SUT::Build;
use WebDriver2::SUT::Navigator;
use WebDriver2::SUT::Service;
use WebDriver2::Test::PO-Test;
use WebDriver2::Until;
use WebDriver2::Until::SUT;
use WebDriver2::Until::Command;



class Root-Content does WebDriver2::SUT::Service {
	has Str:D $.name = 'example';
	my IO::Path $html-file =
			$*CWD.add: <xt content example.html>;
	
	method title ( --> Str:D ) { $!session.title }
	
	method refresh { $!session.refresh; }

	method heading ( --> Str:D ) {
		.resolve.text with self.get: 'the-h2';
	}

	method each-list-item ( &action ) {
		for self.get( 'a-mli' ).iterator {
			&action( self );
		}
	}

	method li {
		.resolve with self.get: 'a-mli';
	}

	method open {
			my $url =
					WebDriver2::SUT::Tree::URL.new:
							'file://' ~ $html-file;
			$!session.navigate: $url.Str;
	}

	method open-other-frame {
		$!session.top;
		.resolve.click with self.get: 'the-button';
		self.switch-to-replacement-frame;
	}
	
	method switch-to-original-frame {
        .resolve.switch-to with self.get: 'the-original-frame';
    }
    
    method switch-to-replacement-frame {
        .resolve.switch-to with self.get: 'the-replacement-frame';
    }
}



class Original-Frame does WebDriver2::SUT::Service {
	has Str:D $.name = 'example-original-frame';
	
	method heading ( --> Str:D ) {
		.resolve.text with self.get: 'orig-h2';
	}

	method each-list-item ( &action ) {
		for self.get( 'a-fli' ).iterator {
			&action( self );
		}
	}

	method li {
		.resolve with self.get: 'a-fli';
	}
	
	method return-to-parent {
        $!session.switch-to-parent;
    }
}

class Replacement-Frame does WebDriver2::SUT::Service {
	has Str:D $.name = 'example-replacement-frame';
	
	method heading ( --> Str:D ) {
		.resolve.text with self.get: 'rep-h2';
	}

	method each-list-item ( &action ) {
		for self.get( 'rep-li' ).iterator {
			&action( self );
		}
	}

	method li ( --> WebDriver2::Model::Element:D ) {
		.resolve with self.get: 'rep-li';
	}
	method loaded {
			my WebDriver2::Until $input-present =
					WebDriver2::Until::SUT::Present.new:
							duration => 10,
							interval => 1 / 10,
							element => self.get: 'rep-li';
			$input-present.retry;
	}
	
	method switch-to-nested-frame {
		.resolve.switch-to with self.get: 'nested-frame';
	}
	
	method return-to-parent {
        $!session.switch-to-parent;
    }
}

class Nested-Frame does WebDriver2::SUT::Service {
	has Str:D $.name = 'example-nested-frame';
	
	method heading ( --> Str:D ) {
		.resolve.text with self.get: 'nested-h2';
	}

	method each-list-item ( &action ) {
		for self.get( 'nested-li' ).iterator {
			&action( self );
		}
	}

	method li ( --> WebDriver2::Model::Element:D ) {
		.resolve with self.get: 'nested-li';
	}
	
	method return-to-parent {
        $!session.switch-to-parent;
    }
}

class Example-Test does WebDriver2::Test::PO-Test {
	has Str:D $.sut-name = 'example';
	has Int:D $.plan = 20;
	has Str:D $.name = 'example test name';
	has Str:D $.description = 'example test description';
	
	has Root-Content $!mls;
	has Original-Frame $!of;
	has Replacement-Frame $!rf;
	has Nested-Frame $!nf;
	
	method services {
		$!mls, \( :$!browser, :$!debug-level ),
		$!of, \( :$!browser, :$!debug-level ),
		$!rf, \( :$!browser, :$!debug-level ),
		$!nf, \( :$!browser, :$!debug-level )
	}
	
	method test {
		my Str:D @results =
				'main - uno',
				'main - due',
				'main - tre',
				'initial-frame - uno',
				'initial-frame - due',
				'initial-frame - tre',
				'replacement-frame - uno',
				'replacement-frame - due',
				'replacement-frame - tre',
				'nested-frame - uno',
				'nested-frame - due',
				'nested-frame - tre',
				;
		$!mls.open;
		self.is: 'main title', 'ml test', $!mls.title;
		self.is: 'main heading', 'example', $!mls.heading;
		$!mls.each-list-item: -> Root-Content $frame {
			self.is: 'main li', @results.shift, $frame.li.text;
		};
		
		$!mls.switch-to-original-frame;

		self.is: 'original frame heading', 'example frame', $!of.heading;
		$!of.each-list-item: -> Original-Frame $frame {
			self.is: 'original frame li', @results.shift, $frame.li.text;
		};
		
		$!of.return-to-parent;

		$!mls.open-other-frame;

		self.is: 'replacement frame heading', 'navigated frame', $!rf.heading;
		$!rf.each-list-item: -> Replacement-Frame $frame {
			self.is: 'replacement frame li', @results.shift, $frame.li.text;
		};
		
		$!rf.switch-to-nested-frame;
		
		self.is: 'nested frame heading', 'nested frame', $!nf.heading;
		$!nf.each-list-item: -> Nested-Frame $frame {
			self.is: 'nested frame li', @results.shift, $frame.li.text;
		};

		self.is: 'all items found', 0, +@results;
		
		$!nf.return-to-parent;
		self.is: 'replacement frame heading', 'navigated frame', $!rf.heading;
		$!rf.return-to-parent;
		self.is: 'main heading', 'example', $!mls.heading;

		$!mls.refresh;
	}
}

constant &MAIN = po-test Example-Test;

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



class ML does WebDriver2::SUT::Service {
    my IO::Path $html-file =
            .add: 'ml.html' with $*PROGRAM.parent.parent.add: 'content';

    method title ( --> Str:D ) { $!session.title }
    
    method refresh { $!session.refresh; }

    method name (--> Str:D) {
        'lr'
    }

    method li {
        my $url = WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file;
        $!session.navigate: $url.Str;
        my WebDriver2::Until $stale =
                WebDriver2::Until::Command::Stale.new:
                        duration => 3,
                        interval => 1 / 10,
                        element => .resolve with self.get: 'button';
        .resolve.click with self.get: 'button';
        $stale.retry;
    }
	
	method switch-to-l {
		.resolve.switch-to with self.get: 'lf';
	}
	method switch-to-r {
        .resolve.switch-to with self.get: 'rf';
    }
}

class LR does WebDriver2::SUT::Service {
	my IO::Path $html-file =
                .add: 'lr-root.html'
                with $*PROGRAM.parent.parent.add: 'content';
    
        method title ( --> Str:D ) { $!session.title }
        
        method refresh { $!session.refresh; }
    
        method name (--> Str:D) { 'lr-root' }
    	
    	method switch-to-l {
    		.resolve.switch-to with self.get: 'lf';
    	}
    	method switch-to-r {
            .resolve.switch-to with self.get: 'rf';
        }
}

class L does WebDriver2::SUT::Service {
    
    method name (--> Str:D) {
        'l'
    }

    multi method i ( --> Str:D ) {
        .resolve.value with self.get: 'li';
    }

    multi method i ( Str:D $i ) {
        my $input = .resolve with self.get: 'li';
        $input.send-keys: $i;
    }
    
    method return-to-parent {
        $!session.switch-to-parent;
    }
}

class R does WebDriver2::SUT::Service {
    
    method name (--> Str:D) {
        'r'
    }

    multi method i ( --> Str:D ) {
        .resolve.value with self.get: 'ri';
    }

    multi method i ( Str:D $i ) {
        my $input = .resolve with self.get: 'ri';
        $input.send-keys: $i;
    }
    
    method return-to-parent {
        $!session.switch-to-parent;
    }
    
    method loaded {
        my WebDriver2::Until $input-present =
                WebDriver2::Until::SUT::Present.new:
                        duration => 10,
                        interval => 1 / 10,
                        element => self.get: 'ri';
        $input-present.retry;
    }
}

class LR-Test does WebDriver2::Test::PO-Test {
    has Str:D $.sut-name = 'lr';
    has Int:D $.plan = 3;
    has Str:D $.name = 'lr';
    has Str:D $.description = 'lr service and frames test';
	
    has ML $!mls;
    has LR $!lrs;
    has L $!ls;
    has R $!rs;
    
    method services {
        $!mls, \( :$!browser, :$!debug-level ),
        $!lrs, \( :$!browser, :$!debug-level ),
        $!ls, \( :$!browser, :$!debug-level ),
        $!rs, \( :$!browser, :$!debug-level ),
    }

    method pre-test { }
    method post-test { }

    method test {
        $!mls.li;
        self.is: 'main title', 'lr root', $!mls.title;

        $!mls.refresh;
        $!lrs.switch-to-l;
        $!ls.i: 'li';
		$!ls.return-to-parent;
		$!lrs.switch-to-r;
        $!rs.i: 'ri';
		$!ls.return-to-parent;
		$!lrs.switch-to-l;
        self.is: 'li', 'li', $!ls.i;
		$!ls.return-to-parent;
		$!lrs.switch-to-r;
        self.is: 'ri', 'ri', $!rs.i;
    }
}

constant &MAIN = po-test LR-Test;


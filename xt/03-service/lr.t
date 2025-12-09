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
        'ml'
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
}

class L does WebDriver2::SUT::Service {
    
    method name (--> Str:D) {
        'l'
    }

    multi method i ( --> Str:D ) {
        my $f = self.get: 'l';
        $f.resolve;
        $f.present.switch-to;
        .resolve.value with self.get: 'li';
    }

    multi method i ( Str:D $i ) {
        my $f = self.get: 'l';
        $f.resolve;
        $f.present.switch-to;
        my $input = .resolve with self.get: 'li';
        $input.send-keys: $i;
    }
}

class R does WebDriver2::SUT::Service {
    
    method name (--> Str:D) {
        'r'
    }

    multi method i ( --> Str:D ) {
        my $f = self.get: 'r';
        $f.resolve;
        $f.present.switch-to;
        .resolve.value with self.get: 'ri';
    }

    multi method i ( Str:D $i ) {
        my $el = self.get: 'r';
        $el.resolve;
        $el.present.switch-to;
        my $input = .resolve with self.get: 'ri';
        $input.send-keys: $i;
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

class LR does WebDriver2::Test::PO-Test {
    has Str:D $.sut-name = 'lr';
    has Int:D $.plan = 3;
    has Str:D $.name = 'lr';
    has Str:D $.description = 'lr service and frames test';

    has ML $!mls;
    has L $!ls;
    has R $!rs;
    
    method services {
        $!mls, \( :$!browser, :$!debug ),
        $!ls, \( :$!browser, :$!debug ),
        $!rs, \( :$!browser, :$!debug ),
    }

    method pre-test { }
    method post-test { }

    method test {
        $!mls.li;
        self.is: 'main title', 'lr root', $!mls.title;

        $!mls.refresh;
        $!ls.i: 'l';
        $!rs.loaded;
        $!rs.i: 'r';
        self.is: 'l', 'l', $!ls.i;
        self.is: 'r', 'r', $!rs.i;
    }
}

constant &MAIN = po-test LR;


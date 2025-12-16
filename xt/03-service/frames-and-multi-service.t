use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Test::Debugging;
use WebDriver2::Until;
use WebDriver2::Until::Command;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;

use WebDriver2::SUT::Build;
use WebDriver2::SUT::Service;
use WebDriver2::SUT::Tree;

use WebDriver2::Test::PO-Test;
use WebDriver2::Test::Config-From-File;

my IO::Path $html-file =
		.add: 'page-from.html' with $*PROGRAM.parent.parent.add: 'content';

class From-Test-Service does WebDriver2::SUT::Service {
	
	method nav {
		my $url = WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file;
		$!session.navigate: $url.Str;
	}

	method name ( --> Str:D ) { 'page-from' } # lists

	method page-link {
		my WebDriver2::Model::Element $element = .resolve with self.get: 'a';
		my WebDriver2::Until $stale =
				WebDriver2::Until::Command::Stale.new:
						duration => 5,
						interval => 1 / 10,
						:$element,
						:soft;
# 		.resolve.click with self.get: 'a';
		$element.click;
		$stale.retry;
	}
}

class To-Test-Service does WebDriver2::SUT::Service {
	
	method name ( --> Str:D ) { 'page-to' } # lists

	method item-text {
		.resolve.text with self.get: 'item';
	}
	
	method switch-to-to-frame {
		.resolve.switch-to with self.get: 'iframe';
	}
	
	method inner-h2-text ( --> Str:D ) {
		.resolve.text with self.get: 'h2';
	}
}

class Frames-Test-Service does WebDriver2::SUT::Service {
	
	method name ( --> Str:D ) { 'page-to-frame' } # lists

	method refresh {
		$!session.refresh;
	}

	method top {
		$!session.top;
	}
	
	method inner-h2-text ( --> Str:D ) {
		.resolve.text with self.get: 'inner-h2';
	}
}

class Frames-Test does WebDriver2::Test::PO-Test {
	has Str:D $.sut-name = 'page-to';
	has Int:D $.plan = 1;
	has Str:D $.name = 'frames';
	has Str:D $.description = 'tests nesting frames';
	
	has From-Test-Service $!from;
	has To-Test-Service $!to;
	has Frames-Test-Service $!frames;
	
	method services {
		$!from, \( :$!browser, :$!debug-level ),
		$!to, \( :$!browser, :$!debug-level ),
		$!frames, \( :$!browser, :$!debug-level ),
	}
	
	method pre-test { }
	method post-test { }
	
	method test {
		$!from.nav;
		self.debug: Level::WARN, 'page link not stale' unless $!from.page-link;
		$!frames.refresh;
		$!frames.top;
		$!to.switch-to-to-frame;
		self.skip: 'asynchronous navigation not working yet', 1;
		False and self.is:
				'get content from nested frame',
				'internal frame',
				$!to.inner-h2-text
				;
	}
}

constant &MAIN = po-test Frames-Test;

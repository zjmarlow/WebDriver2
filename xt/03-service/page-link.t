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



class Page-Link-From-Service does WebDriver2::SUT::Service {
	my IO::Path $html-file =
			.add: 'page-from.html' with $*PROGRAM.parent.parent.add: 'content';
	
	method html-file ( --> IO::Path ) { $html-file }
	
	method title ( --> Str:D ) { $!session.title }
	
	method name ( --> Str:D ) { 'page-from' } # lists
	
	method top-retry {
		WebDriver2::Until::Command::Stale.new:
				element => self.get( 'h2' ).resolve,
				duration => 2,
				interval => 1 / 10,
				:!soft;
	}
	method nav {
		my $url = WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file;
		$!session.navigate: $url.Str;
	}
	method page-h2-text {
		.resolve.text with self.get: 'h2';
	}
	method page-input {
		.resolve with self.get: 'text';
	}
	method page-link {
		.resolve with self.get: 'a';
	}
}

class Page-Link-To-Service does WebDriver2::SUT::Service {
	
	method name ( --> Str:D ) { 'page-to' } # lists
	
	method title ( --> Str:D ) { $!session.title }
	
	method top-retry {
		WebDriver2::Until::Command::Stale.new:
			element => self.get( 'item' ).resolve,
			duration => 2,
			interval => 1 / 10,
			:!soft;
	}
	
	method iframe {
		my $f = .resolve.switch-to with self.get: 'iframe'; # 'iframe'
		self.debug: Level::trace, $f.raku;
		.tag-name.&self::debug for $f.elements:
				WebDriver2::Command::Element::Locator::Xpath.new: '//*';
	}
	
	method para {
		.resolve.text with self.get: 'p-inner';
	}
	
	method each-repeated ( Str:D $list, &action ) {
		.&&action for do .iterator with self.get: $list;
	}
}

class Frames-Test does WebDriver2::Test::PO-Test {
	has Str:D $.sut-name = 'page-to';
	has Int $.plan = 14;
	has Str:D $.name = 'page-to';
	has Str:D $.description = 'tests nesting frames';
	
	has Page-Link-From-Service $!from-service;
	has Page-Link-To-Service $!to-service;
	
	method services {
		$!from-service, \( :$!browser, :$!debug-level ),
		$!to-service, \( :$!browser, :$!debug-level ),
	}
	
	method pre-test { }
	method post-test { }
	
	method test {
		$!from-service.nav;
		self.is: 'page title', 'iframe test', $!from-service.title;
		self.is: 'page h2 test', 'iframe test', $!from-service.page-h2-text;
		my $stale = $!from-service.page-link;
		my WebDriver2::Until $until-stale =
				WebDriver2::Until::Command::Stale.new:
						element => $stale,
						duration => 5,
						interval => 1 / 10,
						:soft
				;
		$stale.click;
		self.ok: 'wait stale', $until-stale.retry;
		my Exception:D $xx =
			WebDriver2::Command::Result::X.new:
					execution-status =>
						WebDriver2::Command::Execution-Status.new:
							type => WebDriver2::Command::Execution-Status::Type::Stale,
							message => ''
				;
		self.throws-like:
				'interact stale',
				$xx,
				{ $stale.click },
				execution-status => { .type === WebDriver2::Command::Execution-Status::Type::Stale }
				;
		my Str:D @expected = 'to page first', 'to page second';
		$!to-service.each-repeated: 'item', {
			self.is:
				"new list @expected[0]",
				@expected.shift,
				.resolve.text;
		};
		self.is: 'all new items seen', 0, +@expected;
		$!to-service.iframe;
		@expected = 'internal frame', 'one', 'two';
		$!to-service.each-repeated: 'h2-inner', {
			self.is:
					"inner list @expected[0]",
					@expected.shift,
					.resolve.text;
		};
		self.is: 'all inner items seen', 0, +@expected;
		@expected = <first second>;
		$!to-service.each-repeated: 'p-inner', {
			self.is:
					"inner para @expected[0]",
					@expected.shift,
					.resolve.text
		};
		self.is: 'all inner para seen', 0, +@expected;
	}
}

constant &MAIN = po-test Frames-Test;

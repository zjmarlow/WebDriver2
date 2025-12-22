use Test;

use lib <lib t/lib>;

use WebDriver2::Test::Adapter;
use WebDriver2::Test::PO-Test;
use WebDriver2::SUT::Service;
use WebDriver2::SUT::Tree;

my IO::Path $html-file =
	.add:
			'frame-navigation.html'
			with $*CWD.add: 'xt', 'content'
			;

class Frame-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'frame-navigation';
	has WebDriver2::Test::Adapter:D $!test is required is built;
	
	method nav {
		my $url = WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file;
		$!session.navigate: $url.Str;
	}
	
	method main {
		$!session.top;
	}
	
	method h2-main-text ( --> Str:D ) {
		.resolve.text with self.get: 'h2-main';
	}
	
	method iframe-one {
		.resolve.switch-to with self.get: 'iframe-1';
	}
	
	method h2-one-text ( --> Str:D ) {
		.resolve.text with self.get: 'h2-1';
	}
	
	method each-iframe ( Str:D @exp ) {
		for do .iterator with self.get: 'iframes-1' {
			.resolve.frame.switch-to;
			$!test.is:
					"nested h2 @exp[0]",
					@exp.shift,
					.resolve.text with self.get: 'h2-i'
					;
			$!session.switch-to-parent;
		}
	}
	
	method iframe-two {
        .resolve.switch-to with self.get: 'iframe-2';
    }
	
	method h2-two-text ( --> Str:D ) {
        .resolve.text with self.get: 'h2-2';
    }
}

class Frame-Stale-Test does WebDriver2::Test::PO-Test {
	has Str:D $.sut-name = 'frame-navigation';
	has Int:D $.plan = 8;
	has Str:D $.name = 'frame-navigation';
	has Str:D $.description = 'frame navigation with single service test';
	has Frame-Service $!fs-main = Frame-Service;
	
	method services {
		$!fs-main, \( :$!browser, prefix => '', :$!debug-level, test => self ),
	}
	
	method test {
	$!fs-main.nav;
		self.is:
				'main h2',
				'iframe stale test h2 - main',
				$!fs-main.h2-main-text
				;
		$!fs-main.iframe-one;
		self.is:
				'iframe stale test h2 - 1',
				'iframe stale test h2 - 1',
				$!fs-main.h2-one-text
				;
		my Str:D @exp =
			Array[Str:D].new:
					'iframe stale test h2 - 1-1',
					'iframe stale test h2 - 1-2'
					;
		$!fs-main.each-iframe: @exp;
		self.is: 'all h2 seen', 0, +@exp;
		self.is:
				'iframe stale test h2 - 1',
				'iframe stale test h2 - 1',
				$!fs-main.h2-one-text
				;
		$!fs-main.main;
		self.is:
				'main h2',
				'iframe stale test h2 - main',
				$!fs-main.h2-main-text
				;
		$!fs-main.iframe-two;
		self.is:
				'iframe stale test h2 - 2',
				'iframe stale test h2 - 2',
				$!fs-main.h2-two-text
				;
	}
}

constant &MAIN = po-test Frame-Stale-Test;

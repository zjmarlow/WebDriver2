use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Test::Template;

use WebDriver2::Test::Adapter;
use WebDriver2::Test::Debugging;

use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;

my IO::Path $html-file = .add: 'doc-main.html' with 'content'.IO;

class Session-Test does WebDriver2::Test::Template {
#	has WebDriver2::Driver $!session;
#	has Str $.browser;
	has Str:D $.sut-name = 'session-sut-name';
	has Int:D $.plan = 4;
	has Str:D $.name = 'session-name';
	has Str:D $.description = 'session test';

	submethod BUILD (
			WebDriver2::Driver-Actions:D :$!driver,
			IO::Path:D :$!test-root = 'xt'.IO,
			Int:D :$!close-delay = 3,
			Int:D :$!debug = 0
    ) { }
	
	method pre-test { }
	method post-test { }
	
	method test {
#		if $.browser eq 'firefox' {
#			skip 'geckodriver does not return valid JSON before session creation';
#		} else {
##			self.throws-like:
#			self.nok:
#					'no title before session',
#					$!session.title;
##					WebDriver2::Command::Result::X:D,
##					{ $!session.title };
#		}
#		self.lives-ok: 'session created', { $!session.session };
		my IO::Path:D $html-file = $!test-root.add: <content doc-main.html>;
		my Str:D $url = 'file://' ~ $html-file.absolute;
		self.nok: 'no title before navigation', $!session.title;
		$!session.navigate: $url;
		self.is: 'title after navigation', 'simple example', $!session.title;
		$!session.delete-session;
		if $!session.browser eq 'firefox' {
			self.throws-like:
					'no title after session deletion',
					WebDriver2::Command::Result::X:D,
					{ $!session.title },
					message => rx:m :s/.*error\"\s*\:\s*\"invalid session id.*/;
		} elsif $!session.browser eq 'safari' {
			self.throws-like:
					'no title after session deletion',
					WebDriver2::Command::Result::X:D,
					{ $!session.title },
					message => *.contains: 'invalid session id';
		} else {
#			self.throws-like:
#					'no title after session deletion',
#					WebDriver2::Command::Result::X:D,
#					{ $!session.title },
#					message => "Session\ninvalid session id";
			try $!session.title;
			self.ok: 'right exception', $! ~~ WebDriver2::Command::Result::X:D;
			self.is: 'no title after session deletion', "Session\ninvalid session id", $!.Str;
		}
		say '   ';
#		$!session.session;
#		done-testing;
	}
	
	method handle-test-failure ( Str:D $description ) {
#		warn $description;
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Session-Test.new: $browser, :$debug, test-root => 'xt'.IO;
}

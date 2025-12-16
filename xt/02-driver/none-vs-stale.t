use Test;

use lib <lib t/lib>;

use WebDriver2::Until;
use WebDriver2::Until::Command;
use WebDriver2::Test::Template;
use WebDriver2::Command::Execution-Status;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;

class Local
		does WebDriver2::Test::Template
#		does WebDriver2::Test::Config-From-File
{
	has Str:D $.sut-name = 'test';
	has Int:D $.plan = 3;
	has Str:D $.name = 'none vs stale';
	has Str:D $.description = 'none and stale both handled';
	
	submethod BUILD (
			WebDriver2::Driver-Actions:D :$!driver,
			IO::Path:D :$!test-root = 'xt'.IO,
			Int:D :$!close-delay = 3,
			Int:D :$!debug-level = 0
	) { }
	
	method pre-test { }
	method post-test { }
	
	method test {
		my IO::Path:D $html-file = $!test-root.add: <content test.html>;
#				.add: 'test.html' with $*CWD.add: 'content';
		$!session.set-window-rect( 1200, 750, 8, 8 ) if $!session.browser eq 'safari';
		$!session.navigate: 'file://' ~ $html-file.absolute;
		
		ok
			self.element-by-id( 'outer' )
			~~ self.element-by-tag( 'ul' ),
			'same element found different ways';
		
		throws-like
				{ self.element-by-id: 'not here'; },
				WebDriver2::Command::Result::X.new( execution-status => WebDriver2::Command::Execution-Status.new: type => WebDriver2::Command::Execution-Status::Type::Element, message => '' ),
#				Exception,
				'not found',
						;
#				execution-status => { .type.isa: WebDriver2::Command::Execution-Status::Type::Element; };
		
		my $outer = self.element-by-id: 'outer';
		my WebDriver2::Until $stale = WebDriver2::Until::Command::Stale.new:
				element => $outer,
				duration => 3,
				interval => 1/10;
		$outer.click;
		$!session.accept-alert;
		ok $stale.retry, 'stale check';
		
		
#		throws-like
#				{ $outer.click },
#				WebDriver2::Command::Result::X,
#				'stale',
#				execution-status => { .type ~~ WebDriver2::Command::Execution-Status::Type::Stale };
		
	}
	method element-by-tag( Str $tag-name ) {
		$!session.element( WebDriver2::Command::Element::Locator::Tag-Name.new: $tag-name )
	}

	method element-by-id( Str $id ) {
		$!session.element( WebDriver2::Command::Element::Locator::ID.new: $id )
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Local.new: $browser, :$debug, test-root => 'xt'.IO;
}

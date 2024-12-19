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
		does WebDriver2::Test::Config-From-File
{
	has Str:D $.sut-name = 'test';
	has Int:D $.plan = 2;
	has Str:D $.name = 'none vs stale';
	has Str:D $.description = 'none and stale both handled';
#	has IO::Path:D $!test-root = 'xt'.IO;
	
	method pre-test { }
	method post-test { }
	
	method test {
		my IO::Path:D $html-file = $!test-root.add: <content frame-alert-root-doc.html>;
		#				.add: 'test.html' with $*CWD.add: 'content';
		$.driver.set-window-rect( 1200, 750, 8, 8 ) if $.browser eq 'safari';
		$.driver.navigate: 'file://' ~ $html-file.absolute;
		
		.frame.switch-to with self.element-by-tag: 'iframe';
		.click with self.element-by-tag: 'h2';
		$!driver.accept-alert;
		ok self.element-by-id( 'inner-form' ), 'still in iframe';
		.click with self.element-by-tag: 'p';
		$!driver.accept-alert;
		$!driver.top;
		ok self.element-by-id( 'form' ), 'root page';
	}
	method element-by-tag( Str $tag-name ) {
		$.driver.element( WebDriver2::Command::Element::Locator::Tag-Name.new: $tag-name )
	}
	
	method element-by-id( Str $id ) {
		$.driver.element( WebDriver2::Command::Element::Locator::ID.new: $id )
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Local.new: $browser, :$debug, test-root => 'xt'.IO;
}

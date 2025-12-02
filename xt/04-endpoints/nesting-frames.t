use Test;

use lib <lib t/lib>;

use WebDriver2::Test::Template;
use WebDriver2::Test::Locating-Test;

my $file = .add: 'lists.html' with $*PROGRAM.parent.parent.add: 'content';

class Test-Nav-To-Frame
		does WebDriver2::Test::Template
#		does WebDriver2::Test::Locating-Test
{
	has Int:D $.plan = 35;
	has Str:D $.name = 'nesting frames';
	has Str:D $.description = 'nesting frames test';
	
	submethod BUILD (
			WebDriver2::Driver-Actions:D :$!driver,
			IO::Path:D :$!test-root = 'xt'.IO,
			Int:D :$!close-delay = 3,
			Int:D :$!debug = 0
	) { }
	
	method pre-test { }
	method post-test { }
	
	method test {
		$!session.navigate: 'file://' ~ $file.absolute;
		
		self.nok: 'at page; no parent frame', $!session.switch-to-parent.defined;
		self.page-content;
		
		# descend using tag
		.frame.switch-to with $!session.element: tag-locator 'iframe';
		self.frame0-content;
		
		.frame.switch-to with $!session.element: tag-locator 'iframe';
		self.frame1-content;
		
		$!session.switch-to-parent;
		if $!session.browser eq 'safari' {
			skip 'safaridriver switch to parent frame bug', 2;
		} else {
			self.frame0-content;
		}
		
		$!session.switch-to-parent;
		self.page-content;
		
		# at top and make sure frame switching stops at page
		self.nok: 'at page; no parent frame', $!session.switch-to-parent.defined;
		self.page-content;
		
		# descend using id
		.frame.switch-to with $!session.element: id-locator 'frame';
		self.frame0-content;
		
		.frame.switch-to with $!session.element: id-locator 'internal';
		self.frame1-content;
		
		$!session.switch-to-parent.switch-to-parent;
		# at top but no check for parent to make sure it doesn't affect results
		self.page-content;
		
		# descend using tag
		.frame.switch-to with $!session.element: tag-locator 'iframe';
		self.frame0-content;
		
		.frame.switch-to with $!session.element: tag-locator 'iframe';
		self.frame1-content;
		
		# TOP
		$!session.top;
		self.nok: 'at page; no parent frame', $!session.switch-to-parent.defined;
		self.page-content;
		
		# descend using id
		.frame.switch-to with $!session.element: id-locator 'frame';
		self.frame0-content;
		
		.frame.switch-to with $!session.element: id-locator 'internal';
		self.frame1-content;
		
		# TOP
		$!session.top;
		# at top but no check for parent to make sure it doesn't affect results
		
		# descend using tag
		.frame.switch-to with $!session.element: tag-locator 'iframe';
		self.frame0-content;
		
		.frame.switch-to with $!session.element: tag-locator 'iframe';
		self.frame1-content;
	}
	
	method page-content {
		self.is: 'page h2', 'test', .text with $!session.element: tag-locator 'h2';
		self.is: 'li text', 'one', .text with $!session.element: tag-locator 'li';
	}
	
	method frame0-content {
		self.is:
				'frame h2',
				'list frame test',
				.text
				with $!session.element: tag-locator 'h2';
		self.is:
				'label text',
				'text input:',
				.text.trim
				with $!session.element: tag-locator 'label';
	}
	
	method frame1-content {
		self.is:
				'inner frame h2',
				'internal frame',
				.text
				with $!session.element: tag-locator 'h2';
		self.is: 'p text', 'first', .text with $!session.element: tag-locator 'p';
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Test-Nav-To-Frame.new: $browser, :$debug, test-root => 'xt'.IO;
}

use Test;

use lib <lib t/lib>;

use PostCocoon::Url;

use WebDriver2;
use WebDriver2::Test::Config-From-File;

use WebDriver2::Until;
use WebDriver2::Until::Command;
use WebDriver2::Test::Locating-Test;
use WebDriver2::Test::Template;
use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;

my IO::Path $html-from-file =
		.add: 'page-from.html'
with $*PROGRAM.parent.parent.add: 'content';
my IO::Path $html-to-file =
		.add: 'page-to.html' with $*PROGRAM.parent.parent.add: 'content';

class Nav-Test
		does WebDriver2::Test::Template
#		does WebDriver2::Test::Locating-Test
{
	has Int:D $.plan = 18;
	has Str:D $.name = 'browser navigation';
	has Str:D $.description = q:to/DESCRIPTION/;
		tests Navigate To, Get Current URL, Back, Forward, Refresh
	DESCRIPTION

	submethod BUILD (
			WebDriver2::Driver-Actions:D :$!driver,
			IO::Path:D :$!test-root = 'xt'.IO,
			Int:D :$!close-delay = 3,
			Int:D :$!debug = 0
	) { }
	
	method pre-test { }
	method post-test { }
	
	method test {
		$!session.navigate: 'file://' ~ $html-from-file.absolute;
		
		# INITIAL PAGE TESTS
		self.is: 'navigation url result', self.prep-path( $html-from-file ), url-decode $!session.url;
		self.is: 'starting page title', 'iframe test', $!session.title;
		
		my WebDriver2::Until $title =
				WebDriver2::Until::Command::Title-Is.new:
						:$!session,
						title => 'to page';
		.click with $!session.element: tag-locator 'a';
		
		# DESTINATION PAGE TESTS
		$title.retry;
		self.is:
				'browser follows link',
				self.prep-path( $html-to-file ),
				url-decode $!session.url;
		self.is:
				'destination page element check',
				'to page second',
				.text with $!session.element: id-locator 'page-to-heading-3';
		
		# BACK TO INITIAL PAGE TESTS
		$!session.back;
		self.is: 'url for return to initial page', self.prep-path( $html-from-file ) ~ '#', url-decode $!session.url;
		self.is: 'title for return to initial page', 'iframe test', $!session.title;
		my WebDriver2::Model::Element @h2s =
				$!session.elements: tag-locator 'h2';
		if self.is: 'back to initial page - correct content', 1, @h2s.elems
			and self.is: 'text content', 'iframe test', @h2s[0].text
		{
			@h2s[0].click;
			my WebDriver2::Model::Element @p =
					$!session.elements: tag-locator 'p';
			if self.is: 'one element dynamically added', 2, @p.elems {
				self.is: 'added element text', 'added', @p[0].text;
				$!session.refresh;
				@p = $!session.elements: tag-locator 'p';
				self.is: 'dynamically added element not present on refresh', 1, @p.elems;
				self.isnt: 'added element no longer present', 'added', @p[0].text;
				
				# BROWSER FORWARD TEST
				$!session.forward;
				self.is: 'destination page title', 'to page', $!session.title;
				self.is:
						'destination page url',
						self.prep-path( $html-to-file ),
						url-decode $!session.url;
				@h2s = $!session.elements: tag-locator 'h2';
				if self.is: 'forward to destination page - correct content', 2, @h2s.elems {
					self.is: 'text content', 'to page first', @h2s[0].text;
					self.is: 'text content', 'to page second', @h2s[1].text;
					@p = $!session.elements: tag-locator 'p';
					self.is: 'content from initial page not present', 0, @p.elems;
				} else {
					self.diag: 'incorrect content after browser forward test; skipping rest of content tests';
				}
			} else {
				self.diag: 'incorrect content added; skipping driver.refresh test';
			}
		} else {
			self.diag: join '; ',
					'incorrect content after browser back test',
					'skipping retest of initial page',
					'skipping browser forward test';
		}
		
	}
	
	method prep-path ( IO::Path $path ) {
		#		return 'file://' ~ $path.absolute if $.browser eq 'safari';
		return 'file://' ~ $path.absolute unless $*SPEC.isa: IO::Spec::Win32;
		'file:///' ~ $path.absolute.subst: '\\', '/', :g;
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Nav-Test.new: $browser, :$debug, test-root => 'xt'.IO;
}

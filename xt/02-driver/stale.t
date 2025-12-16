use Test;

use lib 'lib', 't/lib';

use WebDriver2;
use WebDriver2::Until;
use WebDriver2::Until::Command;
use WebDriver2::Test::Template;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;
#use WebDriver2::Test::Locating-Test;

my IO::Path:D $html-file = .add: 'test.html' with $*CWD.add: <xt content>;
my IO::Path:D $from-file = .add: 'page-from.html' with $*CWD.add: <xt content>;
my WebDriver2::Command::Element::Locator::ID:D $link =
		WebDriver2::Command::Element::Locator::ID.new: 'link-to-page';
my WebDriver2::Command::Element::Locator::ID:D $h2 =
		WebDriver2::Command::Element::Locator::ID.new: 'page-to-heading-2';

class Stale
		does WebDriver2::Test::Template
#		does WebDriver2::Test::Locating-Test
{
	has Str:D $.sut-name = 'stale';
	has Int:D $.plan = 10;
	has Str:D $.name = 'stale';
	has Str:D $.description = 'stale handling';
	
	submethod BUILD (
			WebDriver2::Driver-Actions:D :$!driver,
			IO::Path:D :$!test-root = 'xt'.IO,
			Int:D :$!close-delay = 3,
			Int:D :$!debug-level = 0
	) { }
	
	method pre-test { }
	method post-test { }
	
	method test {
		$!session.navigate: 'file://' ~ $html-file.absolute;
		is $!session.title, 'test', 'page title';
		my WebDriver2::Model::Element $stale = self.element-by-id: 'cb';
		my WebDriver2::Model::Element $stale2 = self.element-by-id: 'text';
		my WebDriver2::Model::Element $stale3 = self.element-by-id: 'button';
		my WebDriver2::Model::Element $iframe = self.element-by-id: 'iframe';
		my WebDriver2::Model::Element $reachable = self.element-by-id: 'link-to-page';
		self.ok: 'element in iframe reachable from containing page', $reachable.enabled;
		$iframe.frame.switch-to;
		if $!session.browser ne 'firefox' {
			
			$!session.navigate: 'file://' ~ $html-file.absolute;
			
			self.ok:
					'stale',
					.retry with WebDriver2::Until::Command::Stale.new:
							element => $stale,
							duration => 3,
							interval => 1 / 10
					;
			self.throws-like:
					'stale',
					WebDriver2::Command::Result::X.new(
							execution-status =>
							WebDriver2::Command::Execution-Status.new:
									type => WebDriver2::Command::Execution-Status::Type::Stale,
									message => ''
					),
					{
						$stale.click;
						$stale2.send-keys: 'hello';
						$stale3.value.say;
					},
					execution-status => { .type === WebDriver2::Command::Execution-Status::Type::Stale };
		} else {
			skip 'firefox stale / frame interaction', 2;
		}
		$!session.top;
		$stale = $!session.element: $link;
		my WebDriver2::Until $until-stale =
				WebDriver2::Until::Command::Stale.new:
						element => $stale,
						duration => 3,
						interval => 1 / 10;
		$stale.click;
		self.ok: 'link turned stale', $until-stale.retry;
#		$iframe.frame.switch-to;
		self.is:
				'new content available',
				'to page first',
				.text with $!session.element: $h2;
		
		
		
		$!session.navigate: 'file://' ~ $from-file.absolute;
		my WebDriver2::Model::Element $a = self.element-by-id: 'link-to-page';
		$a.click;
		
		sleep 5;
		
		my WebDriver2::Model::Element $h22 = self.element-by-id: 'page-to-heading-2';
		self.lives-ok: 'on new page', {
			self.is: 'found new correct new content', 'to page first', $h22.text
		};
		self.ok: 'a from old page is stale',
				.retry with
				WebDriver2::Until::Command::Stale.new:
						element => $a,
						duration => 5,
						interval => 1 / 10
				;
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
				{ $a.click },
				execution-status => *.type === WebDriver2::Command::Execution-Status::Type::Stale
				;
	}
	
	method element-by-id( Str $id ) {
		$!session.element( WebDriver2::Command::Element::Locator::ID.new: $id )
	}
	method element-by-tag ( Str:D $tag ) {
#		.resolve with
			$!session.element:
					WebDriver2::Command::Element::Locator::Tag-Name.new: $tag;
	}
}

sub MAIN (
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Stale.new: $browser, test-root => 'xt'.IO, :$debug;
}

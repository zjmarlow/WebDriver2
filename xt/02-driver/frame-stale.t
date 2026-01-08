use Test;

use lib <../HTTP-UserAgent/lib lib t/lib>;

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
	has Str:D $.sut-name = 'test';
	has Int:D $.plan = 6;
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
		my WebDriver2::Model::Element $outer-el = self.element-by-id: 'text';
		my WebDriver2::Model::Element $frame = self.element-by-id: 'iframe';
		self.is:
				'iframe reachable',
				'iframe',
				$frame.id;
		self.is:
				'element reachable',
				'text',
				$outer-el.id;
# 		$frame.frame.switch-to;
		$!session.navigate: 'file://' ~ $html-file.absolute;
		self.throws-like:
				'stale outer element',
				WebDriver2::Command::Result::X.new(
						execution-status =>
						WebDriver2::Command::Execution-Status.new:
								type => WebDriver2::Command::Execution-Status::Type::Stale,
								message => ''
				),
				{ $outer-el.id },
				execution-status => { .type === WebDriver2::Command::Execution-Status::Type::Stale }
				;
		self.throws-like:
                'stale frame element',
                WebDriver2::Command::Result::X.new(
                        execution-status =>
                        WebDriver2::Command::Execution-Status.new:
                                type => WebDriver2::Command::Execution-Status::Type::Stale,
                                message => ''
                ),
                { $frame.id },
                execution-status => { .type === WebDriver2::Command::Execution-Status::Type::Stale }
                ;
        $frame = self.element-by-id: 'iframe';
        $frame.frame.switch-to;
		my WebDriver2::Model::Element $ifr-cb = self.element-by-id: 'iframe-cb';
        self.is:
                'iframe checkbox reachable',
                'iframe-cb',
                $ifr-cb.id
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

constant &MAIN = driver-test Stale;

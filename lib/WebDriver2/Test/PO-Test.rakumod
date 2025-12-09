use Test;

use MIME::Base64;

use WebDriver2::SUT::Service::Loader;
use WebDriver2::Test::Adapter;
use WebDriver2::Test::Debugging;
use WebDriver2::Driver;
use WebDriver2::SUT::Service;
use WebDriver2::Test::Config-From-File;

role WebDriver2::Test::PO-Test
		does WebDriver2::Test::Adapter
		does WebDriver2::Test::Debugging
		does WebDriver2::Test::Config-From-File
{
	my class Bootstrap-Service {
		has WebDriver2::Session-Actions:D $!session
				is required
				is built
				handles <browser frames delete-session>;
		multi method screenshot {
			$!session.screenshot;
		}
		multi method screenshot ( Str:D $name ) {
			my Instant $now = now;
			my $screenshot = self.screenshot;
			unless $screenshot {
				warn "no screenshot for $name";
				return;
			}
			my Str:D $test-name = .[*-1] with self.^name.split: /\:\:/;
			my Str:D $fn =
					join '-',
							$name,
							$test-name,
							$now.to-posix[0] ~ '.png';
			.spurt: MIME::Base64.decode: $screenshot
				with IO::Path.new: $fn.subst: /<-[.a..zA..Z0..9_-]>+/, '-', :g;
		}
	}
	my constant $PLAN = 2;
	
	has Bootstrap-Service $!service
			handles <browser screenshot frames delete-session>;
	
	has Str $!browser;
	has IO::Path:D $!test-root is required is built where .d = 'xt'.IO;
	has Int:D $.close-delay is rw is required;
	
	method new (
			Str $browser is copy,
			IO::Path(Str:D) :$test-root = 'xt'.IO,
			Int:D :$close-delay = 3,
			Int:D :$debug = 0
	) {
		plan $PLAN;
		try $browser ||= browser-from-file;
		self.bail: $!.message without $browser;
		my WebDriver2::Driver-Actions $driver;
		try $driver = WebDriver2::Driver.new: $browser, :$debug;
		self.bail: $!.message without $driver;
		my WebDriver2::Session-Actions $session;
		self.lives-ok: 'session created', { $session = $driver.session };
		try {
			CATCH {
				default {
					.note;
					self.handle-error: .self;
					self.cleanup;
					self.flunk: .message;
				}
			}
			my WebDriver2::Test::PO-Test:D $self =
			self.bless:
					:$browser,
					:$test-root,
					:$close-delay,
					:$debug
					;
			$self!init: $session;
		}
	}
	
	method !init ( WebDriver2::Session-Actions:D $session ) {
		$session.set-window-rect: 1200, 750, 8, 8
			if $session.browser eq 'chrome' | 'safari';
		$!service = Bootstrap-Service.new: :$session;
		my WebDriver2::SUT::Tree::SUT $sut =
				WebDriver2::SUT::Build.page:
						{ $session.top },
						$.sut-name,
						:$.debug
				;
		my WebDriver2::SUT::Service::Loader:D $loader =
				WebDriver2::SUT::Service::Loader.new:
						:$.debug,
						:$!test-root,
						:$sut
				;
		$loader.load-elements: Array[WebDriver2::SUT::Service:D].new:
			self.services.map:
			-> WebDriver2::SUT::Service $s is rw,
			   Capture:D $a { $s .=new: :$session, :$sut, |$a };
		die 'service(s) failed initialization'
			if self.services.grep: { !.defined ?? .say || True !! False };
		self;
	}
	
	method services { ... }
	
	method plan ( --> Int ) { Int }
	method name ( --> Str:D ) { ... }
	method description ( --> Str:D ) { ... }
	method sut-name ( --> Str:D ) { ... }
	
	method pre-test { }
	method test { ... }
	method post-test { }
	method !close {
		say "\nclosing in";
		.say, sleep 1 for [R,] 1 .. $!close-delay;
		self.delete-session;
	}
	method cleanup {
		self!close;
	}
	
	method execute {
		try {
			self.subtest: $.name => {
				plan $.plan with $.plan;
				self.pre-test;
				self.test;
				self.post-test;
			};
			self!close;
			CATCH {
				default {
					.note;
					self.handle-error: .self;
					self.cleanup;
				}
			}
		}
		done-testing unless $.plan;
	}
	method handle-test-failure ( Str $descr ) {
		self.screenshot: $descr;
	}
	method handle-error ( Exception $x ) {
		.raku.say for self.frames;
		self.screenshot: $x.WHAT.Str;
	}
}

our sub po-test ( WebDriver2::Test::PO-Test:U $test-class ) {
	sub (
			Str $browser? is copy,
			IO::Path(Str:D) :$test-root = 'xt'.IO,
			Int:D :$close-delay = 3,
			Int:D :$debug = 0
	) {
		$browser ||= browser-from-file;
		.execute
		with $test-class.new:
				 $browser,
				:$close-delay,
				:$test-root,
				:$debug
				;
	}
}

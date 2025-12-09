use Test;

use MIME::Base64;
use WebDriver2::Test::Adapter;
use WebDriver2::Test::Debugging;
use WebDriver2;
use WebDriver2::Driver;
use WebDriver2::Test::Config-From-File;

unit role WebDriver2::Test::Template
		does WebDriver2::Test::Adapter
		does WebDriver2::Test::Debugging
		does WebDriver2::Test::Config-From-File;

my constant $PLAN = 2;
has IO::Path:D $.test-root is required;
has Int:D $.close-delay is rw is required;
has WebDriver2::Driver-Actions:D $!driver is required;
has WebDriver2::Session-Actions $!session;

#method browser ( --> Str:D ) { $!driver-provider.browser }

method plan ( --> Int ) { Int; }
method name ( --> Str:D ) { ... }
method description ( --> Str:D ) { ... }

multi method new (
		Str $browser is copy,
		IO::Path:D :$test-root = 't'.IO,
		Int:D :$close-delay = 3,
		Int:D :$debug is copy = 0,
		*%_
) {
	self.set-from-file: $browser, :$test-root, :$debug;
	my WebDriver2::Driver-Actions $driver =
			WebDriver2::Driver.new: $browser, :$debug;
	self.bless:
			:$driver,
			:$test-root,
			:$debug,
			:$close-delay,
			|%_,
#			driver-provider => WebDriver2::Driver::Provider.new: $browser, :$debug
	;
}

method !init {
	self.lives-ok: 'session created', { $!session = $!driver.session };
	$!session.set-window-rect: 1200, 750, 8, 8
		if $!session.browser eq 'chrome' | 'safari';
}
method pre-test { ... }
method test { ... }
method post-test { ... }
method !close {
	say "\nclosing in";
	.say, sleep 1 for ( 1 .. $.close-delay ).reverse;
	
	$!session.delete-session;
}
#method !done-testing { done-testing }
method cleanup {
	self!close;
}

method execute {
	try {
		plan $PLAN;
		self!init;
		
		self.subtest: Pair.new: $.name, {
			plan $.plan with $.plan;
			self.pre-test;
			self.test;
			self.post-test;
		};
		
		self!close;
		CATCH {
			default {
				.note;
				self.handle-error: $_;
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
	.raku.say for $!session.frames;
	self.screenshot: $x.WHAT.Str;
}

multi method screenshot {
	$!session.screenshot; #  if $!driver-provider.driver.session-id;
}

multi method screenshot ( Str:D $name ) {
	my $screenshot = self.screenshot;
	unless $screenshot {
		warn "no screenshot for $name";
		return;
	}
	my Instant $now = now;
	my Str:D $fn = join '-', $name, $now.to-posix[0] ~ '.png';
	IO::Path.new( $fn.subst: /<-[.a..zA..Z0..9_-]>+/, '-', :g )
			.spurt: MIME::Base64.decode: $screenshot;
}

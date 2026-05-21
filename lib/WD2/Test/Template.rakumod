use Test;

use MIME::Base64;
use WD2;
use WD2::Test::Adapter;
use WD2::Debug;
use WD2::Component::Driver;
use WD2::Config;

role WD2::Test::Template
		does WD2::Test::Adapter
		does WD2::Config::From-File
{
	my constant $PLAN = 2;
	has WD2::Debug:D $.debug is required = WD2::Debug.new;
	has Bool $.no-auto-ss;
	has IO::Path $.test-root;
	has Int:D $.close-delay is rw is required;
	has Str:D $.browser is required;
	has WD2::Component::Driver:D $!driver is built is required;
	has WD2::Component::Session $!session;
	
	method plan ( --> Int ) { ... }
	method name ( --> Str:D ) { ... }
	method description ( --> Str:D ) { ... }
	
	method new (
			Str $browser? is copy,
			Str:D :$host = '127.0.0.1',
			Int :$port,
			IO::Path :$test-root = 'xt'.IO,
			Int:D :$close-delay = 3,
			Level:D :$debug-level is copy = Level::WARN,
			*%_
	) {
		self.set-from-file: $test-root, $browser, :$debug-level;
		my WD2::Component::Driver:D $driver =
				Provider.get-driver: $browser, :$host, :$port, :$debug-level;
		self.bless:
				:$browser,
				:$driver,
				:$test-root,
				:$close-delay,
				:$debug-level,
				  debug => WD2::Debug.new( :$debug-level ),
				|%_,
				;
	}
	
	method init {
		plan $PLAN;
		self.lives-ok: 'session created', { $!session = $!driver.new-session };
		$!session.set-window-rect: 1200, 750, 8, 8
			if $!browser eq 'chrome' | 'safari';
	}
	method pre-test { }
	method test { ... }
	method post-test { }
	method close {
		if $!close-delay < 0 {
			$!session.session-id.say;
			DateTime.now.Str.say;
			return;
		}
		say "\nclosing in";
		.say, sleep 1 for [R,] 1 .. $!close-delay;
		$!session.delete;
		DateTime.now.Str.say;
	}
	
	method cleanup {
		self.close;
	}
	
	method execute {
		try {
			self.init;
			
			self.subtest: Pair.new: $.name, {
				self.pre-test;
				plan $.plan with $.plan;
				self.test;
				self.post-test;
				done-testing unless $.plan;
			};
			
			self.close;
			CATCH {
				default {
					.note;
					self.handle-error: $_;
					self.cleanup;
				}
			}
		}
	}
	
	method handle-test-failure ( Str $descr ) {
		self.screenshot: $descr unless $!no-auto-ss;
	}
	
	method handle-error ( Exception $x ) {
# 		.raku.say for $!session.frames;
		self.screenshot: $x.WHAT.Str unless $!no-auto-ss;
	}
	
	multi method screenshot {
		$!session.take-screenshot;
	}
	
	multi method screenshot ( Str:D $name ) {
		my Instant $now = now;
		my $screenshot = self.screenshot;
		unless $screenshot {
			warn "no screenshot for $name";
			return;
		}
		my Str:D $test-name = .tail with self.^name.split: /\:\:/;
		my Str:D $fn =
				join '-',
						$name,
						$test-name,
						$now.to-posix.head ~ '.png';
		.spurt: MIME::Base64.decode: $screenshot
			with IO::Path.new: $fn.subst: /<-[.a..zA..Z0..9_-]>+/, '-', :g;
	}
}

our sub driver-test ( WD2::Test::Template:U $test-class, Str :$default-browser ) {
	sub (
			Str $browser? is copy,
			Str:D :$host = '127.0.0.1',
			Int:D :$port = 9515,
			IO::Path(Str:D) :$test-root,
			Int:D :$close-delay = 3,
			Bool:D :$no-auto-ss = False,
			Str:D :debug(:$debug-level) = 'WARN',
			*%rest
	) {
		my %args = :$host, :$port, :$close-delay, :$no-auto-ss, :$debug-level;
		if not $browser {
			if $default-browser {
				$browser = $default-browser;
			} elsif $test-root {
				if $test-root.d {
					%args<test-root> = $test-root;
				} else {
					warn "$test-root DNE; using default";
				}
			}
		}
		.execute
		with $test-class.new:
				$browser,
				|%args,
				debug-level => Level::{ $debug-level },
				|%rest
				;
	}
}

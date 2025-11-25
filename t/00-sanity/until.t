use Test;

use lib <lib>;

use WebDriver2::Driver::Provider;
use WebDriver2::Test; # ::Adapter;
use WebDriver2::Until-C;

my class TA does WebDriver2::Test {
	has Str $.name = 'until test';
	has Str $.description = 'test timeouts';
	submethod BUILD ( IO::Path:D :$!test-root = 't'.IO, WebDriver2::Driver::Provider :$!driver-provider, Int:D :$!close-delay, Int:D :$!debug = 0 ) {  }
#	multi method new ( TA:U: Str $browser is copy, IO::Path:D :$test-root = 't'.IO, Int:D :$debug is copy = 0 ) {
#		my $self = callsame;
#		$self.services;
#		$self;
#	}
	method pre-test { }
	method post-test { }
	method test { }
#	method is ( *@_ ) { $.driver.session-id.say; callsame; }
} # ::Adapter {}

my $test = TA.new: 'chrome';
plan 14;

did duration => Duration.new: 3;

my &simple-ok = sub {
	'hello'
};

$test.is: 'simple True', 'hello', .() with basic &simple-ok;



my &simple-repeat = sub {
	my @a = 1, 2, 3;
	sub {
		@a.shift
	}
}

$test.ok: 'simple repeat',
		.() with basic &simple-repeat(),
		expect => sub ($value) {
			$value == 3
		};



my class Simple-Throwable is Exception {}

my &simple-throw = {
	Simple-Throwable.new.throw
}

$test.isa-ok:
		'simple thrown returned',
		Simple-Throwable,
		.() with throwable &simple-throw;

$test.is:
		'simple no thrown',
		'no throw',
		.() with throwable sub { 'no throw' };

$test.is:
		'no throw no throw - defined',
		'hello',
		.() with no-throw Simple-Throwable, { 'hello' };

$test.is:
		'no throw no throw - undefined',
		Any,
		.() with no-throw Simple-Throwable, { ; };

my class Other-Throwable is Exception { }

$test.throws-like:
		'no throw - wrong exception',
		Other-Throwable,
		no-throw Simple-Throwable, { Other-Throwable.new.throw };



$test.isa-ok:
		'no throw - expected exception',
#		False,
		Simple-Throwable,
		.() with no-throw Simple-Throwable, { Simple-Throwable.new.throw };

my @any = Simple-Throwable, Other-Throwable;
$test.isa-ok:
		'no throw - junction - one',
#		False,
		Simple-Throwable,
		.() with no-throw @any, { Simple-Throwable.new.throw };

$test.isa-ok:
		'no throw - junction - other',
#		False,
		Other-Throwable,
		.() with no-throw @any, { Other-Throwable.new.throw };

my class Another-Throwable is Exception { }
$test.throws-like:
		'throw - junction - neither',
		Another-Throwable,
		no-throw @any, { Another-Throwable.new.throw };

$test.isa-ok:
		'expect throw',
		Simple-Throwable,
		.() with expect-throw Simple-Throwable, { Simple-Throwable.new.throw };

# TODO : better expect-throw coverage

# retry

# x simple OK
# x simple repeat
# x simple timeout

# - chained
$test.is:
		'nested basic',
		6,
		.() with basic sub { 3 * .() with basic sub { 2 } };

###############################################################################

my &simple-timeout = sub { sleep 4; Any };

$test.throws-like:
		'simple timeout',
		WebDriver2::Until-C::Timeout::X,
		basic &simple-timeout;

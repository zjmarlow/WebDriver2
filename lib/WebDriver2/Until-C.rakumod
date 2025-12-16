use WebDriver2;
use WebDriver2::Test::Debugging;

use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;

class WebDriver2::Until-C::Timeout::X is Exception {
	method message () {
		'timeout'
	}
}

my Duration $_interval = Duration.new: 1 / 10;
my Duration $_max-duration = Duration.new: 1 * 60;
my Level:D $_debug = Level::WARN;

our sub did (
		Real :$duration = $_max-duration,
		Real :$interval = $_interval,
		Level:D :$debug-level = $_debug
) {
	$_max-duration = $duration if $duration;
	$_interval = $interval if $interval;
	$_debug = $debug-level with $debug-level;
}

our sub basic (
		&operation is required,
		:&expect = sub ( $value ) { $value.defined }, # { $value !=== Any }
		:&cleanup,
		Duration :$duration = $_max-duration,
		Duration :$interval = $_interval,
		Bool :$soft,
		Int :$debug-level is copy = $_debug
) {
	sub {
		my $return;
#$debug-level = 2;
		my Instant $start = now;
		say "\n\nSTARTING TRIALS " ~ $start.DateTime ~ "\n\n" if $debug-level;
		repeat {
			say "\n\nTRYING " ~ $start.DateTime ~ "\n\n" if $debug-level > 1;
			$return = &operation();
			say "\n\nOP VAL ", $return.raku, "\n\n" if $debug-level;
			return $return if &expect( $return );
			sleep $interval;
		} while (now - $start) < $duration;
		&cleanup() if &cleanup;
		WebDriver2::Until-C::Timeout::X.new.throw unless $soft;
		$return;
	}
}

our sub throwable (&operation) {
	-> {
		my $val;
		try $val = &operation();
		$! or $val
	};
}



our proto sub expect-throw ( | ) {*}

multi sub expect-throw ( $exception, &operation ) {
	sub {
		my $result = .() with throwable &operation;
		return False unless $result ~~ Exception;
		$result.rethrow unless $result ~~ $exception;
		$result;
	}
}

multi sub expect-throw ( @exception, &operation ) {
	sub {
		my $result = .() with throwable &operation;
		return False unless $result ~~ Exception;
		$result.rethrow unless [or] ( $result <<~~<< @exception );
		$result;
	}
}

# wait for exception
our sub expect-throw-type ( @types, &operation ) {
	sub {
		my $result = .() with throwable &operation;
		return $result unless $result ~~ WebDriver2::Command::Result::X;
#		return WebDriver2::Command::Result::X
#			unless $result.defined and $result ~~ WebDriver2::Command::Result::X;
		$result.rethrow unless [or] ( $result.execution-status.type <<~~<< @types );
		$result;
	}
}



our proto sub no-throw ( | ) {*}

# wait until expected exception no longer occurs;
# propagate throw if exception not expected
multi sub no-throw ($exception, &operation) {
	sub {
		my $result = .() with throwable &operation;
		return $result unless $result ~~ Exception;
		$result.rethrow unless $result ~~ $exception;
		$result; # return the expected exception
	}
}

# wait until expected exception no longer occurs;
# propagate throw if exception not expected
# TODO : does this work ?
multi sub no-throw (@exception, &operation) {
	sub {
		my $result = .() with throwable &operation;
		return $result unless $result ~~ Exception;
#		$result.rethrow unless [or] ( $result <<~~<< @exception );
		$result.rethrow unless $result ~~ @exception.any;
#		False;
		$result;
	}
}

# wait until expected exception no longer occurs;
# propagate throw if exception not expected
multi sub no-throw ( &matcher, &operation ) {
	sub {
		my $result = .() with throwable &operation;
		return $result unless $result ~~ Exception;
		$result.rethrow unless &matcher( $result );
#		False;
		$result;
	}
}

# wait until expected exception no longer occurs;
# propagate throw if exception not expected
our sub no-throw-type ( @types, &operation ) {
	sub {
		my $result = .() with throwable &operation;
		return $result unless $result ~~ Exception;
		$result.rethrow unless $result ~~ WebDriver2::Command::Result::X;
		$result.rethrow unless [or] ( $result.execution-status.type <<~~<< @types );
#		return WebDriver2::Command::Result::X; # False;
		$result;
	}
}

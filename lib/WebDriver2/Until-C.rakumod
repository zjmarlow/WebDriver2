use WebDriver2;

use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;

class WebDriver2::Until-C::Timeout::X is Exception {
	method message () {
		'timeout'
	}
}

my Duration $_interval = Duration.new: 1 / 10;
my Duration $_max-duration = Duration.new: 1 * 60;
my Int $_debug = 0;

our sub did (
		Real :$duration = $_max-duration,
		Real :$interval = $_interval,
		Int :$debug = $_debug
) {
	$_max-duration = $duration if $duration;
	$_interval = $interval if $interval;
	$_debug = $debug with $debug;
}

our sub basic (
		&operation is required,
		:&expect = sub ( $value ) { $value.defined }, # { $value !=== Any }
		:&cleanup,
		Duration :$duration = $_max-duration,
		Duration :$interval = $_interval,
		Bool :$soft,
		Int :$debug is copy = $_debug
) {
	sub {
		my $return;
#$debug = 2;
		my Instant $start = now;
		say "\n\nSTARTING TRIALS " ~ $start.DateTime ~ "\n\n" if $debug;
		repeat {
			say "\n\nTRYING " ~ $start.DateTime ~ "\n\n" if $debug > 1;
			$return = &operation();
			say "\n\nOP VAL ", $return.raku, "\n\n" if $debug;
			return $return if &expect( $return );
			sleep $interval;
		} while (now - $start) < $duration;
		&cleanup() if &cleanup;
		WebDriver2::Until-C::Timeout::X.new.throw unless $soft;
		$return;
	}
}

our sub throwable (&operation) {
	sub {
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

our sub expect-throw-type ( @types, &operation ) {
	sub {
		my $result = .() with throwable &operation;
		return False unless $result ~~ Exception;
		$result.rethrow unless [or] ( $result.execution-status.type <<~~<< @types );
#say 'EXPECT ', $result.raku;
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
		$result.rethrow unless [or] ( $result <<~~<< @exception );
		False;
	}
}

# wait until expected exception no longer occurs;
# propagate throw if exception not expected
multi sub no-throw ( &matcher, &operation ) {
	sub {
		my $result = .() with throwable &operation;
		return $result unless $result ~~ Exception;
		$result.rethrow unless &matcher( $result );
		False;
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
#say 'NO THROW TYPE ', $result.raku;
		False;
	}
}

use WD2::Debug;

class WD2::Wait::Timeout::X is Exception {
	method message () {
		'timeout'
	}
}

my Duration $_interval = Duration.new: 1 / 10;
my Duration $_max-duration = Duration.new: 1 * 60;
my Level:D $_debug = Level::WARN;

sub did (
		Rat :$duration = $_max-duration,
		Rat :$interval = $_interval,
		Level:D :$debug-level = $_debug
) is export(:config) {
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
) is export(:basic) {
	sub {
		my $return;
		my Instant $start = now;
		repeat {
			$return = &operation();
			return $return if &expect( $return );
			sleep $interval;
		} while (now - $start) < $duration;
		&cleanup() if &cleanup;
		WD2::Wait::Timeout::X.new.throw unless $soft;
		$return;
	}
}

our sub throwable (&operation) is export(:throw) {
	-> {
		my $val;
		try $val = &operation();
		$! or $val
	};
}



our proto sub expect-throw ( | ) is export(:throw) {*}

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
		$result.rethrow unless $result ~~ @exception.any;
		$result;
	}
}

# wait for exception
our sub expect-throw-type ( @types, &operation ) is export(:throw) {
	sub {
		my $result = .() with throwable &operation;
		return $result unless $result ~~ WD2::Endpoints::Result::X;
#		return WD2::Endpoints::Result::X
#			unless $result.defined and $result ~~ WD2::Endpoints::Result::X;
		$result.rethrow unless $result.execution-status.type ~~ @types.any;
		$result;
	}
}



our proto sub no-throw ( | ) is export(:throw) {*}

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
our sub no-throw-type ( @types, &operation ) is export(:throw) {
	sub {
		my $result = .() with throwable &operation;
		return $result unless $result ~~ Exception;
		$result.rethrow unless $result ~~ WD2::Endpoints::Result::X;
		$result.rethrow unless $result.execution-status.type ~~ @types.any;
#		return WD2::Endpoints::Result::X; # False;
		$result;
	}
}

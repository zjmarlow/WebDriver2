use WebDriver2;

class WebDriver2::Until-C::Timeout::X is Exception {
	method message () {
		'timeout'
	}
}

my Real $_interval = 1 / 10;
my Real $_max-duration = 1 * 60;
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
		:&expect = sub ( $value ) { $value !=== Any },
		:&cleanup,
		Real :$duration = $_max-duration,
		Real :$interval = $_interval,
		Bool :$soft,
		Int :$debug = $_debug
) {
	sub {
		my $return;
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
		return False unless $result ~~ $exception;
		return $result;
	}
}

our proto sub no-throw ( | ) {*}

# wait until expected exception no longer occurs;
# propagate throw if exception not expected
multi sub no-throw ($exception, &operation) {
	sub {
		my $result = .() with throwable &operation;
		return $result unless $result ~~ Exception;
		$result.throw unless $result ~~ $exception;
		False;
	}
}

# wait until expected exception no longer occurs;
# propagate throw if exception not expected
multi sub no-throw (@exception, &operation) {
	sub {
		my $result = .() with throwable &operation;
		return $result unless $result ~~ Exception;
		$result.throw unless $result ~~ @exception.any;
		False;
	}
}

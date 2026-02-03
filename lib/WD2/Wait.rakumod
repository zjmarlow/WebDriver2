use WD2::Debug;
use WD2::Endpoints;

my Duration:D $_duration = Duration.new: 3;
my Duration:D $_interval = Duration.new: 1/10;

my Duration:D $_min-duration = Duration.new: 1/10;
my Duration:D $_max-duration = Duration.new: 10 * 60;
my Duration:D $_min-interval = Duration.new: 1/100;
my Duration:D $_max-interval = Duration.new: 10;
my Level:D $_debug = Level::WARN;

class WD2::Wait::Timeout::X is Exception {
	method message () {
		'timeout'
	}
}

our sub wait-defaults (
		Duration :$duration,
		Duration :$min-duration,
		Duration :$max-duration = $_max-duration,
		Duration :$interval,
		Duration :$min-interval,
		Duration :$max-interval,
		Level :$debug-level = $_debug
) is export(:config) {
	$_duration = $duration if $duration;
	$_min-duration = $min-duration if $min-duration;
	$_max-duration = $max-duration if $max-duration;
	$_interval = $interval if $interval;
	$_min-interval = $min-interval if $min-interval;
	$_max-interval = $max-interval if $max-interval;
	$_debug = $debug-level with $debug-level;
}

sub check-bounds (
	Duration:D $duration,
	Duration:D $interval
) {
	if $duration < $_min-duration {
		$duration = $_min-duration;
		warn "setting duration $duration to $_min-duration";
	} elsif $duration > $_max-duration {
		$duration = $_max-duration;
		warn "setting duration $duration to $_max-duration";
	}
	if $interval < $_min-interval {
		$interval = $_min-interval;
		warn "setting interval $interval to $_min-interval";
	} elsif $interval > $_max-interval {
		$interval = $_max-interval;
		warn "setting interval $interval to $_max-interval";
	}
}

our sub basic-op (
		&operation where .defined,
		:&cleanup,
		Duration:D :$duration = $_duration,
		Duration:D :$interval = $_interval,
		Bool :$soft,
		Level :$debug-level = $_debug
) is export(:base :basic) {
	check-bounds $duration, $interval;
	-> {
		my $return;
		my Bool:D $expired = False;
		my Instant:D $start = now;
		react whenever Supply.interval: $interval {
			try $return = &operation();
			done if $return or $expired = now - $start > $duration;
		}
		&cleanup() if &cleanup;
		WD2::Wait::Timeout::X.new.throw if $expired and not $soft;
		$return;
	}
}

our sub basic (
		&operation where .defined,
		:&expect = -> $value { $value.defined },
		:&cleanup,
		Duration:D :$duration = $_duration,
		Duration:D :$interval = $_interval,
		Bool :$soft,
		Level :$debug-level = $_debug
) is export(:base :basic) {
	check-bounds $duration, $interval;
	-> {
		my $return;
		my Bool:D $expired = False;
		my Instant:D $start = now;
		react whenever Supply.interval: $interval {
			try $return = &operation();
			done if $! && &expect($!) || &expect($return) or $expired = now - $start > $duration;
		}
		&cleanup() if &cleanup;
		WD2::Wait::Timeout::X.new.throw if $expired and not $soft;
		$return;
	}
}

our sub basic-true (
		&operation where .defined,
		:&cleanup,
		Duration:D :$duration = $_duration,
		Duration:D :$interval = $_interval,
		Bool :$soft,
		Level :$debug-level = $_debug
) is export(:basic) {
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	my &expect = -> $value { $value === True };
	basic &operation, :&expect, |%args;
}

our sub basic-so-true (
		&operation where .defined,
		:&cleanup,
		Duration:D :$duration = $_duration,
		Duration:D :$interval = $_interval,
		Bool :$soft,
		Level :$debug-level = $_debug
) is export(:basic) {
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	my &expect = -> $value { so $value };
	basic &operation, :&expect, |%args;
}

our sub basic-to-true (
		&operation where .defined,
		:&cleanup,
		Duration:D :$duration = $_duration,
		Duration:D :$interval = $_interval,
		Bool :$soft,
		Level :$debug-level = $_debug
) is export(:basic) {
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	my &expect = <-> $val {
		! $val === True
				?? ( $val = True )
				!! ( $val = False )
	};
	basic &operation, :&expect, |%args;
}

our sub basic-equals (
		&operation where .defined,
		$value,
		:&cleanup,
		Duration:D :$duration = $_duration,
		Duration:D :$interval = $_interval,
		Bool :$soft,
		Level :$debug-level = $_debug
) is export(:basic) {
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	my &expect = -> $val { $val == $value };
	basic &operation, :&expect, |%args;
}



#| performs the operation and returns a (non-failure) exception
#|   if there was one,
#|   otherwise the return value
our sub throwable (&operation) is export(:throw) {
	-> {
		my $val;
		try $val = &operation();
		$! or $val
	};
}

our sub expect-throw ( &operation ) is export(:throw){
	-> {
		my $result = .() with throwable &operation;
		return False unless $result.isa: Exception;
		$result but True;
	}
}

#| rethrow wrong exception
#| return the type if it was expected
#| return Error-Code:U otherwise
our sub expect-throw-type ( &operation, Error-Code:D @types ) is export(:throw) {
	-> {
		my $result = .() with throwable &operation;
		if $result.isa: WD2::Endpoints::Result::X {
			if $result.execution-error.error === @types.any {
				$result = $result.execution-error.error;
			} else {
				$result = Error-Code;
			}
		} elsif $result.isa: Exception {
			$result.rethrow;
		} else {
			$result = Error-Code;
		}
		$result;
	}
}



# wait until exception no longer occurs
our sub no-throw (&operation) {
	-> {
		my $result = .() with throwable &operation;
		return $result unless $result ~~ Exception;
		$result but False;
	}
}

# wait until expected exception no longer occurs;
# propagate throw if exception not expected
our sub no-throw-type ( &operation, Error-Code:D @types ) is export(:throw) {
	-> {
		my $result = .() with throwable &operation;
		return $result unless $result ~~ Exception;
		$result.rethrow unless $result ~~ WD2::Endpoints::Result::X;
		$result.rethrow unless $result.execution-error.error === @types.any;
		$result but False;
	}
}

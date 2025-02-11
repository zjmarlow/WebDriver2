use WebDriver2;

use WebDriver2::Command::Result;

class WebDriver2::Until::Timeout::X is Exception {
	method message ( ) { 'timeout' }
}

role WebDriver2::Until::Sequential {
	has &!next;
	;
	method preceed ( &inner ) {
	
	}
}

class WebDriver2::Until {
	my Real $_interval = 1/10;
	my Int $_debug = 0;

	has &!operation is required;
	has &!matcher;
	has &!cleanup;
	has Duration $.duration is required;
	has Duration $!interval = $_interval;
	has Bool $!soft = False;
	has Int $!debug = 0;

	method interval ( WebDriver2::Until:U: Real $val ) {
		$_interval = $val;
	}
	method debug ( WebDriver2::Until:U: Int $val ) {
		$_debug = $val;
	}

	submethod BUILD (
			:&!operation,
			:&!matcher,
			:&!cleanup,
			Duration :$!duration,
			Duration :$!interval,
			Bool :$!soft,
			Int :$!debug
	) { }

	method new (
			:&operation,
			:&matcher,
			:&cleanup,
			Real :$duration,
			Real :$interval,
			Bool :$soft,
			Int :$debug
	) {
		self.bless:
				:&operation,
				:&matcher,
				:&cleanup,
				duration => ( ( DateTime.now.later: seconds => $duration ) - DateTime.now ),
				interval => Duration.new( $interval // $_interval ),
				:$soft,
				debug => $debug // $_debug;
	}

	method retry {
		my Instant $start = now;
		say "\n\nSTARTING TRIALS " ~ $start.DateTime ~ "\n\n" if $!debug;
		repeat {
			say "\n\nTRYING " ~ $start.DateTime ~ "\n\n" if $!debug;
			my $return = &!operation();
			say "\n\nOP VAL ", $return.raku, "\n\n" if $!debug;
			return $return
				if &!matcher and &!matcher( $return )
				or not &!matcher and $return;
			&!cleanup() if &!cleanup;
			sleep $!interval;
		} while ( now - $start ) < $!duration;
		WebDriver2::Until::Timeout::X.new.throw unless $!soft;
	}
}

# returns $! from thrown instead of propagating exception
class WebDriver2::Until::Throwable is WebDriver2::Until {
	method new (
			:&operation,
			:&matcher,
			:&cleanup,
			Real :$duration,
			Real :$interval,
			Bool :$soft,
			Int :$debug
	) {
		callwith operation => sub {
			my $val;
			try $val = &operation();
			$! or $val;
		}, :&matcher, :&cleanup, :$duration, :$interval, :$soft, :$debug;
	}
}

class WebDriver2::Until::Throws is WebDriver2::Until::Throwable {
	method new (
			:&operation,
			:$exception,
			:&matcher,
			:&cleanup,
			Real :$duration,
			Real :$interval,
			Bool :$soft,
			Int :$debug
	) {
		callwith :&operation, :$exception,
		matcher => sub ( $ret ) {
			$ret ~~ $exception and ! &matcher || &matcher( $ret );
		}, :&cleanup, :$duration, :$interval, :$soft, :$debug;
	}
}

# wait until expected exception no longer occurs;
# propagate throw if exception not expected
class WebDriver2::Until::No-Throw is WebDriver2::Until::Throwable {
	method new (
			:&operation,
			:$exception,
			:&cleanup,
			Real :$duration,
			Real :$interval,
			Bool :$soft,
			Int :$debug
	) {
		callwith :&operation,
		matcher => sub ( $ret ) {
#say 'No-Throw ', ( $ret ~~ $exception ), ', ', $ret.raku, "\n\t", $exception.raku;
			if $ret ~~ Exception {
#say 'ret ', $ret.raku;
				return False if $ret ~~ $exception;
				$ret.rethrow;
			}
			return $ret;
		}, :&cleanup, :$duration, :$interval, :$soft, :$debug;
	}
}

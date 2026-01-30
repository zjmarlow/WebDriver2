role WD2::Config::From-File {
	my IO::Path $browser-file = $*CWD.add: 'browser';
	my IO::Path $debug-file = $*CWD.add: 'debug';
	
	method set-from-file ( Str $browser is rw, IO::Path :$test-root = 'xt'.IO
	#`[, Level $debug-level is rw ] ) {
		unless $browser {
			die 'must provide valid browser argument or specify in browser file'
			unless $test-root.add( 'browser' ).e;
			$browser = .trim.lc with $browser-file.slurp: :close;
		}
	}
}

our sub browser-from-file ( IO::Path $test-root = 'xt'.IO ) {
	my IO::Path:D $browser-file = $test-root.add: 'browser';
	die 'missing plain file "browser"' unless $browser-file.f;
	.trim.lc with $browser-file.slurp: :close;
}

my sub pre-process ( IO::Path $file --> Str ) {
	my Str $buff;
	for $file.lines -> Str $line {
		given $line {
			when /^ \s*\#include\s+\'(<-[']>+)\'/ {
				$buff ~= pre-process( $file.parent.add( $/[0].Str ) );
			}
			when /^ \s*\# / {
				next;
			}
			default {
				$buff ~= $line;
			}
		}
	}
	return $buff;
}

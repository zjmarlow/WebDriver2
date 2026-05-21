role WD2::Config::From-File {
	# my IO::Path $browser-file = $*CWD.add: 'browser';
	# my IO::Path $debug-file = $*CWD.add: 'debug';
	
	method set-from-file (
			IO::Path:D $test-root,
			Str $browser is rw,
			# Level $debug-level is rw
	) {
		return if $browser;
		$browser = browser-from-file $test-root unless $browser;
	}
}

our sub browser-from-file ( IO::Path:D $test-root ) {
	my IO::Path:D $browser-file = $test-root.add: 'browser';
	die 'missing plain file "browser" using test root ' ~ $test-root.Str
		unless $browser-file.f;
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

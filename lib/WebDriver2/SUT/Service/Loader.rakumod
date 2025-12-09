use WebDriver2;

use WebDriver2::SUT::Build;
use WebDriver2::SUT::Tree;
use WebDriver2::SUT::Service;
use WebDriver2::Test::Debugging;

use WebDriver2::SUT::Navigator;

unit class WebDriver2::SUT::Service::Loader does WebDriver2::Test::Debugging;

my WebDriver2::SUT::Service::Loader $instance;

has IO::Path:D $!test-root is required is built;
has IO::Path:D $!def-dir is required is built;
has WebDriver2::SUT::Tree::SUT $!sut is built;



method new (
#		Str:D :$sut-name,
		WebDriver2::SUT::Tree::SUT :$sut,
		IO::Path:D :$test-root = 'xt'.IO,
		Int:D :$debug = 0
) {
	if $instance {
		note 'service loader instance exists; ignoring args.  ';
		#				~ "updating debug to $debug";
		#		$instance.debug = $debug;
		return $instance;
	}
	my IO::Path $def-dir = $test-root.add: 'def';
	$instance = self.bless: :$sut, :$test-root, :$def-dir, :$debug;
}

method load-elements ( WebDriver2::SUT::Service:D @svc ) {
	for @svc -> WebDriver2::SUT::Service:D $svc {
		my Str:D $prefix = $svc.prefix;
		my Str:D $key-prefix = $svc.key-prefix;
		my Str ( $k, $v );
		my WebDriver2::SUT::Tree::APage $page;
		my WebDriver2::SUT::Navigator $nav;
		my WebDriver2::SUT::Tree::ANode %elements;
		
		my Str $svc-fn = .[*-1].lc with $svc.name.split: '::';
		say 'LOADING ', $svc-fn if $!debug;
		for $!def-dir.add( "$svc-fn.service" ).lines -> Str $line {
			if $line ~~ /^\s*\#page\:\s*\S+/ {
				$page = $!sut.get: .[1].trim with $line.split: /\:/, 2;
				$nav = WebDriver2::SUT::Navigator.new: tree => $page, :$!debug;
				next;
			}
			next if $line ~~ /^\s*[\#.*]?\s*$/;
			die 'no page set' unless $nav and $page;
			($k, $v) = $line.split(/\:/, 2)>>.trim;
			$k = $key-prefix ~ '-' ~ $k if $key-prefix;
			die "element named $k already set" if %elements{$k}:exists;
			$svc.add-element: $k, $nav.traverse: "$prefix$v";
		}
	}
	return
}

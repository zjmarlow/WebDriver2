use Test;

use MIME::Base64;

use WebDriver2::Test::PO-Test;
use WebDriver2::SUT::Tree;
use WebDriver2::SUT::Service::Loader;

unit role WebDriver2::Test::Service-Test does WebDriver2::Test::PO-Test;

has WebDriver2::SUT::Service::Loader $!loader;

method loader ( --> WebDriver2::SUT::Service::Loader:D ) {
	$!loader ||= WebDriver2::SUT::Service::Loader.new:
			:$.debug,
			:$.test-root,
			sut =>
				WebDriver2::SUT::Build.page:
						{ $!session.top },
						$.sut-name,
						:$.debug;
}

#multi method new ( WebDriver2::Test::Service-Test:U: Str $browser is copy, IO::Path:D :$test-root = 't'.IO, Int:D :$debug is copy = 0 ) {
#	my $self = callsame;
#	$self.services;
#	$self;
#}

method sut-name ( --> Str:D ) { ... }

method services ( Str:D $browser ) { ... }

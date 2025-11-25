use Test;
use MIME::Base64;

use WebDriver2;
use WebDriver2::Driver::Chrome;
use WebDriver2::Driver::Edge;
use WebDriver2::Driver::Firefox;
use WebDriver2::Driver::Safari;
use WebDriver2::Test::Debugging;
use WebDriver2::Test::Config-From-File;

my WebDriver2 %driver = (
		chrome => WebDriver2::Driver::Chrome,
		edge => WebDriver2::Driver::Edge,
		firefox => WebDriver2::Driver::Firefox,
		safari => WebDriver2::Driver::Safari,
);

unit class WebDriver2::Driver::Provider
		does WebDriver2::Test::Debugging
		does WebDriver2::Test::Config-From-File;

my WebDriver2 $driver;
my WebDriver2::Driver::Provider $instance;

has Str:D $.browser is required;

submethod BUILD ( Str:D :$!browser ) { }

method new ( Str:D $browser ) { $instance // ( $instance = self.bless: :$browser ) }

#has Int $.close-delay is rw = 3;

#method os ( --> Str:D ) { ... }
#method browser ( --> Str:D ) { ... }

method driver ( --> WebDriver2:D ) {
	self.set-from-file: $!browser, #`[ $.debug ] unless $driver;
	$driver ||= %driver{ $!browser }.new: :$.debug;
}

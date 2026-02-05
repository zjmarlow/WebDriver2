use lib <../http-useragent/lib lib>;

use WD2;
use WD2::Component::Driver;
use WD2::Component::Session;

sub MAIN ( Str:D $browser, Str:D $session-id, Str:D $host = '127.0.0.1', Int:D $port = 9515 ) {
	my WD2::Component::Driver:D $driver =
		Provider.get-driver: $browser, :$host, :$port;
	my WD2::Component::Session:D $session =
			WD2::Component::Session.new:
					:$driver,
					host => $driver.host,
					port => $driver.port,
					:$session-id;
	$session.delete;
}

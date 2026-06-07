use WD2::Endpoints;
use WD2::Locators;
use WD2::Component::Session;

unit class WD2::Component::Driver does WD2::Endpoints;

has Str:D $.browser is required;

method url ( *@command --> Str:D ) {
	join '/', "http://$!host:$!port", |@command;
}

multi method status (
		WD2::Component::Driver:D:
) { WD2::Component::Driver.status: self }
multi method status (
		WD2::Component::Driver:U: WD2::Component::Driver:D $driver ) {
	my $return = self.check-status: self.request: self.get-request: $driver, 'status';
	return .<value> with $return;
	$return;
}
multi method new-session (
		WD2::Component::Driver:D:
		%capabilities = { capabilities => { } }
		--> WD2::Component::Session:D
) { WD2::Component::Driver.new-session: %capabilities, self }
multi method new-session (
		WD2::Component::Driver:U: %capabilities, WD2::Component::Driver:D $driver --> WD2::Component::Session:D
) {
	%capabilities<capabilities> = { } unless %capabilities and %capabilities<capabilities>.isa: Hash;
	my $return = self.check-status:
		self.request: self.post-request: %capabilities, $driver, 'session';
	return WD2::Component::Session.new:
			:$driver,
			host => $driver.host,
			port => $driver.port,
			session-id => .<value><sessionId>
	with $return;
	$return;
}

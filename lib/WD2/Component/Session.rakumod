use WD2::Endpoints;
use WD2::Locators;
use WD2::Component::Element;

unit class WD2::Component::Session does WD2::Endpoints;

has WD2::Endpoints:D $.driver is required;
has Str:D $.session-id is required;
method url ( *@command --> Str:D ) {
	$!driver.url: 'session', $!session-id, @command;
}

multi method delete ( WD2::Component::Session:D: ) {
	WD2::Component::Session.delete: self;
}
multi method delete (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
) {
	my $return = self.check-status: self.request: self.delete-request: $session;
	return $session.driver with $return;
	$return;
}
multi method get-timeouts (
		WD2::Component::Session:D:
) { WD2::Component::Session.get-timeouts: self }
multi method get-timeouts (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
) {
	my $return = self.check-status: self.request: self.get-request: $session, 'timeouts';
	return .<value> with $return;
	$return;
}
multi method set-timeouts (
		WD2::Component::Session:D:
		Int $script,
		Int $pageLoad,
		Int $implicit
		--> WD2::Component::Session:D
) { WD2::Component::Session.set-timeouts: $script, $pageLoad, $implicit, self }
multi method set-timeouts (
		WD2::Component::Session:U:
		Int $script,
		Int $pageLoad,
		Int $implicit,
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my $return = self.check-status: self.request:
			self.post-request: {
				:$script,
				:$pageLoad,
				:$implicit
			},
			$session,
			'timeouts'
	;
	return $session with $return;
	$return;
}
multi method navigate-to (
		WD2::Component::Session:D:
	Str:D $url --> WD2::Component::Session:D
) { WD2::Component::Session.navigate-to: $url, self }
multi method navigate-to (
		WD2::Component::Session:U:
		Str:D $url, WD2::Component::Session:D $session --> WD2::Component::Session:D
) {
	my $return = self.check-status: self.request: self.post-request: { :$url }, $session, 'url';
	return $session with $return;
	$return;
}
multi method current-url (
		WD2::Component::Session:D:
		--> Str:D
) { WD2::Component::Session.current-url: self }
multi method current-url (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> Str:D
) {
	my $return = self.check-status: self.request: self.get-request: $session, 'url';
	return .<value> with $return;
	$return;
}
multi method back (
		WD2::Component::Session:D:
		--> WD2::Component::Session:D
) { WD2::Component::Session.back: self }
multi method back (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my $return = self.check-status: self.request: self.post-request: { }, $session, 'back';
	return $session with $return;
	$return;
}
multi method forward (
		WD2::Component::Session:D:
		--> WD2::Component::Session:D
) { WD2::Component::Session.forward: self }
multi method forward (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my $return = self.check-status: self.request: self.post-request: { }, $session, 'forward';
	return $session with $return;
	$return;
}
multi method refresh (
		WD2::Component::Session:D:
		--> WD2::Component::Session:D
) { WD2::Component::Session.refresh: self }
multi method refresh (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my $return = self.check-status: self.request: self.post-request: { }, $session, 'refresh';
	return $session with $return;
	$return;
}
multi method title (
		WD2::Component::Session:D:
		--> Str:D
) { WD2::Component::Session.title: self }
multi method title (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> Str:D
) {
	my $return = self.check-status: self.request: self.get-request: $session, 'title';
	return .<value> with $return;
	$return;
}
multi method get-window-handle (
		WD2::Component::Session:D:
		--> Str:D
) { WD2::Component::Session.get-window-handle: self }
multi method get-window-handle (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> Str:D
) {
	my $return = self.check-status: self.request: self.get-request: $session, 'window';
	return .<value> with $return;
	$return;
}
multi method close-window (
		WD2::Component::Session:D:
		--> WD2::Component::Session:D
) { WD2::Component::Session.close-window: self }
multi method close-window (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my $return = self.check-status: self.request: self.delete-request: $session, 'window';
	return $session with $return;
	$return;
}
multi method switch-to-window (
		WD2::Component::Session:D:
		Str:D $handle --> WD2::Component::Session:D
) { WD2::Component::Session.switch-to-window: $handle, self }
multi method switch-to-window (
		WD2::Component::Session:U:
		Str:D $handle, WD2::Component::Session:D $session --> WD2::Component::Session:D
) {
	my $return = self.check-status: 
			self.request: self.post-request: { :$handle }, $session, 'window';
	return $session with $return;
	$return;
}
multi method get-window-handles (
		WD2::Component::Session:D:
		--> List:D[ Str:D ]  ) { WD2::Component::Session.get-window-handles: self }
multi method get-window-handles (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> List:D[ Str:D ] ) {
	my $return = self.check-status: self.request: self.get-request: $session, <window handles>;
	return .<value> with $return;
	$return;
}
multi method new-window (
		WD2::Component::Session:D:
		Str:D $type where <tab window>.any
) { WD2::Component::Session.new-window: $type, self }
multi method new-window (
		WD2::Component::Session:U:
		Str:D $type where <tab window>.any, WD2::Component::Session:D $session ) {
	my %args = ();
	%args{ 'type hint' } = $type if $type;
	my $return = self.check-status:
			self.request: %args, self.post-request: $session, <window new>;
	return .<value> with $return;
	$return;
}
multi method switch-to-frame ( WD2::Component::Session:D: --> WD2::Component::Session:D ) {
	my $return = self.check-status: self.request: self.post-request: { id => Str }, self, 'frame';
	return self with $return;
	$return;
}
multi method switch-to-frame ( WD2::Component::Session:D: Int $frame --> WD2::Component::Session:D ) {
	my $return = self.check-status: 
			self.request: self.post-request: { id => $frame }, self, 'frame';
	return self with $return;
	$return;
}
method top ( WD2::Component::Session:D: --> WD2::Component::Session:D ) {
	self.switch-to-frame;
}
multi method switch-to-parent-frame (
		WD2::Component::Session:D:
		--> WD2::Component::Session:D
) { WD2::Component::Session.switch-to-parent-frame: self }
multi method switch-to-parent-frame (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my $return = self.check-status: 
			self.request: self.post-request: { }, $session, <frame parent>;
	return $session with $return;
	$return;
}
multi method get-window-rect (
		WD2::Component::Session:D:
) { WD2::Component::Session.get-window-rect: self }
multi method get-window-rect (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session ) {
	my $return = self.check-status: self.request: self.get-request: $session, <window rect>;
	return .<value> with $return;
	$return;
}
multi method set-window-rect (
		WD2::Component::Session:D:
		Int $width,
		Int $height,
		Int $x,
		Int $y,
		--> WD2::Component::Session:D
) { WD2::Component::Session.set-window-rect:
		$width,
		$height,
		$x,
		$y,
		self
}
multi method set-window-rect (
		WD2::Component::Session:U:
		Int $width,
		Int $height,
		Int $x,
		Int $y,
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my %args = grep *.value.defined, do :$width, :$height, :$x, :$y;
	my $return = self.check-status:
			self.request: self.post-request: %args, $session, <window rect>;
	return $session with $return;
	$return;
}
multi method maximize-window (
		WD2::Component::Session:D:
		--> WD2::Component::Session:D
) { WD2::Component::Session.maximize-window: self }
multi method maximize-window (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my $return = self.check-status:
			self.request: self.post-request: { }, $session, <window maximize>;
	return $session with $return;
	$return;
}
multi method minimize-window (
		WD2::Component::Session:D:
		--> WD2::Component::Session:D
) { WD2::Component::Session.minimize-window: self }
multi method minimize-window (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my $return = self.check-status:
			self.request: self.post-request: { }, $session, <window minimize>;
	return $session with $return;
	$return;
}
multi method fullscreen-window (
		WD2::Component::Session:D:
		--> WD2::Component::Session:D
) { WD2::Component::Session.fullscreen-window: self }
multi method fullscreen-window (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my $return = self.check-status:
			self.request: self.post-request: { }, $session, <window fullscreen>;
	return $session with $return;
	$return;
}
multi method active-element (
		WD2::Component::Session:D:
		--> Element:D
) { WD2::Component::Session.active-element: self }
multi method active-element (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> Element:D
) {
	my $return = self.check-status: self.request: self.get-request: $session, <element active>;
	return Element.new:
			host => $session.host,
			port => $session.port,
			:$session,
			element-id => $return<value>{ $Element::IDENTIFIER }
	with $return;
	$return;
}

multi method find-element (
		WD2::Component::Session:D:
		By:D $locator --> Element:D
) { WD2::Component::Session.find-element: $locator, self }

multi method find-element (
		WD2::Component::Session:U:
		By:D $locator,
		WD2::Component::Session:D $session
		--> Element:D
) {
	my $return = self.check-status:
			self.request: self.post-request: $locator.args, $session, 'element';
	return Element.new:
			host => $session.host,
			port => $session.port,
			:$locator,
			:$session,
			element-id => $return<value>{ $Element::IDENTIFIER }
	with $return;
	$return;
}
multi method find-elements (
		WD2::Component::Session:D:
		By:D $locator,
		--> List:D[ Element:D ]
) {
	WD2::Component::Session.find-elements: $locator, self
}
multi method find-elements (
		WD2::Component::Session:U:
		By:D $locator,
		WD2::Component::Session:D $session
		--> List:D[ Element:D ]
) {
	my $return = self.check-status:
			self.request: self.post-request: $locator.args, $session, 'elements';
	without $return {
		$return.handled = False;
		return $return;
	}
	my Element:D @elements = Array[ Element:D ].new;
	for $return<value>>>.{ $Element::IDENTIFIER } -> $element-id {
		@elements.push:
				Element.new:
						host => $session.host,
						port => $session.port,
						:$locator,
						:$session,
						:$element-id
				;
	}
	@elements;
}
method present (
		WD2::Component::Session:D:
		By:D $locator
		--> WD2::Component::Element
) {
	my WD2::Component::Element:D @elements = self.find-elements: $locator;
	@elements ?? @elements[0] !! WD2::Component::Element;
}

multi method page-source (
		WD2::Component::Session:D:
		--> Str:D
) { WD2::Component::Session.page-source: self }

multi method page-source (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> Str:D
) {
	my $return = self.check-status: self.request: self.get-request: $session, 'source';
	return .<value> with $return;
	$return;
}
multi method execute-script (
		WD2::Component::Session:D:
		Str:D $script,
		@args
) {
	WD2::Component::Session.execute-script: $script, @args, self
}
multi method execute-script (
		WD2::Component::Session:U:
		Str:D $script,
		@args,
		WD2::Component::Session:D $session
) {
	my $return = self.check-status:
			self.request:
					self.post-request:
							{ :$script, :@args }, $session, <execute sync>;
	return .<value> with $return;
	$return;
}
multi method execute-async-script (
		WD2::Component::Session:D:
		Str:D $script,
		@args,
		) { WD2::Component::Session.execute-async-script: $script,
		@args, self
		}
multi method execute-async-script (
		WD2::Component::Session:U:
		Str:D $script,
		@args,
		WD2::Component::Session:D $session ) {
	my $return = self.check-status:
			self.request:
					self.post-request:
							{ :$script, :@args }, $session, <execute async>;
	return .<value> with $return;
	$return;
}
multi method get-all-cookies (
		WD2::Component::Session:D:
		--> List:D
) { WD2::Component::Session.get-all-cookies: self }
multi method get-all-cookies (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> List:D
) {
	my $return = self.check-status: self.request: self.get-request: $session, 'cookie';
	return Array.new: |.<value> with $return;
	$return;
}
multi method get-named-cookie ( WD2::Component::Session:D: Str:D $name ) {
	WD2::Component::Session.get-named-cookie: $name, self
}
multi method get-named-cookie (
		WD2::Component::Session:U:
		Str:D $name, WD2::Component::Session:D $session ) {
	my $return = self.check-status: 
			self.request: self.get-request: $session, 'cookie', $name;
	return $session with $return;
	$return;
}
=begin table :caption<cookie object structure>
	RFC 6265 Field		| JSON Key | Attribute Key
	=========================================
	name				| name		|
	value				| value		|
	path				| path		| Path
	domain				| domain	| Domain
	secure-only-flag	| secure	| Secure
	http-only-flag		| httpOnly	| HttpOnly
	expiry-time			| expiry	| Max-Age
	samesite			| sameSite	| SameSite
=end table
multi method add-cookie (
		Str:D $name,
		Str:D $value,
		%cookie,
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my %args =
		.flat with do grep -> $k, $v { $v.defined and $k, $v },
		.flat with do :$name.kv, :$value.kv,
			%cookie<path domain secure httpOnly expiry sameSite>:kv;
	my $return = self.check-status:
			self.request: self.post-request: { cookie => %args }, $session, 'cookie';
	return $session with $return;
	$return;
}
multi method add-cookie (
		Str:D $name,
		Str:D $value,
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my %args = :$name, :$value;
	my $return = self.check-status:
			self.request: self.post-request: { cookie => %args }, $session, 'cookie';
	return $session with $return;
	$return;
}
multi method delete-cookie (
		WD2::Component::Session:D:
		Str:D $name
		--> WD2::Component::Session:D
) { WD2::Component::Session.delete-cookie: $name, self }
multi method delete-cookie (
		WD2::Component::Session:U:
		Str:D $name,
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my $return = self.check-status:
			self.request: self.delete-request: $session, 'cookie', $name;
	return $session with $return;
	$return;
}
multi method delete-all-cookies (
		WD2::Component::Session:D:
		--> WD2::Component::Session:D
) { WD2::Component::Session.delete-all-cookies: self }
multi method delete-all-cookies (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my $return = self.check-status: self.request: self.delete-request: $session, 'cookie';
	return $session with $return;
	$return;
}
multi method perform-actions (
		WD2::Component::Session:D:
		--> WD2::Component::Session:D
) { WD2::Component::Session.perform-actions: self }
multi method perform-actions (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	!!! 'nyi'
}
multi method release-actions (
		WD2::Component::Session:D:
		--> WD2::Component::Session:D
) { WD2::Component::Session.release-actions: self }
multi method release-actions (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	!!! 'nyi'
}
multi method dismiss-alert (
		WD2::Component::Session:D:
		--> WD2::Component::Session:D
) { WD2::Component::Session.dismiss-alert: self }
multi method dismiss-alert (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my $return = self.check-status:
			self.request: self.post-request: { }, $session, <alert dismiss>;
	$return;
}
multi method accept-alert (
		WD2::Component::Session:D:
		--> WD2::Component::Session:D
) { WD2::Component::Session.accept-alert: self }
multi method accept-alert (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> WD2::Component::Session:D
) {
	my $return = self.check-status:
			self.request: self.post-request: { }, $session, <alert accept>;
	return $session with $return;
	$return;
}
multi method get-alert-text (
		WD2::Component::Session:D:
		--> Str:D
) { WD2::Component::Session.get-alert-text: self }
multi method get-alert-text (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> Str:D
) {
	my $return = self.check-status: self.request: self.get-request: $session, <alert text>;
	return .<value> with $return;
	$return;
}
multi method send-alert-text (
		WD2::Component::Session:D:
		Str:D $text --> WD2::Component::Session:D
) { WD2::Component::Session.send-alert-text: $text, self }
multi method send-alert-text (
		WD2::Component::Session:U:
		Str:D $text, WD2::Component::Session:D $session --> WD2::Component::Session:D
) {
	my $return = self.check-status:
			self.request: self.post-request: { :$text }, $session, <alert text>;
	return $session with $return;
	$return;
}
multi method take-screenshot (
		WD2::Component::Session:D:
		--> Str:D
) { WD2::Component::Session.take-screenshot: self }
multi method take-screenshot (
		WD2::Component::Session:U:
		WD2::Component::Session:D $session
		--> Str:D
) {
	my $return = self.check-status: self.request: self.get-request: $session, 'screenshot';
	return .<value> with $return;
	$return;
}

=begin table :caption<print options>
	Property		| JSON Key		| Value Type and Valid Values
	==========================================================
	orientation		| orientation 	| Str : { portrait ( default ), landscape }
	==========================================================
	scale			| scale			| Rat : [ 0.1, 2 ] ( default : 1 )
	==========================================================
	background		| background	| Bool : ( default : False )
	==========================================================
	pageWidth		| width			| Rat : [ 2.54 / 72, Inf ) ( default : 21.59 )
	==========================================================
	pageHeight		| height		| Rat : [ 2.54 / 72, Inf ) ( default : 27.94 )
	==========================================================
	margin			| margin		| JSON Obj : ( default : { } )
	----------------------------------------------------------
	- marginTop		| top			| Rat : [ 0, Inf ) ( default : 1 )
	----------------------------------------------------------
	- marginBottom	| bottom		| Rat : [ 0, Inf ) ( default : 1 )
	----------------------------------------------------------
	- marginLeft	| left			| Rat : [ 0, Inf ) ( default : 1 )
	----------------------------------------------------------
	- marginRight	| right			| Rat : [ 0, Inf ) ( default : 1 )
	==========================================================
	shrinkToFit		| shrinkToFit	| Bool : ( default : True )
	==========================================================
	pageRanges		| pageRanges	| Array:D[ Int:D ] : ( default : [ ] )
=end table
multi method print-page (
		WD2::Component::Session:D:
		%args --> Str:D
) { WD2::Component::Session.print-page: %args, self }
multi method print-page (
		WD2::Component::Session:U:
		%args, WD2::Component::Session:D $session --> Str:D
) {
	my $return = self.check-status: self.request: self.post-request: %args, $session, 'print';
	return .<value> with $return;
	$return;
}

use HTTP::UserAgent;
use JSON::Fast;

use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;

use WD2::Locators;

my HTTP::UserAgent $ua = HTTP::UserAgent.new;

role Command is export {
	method url ( *@command --> Str:D ) { ... }
}

sub request ( Str:D $method, Command:D $command, *@command --> HTTP::Request:D ) {
	my Str:D $url = $command.url: @command;
	given $method {
		when 'GET' { return HTTP::Request.new: GET => $url }
		when 'POST' { return HTTP::Request.new: POST => $url }
		when 'DELETE' { return HTTP::Request.new: DELETE => $url }
	}
}
sub get-request ( Command:D $command, *@command --> HTTP::Request:D ) {
	request 'GET', $command, @command;
}
sub post-request ( $return, Command:D $command, *@command --> HTTP::Request:D ) {
	my HTTP::Request $req = request 'POST', $command, @command;
	my Str:D $json = to-json $return;
	# debug: Level::extra, $json;
	$req.add-content: $json;
	$req;
}
sub delete-request ( Command:D $command, *@command --> HTTP::Request:D ) {
	request 'DELETE', $command, @command;
}

sub check-status ( HTTP::Response $response ) {
	my $return = from-json $response.content;
	return $return if $response.code.Int == 200;
	
	Failure.new:
			WebDriver2::Command::Result::X.new:
					execution-status =>
						WebDriver2::Command::Execution-Status.new:
								status => $response.code,
								error => $return<value><error>,
								message => $return<value><message> // '',
								stacktrace => $return<value><stacktrace> // '',
								data => $return<value><data> // { }
								;
}

class Driver { ... }
class Session { ... }
class Element { ... }

class Shadow does Command is export {
	our constant $IDENTIFIER = 'shadow-6066-11e4-a52e-4f735466cecf';
	
	has Session:D $.session is required;
	has Str:D $.shadow-id is required;
	method url ( *@command --> Str:D ) {
		$!session.url: 'shadow', $!shadow-id, @command;
	}
	
	method find-element ( By:D $locator --> Element:D ) {
		self.find-sub-shadow-element: $locator;
	}
	method find-elements ( By:D $locator --> List:D[ Element:D ] ) {
		self.find-sub-shadow-elements: $locator;
	}
	
	multi method find-sub-shadow-element (
			Shadow:D:
			By:D $locator
			--> Element:D
	) { Shadow.find-sub-shadow-element: $locator, self }
	
	multi method find-sub-shadow-element (
			Shadow:U:
			By:D $locator,
			Shadow:D $shadow --> Element:D
	) {
		my $return = check-status
				$ua.request: post-request $locator.args, $shadow, 'element';
		return Element.new:
				host => $shadow.session.driver.host,
				port => $shadow.session.driver.port,
				session => $shadow.session,
				element-id => $return<value>{ $Element::IDENTIFIER }
		with $return;
		$return.handled = False;
		$return;
	}
	
	multi method find-sub-shadow-elements (
			Shadow:D:
			By:D $locator,
			--> Element:D
	) { Shadow.find-sub-shadow-elements: $locator, self }
	
	multi method find-sub-shadow-elements (
			Shadow:U:
			By:D $locator,
			Shadow:D $shadow
			--> List:D[ Element:D ]
	) {
		my $return = check-status
				$ua.request: post-request $locator.args, $shadow, 'elements';
		without $return {
			$return.handled = False;
			return $return;
		}
		my Element:D @elements = Array[ Element:D ].new;
		for $return<value>>>.{ $Element::IDENTIFIER } -> $element-id {
			@elements.push:
					Element.new:
							host => $shadow.session.driver.host,
							port => $shadow.session.driver.port,
							session => $shadow.session,
							:$element-id
					;
		}
		@elements;
	}
}

class Element does Command is export {
	our constant $IDENTIFIER = 'element-6066-11e4-a52e-4f735466cecf';
	
	has Session:D $.session is required;
	has Str:D $.element-id is required;
	method url ( *@command --> Str:D ) {
		$!session.url: 'element', $!element-id, @command;
	}
	
	multi method switch-to (
			Element:D:
			--> Session:D
	) { Element.switch-to: self }
	multi method switch-to (
			Element:U:
			Element:D $element
			--> Session:D
	) {
		my $return = check-status
				$ua.request:
						post-request
								{
									id => Pair.new:
												$Element::IDENTIFIER,
												$element.element-id
								},
								$element.session,
								'frame'
								;
		return $element.session with $return;
		$return.handled = False;
		$return;
	}
	
	method find-element ( By:D $locator --> Element:D ) {
		self.find-sub-element: $locator;
	}
	method find-elements ( By:D $locator --> List:D[ Element:D ] ) {
		self.find-sub-elements: $locator;
	}
	multi method find-sub-element (
			Element:D:
			By:D $locator,
			--> Element:D
	) { Element.find-sub-element: $locator, self }
	
	multi method find-sub-element (
			Element:U:
			By:D $locator,
			Element:D $element
			--> Element:D
	) {
		my $return = check-status
				$ua.request: post-request $locator.args, $element, 'element';
		return Element.new:
				host => $element.session.driver.host,
				port => $element.session.driver.port,
				session => $element.session,
				element-id => $return<value>{ $Element::IDENTIFIER }
		with $return;
		$return.handled = False;
		$return;
	}
	
	multi method find-sub-elements (
			Element:D:
			By:D $locator,
			--> List:D[ Element:D ]
	) { Element.find-sub-elements: $locator, self }
	
	multi method find-sub-elements (
			Element:U:
			By:D $locator,
			Element:D $element
			--> List:D[ Element:D ]
	) {
		my $return = check-status
				$ua.request: post-request $locator.args, $element, 'elements';
		without $return {
			$return.handled = False;
			return $return;
		}
		my Element:D @elements = Array[ Element:D ].new;
		for $return<value>>>.{ $Element::IDENTIFIER } -> $element-id {
			@elements.push:
					Element.new:
							host => $element.session.driver.host,
							port => $element.session.driver.port,
							session => $element.session,
							:$element-id
					;
		}
		@elements;
	}
	
	multi method shadow-root (
			Element:D:
			--> Shadow:D
	) { Element.shadow-root: Element }
	
	multi method shadow-root (
			Element:U:
			Element:D $element --> Shadow:D
	) {
		my $return = check-status $ua.request: get-request $element, 'shadow';
		return Shadow.new:
				host => $element.session.driver.host,
				port => $element.session.driver.port,
				session => $element.session,
				shadow-id => $return<value>{ $Shadow::IDENTIFIER }
		with $return;
		$return.handled = False;
		$return;
	}
			
	multi method is-element-selected (
			Element:D:
			--> Bool:D
	) { Element.is-element-selected: self }
			
	multi method is-element-selected (
			Element:U:
			Element:D $element --> Bool:D
	) {
		my $return = check-status $ua.request: get-request $element, 'selected';
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	
	multi method attribute (
			Element:D:
			Str:D $name,
			--> Str:D
	) { Element.attribute: $name, self }
	
	multi method attribute (
			Element:U:
			Str:D $name,
			Element:D $element --> Str:D
	) {
		my $return = check-status $ua.request: get-request $element, 'attribute', $name;
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	
	multi method property (
			Element:D:
			Str:D $name,
			--> Str:D
	) { Element.property: $name, self }
	
	multi method property (
			Element:U:
			Str:D $name,
			Element:D $element --> Str:D
	) {
		my $return = check-status $ua.request: get-request $element, 'property', $name;
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	
	multi method css-value (
			Element:D:
			Str:D $name,
			--> Str:D
	) { Element.css-value: $name, self }
	
	multi method css-value (
			Element:U:
			Str:D $name,
			Element:D $element --> Str:D
	) {
		my $return = check-status $ua.request: get-request $element, 'css', $name;
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	
	multi method text (
			Element:D:
			--> Element:D
	) { Element.text: self }
	
	multi method text (
			Element:U:
			Element:D $element --> Element:D
	) {
		my $return = check-status $ua.request: get-request $element, 'text';
		return .<value> with $return;
		$return.Str = False;
		$return;
	}
	
	multi method tag-name (
			Element:D:
			--> Str:D
	) { Element.tag-name: self }
	
	multi method tag-name (
			Element:U:
			Element:D $element --> Str:D
	) {
		my $return = check-status $ua.request: get-request $element, 'name';
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	
	multi method rect (
			Element:D:
	) { Element.rect: self }
	
	multi method rect (
			Element:U:
			Element:D $element ) {
		my $return = check-status $ua.request: get-request $element, 'rect';
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	
	multi method is-enabled (
			Element:D:
			--> Bool:D
	) { Element.is-enabled: self }
	
	multi method is-enabled (
			Element:U:
			Element:D $element --> Bool:D
	) {
		my $return = check-status $ua.request: get-request $element, 'enabled';
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	
	multi method computed-role (
			Element:D:
			--> Str:D
	) { Element.computed-role: self }
	
	multi method computed-role (
			Element:U:
			Element:D $element --> Str:D
	) {
		my $return = check-status $ua.request: get-request $element, 'computedrole';
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	
	multi method computed-label (
			Element:D:
			--> Str:D
	) { Element.computed-label: self }
	
	multi method computed-label (
			Element:U:
			Element:D $element --> Str:D
	) {
		my $return = check-status $ua.request: get-request $element, 'computedlabel';
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	
	multi method click (
			Element:D:
			--> Element:D
	) { Element.click: self }
	
	multi method click (
			Element:U:
			Element:D $element --> Element:D
	) {
		my $return = check-status $ua.request: post-request { }, $element, 'click';
		return $element with $return;
		$return.handled = False;
		$return;
	}
	
	multi method clear (
			Element:D:
			--> Element:D
	) { Element.clear: self }
	
	multi method clear (
			Element:U:
			Element:D $element --> Element:D
	) {
		my $return = check-status $ua.request: post-request { }, $element, 'clear';
		return $element with $return;
		$return.handled = False;
		$return;
	}
	
	multi method send-keys (
			Element:D:
			Str:D $text,
			--> Element:D
	) { Element.send-keys: $text, self }
	
	multi method send-keys (
			Element:U:
			Str:D $text,
			Element:D $element --> Element:D
	) {
		my $return = check-status $ua.request: post-request { :$text }, $element, 'value';
		return $element with $return;
		$return.handled = False;
		$return;
	}
	
	method take-screenshot ( --> Str:D ) {
		self.take-element-screenshot;
	}
	
	multi method take-element-screenshot (
			Element:D:
			--> Str:D
	) { Element.take-element-screenshot: self }
	
	multi method take-element-screenshot (
			Element:U:
			Element:D $element
			--> Str:D
	) {
		my $return = check-status $ua.request: get-request $element, 'screenshot';
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
}

class Session does Command is export {
	has Driver:D $.driver is required;
	has Str:D $.session-id is required;
	method url ( *@command --> Str:D ) {
		$!driver.url: 'session', $!session-id, @command;
	}
	
	multi method delete (
			Session:D:
			--> Driver:D
	) { Session.delete: self }
	multi method delete (
			Session:U:
			Session:D $session
			--> Driver:D
	) {
		my $return = check-status $ua.request: delete-request $session;
		return $session.driver with $return;
		$return.handled = False;
		$return;
	}
	multi method get-timeouts (
			Session:D:
	) { Session.get-timeouts: self }
	multi method get-timeouts (
			Session:U:
			Session:D $session ) {
		my $return = check-status $ua.request: get-request $session, 'timeouts';
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	multi method set-timeouts (
			Session:D:
			Int $script,
			Int $pageLoad,
			Int $implicit
			--> Session:D
	) { Session.set-timeouts: $script, $pageLoad, $implicit, self }
	multi method set-timeouts (
			Session:U:
			Int $script,
			Int $pageLoad,
			Int $implicit,
			Session:D $session
			--> Session:D
	) {
		my $return = check-status $ua.request:
				post-request {
					:$script,
					:$pageLoad,
					:$implicit
				},
				$session,
				'timeouts'
		;
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method navigate-to (
			Session:D:
		Str:D $url --> Session:D
	) { Session.navigate-to: $url, self }
	multi method navigate-to (
			Session:U:
			Str:D $url, Session:D $session --> Session:D
	) {
		my $return = check-status $ua.request: post-request { :$url }, $session, 'url';
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method current-url (
			Session:D:
			--> Str:D
	) { Session.current-url: self }
	multi method current-url (
			Session:U:
			Session:D $session
			--> Str:D
	) {
		my $return = check-status $ua.request: get-request $session, 'url';
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	multi method back (
			Session:D:
			--> Session:D
	) { Session.back: self }
	multi method back (
			Session:U:
			Session:D $session
			--> Session:D
	) {
		my $return = check-status $ua.request: post-request { }, $session, 'back';
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method forward (
			Session:D:
			--> Session:D
	) { Session.forward: self }
	multi method forward (
			Session:U:
			Session:D $session
			--> Session:D
	) {
		my $return = check-status $ua.request: post-request { }, $session, 'forward';
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method refresh (
			Session:D:
			--> Session:D
	) { Session.refresh: self }
	multi method refresh (
			Session:U:
			Session:D $session
			--> Session:D
	) {
		my $return = check-status $ua.request: post-request { }, $session, 'refresh';
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method title (
			Session:D:
			--> Str:D
	) { Session.title: self }
	multi method title (
			Session:U:
			Session:D $session
			--> Str:D
	) {
		my $return = check-status $ua.request: get-request $session, 'title';
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	multi method get-window-handle (
			Session:D:
			--> Str:D
	) { Session.get-window-handle: self }
	multi method get-window-handle (
			Session:U:
			Session:D $session
			--> Str:D
	) {
		my $return = check-status $ua.request: get-request $session, 'window';
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	multi method close-window (
			Session:D:
			--> Session:D
	) { Session.close-window: self }
	multi method close-window (
			Session:U:
			Session:D $session
			--> Session:D
	) {
		my $return = check-status $ua.request: delete-request $session, 'window';
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method switch-to-window (
			Session:D:
			Str:D $handle --> Session:D
	) { Session.switch-to-window: $handle, self }
	multi method switch-to-window (
			Session:U:
			Str:D $handle, Session:D $session --> Session:D
	) {
		my $return = check-status 
				$ua.request: post-request { :$handle }, $session, 'window';
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method get-window-handles (
			Session:D:
			--> List:D[ Str:D ]  ) { Session.get-window-handles: self }
	multi method get-window-handles (
			Session:U:
			Session:D $session
			--> List:D[ Str:D ] ) {
		my $return = check-status $ua.request: get-request $session, <window handles>;
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	multi method new-window (
			Session:D:
			Str:D $type where <tab window>.any
	) { Session.new-window: $type, self }
	multi method new-window (
			Session:U:
			Str:D $type where <tab window>.any, Session:D $session ) {
		my %args = ();
		%args{ 'type hint' } = $type if $type;
		my $return = check-status
				$ua.request: %args, post-request $session, <window new>;
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	multi method switch-to-frame ( Session:D $session --> Session:D
	) {
		my $return = check-status $ua.request: post-request { }, $session, 'frame';
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method switch-to-frame ( Int $frame, Session:D $session --> Session:D
	) {
		my $return = check-status 
				$ua.request: post-request { id => $frame }, $session, 'frame';
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method switch-to-parent-frame (
			Session:D:
			--> Session:D
	) { Session.switch-to-parent-frame: self }
	multi method switch-to-parent-frame (
			Session:U:
			Session:D $session
			--> Session:D
	) {
		my $return = check-status 
				$ua.request: post-request { }, $session, <frame parent>;
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method get-window-rect (
			Session:D:
	) { Session.get-window-rect: self }
	multi method get-window-rect (
			Session:U:
			Session:D $session ) {
		my $return = check-status $ua.request: get-request $session, <window rect>;
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	multi method set-window-rect (
			Session:D:
			Int $width,
			Int $height,
			Int $x,
			Int $y,
			--> Session:D
	) { Session.set-window-rect:
			$width,
			$height,
			$x,
			$y,
			self
	}
	multi method set-window-rect (
			Session:U:
			Int $width,
			Int $height,
			Int $x,
			Int $y,
			Session:D $session
			--> Session:D
	) {
		my %args = grep *.value.defined, do :$width, :$height, :$x, :$y;
		my $return = check-status
				$ua.request: post-request %args, $session, <window rect>;
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method maximize-window (
			Session:D:
			--> Session:D
	) { Session.maximize-window: self }
	multi method maximize-window (
			Session:U:
			Session:D $session
			--> Session:D
	) {
		my $return = check-status
				$ua.request: post-request { }, $session, <window maximize>;
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method minimize-window (
			Session:D:
			--> Session:D
	) { Session.minimize-window: self }
	multi method minimize-window (
			Session:U:
			Session:D $session
			--> Session:D
	) {
		my $return = check-status
				$ua.request: post-request { }, $session, <window minimize>;
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method fullscreen-window (
			Session:D:
			--> Session:D
	) { Session.fullscreen-window: self }
	multi method fullscreen-window (
			Session:U:
			Session:D $session
			--> Session:D
	) {
		my $return = check-status
				$ua.request: post-request { }, $session, <window fullscreen>;
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method active-element (
			Session:D:
			--> Element:D
	) { Session.active-element: self }
	multi method active-element (
			Session:U:
			Session:D $session
			--> Element:D
	) {
		my $return = check-status $ua.request: get-request $session, <element active>;
		return Element.new:
				host => $session.driver.host,
				port => $session.driver.port,
				:$session,
				element-id => $return<value>{ $Element::IDENTIFIER }
		with $return;
		$return.handled = False;
		$return;
	}
	
	multi method find-element (
			Session:D:
			By:D $locator --> Element:D
	) { Session.find-element: $locator, self }
	
	multi method find-element (
			Session:U:
			By:D $locator, Session:D $session --> Element:D
	) {
		my $return = check-status
				$ua.request: post-request $locator.args, $session, 'element';
		return Element.new:
				host => $session.driver.host,
				port => $session.driver.port,
				:$session,
				element-id => $return<value>{ $Element::IDENTIFIER }
		with $return;
		$return.handled = False;
		$return;
	}
	multi method find-elements (
			Session:D:
			By:D $locator,
			--> List:D[ Element:D ]
	) {
		Session.find-elements: $locator, self
	}
	multi method find-elements (
			Session:U:
			By:D $locator,
			Session:D $session
			--> List:D[ Element:D ]
	) {
		my $return = check-status
				$ua.request: post-request $locator.args, $session, 'elements';
		without $return {
			$return.handled = False;
			return $return;
		}
		my Element:D @elements = Array[ Element:D ].new;
		for $return<value>>>.{ $Element::IDENTIFIER } -> $element-id {
			@elements.push:
					Element.new:
							host => $session.driver.host,
							port => $session.driver.port,
							:$session,
							:$element-id
					;
		}
		@elements;
	}
	
	multi method page-source (
			Session:D:
			--> Str:D
	) { Session.page-source: self }
	
	multi method page-source (
			Session:U:
			Session:D $session
			--> Str:D
	) {
		my $return = check-status $ua.request: get-request $session, 'source';
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	multi method execute-script (
			Session:D:
			Str:D $script, @args ) {
		Session.execute-script: $script, @args, self
	}
	multi method execute-script (
			Session:U:
			Str:D $script,
			@args,
			Session:D $session ) {
		my $return = check-status
				$ua.request:
						post-request
								{ :$script, :@args }, $session, <execute sync>;
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	multi method execute-async-script (
			Session:D:
			Str:D $script,
			@args,
			) { Session.execute-async-script: $script,
			@args, self
			}
	multi method execute-async-script (
			Session:U:
			Str:D $script,
			@args,
			Session:D $session ) {
		my $return = check-status
				$ua.request:
						post-request
								{ :$script, :@args }, $session, <execute async>;
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	multi method get-all-cookies (
			Session:D:
			--> List:D
	) { Session.get-all-cookies: self }
	multi method get-all-cookies (
			Session:U:
			Session:D $session
			--> List:D
	) {
		my $return = check-status $ua.request: get-request $session, 'cookie';
		return Array.new: |.<value> with $return;
		$return.handled = False;
		$return;
	}
	multi method get-named-cookie ( Session:D: Str:D $name ) {
		Session.get-named-cookie: $name, self
	}
	multi method get-named-cookie (
			Session:U:
			Str:D $name, Session:D $session ) {
		my $return = check-status 
				$ua.request: get-request $session, 'cookie', $name;
		return $session with $return;
		$return.handled = False;
		$return;
	}
	=begin table :caption<cookie object structure>
		RFC 6265 Field   | JSON Key | Attribute Key
		=========================================
		name			| name	|
		value			| value	|
		path			| path	| Path
		domain		| domain   | Domain
		secure-only-flag | secure   | Secure
		http-only-flag   | httpOnly | HttpOnly
		expiry-time	| expiry   | Max-Age
		samesite		| sameSite | SameSite
	=end table
	multi method add-cookie (
			Str:D $name,
			Str:D $value,
			%cookie,
			Session:D $session
			--> Session:D
	) {
		my %args =
			.flat with do grep -> $k, $v { $v.defined and $k, $v },
			.flat with do :$name.kv, :$value.kv,
				%cookie<path domain secure httpOnly expiry sameSite>:kv;
		my $return = check-status
				$ua.request: post-request { cookie => %args }, $session, 'cookie';
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method add-cookie (
			Str:D $name,
			Str:D $value,
			Session:D $session
			--> Session:D
	) {
		my %args = :$name, :$value;
		my $return = check-status
				$ua.request: post-request { cookie => %args }, $session, 'cookie';
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method delete-cookie (
			Session:D:
			Str:D $name --> Session:D
	) { Session.delete-cookie: $name, self }
	multi method delete-cookie (
			Session:U:
			Str:D $name, Session:D $session --> Session:D
	) {
		my $return = check-status
				$ua.request: delete-request $session, 'cookie', $name;
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method delete-all-cookies (
			Session:D:
			--> Session:D
	) { Session.delete-all-cookies: self }
	multi method delete-all-cookies (
			Session:U:
			Session:D $session
			--> Session:D
	) {
		my $return = check-status $ua.request: delete-request $session, 'cookie';
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method perform-actions (
			Session:D:
			--> Session:D
	) { Session.perform-actions: self }
	multi method perform-actions (
			Session:U:
			Session:D $session
			--> Session:D
	) {
		!!! 'nyi'
	}
	multi method release-actions (
			Session:D:
			--> Session:D
	) { Session.release-actions: self }
	multi method release-actions (
			Session:U:
			Session:D $session
			--> Session:D
	) {
		!!! 'nyi'
	}
	multi method dismiss-alert (
			Session:D:
			--> Session:D
	) { Session.dismiss-alert: self }
	multi method dismiss-alert (
			Session:U:
			Session:D $session
			--> Session:D
	) {
		my $return = check-status
				$ua.request: post-request { }, $session, <alert dismiss>;
		$return.handled = False;
		$return;
	}
	multi method accept-alert (
			Session:D:
			--> Session:D
	) { Session.accept-alert: self }
	multi method accept-alert (
			Session:U:
			Session:D $session
			--> Session:D
	) {
		my $return = check-status
				$ua.request: post-request { }, $session, <alert accept>;
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method get-alert-text (
			Session:D:
			--> Str:D
	) { Session.get-alert-text: self }
	multi method get-alert-text (
			Session:U:
			Session:D $session
			--> Str:D
	) {
		my $return = check-status $ua.request: get-request $session, <alert text>;
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	multi method send-alert-text (
			Session:D:
			Str:D $text --> Session:D
	) { Session.send-alert-text: $text, self }
	multi method send-alert-text (
			Session:U:
			Str:D $text, Session:D $session --> Session:D
	) {
		my $return = check-status
				$ua.request: post-request { :$text }, $session, <alert text>;
		return $session with $return;
		$return.handled = False;
		$return;
	}
	multi method take-screenshot (
			Session:D:
			--> Str:D
	) { Session.take-screenshot: self }
	multi method take-screenshot (
			Session:U:
			Session:D $session
			--> Str:D
	) {
		my $return = check-status $ua.request: get-request $session, 'screenshot';
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	
	=begin table
		Property	| JSON Key	| Value Type and Valid Values
		==========================================================
		orientation	| orientation | Str : { portrait ( default ), landscape }
		==========================================================
		scale		| scale	| Rat : [ 0.1, 2 ] ( default : 1 )
		==========================================================
		background	| background  | Bool : ( default : False )
		==========================================================
		pageWidth	| width	| Rat : [ 2.54 / 72, Inf ) ( default : 21.59 )
		==========================================================
		pageHeight	| height	| Rat : [ 2.54 / 72, Inf ) ( default : 27.94 )
		==========================================================
		margin		| margin	| JSON Obj : ( default : { } )
		----------------------------------------------------------
		- marginTop	| top		| Rat : [ 0, Inf ) ( default : 1 )
		----------------------------------------------------------
		- marginBottom | bottom	| Rat : [ 0, Inf ) ( default : 1 )
		----------------------------------------------------------
		- marginLeft   | left		| Rat : [ 0, Inf ) ( default : 1 )
		----------------------------------------------------------
		- marginRight  | right	| Rat : [ 0, Inf ) ( default : 1 )
		==========================================================
		shrinkToFit	| shrinkToFit | Bool : ( default : True )
		==========================================================
		pageRanges	| pageRanges  | Array:D[ Int:D ] : ( default : [ ] )
	=end table
	multi method print-page (
			Session:D:
			%args --> Str:D
	) { Session.print-page: %args, self }
	multi method print-page (
			Session:U:
			%args, Session:D $session --> Str:D
	) {
		my $return = check-status $ua.request: post-request %args, $session, 'print';
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
}

class Driver does Command is export {
	has Str:D $.host is required = '127.0.0.1';
	has Int:D $.port is required;
	method url ( *@command --> Str:D ) {
		join '/', "http://$!host:$!port", |@command;
	}
	
	multi method status (
			Driver:D:
	) { Driver.status: self }
	multi method status (
			Driver:U: Driver:D $driver ) {
		my $return = check-status $ua.request: get-request $driver, 'status';
		return .<value> with $return;
		$return.handled = False;
		$return;
	}
	multi method new-session (
			Driver:D:
			%capabilities --> Session:D
	) { Driver.new-session: %capabilities, self }
	multi method new-session (
			Driver:U: %capabilities, Driver:D $driver --> Session:D
	) {
		%capabilities<capabilities> = { } unless %capabilities and %capabilities<capabilities>.isa: Hash;
		my $return = check-status
			$ua.request: post-request %capabilities, $driver, 'session';
		return Session.new:
				:$driver,
				session-id => .<value><sessionId>
		with $return;
		$return.handled = False;
		$return;
	}
}

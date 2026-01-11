use WebDriver2::Test::Debugging;

sub methods ( $o ) is export {
	$o.^methods;
}

# Adapter Generator takes two objects and optionally a list of methods;
#   if no method list is provided, then filter out CAPS methods and new
#   and use the intersection of the remaining methods between the two objects

# role Adapter {
# 	
# }

# sub EXPORT ( $r, $s ) {
# 	Map.new:
# 			Adapter => class { constant  = $r.WHAT.^lookup('m') o $s.WHAT.^lookup('m')};
# }



module WD2P {
	use HTTP::UserAgent;
	my HTTP::UserAgent $ua = HTTP::UserAgent.new;
	
	role By {
		has Str:D $.value is required;
		method using ( --> Str:D ) { ... }
		method value ( Str:D $value ) { self.bless: :$value }
		method args ( Str:D $value --> Hash:D[ Str:D ] ) {
			{ :$.using, :$value }
		}
	}
	class By::Tag does By {
		has Str:D $.using = 'tag name';
	}
	class By::CSS does By {
		has Str:D $.using = 'css selector';
	}
	class By::ID is By::CSS {
		method value ( Str:D $value ) {
			callwith "#$value";
		}
	}
	class By::Link-Text does By {
		has Str:D $.using = 'link text';
	}
	class By::Partial-Link-Text does By {
		has Str:D $.using = 'partial link text';
	}
	class By::XPath does By {
		has Str:D $.using = 'xpath';
	}
	
	class Return-Value {
		has Str:D $.str is required;
		has Str:D $.execution-status is required;
		has Str $.value is required;
	}
	
	class Status is Return-Value {
		has Str:D $.version is required;
		has Bool:D $.ready is required;
		has Str:D $.message is required;
	}
	
	my role Request-Builder does WebDriver2::Test::Debugging {
		use JSON::Fast;
		# trusts WD2P::Session;
		# trusts WD2P::Driver;
		
		method host ( --> Str:D ) { ... }
		method port ( --> Int:D ) { ... }
		
		method !request (
				Str:D $method,
				*@command
				--> HTTP::Request:D
		) {
			my Str:D $url = join '/', "http://$.host:$.port/", |@command;
			self.debug: Level::extra, $method, $url;
			given $method {
				when 'GET' { return HTTP::Request.new: GET => $url; }
				when 'POST' { return HTTP::Request.new: POST => $url; }
				when 'DELETE' { return HTTP::Request.new: DELETE => $url; }
			}
		}
		
		method !get-request (
				*@command
				--> HTTP::Request:D
		) {
			self!request: 'GET', @command;
		}
		
		method !post-request (
				$data,
				*@command
				--> HTTP::Request:D
		) {
			my HTTP::Request $req = self!request: 'POST', @command;
			my Str:D $json = to-json $data;
			self.debug: Level::extra, $json;
			$req.add-content: $json;
			$req;
		}
		
		method !delete-request (
				*@command
				--> HTTP::Request:D
		) {
			self!request: 'DELETE', @command;
		}
	}
	
	role Driver-Request does Request-Builder {
		has Str:D $.host = '127.0.0.1';
		method status ( --> HTTP::Request:D ) { ... }
		method new-session ( *%capabilities --> HTTP::Request:D ) { ... }
	}
	
	role Session-Request does Request-Builder {
		has Str:D $!session-id is built is required;
		
		method delete-session ( --> HTTP::Request:D ) { ... }
		method get-timeouts ( --> HTTP::Request:D ) { ... }
		method set-timeouts (
				Int :$script,
				Int :$pageLoad,
				Int :$implicit
				--> HTTP::Request:D
		) { ... }
		method navigate-to ( Str:D $url --> HTTP::Request:D ) { ... }
		method get-current-url ( --> HTTP::Request:D ) { ... }
		method back ( --> HTTP::Request:D ) { ... }
		method forward ( --> HTTP::Request:D ) { ... }
		method refresh ( --> HTTP::Request:D ) { ... }
		method get-title ( --> HTTP::Request:D ) { ... }
		method get-window-handle ( --> HTTP::Request:D ) { ... }
		method close-window ( --> HTTP::Request:D ) { ... }
		method switch-to-window (  Str:D $handle --> HTTP::Request:D ) { ... }
		method get-window-handles ( --> HTTP::Request:D ) { ... }
		method new-window ( --> HTTP::Request:D ) { ... }
		method switch-to-frame ( Int $frame --> HTTP::Request:D ) { ... }
		method switch-to-parent-frame ( --> HTTP::Request:D ) { ... }
		method get-window-rect ( --> HTTP::Request:D ) { ... }
		method set-window-rect (
				Int :$width,
				Int :$height,
				Int :$x,
				Int :$y
				--> HTTP::Request:D
		) { ... }
		method maximize-window ( --> HTTP::Request:D ) { ... }
		method minimize-window ( --> HTTP::Request:D ) { ... }
		method fullscreen-window ( --> HTTP::Request:D ) { ... }
		method get-active-element ( --> HTTP::Request:D ) { ... }
		
		method get-page-source ( --> HTTP::Request:D ) { ... }
		method execute-script ( Str:D $script, *@args --> HTTP::Request:D ) { ... }
		method execute-async-script ( Str:D $script, *@args --> HTTP::Request:D ) { ... }
		method get-all-cookies ( --> HTTP::Request:D ) { ... }
		method get-named-cookie ( Str:D $name --> HTTP::Request:D ) { ... }
		method add-cookie ( --> HTTP::Request:D ) { ... }
		method delete-cookie ( Str:D $name --> HTTP::Request:D ) { ... }
		method delete-all-cookies ( --> HTTP::Request:D ) { ... }
		method perform-actions ( --> HTTP::Request:D ) { ... }
		method release-actions ( --> HTTP::Request:D ) { ... }
		method dismiss-alert ( --> HTTP::Request:D ) { ... }
		method accept-alert ( --> HTTP::Request:D ) { ... }
		method get-alert-text ( --> HTTP::Request:D ) { ... }
		method send-alert-text ( --> HTTP::Request:D ) { ... }
		method take-screenshot ( --> HTTP::Request:D ) { ... }
		method take-element-screenshot ( --> HTTP::Request:D ) { ... }
		method print-page ( --> HTTP::Request:D ) { ... }
	}
	
	class Request::Chromium does Driver-Request does Session-Request {
		has Int:D $.port = 9515;
		use JSON::Fast;
		method status ( --> HTTP::Request:D ) {
			self!get-request: 'status'
		}
		
		method new-session ( *%capabilities --> HTTP::Request:D ) {
			self!post-session: %capabilities, 'session';
		}
		
		# SESSION REQUESTS
		
		method delete-session ( Str:D $session-id --> HTTP::Request:D ) {
			self!delete-request: 'session', $session-id;
		}
		
		method get-timeouts ( Str:D $session-id --> HTTP::Request:D ) {
			self!get-request: 'session', $session-id, 'timeouts';
		}
		
		method set-timeouts (
				Str:D $session-id,
				Int :$script,
				Int :$pageLoad,
				Int :$implicit
				--> HTTP::Request:D
		) {
			self!post-request: {
				:$script,
				:$pageLoad,
				:$implicit
			}, 'session', $session-id, 'timeouts';
		}
		
		method navigate-to ( Str:D $session-id, Str:D $url --> HTTP::Request:D ) {
			self!post-request: { :$url }, 'session', $session-id, 'url';
		}
		
		method get-current-url ( Str:D $session-id --> HTTP::Request:D ) {
			self!get-request: 'session', $session-id, 'url';
		}
		
		method back ( Str:D $session-id --> HTTP::Request:D ) {
			self!post-request: { }, 'session', $session-id, 'back';
		}
		
		method forward ( Str:D $session-id --> HTTP::Request:D ) {
			self!post-request: { }, 'session', $session-id, 'forward';
		}
		
		method refresh ( Str:D $session-id --> HTTP::Request:D ) {
			self!post-request: { }, 'session', $session-id, 'refresh';
		}
		
		method get-title ( Str:D $session-id --> HTTP::Request:D ) {
			self!get-request: 'session', $session-id, 'title';
		}
		
		method get-window-handle ( Str:D $session-id --> HTTP::Request:D ) {
			self!get-request: 'session', $session-id, 'window';
		}
		
		method close-window ( Str:D $session-id --> HTTP::Request:D ) {
			self!delete-request: 'session', $session-id, 'window';
		}
		
		method switch-to-window ( Str:D $session-id, Str:D $handle --> HTTP::Request:D ) {
			self!post-request: { :$handle }, 'session', $session-id, 'window';
		}
		
		method get-window-handles ( Str:D $session-id --> HTTP::Request:D ) {
			self!get-request: 'session', $session-id, |<window handles>;
		}
		
		method new-window ( Str:D $session-id --> HTTP::Request:D ) {
			self!post-request: { 'type hint' => 'tab' }, 'session', $session-id, |<window new>;
		}
		
		
		
		method switch-to-frame ( Str:D $session-id, Int $id ) {
			self!post-request: { :$id }, 'session', $session-id, 'frame';
		}
		
		method switch-to-parent-frame ( Str:D $session-id --> HTTP::Request:D ) {
			self!post-request: { }, 'session', $session-id, |<frame parent>;
		}
		
		method get-window-rect ( Str:D $session-id --> HTTP::Request:D ) {
			self!get-request: 'session', $session-id, |<window rect>;
		}
		
		method set-window-rect (
				Str:D $session-id,
				Int :$width,
				Int :$height,
				Int :$x,
				Int :$y
				--> HTTP::Request:D
		) {
			self!post-request: { :$width, :$height, :$x, :$y }, 'session', $session-id, |<window rect>;
		}
		
		method maximize-window ( Str:D $session-id --> HTTP::Request:D ) {
			self!post-request: { }, 'session', $session-id, |<window maximize>;
		}
		
		method minimize-window ( Str:D $session-id --> HTTP::Request:D ) {
			self!post-request: { }, 'session', $session-id, |<window minimize>;
		}
		
		method fullscreen-window ( Str:D $session-id --> HTTP::Request:D ) {
			self!post-request: { }, 'session', $session-id, |<window fullscreen>;
		}
		
		method get-active-element ( Str:D $session-id --> HTTP::Request:D ) {
			self!get-request: 'session', $session-id, |<element active>;
		}
		
		method find-element ( Str:D $session-id, By $locator --> HTTP::Request:D ) {
			self!post-request: $locator.args, 'session', $session-id, 'element';
		}
		
		method find-elements ( Str:D $session-id, By $locator --> HTTP::Request:D ) {
			self!post-request: $locator.args, 'session', $session-id, 'elements';
		}
		
		
		
		method get-page-source ( Str:D $session-id --> HTTP::Request:D ) {
			self!get-request: 'session', $session-id, 'source';
		}
		
		method execute-script (
				Str:D $session-id,
				Str:D $script,
				*@args --> HTTP::Request:D
		) {
			self!post-request: { :$script, :@args }, 'session', $session-id, |<execute sync>;
		}
		
		method execute-async-script (
				Str:D $session-id,
				Str:D $script,
				*@args --> HTTP::Request:D
		) {
			self!post-request: { :$script, :@args }, 'session', $session-id, |<execute async>;
		}
		
		method get-all-cookies ( Str:D $session-id --> HTTP::Request:D ) {
			self!get-request: 'session', $session-id, 'cookie';
		}
		
		method get-named-cookie ( Str:D $session-id, Str:D $name --> HTTP::Request:D ) {
			self!get-request: 'session', $session-id, 'cookie', $name;
		}
		
		method add-cookie (
				Str:D $session-id,
				Str:D :$name,
				Str:D :$value,
				Str:D :$path?,
				Str:D :$domain?,
				Bool:D :$secure?,
				Bool:D :$httpOnly?,
				Int:D :$expiry?,
				Bool:D :$sameSite?
				--> HTTP::Request:D
		) {
			my %args = grep *.value.defined,
				( :$name, :$value, :$path, :$domain, :$secure, :$httpOnly, :$expiry, :$sameSite );
			self!post-request: cookie => %args, 'session', $session-id, 'cookie';
		}
		
		method delete-cookie ( Str:D $session-id, Str:D $name --> HTTP::Request:D ) {
			self!delete-request: 'session', $session-id, 'cookie', $name;
		}
		
		method delete-all-cookies ( Str:D $session-id --> HTTP::Request:D ) {
			self!delete-request: 'session', $session-id, 'cookie';
		}
		
		method perform-actions ( Str:D $session-id --> HTTP::Request:D ) {
			!!! 'nyi'
		}
		
		method release-actions ( Str:D $session-id --> HTTP::Request:D ) {
			!!! 'nyi'
		}
		
		method dismiss-alert ( Str:D $session-id --> HTTP::Request:D ) {
			self!post-request: { }, 'session', $session-id, |<alert dismiss>;
		}
		
		method accept-alert ( Str:D $session-id --> HTTP::Request:D ) {
			self!post-request: { }, 'session', $session-id, |<alert accept>;
		}
		
		method get-alert-text ( Str:D $session-id --> HTTP::Request:D ) {
			self!get-request: 'session', $session-id, |<alert text>;
		}
		
		method send-alert-text ( Str:D $text, Str:D $session-id --> HTTP::Request:D ) {
			self!post-request: { :$text }, 'session', $session-id, |<alert text>;
		}
		
		method take-screenshot ( Str:D $session-id --> HTTP::Request:D ) {
			self!get-request: 'session', $session-id, 'screenshot';
		}
		
		method print-page (
				Str:D $session-id,
				Str:D $orientation where <portrait landscape>.any = 'portrait'
				--> HTTP::Request:D
		) {
			self!post-request: { :$orientation }, 'session', $session-id, 'print';
		}
		
		# ELEMENT REQUESTS
		
		method take-element-screenshot ( Str:D $session-id --> HTTP::Request:D ) {
			
		}
	}
	
	role Element-Request does Request-Builder {
		method find-sub-element ( Str:D $sid --> HTTP::Request:D ) { ... }
		method find-sub-elements ( Str:D $sid --> HTTP::Request:D ) { ... }
		
		method switch-to-frame ( --> HTTP::Request:D ) { ... }
		
		method get-element-shadow-root ( --> HTTP::Request:D ) { ... }
		
		method is-element-selected ( Str:D $sid --> HTTP::Request:D ) { ... }
		method get-element-attribute ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) { ... }
		method get-element-property ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) { ... }
		method get-element-css-value ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) { ... }
		method get-element-text ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) { ... }
		method get-element-tag-name ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) { ... }
		method get-element-rect ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) { ... }
		method is-element-enabled ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) { ... }
		method get-computed-role ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) { ... }
		method get-computed-label ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) { ... }
		method element-click ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) { ... }
		method element-clear ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) { ... }
		method element-send-keys ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) { ... }
		method take-element-screenshot ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) { ... }
	}
	
	class Element-Request::Default does Element-Request {
		has Str:D $.host is required;
		has Int:D $.port is required;
		
		method find-element (  ) {
			self.find-sub-element: ;
		}
		method find-elements (  ) {
			self.find-sub-elements: ;
		}
		
		method find-sub-element ( Str:D $sid --> HTTP::Request:D ) {
			
		}
		
		method find-sub-elements ( Str:D $sid --> HTTP::Request:D ) {
			
		}
		
		
		
		method get-element-shadow-root ( --> HTTP::Request:D ) { { } }
				
		method is-element-selected ( Str:D $sid --> HTTP::Request:D ) {
			
		}
		
		method get-element-attribute ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			
		}
		
		method get-element-property ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			
		}
		
		method get-element-css-value ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			
		}
		
		method get-element-text ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			
		}
		
		method get-element-tag-name ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			
		}
		
		method get-element-rect ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			
		}
		
		method is-element-enabled ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			
		}
		
		method get-computed-role ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			
		}
		
		method get-computed-label ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			
		}
		
		method element-click ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			
		}
		
		method element-clear (
				Str:D $sid,
				Str:D $element-id
				--> HTTP::Request:D
		) {
			
		}
		
		method element-send-keys ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			
		}
		
		method take-element-screenshot ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			
		}

		method switch-to-frame {
			
		}
	}
	
	role Shadow-Request does Request-Builder {
		
		
		method find-sub-shadow-element ( Str:D $sid, Str:D $shadow-id --> HTTP::Request:D ) {
			
		}
		
		method find-sub-shadow-elements ( Str:D $sid, Str:D $shadow-id --> HTTP::Request:D ) {
			
		}
	}
	
	class Shadow-Request::Default does Shadow-Request {
		has Str:D $.host is required;
		has Int:D $.port is required;
		
		method find-sub-shadow-element ( Str:D $sid, Str:D $shadow-id --> HTTP::Request:D ) {
			
		}
		
		method find-sub-shadow-elements ( Str:D $sid, Str:D $shadow-id --> HTTP::Request:D ) {
			
		}
	}
	
	class Element { ... }
	
	use WebDriver2::Command::Execution-Status;
	
	role Result does WebDriver2::Test::Debugging {
		method !status-args( HTTP::Response $response, $type ) { # PRIVATE OKAY
			my $data = from-json $response.content;
			\(
					code => $data<value><error>,
					:$type,
					message => $data<value><message>
			)
		}
		
		method find-element (
				HTTP::Response:D $response
				--> Element:D
		) { ... }
		method find-elements (
				HTTP::Response:D $response
				--> Array:D[ Element:D ]
		) { ... }
	}
	
	class Result::Chromium does Result {
		method find-element (
				HTTP::Response:D $response
				--> Element:D
		) {
			
		}
		method find-elements (
				HTTP::Response:D $response
				--> Array:D[ Element:D ]
		) { ... }
	}
	
	class Result::Chrome is Result::Chromium {
		
	}
	
	class Result::Edge is Result::Chromium {
		
	}
	
	role Context {
		method find-element ( By:D $locator --> Element:D ) { ... }
		method find-elements ( By:D $locator --> Array:D[ Element:D ] ) { ... }
		# method switch-to-parent-frame ( --> Bool:D ) { ... }
		method take-screenshot ( --> Str:D ) { ... }
	}
	
	class Element does Context {
		has Str:D $!session-id is built is required;
		has Str:D $!element-id is built is required;
		has Str:D $.browser is required;
		has Element-Request:D $!request is built is required;
		
		method find-element ( By:D $locator --> Element:D ) {
			
		}
		method find-elements ( By:D $locator --> Array:D[ Element:D ] ) { ... }
		method switch-to-parent-frame ( --> Bool:D ) { ... }
		method take-screenshot ( --> Str:D ) { }
	}
	
	class Frame is Element {
		
	}
	
	class Page is Frame {
		
	}
	
	class Session does Context {
		has Str:D $!id is built is required;
		has Str:D $.browser is required;
		has Request:D $request is built is required;
		has Result:D $result is built is required;
		
		method find-element ( By:D $locator --> Element:D ) {
			$result.find-element: $ua.request: $request.find-element: $locator;
		}
		method find-elements ( By:D $locator --> Array:D[ Element:D ] ) {
			$result.find-elements: $ua.request: $request.find-elements: $locator;
		}
		method take-screenshot ( --> Str:D ) {
			
		}
	}
	
	role Driver {
		# trusts WD2P::Session;
		
		has Driver-Request $!request is built is required;
		has Result $!result is built is required;
		
		has Str:D $.host is required = '127.0.0.1';
		has Int:D $.port is required;
		has Str:D $.browser is required;
		
		
		
		method start { }
		
		method new-session ( *%capabilities --> WD2P::Session:D ) { ... }
		method status ( --> WD2P::Status:D ) { ... }
		
		method stop { }
	}
	
	class WD2P::Driver::Chrome does WD2P::Driver {
		method new (
				Str:D $host = '127.0.0.1';
				Int:D $port = 9515,
		) {
			self.bless:
					browser => 'chrome';
					request => Driver-Request::Chrome,
					result => Result::Chrome,
					:$host,
					:$port,
					;
		}
		
		multi method new-session ( *%capabilities ) {
			$!result.new-session: $ua.request: $!request.new-session: %capabilities;
		}
		
		multi method new-session ( --> HTTP::Request:D ) {
			self.new-session: {
				capabilities => {
					alwaysMatch => {
						unhandledPromptBehavior => {
							alert => 'ignore',
							beforeUnload => 'ignore',
							confirm => 'ignore',
							default => 'ignore',
							prompt => 'ignore',
							defaultPrompt => 'ignore',
							:!notify
						}
					}
				}
			}
		}
		
		method status {
			$!result.status: $ua.request: $!request.status;
		}
	}
	
	class Driver::Edge does WD2P::Driver {
		method new (
				Str:D $host = '127.0.0.1';
				Int:D $port = 9515,
		) {
			self.bless:
					browser => 'edge';
					param => Param::Edge,
					result => Result::Edge,
					:$host,
					:$port,
					;
		}
		
		multi method new-session ( *%capabilities ) {
			$!result.new-session: $ua.request: $!request.new-session: %capabilities;
		}
		
		multi method new-session ( --> HTTP::Request:D ) {
			self.new-session: {
				capabilities => {
					alwaysMatch => {
						unhandledPromptBehavior => {
							alert => 'ignore',
							beforeUnload => 'ignore',
							confirm => 'ignore',
							default => 'ignore',
							prompt => 'ignore',
							defaultPrompt => 'ignore',
							:!notify
						}
					}
				}
			}
		}
		
		method status {
			$!result.status: $ua.request: $!request.status;
		}
	}
	
	class Convenience {
		method action-sequence (  ) { ... }
		#| return Element:U if not found instead of throwing
		method find-element-soft ( By $locator --> Element ) { ... }
		method set-zoom ( Rat:D $ratio ) { ... }
	}
}

class WD2P::Driver::Provider {
	my WD2P::Driver %driver = (
		chrome => WD2P::Driver::Chrome,
		edge => WD2P::Driver::Edge,
	);
	method get (
			Str:D $browser where %driver.keys.any,
			Str:D :$host = '127.0.0.1',
			Int :$port
			--> WD2P::Driver:D
	) {
		my %args = :$host;
		%args<port> = $port if $port;
		%driver{ $browser }
		// %driver{ $browser } = %driver{ $browser }.new: |%args;
	}
}

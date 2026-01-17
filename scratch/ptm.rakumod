# use ptma;

# use lib <../http-useragent/lib>; # C:\Users\ZacharyMarlow\vsc\http-useragent\lib

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
	
	role Driver { ... }
	role Session { ... }
	role Element { ... }
	
	role Context {
		method find-element ( By:D $locator --> Element:D ) { ... }
		method find-elements ( By:D $locator --> Array:D[ Element:D ] ) { ... }
		method switch-to-parent-frame ( --> Bool:D ) { ... }
	}
	
	role Request-Builder does WebDriver2::Test::Debugging {
		use JSON::Fast;
		# trusts WD2P::Session;
		# trusts WD2P::Driver;
		
		method host ( --> Str:D ) { ... }
		method port ( --> Int:D ) { ... }
		
		method request (
				Str:D $method,
				*@command
				--> HTTP::Request:D
		) {
			my Str:D $url = "http://$.host:$.port/"; ~ @command.join: '/';
			self.debug: Level::extra, $method, $url;
			given $method {
				when 'GET' { return HTTP::Request.new: GET => $url; }
				when 'POST' { return HTTP::Request.new: POST => $url; }
				when 'DELETE' { return HTTP::Request.new: DELETE => $url; }
			}
		}
		
		method get-request (
				*@command
				--> HTTP::Request:D
		) {
			self.request: 'GET', @command;
		}
		
		method post-request (
				$data,
				*@command
				--> HTTP::Request:D
		) {
			my HTTP::Request $req = self.request: 'POST', @command;
			my Str:D $json = to-json $data;
			self.debug: Level::extra, $json;
			$req.add-content: $json;
			$req;
		}
		
		method delete-request (
				*@command
				--> HTTP::Request:D
		) {
			self.request: 'DELETE', @command;
		}
	}
	
	role Driver-Request does Request-Builder {
		method status ( --> HTTP::Request:D ) { ... }
		method new-session ( *%capabilities --> HTTP::Request:D ) { ... }
	}
	
	class Driver-Request::Chromium does Driver-Request {
		use JSON::Fast;
		has Str:D $.host = '127.0.0.1';
		has Int:D $.port = 9515;
		method status ( --> HTTP::Request:D ) {
			self.get-request: 'status'
		}
		
		multi method new-session ( *%capabilities --> HTTP::Request:D ) {
			self.post-session: %capabilities, 'session';
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
		method switch-to-window ( Str:D $handle --> HTTP::Request:D ) { ... }
		method get-window-handles ( --> HTTP::Request:D ) { ... }
		method new-window ( --> HTTP::Request:D ) { ... }
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
	
	class Session-Request::Default does Session-Request {
		has Str:D $.host is required;
		has Int:D $.port is required;
		method !args { 'session', $!session-id }
		
		method delete-session ( --> HTTP::Request:D ) {
			self.delete-request: self!args;
		}
		
		method get-timeouts ( --> HTTP::Request:D ) {
			self.get-request: self!args, 'timeouts';
		}
		
		method set-timeouts (
				Int :$script,
				Int :$pageLoad,
				Int :$implicit
				--> HTTP::Request:D
		) {
			self.post-request: {
				:$script,
				:$pageLoad,
				:$implicit
			}, self!args, 'timeouts';
		}
		
		method navigate-to ( Str:D $url --> HTTP::Request:D ) {
			self.post-request: { :$url }, self!args, 'url';
		}
		
		method get-current-url ( --> HTTP::Request:D ) {
			self.get-request: self!args, 'url';
		}
		
		method back ( --> HTTP::Request:D ) {
			self.post-request: { }, self!args, 'back';
		}
		
		method forward ( --> HTTP::Request:D ) {
			self.post-request: { }, self!args, 'forward';
		}
		
		method refresh ( --> HTTP::Request:D ) {
			self.post-request: { }, self!args, 'refresh';
		}
		
		method get-title ( --> HTTP::Request:D ) {
			self.get-request: self!args, 'title';
		}
		
		method get-window-handle ( --> HTTP::Request:D ) {
			self.get-request: self!args, 'window';
		}
		
		method close-window ( --> HTTP::Request:D ) {
			self.delete-request: self!args, 'window';
		}
		
		method switch-to-window ( Str:D $handle --> HTTP::Request:D ) {
			self.post-request: { :$handle }, self!args, 'window';
		}
		
		method get-window-handles ( --> HTTP::Request:D ) {
			self.get-request: self!args, <window handles>;
		}
		
		method new-window ( Str $target = 'tab' --> HTTP::Request:D ) {
			self.post-request: { 'type hint' => $target }, self!args <window new>;
		}
		
		method switch-to-parent-frame ( --> HTTP::Request:D ) {
			self.post-request: { }, self!args, <frame parent>;
		}
		
		method get-window-rect ( --> HTTP::Request:D ) {
			self.get-request: self!args, <window rect>
		}
		
		method set-window-rect (
				Int :$width,
				Int :$height,
				Int :$x,
				Int :$y
				--> HTTP::Request:D
		) {
			self.post-request: { :$width, :$height, :$x, :$y }, self!args, <window rect>;
		}
		
		method maximize-window ( --> HTTP::Request:D ) {
			self.post-request: { }, self!args, <window maximize>;
		}
		
		method minimize-window ( --> HTTP::Request:D ) {
			self.post-request: { }, self!args, <window minimize>;
		}
		
		method fullscreen-window ( --> HTTP::Request:D ) {
			self.post-request: { }, self!args, <window fullscreen>;
		}
		
		method get-active-element ( --> HTTP::Request:D ) {
			self.get-request: self!args, <element active>;
		}
		
		method find-element ( By $locator --> HTTP::Request:D ) {
			self.post-request: $locator.args, self!args, 'element';
		}
		
		method find-elements ( By $locator --> HTTP::Request:D ) {
			self.post-request: $locator.args, self!args, 'elements';
		}
		
		
		
		method get-page-source ( --> HTTP::Request:D ) {
			self.get-request: self!args, 'source';
		}
		
		method execute-script ( Str:D $script, *@args --> HTTP::Request:D ) {
			self.post-request: { :$script, :@args }, self!args, <execute sync>;
		}
		
		method execute-async-script ( Str:D $script, *@args --> HTTP::Request:D ) {
			self.post-request: { :$script, :@args }, self!args, <execute async>;
		}
		
		method get-all-cookies ( --> HTTP::Request:D ) {
			self.get-request: self!args, 'cookie';
		}
		
		method get-named-cookie ( Str:D $name --> HTTP::Request:D ) {
			self.get-request: self!args, 'cookie', $name;
		}
		
		method add-cookie ( --> HTTP::Request:D ) {
			...
		}
		
		method delete-cookie ( Str:D $name --> HTTP::Request:D ) {
			
		}
		
		method delete-all-cookies ( --> HTTP::Request:D ) { { } }
		
		method perform-actions ( --> HTTP::Request:D ) {
			
		}
		
		method release-actions ( --> HTTP::Request:D ) {
			
		}
		
		method dismiss-alert ( --> HTTP::Request:D ) { { } }
		
		method accept-alert ( --> HTTP::Request:D ) { { } }
		
		method get-alert-text ( --> HTTP::Request:D ) { { } }
		
		method send-alert-text ( --> HTTP::Request:D ) {
			
		}
		
		method take-screenshot ( --> HTTP::Request:D ) { { } }
		
		method take-element-screenshot ( --> HTTP::Request:D ) {
			
		}
		
		method print-page ( --> HTTP::Request:D ) {
			
		}
	}
	
	role Element-Request does Request-Builder {
		has Str:D $!element-id is built is required;
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
		
		method switch-to-frame ( --> HTTP::Request:D ) {

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
	
	role Result {
		
		
		
	}
	
	class Result::Chromium does Result {
		
	}
	
	class Result::Chrome is Result::Chromium {
		
	}
	
	class Result::Edge is Result::Chromium {
		
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
	
	role Driver {
		has Driver-Request:D $!param is built is required;
		has Result:D $!result is built is required;
		
		has HTTP::UserAgent:D $!ua = HTTP::UserAgent.new;
		has Str:D $.host is required = '127.0.0.1';
		has Int:D $.port is required;
		has Str:D $.browser is required;
		
		method request ( HTTP::Request:D $req --> HTTP::Response:D ) {
			$!ua.request: $req;
		}
		
		method start { }
		
		method session ( --> WD2P::Session:D ) { ... }
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
					param => Param::Chrome,
					result => Result::Chrome,
					:$host,
					:$port,
					;
		}
	}
	
	class WD2P::Driver::Edge does WD2P::Driver {
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
	}
	
	class Session does Context {
		has Str:D $!id is built is required;
		has Str:D $.browser is required;
		
		
	}
	
	class Element does Context {
		has Str:D $!session-id is built is required;
		has Str:D $!element-id is built is required;
		has Str:D $.browser is required;
		
		
	}
	
	class Frame is Element {
		
	}
	
	class Page is Frame {
		
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

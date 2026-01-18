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



#| TODO : REMOVE ME
use lib <../http-useragent/lib>;

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
	
	role Request-Builder does WebDriver2::Test::Debugging {
		use JSON::Fast;
		
		method host ( --> Str:D ) { ... }
		method port ( --> Int:D ) { ... }
		
		method request (
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
	
	role Driver-Request {
		has Str:D $.host = '127.0.0.1';
		method status ( --> HTTP::Request:D ) { ... }
		method new-session ( *%capabilities --> HTTP::Request:D ) { ... }
	}
	
=begin comment
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
=end comment
	
	role Session-Request {
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

=begin table
	Property       | JSON Key    | Value Type and Valid Values
	==========================================================
	orientation    | orientation | Str : { portrait ( default ), landscape }
	==========================================================
	scale          | scale       | Rat : [ 0.1, 2 ] ( default : 1 )
	==========================================================
	background     | background  | Bool : ( default : False )
	==========================================================
	pageWidth      | width       | Rat : [ 2.54 / 72, Inf ) ( default : 21.59 )
	==========================================================
	pageHeight     | height      | Rat : [ 2.54 / 72, Inf ) ( default : 27.94 )
	==========================================================
	margin         | margin      | JSON Obj : ( default : { } )
	----------------------------------------------------------
	- marginTop    | top         | Rat : [ 0, Inf ) ( default : 1 )
	----------------------------------------------------------
	- marginBottom | bottom      | Rat : [ 0, Inf ) ( default : 1 )
	----------------------------------------------------------
	- marginLeft   | left        | Rat : [ 0, Inf ) ( default : 1 )
	----------------------------------------------------------
	- marginRight  | right       | Rat : [ 0, Inf ) ( default : 1 )
	==========================================================
	shrinkToFit    | shrinkToFit | Bool : ( default : True )
	==========================================================
	pageRanges     | pageRanges  | Array:D[ Int:D ] : ( default : [ ] )
=end table

		method print-page ( %args --> HTTP::Request:D ) { ... }
	}
	
=begin comment
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
			self.post-request: { 'type hint' => $target }, self!args, <window new>;
		}
		
		multi method switch-to-frame ( Str:D $id --> HTTP::Request:D ) {
			self.post-request: { :$id }, self!args, 'frame';
		}
		multi method switch-to-frame ( Int $id ) {
			self.post-request: { :$id }, self!args, 'frame';
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
		
		method add-cookie (
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
			self.post-request: cookie => %args, self!args, 'cookie';
		}
		
		method delete-cookie ( Str:D $name --> HTTP::Request:D ) {
			self.delete-request: self!args, 'cookie', $name;
		}
		
		method delete-all-cookies ( --> HTTP::Request:D ) {
			self.delete-request: self!args, 'cookie';
		}
		
		method perform-actions ( --> HTTP::Request:D ) {
			!!! 'nyi'
		}
		
		method release-actions ( --> HTTP::Request:D ) {
			!!! 'nyi'
		}
		
		method dismiss-alert ( --> HTTP::Request:D ) {
			self.post-request: { }, self!args, <alert dismiss>;
		}
		
		method accept-alert ( --> HTTP::Request:D ) {
			self.post-request: { }, self!args, <alert accept>;
		}
		
		method get-alert-text ( --> HTTP::Request:D ) {
			self.get-request: self!args, <alert text>;
		}
		
		method send-alert-text ( Str:D $text --> HTTP::Request:D ) {
			self.post-request: { :$text }, self!args, <alert text>;
		}
		
		method take-screenshot ( --> HTTP::Request:D ) {
			self.get-request: self!args, 'screenshot';
		}
		
		# TODO : margins, etc.?
		method print-page (
				Str:D $orientation where <portrait landscape>.any = 'portrait'
				--> HTTP::Request:D
		) {
			self.post-request:{ :$orientation }, 'print';
		}
	}
=end comment
	
	role Element-Request {
		has Str:D $!session-id is built is required;
		has Str:D $!element-id is built is required;
		
		method find-sub-element ( By:D $locator --> HTTP::Request:D ) { ... }
		method find-sub-elements ( By:D $locator --> HTTP::Request:D ) { ... }
		
		method get-element-shadow-root ( --> HTTP::Request:D ) { ... }
		
		method is-element-selected ( --> HTTP::Request:D ) { ... }
		method get-element-attribute ( Str:D $name --> HTTP::Request:D ) { ... }
		method get-element-property ( Str:D $name --> HTTP::Request:D ) { ... }
		method get-element-css-value ( Str:D $name --> HTTP::Request:D ) { ... }
		method get-element-text ( --> HTTP::Request:D ) { ... }
		method get-element-tag-name ( --> HTTP::Request:D ) { ... }
		method get-element-rect ( --> HTTP::Request:D ) { ... }
		method is-element-enabled ( Str --> HTTP::Request:D ) { ... }
		method get-computed-role ( --> HTTP::Request:D ) { ... }
		method get-computed-label ( --> HTTP::Request:D ) { ... }
		method element-click ( --> HTTP::Request:D ) { ... }
		method element-clear ( --> HTTP::Request:D ) { ... }
		method element-send-keys ( Str:D $text --> HTTP::Request:D ) { ... }
		method take-element-screenshot ( --> HTTP::Request:D ) { ... }
	}
	
=begin comment
	class Element-Request::Default does Element-Request {
		has Str:D $.host is required;
		has Int:D $.port is required;
		method !args { 'session', $!session-id, 'element', $!element-id }

		method find-sub-element ( By:D $locator --> HTTP::Request:D ) {
			self.post-request: $locator.args, self!args, 'element';
		}
		method find-sub-elements ( By:D $locator --> HTTP::Request:D ) {
			self.post-request: $locator.args, self!args, 'elements';
		}


	}
=end comment
	
	role Shadow-Request {
		method find-sub-shadow-element ( Str:D $sid, Str:D $shadow-id --> HTTP::Request:D ) { ... }
		method find-sub-shadow-elements ( Str:D $sid, Str:D $shadow-id --> HTTP::Request:D ) { ... }
	}
	
	class Request::Default
			does Driver-Request
			does Session-Request
			does Element-Request
			does Shadow-Request
	{
		use JSON::Fast;
		
		# DRIVER REQUESTS
		
		method status ( --> HTTP::Request:D ) {
			self!get-request: 'status'
		}
		
		method new-session ( *%capabilities --> HTTP::Request:D ) {
			self!post-request: %capabilities, 'session';
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
		
		method switch-to-frame ( --> HTTP::Request:D ) {

		}
		
		multi method switch-to-frame ( Str:D $session-id, Int $id ) {
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
		
		method find-element ( Str:D $session-id, By:D $locator --> HTTP::Request:D ) {
			self!post-request: $locator.args, 'session', $session-id, 'element';
		}
		
		method find-elements ( Str:D $session-id, By:D $locator --> HTTP::Request:D ) {
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
		
		# XXX : ELEMENT REQUESTS
		
		method find-sub-element ( Str:D $sid, Str:D $element-id, By:D $locator --> HTTP::Request:D ) {
			self!post-request: $locator.args, 'session',$sid, 'element', $element-id, 'element';
		}
		
		method find-sub-elements ( Str:D $sid, Str:D $element-id, By:D $locator --> HTTP::Request:D ) {
			self!post-request: $locator.args, 'session',$sid, 'element', $element-id, 'elements';
		}
		
		
		
		method get-element-shadow-root ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			self!get-request: 'session', $sid, 'element', $element-id, 'shadow';
		}
				
		method is-element-selected ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			self!get-request: 'session', $sid, 'element', $element-id, 'selected';
		}
		
		method get-element-attribute ( Str:D $sid, Str:D $element-id, Str:D $name --> HTTP::Request:D ) {
			self!get-request: 'session', $sid, 'element', $element-id, 'attribute', $name;
		}
		
		method get-element-property ( Str:D $sid, Str:D $element-id, Str:D $name --> HTTP::Request:D ) {
			self!get-request: 'session', $sid, 'element', $element-id, 'property', $name;
		}
		
		method get-element-css-value ( Str:D $sid, Str:D $element-id, $property-name --> HTTP::Request:D ) {
			self!get-request: 'session', $sid, 'element', $element-id, 'css', $property-name;
		}
		
		method get-element-text ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			self!get-request: 'session', $sid, 'element', $element-id, 'text';
		}
		
		method get-element-tag-name ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			self!get-request: 'session', $sid, 'element', $element-id, 'name';
		}
		
		method get-element-rect ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			self!get-request: 'session', $sid, 'element', $element-id, 'rect';
		}
		
		method is-element-enabled ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			self!get-request: 'session', $sid, 'element', $element-id, 'enabled';
		}
		
		method get-computed-role ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			self!get-request: 'session', $sid, 'element', $element-id, 'computedrole';
		}
		
		method get-computed-label ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			self!get-request: 'session', $sid, 'element', $element-id, 'computedlabel';
		}
		
		method element-click ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			self!post-request: { }, 'session', $sid, 'element', $element-id, 'click';
		}
		
		method element-clear ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			self!post-request: { }, 'session', $sid, 'element', $element-id, 'clear';
		}
		
		method element-send-keys ( Str:D $sid, Str:D $element-id, Str:D $text --> HTTP::Request:D ) {
			self!post-request: { :$text }, 'session', $sid, 'element', $element-id, 'value';
		}

		multi method switch-to-frame ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			self!post-request: { id => $element-id }, 'session', $sid, 'frame';
		}
		
		method take-element-screenshot ( Str:D $sid, Str:D $element-id --> HTTP::Request:D ) {
			self!get-request: 'session', $sid, 'element', $element-id, 'screenshot';
		}
		
		# SHADOW REQUESTS
		
		method find-sub-shadow-element ( Str:D $sid, Str:D $shadow-id, By:D $locator --> HTTP::Request:D ) {
			self!post-request: $locator.args, 'session', $sid, 'shadow', $shadow-id, 'element';
		}
		
		method find-sub-shadow-elements ( Str:D $sid, Str:D $shadow-id, By:D $locator --> HTTP::Request:D ) {
			self!post-request: $locator.args, 'session', $sid, 'shadow', $shadow-id, 'elements';
		}
	}
	
=begin comment
	class Shadow-Request::Default does Shadow-Request {
		has Str:D $.host is required;
		has Int:D $.port is required;
		
		method find-sub-shadow-element ( Str:D $sid, Str:D $shadow-id --> HTTP::Request:D ) {
			
		}
		
		method find-sub-shadow-elements ( Str:D $sid, Str:D $shadow-id --> HTTP::Request:D ) {
			
		}
	}
=end comment

	class Shadow-Root { ... }
	
	class Element { ... }
	
	use WebDriver2::Command::Execution-Status;
	
	class Session { ... }
	
	role Result does WebDriver2::Test::Debugging {
		
		method check-status ( HTTP::Response $response ) {
			my $data = from-json $response.content;
			return $data if $response.code.Int == 200;
			
			Failure.new:
					WebDriver2::Command::Result::X.new:
							execution-status =>
								WebDriver2::Command::Execution-Status.new:
										status => $response.code,
										error => $data<value><error>,
										message => $data<value><message> // '',
										stacktrace => $data<value><stacktrace> // '',
										data => $data<value><data>
												?? $data<value><data>
												!! Nil
										;
		}
		
		# DRIVER RESULTS
		
		method status ( HTTP::Response:D $response ) {
			
			with self.check-status: $response -> $data {
				
			} else {
				$_;
			}
		}
		method session ( HTTP::Response:D $response --> Session:D ) { ... }
		
		# SESSION RESULTS
		
		method delete-session ( HTTP::Response:D $response --> Bool:D ) { ... }
		method get-timeouts ( HTTP::Response:D $response --> Hash:D[ Int:D ] ) { ... }
		method set-timeouts ( HTTP::Response:D $response --> Session:D ) { ... }
		method navigate-to ( HTTP::Response:D $response --> Session:D ) { ... }
		method get-current-url ( HTTP::Response:D $response --> Str:D ) { ... }
		method back ( HTTP::Response:D $response --> Session:D ) { ... }
		method forward ( HTTP::Response:D $response --> Session:D ) { ... }
		method refresh ( HTTP::Response:D $response --> Session:D ) { ... }
		method get-title ( HTTP::Response:D $response --> Str:D ) { ... }
		method get-window-handle ( HTTP::Response:D $response --> Str:D ) { ... }
		method close-window ( HTTP::Response:D $response --> Session:D ) { ... }
		method switch-to-window ( HTTP::Response:D $response --> Session:D ) { ... }
		method get-window-handles ( HTTP::Response:D $response --> List:D[ Str:D ] ) { ... }
		method new-window ( HTTP::Response:D $response --> Hash:D[ Str:D ] ) { ... }
		method switch-to-frame ( HTTP::Response:D $response --> Session:D ) { ... }
		method switch-to-parent-frame ( HTTP::Response:D $response --> Session:D ) { ... }
		method get-window-rect ( HTTP::Response:D $response --> Hash:D[ Int:D ] ) { ... }
		method set-window-rect ( HTTP::Response:D $response --> Session:D ) { ... }
		method maxamize-window ( HTTP::Response:D $response --> Session:D ) { ... }
		method minimize-window ( HTTP::Response:D $response --> Session:D ) { ... }
		method fullscreen-window ( HTTP::Response:D $response --> Session:D ) { ... }
		method get-active-element ( HTTP::Response:D $response --> Element:D ) { ... }
		method find-element (
				HTTP::Response:D $response
				--> Element:D
		) { ... }
		method find-elements (
				HTTP::Response:D $response
				--> List:D[ Element:D ]
		) { ... }
		method get-page-source ( HTTP::Response:D $response --> Str:D ) { ... }
		#| multiple return types
		method execute-script ( HTTP::Response:D $response ) { ... }
		#| multiple return types
		method execute-async-script ( HTTP::Response:D $response ) { ... }
		method get-all-cookies ( HTTP::Response:D $response --> List:D ) { ... }

=begin table :caption<cookie object structure>
	RFC 6265 Field   | JSON Key | Attribute Key
	=========================================
	name             | name     |
	value            | value    |
	path             | path     | Path
	domain           | domain   | Domain
	secure-only-flag | secure   | Secure
	http-only-flag   | httpOnly | HttpOnly
	expiry-time      | expiry   | Max-Age
	samesite         | sameSite | SameSite
=end table

		method get-named-cookie ( HTTP::Response:D $response --> Hash:D[ Str:D ] ) { ... }
		method add-cookie ( HTTP::Response:D $response --> Session:D ) { ... }
		method delete-cookie ( HTTP::Response:D $response --> Session:D ) { ... }
		method delete-all-cookies ( HTTP::Response:D $response --> Session:D ) { ... }
		method perform-actions ( HTTP::Response:D $response --> Session:D ) { ... }
		method release-actions ( HTTP::Response:D $response --> Session:D ) { ... }
		method dismiss-alert ( HTTP::Response:D $response --> Session:D ) { ... }
		method accept-alert ( HTTP::Response:D $response --> Session:D ) { ... }
		method get-alert-text ( HTTP::Response:D $response --> Str:D ) { ... }
		method send-alert-text ( HTTP::Response:D $response --> Session:D ) { ... }
		method take-screenshot ( HTTP::Response:D $response --> Str:D ) { ... }
		method print-page ( HTTP::Response:D $response --> Str:D ) { ... }
		
		# ELEMENT RESULTS
		
		method find-sub-element ( HTTP::Response:D $response --> Element:D ) { ... }
		method find-sub-elements ( HTTP::Response:D $response --> List:D[ Element:D ] ) { ... }
		method get-element-shadow-root ( HTTP::Response:D $response --> Shadow-Root:D ) { ... }
		method is-element-selected ( HTTP::Response:D $response --> Bool:D ) { ... }
		method get-element-attribute ( HTTP::Response:D $response --> Str ) { ... }
		#| multiple return types
		method get-element-property ( HTTP::Response:D $response ) { ... }
		#| generally JSON Strings but check WebDriver spec; can be undef
		method get-element-css-value ( HTTP::Response:D $response --> Str ) { ... }
		method get-element-text ( HTTP::Response:D $response --> Str:D ) { ... }
		method get-element-tag-name ( HTTP::Response:D $response --> Str:D ) { ... }
		method get-element-rect ( HTTP::Response:D $response --> Hash:D[ Rat:D ] ) { ... }
		method is-element-enabled ( HTTP::Response:D $response --> Bool:D ) { ... }
		method get-computed-role ( HTTP::Response:D $response --> Str:D ) { ... }
		method get-computed-label ( HTTP::Response:D $response --> Str:D) { ... }
		method element-click ( HTTP::Response:D $response --> Element:D ) { ... }
		method element-clear ( HTTP::Response:D $response --> Element:D ) { ... }
		method element-send-keys ( HTTP::Response:D $response --> Element:D ) { ... }
		method take-element-screenshot ( HTTP::Response:D $response --> Str:D ) { ... }
		
		# SHADOW RESULTS
		
		method find-sub-shadow-element ( HTTP::Response:D $response --> Element:D ) { ... }
		method find-sub-shadow-elements ( HTTP::Response:D $response --> List:D[ Element:D ] ) { ... }
	}
	
	class Result::Chromium does Result {
		
		# DRIVER RESULTS
		
		method status ( HTTP::Response:D $response --> Bool:D ) { ... }
		method session ( HTTP::Response:D $response --> Session:D ) { ... }
		
		# SESSION RESULTS
		
		method delete-session ( HTTP::Response:D $response --> Bool:D ) { ... }
		method get-timeouts ( HTTP::Response:D $response --> Hash:D[ Int:D ] ) { ... }
		method set-timeouts ( HTTP::Response:D $response --> Session:D ) { ... }
		method navigate-to ( HTTP::Response:D $response --> Session:D ) { ... }
		method get-current-url ( HTTP::Response:D $response --> Str:D ) { ... }
		method back ( HTTP::Response:D $response --> Session:D ) { ... }
		method forward ( HTTP::Response:D $response --> Session:D ) { ... }
		method refresh ( HTTP::Response:D $response --> Session:D ) { ... }
		method get-title ( HTTP::Response:D $response --> Str:D ) { ... }
		method get-window-handle ( HTTP::Response:D $response --> Str:D ) { ... }
		method close-window ( HTTP::Response:D $response --> Session:D ) { ... }
		method switch-to-window ( HTTP::Response:D $response --> Session:D ) { ... }
		method get-window-handles ( HTTP::Response:D $response --> List:D[ Str:D ] ) { ... }
		method new-window ( HTTP::Response:D $response --> Hash:D[ Str:D ] ) { ... }
		method switch-to-frame ( HTTP::Response:D $response --> Session:D ) { ... }
		method switch-to-parent-frame ( HTTP::Response:D $response --> Session:D ) { ... }
		method get-window-rect ( HTTP::Response:D $response --> Hash:D[ Int:D ] ) { ... }
		method set-window-rect ( HTTP::Response:D $response --> Session:D ) { ... }
		method maxamize-window ( HTTP::Response:D $response --> Session:D ) { ... }
		method minimize-window ( HTTP::Response:D $response --> Session:D ) { ... }
		method fullscreen-window ( HTTP::Response:D $response --> Session:D ) { ... }
		method get-active-element ( HTTP::Response:D $response --> Element:D ) { ... }
		method find-element (
				HTTP::Response:D $response
				--> Element:D
		) { ... }
		method find-elements (
				HTTP::Response:D $response
				--> List:D[ Element:D ]
		) { ... }
		method get-page-source ( HTTP::Response:D $response --> Str:D ) { ... }
		#| multiple return types
		method execute-script ( HTTP::Response:D $response ) { ... }
		#| multiple return types
		method execute-async-script ( HTTP::Response:D $response ) { ... }
		method get-all-cookies ( HTTP::Response:D $response --> List:D ) { ... }

=begin table :caption<cookie object structure>
	RFC 6265 Field   | JSON Key | Attribute Key
	=========================================
	name             | name     |
	value            | value    |
	path             | path     | Path
	domain           | domain   | Domain
	secure-only-flag | secure   | Secure
	http-only-flag   | httpOnly | HttpOnly
	expiry-time      | expiry   | Max-Age
	samesite         | sameSite | SameSite
=end table

		method get-named-cookie ( HTTP::Response:D $response --> Hash:D[ Str:D ] ) { ... }
		method add-cookie ( HTTP::Response:D $response --> Session:D ) { ... }
		method delete-cookie ( HTTP::Response:D $response --> Session:D ) { ... }
		method delete-all-cookies ( HTTP::Response:D $response --> Session:D ) { ... }
		method perform-actions ( HTTP::Response:D $response --> Session:D ) { ... }
		method release-actions ( HTTP::Response:D $response --> Session:D ) { ... }
		method dismiss-alert ( HTTP::Response:D $response --> Session:D ) { ... }
		method accept-alert ( HTTP::Response:D $response --> Session:D ) { ... }
		method get-alert-text ( HTTP::Response:D $response --> Str:D ) { ... }
		method send-alert-text ( HTTP::Response:D $response --> Session:D ) { ... }
		method take-screenshot ( HTTP::Response:D $response --> Str:D ) { ... }
		method print-page ( HTTP::Response:D $response --> Str:D ) { ... }
		
		# ELEMENT RESULTS
		
		method find-sub-element ( HTTP::Response:D $response --> Element:D ) { ... }
		method find-sub-elements ( HTTP::Response:D $response --> List:D[ Element:D ] ) { ... }
		method get-element-shadow-root ( HTTP::Response:D $response --> Shadow-Root:D ) { ... }
		method is-element-selected ( HTTP::Response:D $response --> Bool:D ) { ... }
		method get-element-attribute ( HTTP::Response:D $response --> Str ) { ... }
		#| multiple return types
		method get-element-property ( HTTP::Response:D $response ) { ... }
		#| generally JSON Strings but check WebDriver spec; can be undef
		method get-element-css-value ( HTTP::Response:D $response --> Str ) { ... }
		method get-element-text ( HTTP::Response:D $response --> Str:D ) { ... }
		method get-element-tag-name ( HTTP::Response:D $response --> Str:D ) { ... }
		method get-element-rect ( HTTP::Response:D $response --> Hash:D[ Rat:D ] ) { ... }
		method is-element-enabled ( HTTP::Response:D $response --> Bool:D ) { ... }
		method get-computed-role ( HTTP::Response:D $response --> Str:D ) { ... }
		method get-computed-label ( HTTP::Response:D $response --> Str:D) { ... }
		method element-click ( HTTP::Response:D $response --> Element:D ) { ... }
		method element-clear ( HTTP::Response:D $response --> Element:D ) { ... }
		method element-send-keys ( HTTP::Response:D $response --> Element:D ) { ... }
		method take-element-screenshot ( HTTP::Response:D $response --> Str:D ) { ... }
		
		# SHADOW RESULTS
		
		method find-sub-shadow-element ( HTTP::Response:D $response --> Element:D ) { ... }
		method find-sub-shadow-elements ( HTTP::Response:D $response --> List:D[ Element:D ] ) { ... }
	}
	
	class Result::Chrome is Result::Chromium {
		
	}
	
	class Result::Edge is Result::Chromium {
		
	}
	
	role Context {
		method find-element ( By:D $locator --> Element:D ) { ... }
		method find-elements ( By:D $locator --> List:D[ Element:D ] ) { ... }
		# method switch-to-parent-frame ( --> Bool:D ) { ... }
		method take-screenshot ( --> Str:D ) { ... }
	}
	
	class Shadow-Root does Context {
		method find-element ( By:D $locator --> Element:D ) {
			
		}
		method find-elements ( By:D $locator --> List:D[ Element:D ] ) { ... }
		method take-screenshot ( --> Str:D ) { ... }
	}
	
	class Element does Context {
		has Str:D $!session-id is built is required;
		has Str:D $!element-id is built is required;
		has Str:D $.browser is required;
		has Element-Request:D $!request is built is required;
		
		method find-element ( By:D $locator --> Element:D ) {
			
		}
		method find-elements ( By:D $locator --> List:D[ Element:D ] ) { ... }
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
		method find-elements ( By:D $locator --> List:D[ Element:D ] ) {
			$result.find-elements: $ua.request: $request.find-elements: $locator;
		}
		method take-screenshot ( --> Str:D ) {
			
		}
	}
	
	role Driver {
		has Driver-Request $!request is built is required;
		has Result $!result is built is required;
		
		has Str:D $.host is required = '127.0.0.1';
		has Int:D $.port is required;
		has Str:D $.browser is required;
		
		method request ( HTTP::Request:D $req --> HTTP::Response:D ) {
			$!ua.request: $req;
		}
		
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
	}
	
	class Frame is Element {
		
	}
	
	class Page is Frame {
		
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

=finish


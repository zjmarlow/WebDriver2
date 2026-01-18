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
	
	class Shadow-Root { ... }
	class Element { ... }
	class Session { ... }
	role Driver { ... }
	
	package Request {
		role Base does WebDriver2::Test::Debugging {
			use JSON::Fast;
			
			method host ( --> Str:D ) { ... }
			method port ( --> Int:D ) { ... }
			method command ( *@command --> Positional:D ) { ... }

			method request (
					Str:D $method,
					*@command
					--> HTTP::Request:D
			) {
				my Str:D $url = join '/', "http://$.host:$.port/", |self.command: @command;
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
			method status ( --> HTTP::Request:D ) { ... }
			method new-session ( *%capabilities --> HTTP::Request:D ) { ... }
		}
		
		role Session-Request {
			method delete-session ( Session:D $session --> HTTP::Request:D ) { ... }
			method get-timeouts ( Session:D $session --> HTTP::Request:D ) { ... }
			method set-timeouts (
					Session:D $session,
					Int :$script,
					Int :$pageLoad,
					Int :$implicit
					--> HTTP::Request:D
			) { ... }
			method navigate-to (
					Session:D $session,
					Str:D $url
					--> HTTP::Request:D
			) { ... }
			method get-current-url ( Session:D $session --> HTTP::Request:D ) { ... }
			method back ( Session:D $session --> HTTP::Request:D ) { ... }
			method forward ( Session:D $session --> HTTP::Request:D ) { ... }
			method refresh ( Session:D $session --> HTTP::Request:D ) { ... }
			method get-title ( Session:D $session --> HTTP::Request:D ) { ... }
			method get-window-handle ( Session:D $session --> HTTP::Request:D ) { ... }
			method close-window ( Session:D $session --> HTTP::Request:D ) { ... }
			method switch-to-window (
					Session:D $session,
					Str:D $handle
					--> HTTP::Request:D
			) { ... }
			method get-window-handles ( Session:D $session --> HTTP::Request:D ) { ... }
			method new-window ( Session:D $session --> HTTP::Request:D ) { ... }
			method switch-to-frame (
					Session:D $session,
					Int $frame
					--> HTTP::Request:D
			) { ... }
			method switch-to-parent-frame ( Session:D $session --> HTTP::Request:D ) { ... }
			method get-window-rect ( Session:D $session --> HTTP::Request:D ) { ... }
			method set-window-rect (
					Session:D $session,
					Int :$width,
					Int :$height,
					Int :$x,
					Int :$y
					--> HTTP::Request:D
			) { ... }
			method maximize-window ( Session:D $session --> HTTP::Request:D ) { ... }
			method minimize-window ( Session:D $session --> HTTP::Request:D ) { ... }
			method fullscreen-window ( Session:D $session --> HTTP::Request:D ) { ... }
			method get-active-element ( Session:D $session --> HTTP::Request:D ) { ... }
			
			method get-page-source ( Session:D $session --> HTTP::Request:D ) { ... }
			method execute-script (
					Session:D $session,
					Str:D $script,
					*@args
					--> HTTP::Request:D
			) { ... }
			method execute-async-script (
					Session:D $session,
					Str:D $script,
					*@args
					--> HTTP::Request:D
			) { ... }
			method get-all-cookies ( Session:D $session --> HTTP::Request:D ) { ... }
			method get-named-cookie (
					Session:D $session,
					Str:D $name
					--> HTTP::Request:D
			) { ... }
			method add-cookie ( Session:D $session --> HTTP::Request:D ) { ... }
			method delete-cookie (
					Session:D $session,
					Str:D $name
					--> HTTP::Request:D
			) { ... }
			method delete-all-cookies ( Session:D $session --> HTTP::Request:D ) { ... }
			method perform-actions ( Session:D $session --> HTTP::Request:D ) { ... }
			method release-actions ( Session:D $session --> HTTP::Request:D ) { ... }
			method dismiss-alert ( Session:D $session --> HTTP::Request:D ) { ... }
			method accept-alert ( Session:D $session --> HTTP::Request:D ) { ... }
			method get-alert-text ( Session:D $session --> HTTP::Request:D ) { ... }
			method send-alert-text ( Session:D $session --> HTTP::Request:D ) { ... }
			method take-screenshot ( Session:D $session --> HTTP::Request:D ) { ... }
			method take-element-screenshot (
					Session:D $session
					--> HTTP::Request:D
			) { ... }

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

			method print-page ( Session:D $session, %args --> HTTP::Request:D ) { ... }
		}
		
		role Element-Request {
			method find-sub-element (
					Element:D $element,
					By:D $locator
					--> HTTP::Request:D
			) { ... }
			method find-sub-elements (
					Element:D $element,
					By:D $locator
					--> HTTP::Request:D
			) { ... }
			
			method get-element-shadow-root (
					Element:D $element
					--> HTTP::Request:D
			) { ... }
			
			method is-element-selected (
					Element:D $element
					--> HTTP::Request:D
			) { ... }
			method get-element-attribute (
					Element:D $element,
					Str:D $name
					--> HTTP::Request:D
			) { ... }
			method get-element-property (
					Element:D $element,
					Str:D $name
					--> HTTP::Request:D
			) { ... }
			method get-element-css-value (
					Element:D $element,
					Str:D $name
					--> HTTP::Request:D
			) { ... }
			method get-element-text (
					Element:D $element
					--> HTTP::Request:D
			) { ... }
			method get-element-tag-name (
					Element:D $element
					--> HTTP::Request:D
			) { ... }
			method get-element-rect (
					Element:D $element
					--> HTTP::Request:D
			) { ... }
			method is-element-enabled (
					Element:D $element
					--> HTTP::Request:D
			) { ... }
			method get-computed-role (
					Element:D $element
					--> HTTP::Request:D
			) { ... }
			method get-computed-label (
					Element:D $element
					--> HTTP::Request:D
			) { ... }
			method element-click (
					Element:D $element
					--> HTTP::Request:D
			) { ... }
			method element-clear (
					Element:D $element
					--> HTTP::Request:D
			) { ... }
			method element-send-keys (
					Element:D $element,
					Str:D $text
					--> HTTP::Request:D
			) { ... }
			method take-element-screenshot (
					Element:D $element
					--> HTTP::Request:D
			) { ... }
		}
		
		role Shadow-Request {
			method find-sub-shadow-element (
					Shadow-Root:D $shadow
					--> HTTP::Request:D
			) { ... }
			method find-sub-shadow-elements (
					Shadow-Root:D $shadow
					--> HTTP::Request:D
			) { ... }
		}
		
		class Default
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
			
			method delete-session ( Session:D $session --> HTTP::Request:D ) {
				$session.delete-request;
			}
			
			method get-timeouts ( Session:D $session --> HTTP::Request:D ) {
				$session.get-request: 'timeouts';
			}
			
			method set-timeouts (
					Session:D $session,
					Int :$script,
					Int :$pageLoad,
					Int :$implicit
					--> HTTP::Request:D
			) {
				$session.post-request: {
					:$script,
					:$pageLoad,
					:$implicit
				}, 'timeouts';
			}
			
			method navigate-to ( Session:D $session, Str:D $url --> HTTP::Request:D ) {
				$session.post-request: { :$url }, 'url';
			}
			
			method get-current-url ( Session:D $session --> HTTP::Request:D ) {
				$session.get-request: 'url';
			}
			
			method back ( Session:D $session --> HTTP::Request:D ) {
				$session.post-request: { }, 'back';
			}
			
			method forward ( Session:D $session --> HTTP::Request:D ) {
				$session.post-request: { }, 'forward';
			}
			
			method refresh ( Session:D $session --> HTTP::Request:D ) {
				$session.post-request: { }, 'refresh';
			}
			
			method get-title ( Session:D $session --> HTTP::Request:D ) {
				$session.get-request: 'title';
			}
			
			method get-window-handle ( Session:D $session --> HTTP::Request:D ) {
				$session.get-request: 'window';
			}
			
			method close-window ( Session:D $session --> HTTP::Request:D ) {
				$session.delete-request: 'window';
			}
			
			method switch-to-window ( Session:D $session, Str:D $handle --> HTTP::Request:D ) {
				$session.post-request: { :$handle }, 'window';
			}
			
			method get-window-handles ( Session:D $session --> HTTP::Request:D ) {
				$session.get-request: <window handles>;
			}
			
			method new-window ( Session:D $session --> HTTP::Request:D ) {
				$session.post-request: { 'type hint' => 'tab' }, <window new>;
			}
			
			multi method switch-to-frame ( --> HTTP::Request:D ) {

			}
			
			multi method switch-to-frame ( Session:D $session, Int $id ) {
				$session.post-request: { :$id }, 'frame';
			}
			
			method switch-to-parent-frame ( Session:D $session --> HTTP::Request:D ) {
				$session.post-request: { }, <frame parent>;
			}
			
			method get-window-rect ( Session:D $session --> HTTP::Request:D ) {
				$session.get-request: <window rect>;
			}
			
			method set-window-rect (
					Session:D $session,
					Int :$width,
					Int :$height,
					Int :$x,
					Int :$y
					--> HTTP::Request:D
			) {
				$session.post-request: { :$width, :$height, :$x, :$y }, <window rect>;
			}
			
			method maximize-window ( Session:D $session --> HTTP::Request:D ) {
				$session.post-request: { }, <window maximize>;
			}
			
			method minimize-window ( Session:D $session --> HTTP::Request:D ) {
				$session.post-request: { }, <window minimize>;
			}
			
			method fullscreen-window ( Session:D $session --> HTTP::Request:D ) {
				$session.post-request: { }, <window fullscreen>;
			}
			
			method get-active-element ( Session:D $session --> HTTP::Request:D ) {
				$session.get-request: <element active>;
			}
			
			method find-element (
					Session:D $session,
					By:D $locator
					--> HTTP::Request:D
			) {
				$session.post-request: $locator.args, 'element';
			}
			
			method find-elements (
					Session:D $session,
					By:D $locator
					--> HTTP::Request:D
			) {
				$session.post-request: $locator.args, 'elements';
			}
			
			
			
			method get-page-source ( Session:D $session --> HTTP::Request:D ) {
				$session.get-request: 'source';
			}
			
			method execute-script (
					Session:D $session,
					Str:D $script,
					*@args --> HTTP::Request:D
			) {
				$session.post-request: { :$script, :@args }, <execute sync>;
			}
			
			method execute-async-script (
					Session:D $session,
					Str:D $script,
					*@args --> HTTP::Request:D
			) {
				$session.post-request: { :$script, :@args }, <execute async>;
			}
			
			method get-all-cookies ( Session:D $session --> HTTP::Request:D ) {
				$session.get-request: 'cookie';
			}
			
			method get-named-cookie (
					Session:D $session,
					Str:D $name
					--> HTTP::Request:D
			) {
				$session.get-request: 'cookie', $name;
			}
			
			method add-cookie (
					Session:D $session,
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
					(
							:$name,
							:$value,
							:$path,
							:$domain,
							:$secure,
							:$httpOnly,
							:$expiry,
							:$sameSite
					);
				$session.post-request: cookie => %args, 'cookie';
			}
			
			method delete-cookie ( Session:D $session, Str:D $name --> HTTP::Request:D ) {
				$session.delete-request: 'cookie', $name;
			}
			
			method delete-all-cookies ( Session:D $session --> HTTP::Request:D ) {
				$session.delete-request: 'cookie';
			}
			
			method perform-actions ( Session:D $session --> HTTP::Request:D ) {
				!!! 'nyi'
			}
			
			method release-actions ( Session:D $session --> HTTP::Request:D ) {
				!!! 'nyi'
			}
			
			method dismiss-alert ( Session:D $session --> HTTP::Request:D ) {
				$session.post-request: { }, <alert dismiss>;
			}
			
			method accept-alert ( Session:D $session --> HTTP::Request:D ) {
				$session.post-request: { }, <alert accept>;
			}
			
			method get-alert-text ( Session:D $session --> HTTP::Request:D ) {
				$session.get-request: <alert text>;
			}
			
			method send-alert-text ( Str:D $text, Session:D $session --> HTTP::Request:D ) {
				$session.post-request: { :$text }, <alert text>;
			}
			
			method take-screenshot ( Session:D $session --> HTTP::Request:D ) {
				$session.get-request: 'screenshot';
			}
			
			method print-page (
					Session:D $session,
					Str:D $orientation where <portrait landscape>.any = 'portrait'
					--> HTTP::Request:D
			) {
				$session.post-request: { :$orientation }, 'print';
			}
			
			# XXX : ELEMENT REQUESTS
			
			method find-sub-element (
					Element:D $element,
					By:D $locator
					--> HTTP::Request:D
			) {
				$element.post-request: $locator.args, 'element';
			}
			
			method find-sub-elements (
					Element:D $element,
					By:D $locator
					--> HTTP::Request:D
			) {
				$element.post-request: $locator.args, 'elements';
			}
			
			
			
			method get-element-shadow-root ( Element:D $element --> HTTP::Request:D ) {
				$element.get-request: 'shadow';
			}
					
			method is-element-selected ( Element:D $element --> HTTP::Request:D ) {
				$element.get-request: 'selected';
			}
			
			method get-element-attribute (
					Element:D $element,
					Str:D $name
					--> HTTP::Request:D
			) {
				$element.get-request: 'attribute', $name;
			}
			
			method get-element-property (
					Element:D $element,
					Str:D $name
					--> HTTP::Request:D
			) {
				$element.get-request: 'property', $name;
			}
			
			method get-element-css-value (
					Element:D $element,
					$property-name
					--> HTTP::Request:D
			) {
				$element.get-request: 'css', $property-name;
			}
			
			method get-element-text ( Element:D $element --> HTTP::Request:D ) {
				$element.get-request: 'text';
			}
			
			method get-element-tag-name ( Element:D $element --> HTTP::Request:D ) {
				$element.get-request: 'name';
			}
			
			method get-element-rect ( Element:D $element --> HTTP::Request:D ) {
				$element.get-request: 'rect';
			}
			
			method is-element-enabled ( Element:D $element --> HTTP::Request:D ) {
				$element.get-request: 'enabled';
			}
			
			method get-computed-role ( Element:D $element --> HTTP::Request:D ) {
				$element.get-request: 'computedrole';
			}
			
			method get-computed-label ( Element:D $element --> HTTP::Request:D ) {
				$element.get-request: 'computedlabel';
			}
			
			method element-click ( Element:D $element --> HTTP::Request:D ) {
				$element.post-request: 'click';
			}
			
			method element-clear ( Element:D $element --> HTTP::Request:D ) {
				$element.post-request: 'clear';
			}
			
			method element-send-keys (
					Element:D $element,
					Str:D $text
					--> HTTP::Request:D
			) {
				$element.post-request: 'value';
			}

			multi method switch-to-frame (
					Element:D $element,
					Str:D $element-id
					--> HTTP::Request:D
			) {
				$element.post-request: { id => $element-id }, 'frame';
			}
			
			method take-element-screenshot ( Element:D $element --> HTTP::Request:D ) {
				$element.get-request: 'screenshot';
			}
			
			# SHADOW REQUESTS
			
			method find-sub-shadow-element (
					Shadow-Root:D $shadow,
					By:D $locator
					--> HTTP::Request:D
			) {
				$shadow.post-request: $locator.args, 'element';
			}
			
			method find-sub-shadow-elements (
					Shadow-Root:D $shadow,
					By:D $locator
					--> HTTP::Request:D
			) {
				$shadow.post-request: $locator.args, 'elements';
			}
		}
	}
	
	use WebDriver2::Command::Execution-Status;
	
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
		has Session:D $!session is built is required;
		has Str:D $!element-id is built is required;
		has Str:D $.browser is required;
		has Element-Request:D $!request is built is required;
		has Result:D $!result is built is required;
		
		method command ( *@command --> Positional:D ) {
			$!session.command: 'element', $!element-id, @command;
		}
		
		method find-element ( By:D $locator --> Element:D ) {
			$!result.find-sub-element:
					$ua.request: $!request.find-sub-element: self, $locator;
		}
		method find-elements ( By:D $locator --> List:D[ Element:D ] ) {
			$!result.find-sub-elements:
					$ua.request: $!request.find-sub-elements: self, $locator;
		}
		method switch-to-parent-frame ( --> Bool:D ) { ... }
		method take-screenshot ( --> Str:D ) { }
	}
	
	class Frame is Element {
		
	}
	
	class Page is Frame {
		
	}
	
	class Session does Request::Base does Context {
		has Str:D $.host is required;
		has Int:D $.port is required;
		has Str:D $.browser is required;
		has Str:D $!id is built is required;
		has Session-Request:D $!request is built is required;
		has Result:D $!result is built is required;
		
		method command ( *@command --> Positional:D ) {
			'session', $!id, |@command
		}
		
		method navigate-to ( Str:D $url ) {
			$!result.navigate-to: $ua.request: $!request.navigate-to: self, $url;
		}
		
		method find-element ( By:D $locator --> Element:D ) {
			$!result.find-element: $ua.request: $!request.find-element: self, $locator;
		}
		method find-elements ( By:D $locator --> List:D[ Element:D ] ) {
			$!result.find-elements: $ua.request: $!request.find-elements: self, $locator;
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
			$ua.request: $req;
		}
		
		method start { }
		
		method new-session ( *%capabilities --> WD2P::Session:D ) { ... }
		method status ( --> WD2P::Status:D ) { ... }
		
		method stop { }
	}
	
	class WD2P::Driver::Chrome does WD2P::Driver {
		method new (
				Str:D $host = '127.0.0.1',
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


use WebDriver2::Test::Debugging;

=begin comment

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
# use lib <../http-useragent/lib>;

module WD2P {
	use HTTP::UserAgent;
	my HTTP::UserAgent $ua = HTTP::UserAgent.new;
	
	role By {
		has Str:D $.value is built is required;
		method using ( --> Str:D ) { ... }
		method value ( Str:D $value ) { self.bless: :$value }
		method args ( --> Hash:D[ Str:D ] ) {
			{ :$.using, :$!value }
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
	
	role Shadow-Root { ... }
	role Element { ... }
	role Session { ... }
	role Driver { ... }
	
	package Request {
		role Base does WebDriver2::Test::Debugging {
			use JSON::Fast;
			
			method host ( --> Str:D ) { ... }
			method port ( --> Int:D ) { ... }
			method command ( *@command --> Positional:D ) { @command }

			method request (
					Str:D $method,
					*@command
					--> HTTP::Request:D
			) {
				my Str:D $url = join '/', "http://$.host:$.port", |self.command: @command;
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
			method new-session ( %capabilities --> HTTP::Request:D ) { ... }
		}
		
		role Session-Request {
			method delete-session ( Base:D $base --> HTTP::Request:D ) { ... }
			method get-timeouts ( Base:D $base --> HTTP::Request:D ) { ... }
			method set-timeouts (
					Base:D $base,
					Int :$script,
					Int :$pageLoad,
					Int :$implicit
					--> HTTP::Request:D
			) { ... }
			method navigate-to (
					Base:D $base,
					Str:D $url
					--> HTTP::Request:D
			) { ... }
			method get-current-url ( Base:D $base --> HTTP::Request:D ) { ... }
			method back ( Base:D $base --> HTTP::Request:D ) { ... }
			method forward ( Base:D $base --> HTTP::Request:D ) { ... }
			method refresh ( Base:D $base --> HTTP::Request:D ) { ... }
			method get-title ( Base:D $base --> HTTP::Request:D ) { ... }
			method get-window-handle ( Base:D $base --> HTTP::Request:D ) { ... }
			method close-window ( Base:D $base --> HTTP::Request:D ) { ... }
			method switch-to-window (
					Base:D $base,
					Str:D $handle
					--> HTTP::Request:D
			) { ... }
			method get-window-handles ( Base:D $base --> HTTP::Request:D ) { ... }
			method new-window (
					Base:D $base,
					Str:D $type? where <tab window>.any
					--> HTTP::Request:D
			) { ... }
			multi method switch-to-frame ( Base:D $base --> HTTP::Request:D ) { ... }
			multi method switch-to-frame (
					Base:D $base,
					Int $frame
					--> HTTP::Request:D
			) { ... }
			multi method switch-to-frame (
					Base:D $base,
					Str:D $element-id
					--> HTTP::Request:D
			) { ... }
			method switch-to-parent-frame ( Base:D $base --> HTTP::Request:D ) { ... }
			method get-window-rect ( Base:D $base --> HTTP::Request:D ) { ... }
			method set-window-rect (
					Base:D $base,
					Int :$width,
					Int :$height,
					Int :$x,
					Int :$y
					--> HTTP::Request:D
			) { ... }
			method maximize-window ( Base:D $base --> HTTP::Request:D ) { ... }
			method minimize-window ( Base:D $base --> HTTP::Request:D ) { ... }
			method fullscreen-window ( Base:D $base --> HTTP::Request:D ) { ... }
			method get-active-element ( Base:D $base --> HTTP::Request:D ) { ... }
			
			method find-element (
					Session:D $base,
					By:D $locator
					--> HTTP::Request:D
			) { ... }
			method find-elements (
					Session:D $base,
					By:D $locator
					--> HTTP::Request:D
			) { ... }
			
			method get-page-source ( Base:D $base --> HTTP::Request:D ) { ... }
			method execute-script (
					Base:D $base,
					Str:D $script,
					*@args
					--> HTTP::Request:D
			) { ... }
			method execute-async-script (
					Base:D $base,
					Str:D $script,
					*@args
					--> HTTP::Request:D
			) { ... }
			method get-all-cookies ( Base:D $base --> HTTP::Request:D ) { ... }
			method get-named-cookie (
					Base:D $base,
					Str:D $name
					--> HTTP::Request:D
			) { ... }
			
			method add-cookie ( Base:D $base --> HTTP::Request:D ) { ... }
			method delete-cookie (
					Base:D $base,
					Str:D $name
					--> HTTP::Request:D
			) { ... }
			method delete-all-cookies ( Base:D $base --> HTTP::Request:D ) { ... }
			method perform-actions ( Base:D $base --> HTTP::Request:D ) { ... }
			method release-actions ( Base:D $base --> HTTP::Request:D ) { ... }
			method dismiss-alert ( Base:D $base --> HTTP::Request:D ) { ... }
			method accept-alert ( Base:D $base --> HTTP::Request:D ) { ... }
			method get-alert-text ( Base:D $base --> HTTP::Request:D ) { ... }
			method send-alert-text ( Base:D $base --> HTTP::Request:D ) { ... }
			method take-screenshot ( Base:D $base --> HTTP::Request:D ) { ... }

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

			method print-page ( Base:D $base, %args --> HTTP::Request:D ) { ... }
		}
		
		role Element-Request {
			method find-sub-element (
					Base:D $base,
					By:D $locator
					--> HTTP::Request:D
			) { ... }
			method find-sub-elements (
					Base:D $base,
					By:D $locator
					--> HTTP::Request:D
			) { ... }
			
			method get-element-shadow-root ( Base:D $base --> HTTP::Request:D ) { ... }
			
			method is-element-selected ( Base:D $base --> HTTP::Request:D ) { ... }
			method get-element-attribute (
					Base:D $base,
					Str:D $name
					--> HTTP::Request:D
			) { ... }
			method get-element-property (
					Base:D $base,
					Str:D $name
					--> HTTP::Request:D
			) { ... }
			method get-element-css-value (
					Base:D $base,
					Str:D $name
					--> HTTP::Request:D
			) { ... }
			method get-element-text ( Base:D $base --> HTTP::Request:D ) { ... }
			method get-element-tag-name ( Base:D $base --> HTTP::Request:D ) { ... }
			method get-element-rect ( Base:D $base --> HTTP::Request:D ) { ... }
			method is-element-enabled ( Base:D $base --> HTTP::Request:D ) { ... }
			method get-computed-role ( Base:D $base --> HTTP::Request:D ) { ... }
			method get-computed-label ( Base:D $base --> HTTP::Request:D ) { ... }
			method element-click ( Base:D $base --> HTTP::Request:D ) { ... }
			method element-clear ( Base:D $base --> HTTP::Request:D ) { ... }
			method element-send-keys (
					Base:D $base,
					Str:D $text
					--> HTTP::Request:D
			) { ... }
			method take-element-screenshot ( Base:D $base --> HTTP::Request:D ) { ... }
		}
		
		role Shadow-Request {
			method find-sub-shadow-element (
					WD2P::Shadow-Root:D $shadow
					--> HTTP::Request:D
			) { ... }
			method find-sub-shadow-elements (
					WD2P::Shadow-Root:D $shadow
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
			
			method status ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'status'
			}
			
			method new-session ( Base:D $base, %capabilities --> HTTP::Request:D ) {
				$base.post-request: %capabilities, 'session';
			}
			
			# SESSION REQUESTS
			
			method delete-session ( Base:D $base --> HTTP::Request:D ) {
				$base.delete-request;
			}
			
			method get-timeouts ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'timeouts';
			}
			
			method set-timeouts (
					Base:D $base,
					Int :$script,
					Int :$pageLoad,
					Int :$implicit
					--> HTTP::Request:D
			) {
				$base.post-request: {
					:$script,
					:$pageLoad,
					:$implicit
				}, 'timeouts';
			}
			
			method navigate-to ( Base:D $base, Str:D $url --> HTTP::Request:D ) {
				$base.post-request: { :$url }, 'url';
			}
			
			method get-current-url ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'url';
			}
			
			method back ( Base:D $base --> HTTP::Request:D ) {
				$base.post-request: { }, 'back';
			}
			
			method forward ( Base:D $base --> HTTP::Request:D ) {
				$base.post-request: { }, 'forward';
			}
			
			method refresh ( Base:D $base --> HTTP::Request:D ) {
				$base.post-request: { }, 'refresh';
			}
			
			method get-title ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'title';
			}
			
			method get-window-handle ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'window';
			}
			
			method close-window ( Base:D $base --> HTTP::Request:D ) {
				$base.delete-request: 'window';
			}
			
			method switch-to-window ( Base:D $base, Str:D $handle --> HTTP::Request:D ) {
				$base.post-request: { :$handle }, 'window';
			}
			
			method get-window-handles ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: <window handles>;
			}
			
			method new-window (
					Base:D $base,
					Str:D $type? where <tab window>.any
					--> HTTP::Request:D
			) {
				$base.post-request: { 'type hint' => 'tab' }, <window new>;
			}
			
			multi method switch-to-frame ( Base:D $base --> HTTP::Request:D ) {
				$base.post-request: { }, 'frame';
			}
			
			multi method switch-to-frame ( Base:D $base, Int $id --> HTTP::Request:D ) {
				$base.post-request: { :$id }, 'frame';
			}
			multi method switch-to-frame (
					Base:D $base,
					Str:D $element-id
					--> HTTP::Request:D
			) {
				$base.post-request: { id => $element-id }, 'frame';
			}
			
			method switch-to-parent-frame ( Base:D $base --> HTTP::Request:D ) {
				$base.post-request: { }, <frame parent>;
			}
			
			method get-window-rect ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: <window rect>;
			}
			
			method set-window-rect (
					Base:D $base,
					Int :$width,
					Int :$height,
					Int :$x,
					Int :$y
					--> HTTP::Request:D
			) {
				$base.post-request: { :$width, :$height, :$x, :$y }, <window rect>;
			}
			
			method maximize-window ( Base:D $base --> HTTP::Request:D ) {
				$base.post-request: { }, <window maximize>;
			}
			
			method minimize-window ( Base:D $base --> HTTP::Request:D ) {
				$base.post-request: { }, <window minimize>;
			}
			
			method fullscreen-window ( Base:D $base --> HTTP::Request:D ) {
				$base.post-request: { }, <window fullscreen>;
			}
			
			method get-active-element ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: <element active>;
			}
			
			method find-element (
					Base:D $base,
					By:D $locator
					--> HTTP::Request:D
			) {
				$base.post-request: $locator.args, 'element';
			}
			
			method find-elements (
					Base:D $base,
					By:D $locator
					--> HTTP::Request:D
			) {
				$base.post-request: $locator.args, 'elements';
			}
			
			
			
			method get-page-source ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'source';
			}
			
			method execute-script (
					Base:D $base,
					Str:D $script,
					*@args --> HTTP::Request:D
			) {
				$base.post-request: { :$script, :@args }, <execute sync>;
			}
			
			method execute-async-script (
					Base:D $base,
					Str:D $script,
					*@args --> HTTP::Request:D
			) {
				$base.post-request: { :$script, :@args }, <execute async>;
			}
			
			method get-all-cookies ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'cookie';
			}
			
			method get-named-cookie (
					Base:D $base,
					Str:D $name
					--> HTTP::Request:D
			) {
				$base.get-request: 'cookie', $name;
			}
			
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
			method add-cookie (
					Base:D $base,
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
				$base.post-request: { cookie => %args }, 'cookie';
			}
			
			method delete-cookie ( Base:D $base, Str:D $name --> HTTP::Request:D ) {
				$base.delete-request: 'cookie', $name;
			}
			
			method delete-all-cookies ( Base:D $base --> HTTP::Request:D ) {
				$base.delete-request: 'cookie';
			}
			
			method perform-actions ( Base:D $base --> HTTP::Request:D ) {
				!!! 'nyi'
			}
			
			method release-actions ( Base:D $base --> HTTP::Request:D ) {
				!!! 'nyi'
			}
			
			method dismiss-alert ( Base:D $base --> HTTP::Request:D ) {
				$base.post-request: { }, <alert dismiss>;
			}
			
			method accept-alert ( Base:D $base --> HTTP::Request:D ) {
				$base.post-request: { }, <alert accept>;
			}
			
			method get-alert-text ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: <alert text>;
			}
			
			method send-alert-text ( Str:D $text, Base:D $base --> HTTP::Request:D ) {
				$base.post-request: { :$text }, <alert text>;
			}
			
			method take-screenshot ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'screenshot';
			}
			
			method print-page (
					Base:D $base,
					Str:D $orientation where <portrait landscape>.any = 'portrait'
					--> HTTP::Request:D
			) {
				$base.post-request: { :$orientation }, 'print';
			}
			
			# XXX : ELEMENT REQUESTS
			
			method find-sub-element (
					Base:D $base,
					By:D $locator
					--> HTTP::Request:D
			) {
				$base.post-request: $locator.args, 'element';
			}
			
			method find-sub-elements (
					Base:D $base,
					By:D $locator
					--> HTTP::Request:D
			) {
				$base.post-request: $locator.args, 'elements';
			}
			
			
			
			method get-element-shadow-root ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'shadow';
			}
					
			method is-element-selected ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'selected';
			}
			
			method get-element-attribute (
					Base:D $base,
					Str:D $name
					--> HTTP::Request:D
			) {
				$base.get-request: 'attribute', $name;
			}
			
			method get-element-property (
					Base:D $base,
					Str:D $name
					--> HTTP::Request:D
			) {
				$base.get-request: 'property', $name;
			}
			
			method get-element-css-value (
					Base:D $base,
					$property-name
					--> HTTP::Request:D
			) {
				$base.get-request: 'css', $property-name;
			}
			
			method get-element-text ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'text';
			}
			
			method get-element-tag-name ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'name';
			}
			
			method get-element-rect ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'rect';
			}
			
			method is-element-enabled ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'enabled';
			}
			
			method get-computed-role ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'computedrole';
			}
			
			method get-computed-label ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'computedlabel';
			}
			
			method element-click ( Base:D $base --> HTTP::Request:D ) {
				$base.post-request: { }, 'click';
			}
			
			method element-clear ( Base:D $base --> HTTP::Request:D ) {
				$base.post-request: { }, 'clear';
			}
			
			method element-send-keys (
					Base:D $base,
					Str:D $text
					--> HTTP::Request:D
			) {
				$base.post-request: { :$text }, 'value';
			}

			multi method switch-to-frame (
					Base:D $base,
					Str:D $base-id
					--> HTTP::Request:D
			) {
				$base.post-request: { id => $base-id }, 'frame';
			}
			
			method take-element-screenshot ( Base:D $base --> HTTP::Request:D ) {
				$base.get-request: 'screenshot';
			}
			
			# SHADOW REQUESTS
			
			method find-sub-shadow-element (
					Base:D $base,
					By:D $locator
					--> HTTP::Request:D
			) {
				$base.post-request: $locator.args, 'element';
			}
			
			method find-sub-shadow-elements (
					Base:D $base,
					By:D $locator
					--> HTTP::Request:D
			) {
				$base.post-request: $locator.args, 'elements';
			}
		}
	}
	
	use WebDriver2::Command::Result;
	use WebDriver2::Command::Execution-Status;
	
	role Result does WebDriver2::Test::Debugging {
		use JSON::Fast;
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
										data => $data<value><data> // { }
										;
		}
		
		# DRIVER RESULTS
		
		method status ( HTTP::Response:D $response ) { ... }
		method new-session ( HTTP::Response:D $response --> Session:D ) { ... }
		
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
	
	class Result::Default does Result {
		use JSON::Fast;
		
		# DRIVER RESULTS
		
		=begin comment
		
		my $data = try self.check-status // Nil;
		
		with try self.check-status: $response -> $data {
			
		} else {
			$!; # holds exception
		}
		
		=end comment
		
		method status ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method new-session ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		
		# SESSION RESULTS
		
		method delete-session ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-timeouts ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method set-timeouts ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method navigate-to ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-current-url ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method back ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method forward ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method refresh ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-title ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-window-handle ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method close-window ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method switch-to-window ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-window-handles ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method new-window ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method switch-to-frame ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method switch-to-parent-frame ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-window-rect ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method set-window-rect ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method maxamize-window ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method minimize-window ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method fullscreen-window ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-active-element ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method find-element ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method find-elements ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-page-source ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		#| multiple return types
		method execute-script ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		#| multiple return types
		method execute-async-script ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-all-cookies ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}

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
		method get-named-cookie ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method add-cookie ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method delete-cookie ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method delete-all-cookies ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method perform-actions ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method release-actions ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method dismiss-alert ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method accept-alert ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-alert-text ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method send-alert-text ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method take-screenshot ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method print-page ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		
		# ELEMENT RESULTS
		
		method find-sub-element ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method find-sub-elements ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-element-shadow-root ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method is-element-selected ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-element-attribute ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		#| multiple return types
		method get-element-property ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		#| generally JSON Strings but check WebDriver spec; can be undef
		method get-element-css-value ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-element-text ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-element-tag-name ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-element-rect ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method is-element-enabled ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-computed-role ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method get-computed-label ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method element-click ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method element-clear ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method element-send-keys ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method take-element-screenshot ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		
		# SHADOW RESULTS
		
		method find-sub-shadow-element ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
		method find-sub-shadow-elements ( HTTP::Response:D $response ) {
			.<value> with self.check-status: $response;
		}
	}
	
	class Result::Chromium is Result::Default {
		
	}
	
	class Result::Chrome is Result::Chromium {
		
	}
	
	class Result::Edge is Result::Chromium {
		
	}
	
	role Context {
		method find-element ( By:D $locator --> Element:D ) { ... }
		method find-elements ( By:D $locator --> List:D[ Element:D ] ) { ... }
		# method switch-to-parent-frame ( --> Bool:D ) { ... }
	}
	role Screenshotable {
		method take-screenshot ( --> Str:D ) { ... }
	}
	
	my constant $ELEMENT-IDENTIFIER = 'element-6066-11e4-a52e-4f735466cecf';
	my constant $SHADOW-IDENTIFIER = 'shadow-6066-11e4-a52e-4f735466cecf';
	
	role Shadow-Root does Context {
		has Str:D $!host is built is required;
		has Int:D $!port is built is required;
		has Session:D $!session is built is required;
		has Str:D $!shadow-id is built is required;
		has Request::Shadow-Request $!request is built is required;
		has Result $!result is built is required;
		
		method find-sub-shadow-element ( By:D $locator --> Element:D ) {
			my $data = $!result.find-sub-shadow-element:
					$ua.request: $!request.find-sub-shadow-element: self, $locator;
			Element.new:
					:$!host,
					:$!port,
					session => self,
					element-id => $data{ $ELEMENT-IDENTIFIER },
					:$!request,
					:$!result
					;
		}
		method find-sub-shadow-elements ( By:D $locator --> List:D[ Element:D ] ) {
			my $data = $!result.find-sub-shadow-elements:
					$ua.request: $!request.find-sub-shadow-elements: self, $locator;
			my Element:D @elements = Array[ Element:D ].new;
			for $data>>.{ $ELEMENT-IDENTIFIER } -> $element-id {
				@elements.push:
						Element.new:
								:$!host,
								:$!port,
								session => self,
								:$element-id,
								:$!request,
								:$!result
						;
			}
			@elements;
		}
		method find-element ( By:D $locator --> Element:D ) {
			self.find-sub-shadow-element: $locator;
		}
		method find-elements ( By:D $locator --> List:D[ Element:D ] ) {
			self.find-sub-shadow-elements: $locator;
		}
	}
	
	role Element does Request::Base does Context does Screenshotable {
		has Str:D $.host is built is required;
		has Int:D $.port is built is required;
		has Session:D $!session is built is required;
		has Str:D $!element-id is built is required;
		has Request::Element-Request $!request is built is required;
		has Result $!result is built is required;
		
		method command ( *@command --> Positional:D ) {
			$!session.command: 'element', $!element-id, @command;
		}
		
		method find-sub-element ( By:D $locator --> Element:D ) {
			my $data = $!result.find-sub-element:
					$ua.request: $!request.find-sub-element: self, $locator;
			Element.new:
					session => self,
					element-id => $data{ $ELEMENT-IDENTIFIER },
					:$!request,
					:$!result
					;
		}
		method find-sub-elements ( By:D $locator --> List:D[ Element:D ] ) {
			my $data = $!result.find-sub-elements:
					$ua.request: $!request.find-sub-elements: self, $locator;
			my Element:D @elements = Array[ Element:D ].new;
			for $data>>.{ $ELEMENT-IDENTIFIER } -> $element-id {
				@elements.push:
						Element.new:
								:$!host,
								:$!port,
								session => self,
								:$element-id,
								:$!request,
								:$!result
						;
			}
			@elements;
		}
		method find-element ( By:D $locator --> Element:D ) {
			self.find-sub-element: $locator;
		}
		method find-elements ( By:D $locator --> Element:D ) {
			self.find-sub-elements: $locator;
		}
		method get-element-shadow-root ( --> Shadow-Root:D ) {
			my $data = $!result.get-element-shadow-root:
					$ua.request: $!request.get-element-shadow-root: self;
			Shadow-Root.new:
					:$!host,
					:$!port,
					:$!session,
					shadow-id => $data{ $SHADOW-IDENTIFIER },
					:$!request,
					:$!result
					;
		}
		
		method is-element-selected ( --> Bool:D ) {
			$!result.is-element-selected:
					$ua.request: $!request.is-element-selected: self;
		}
		method selected ( --> Bool:D ) {
			self.is-element-selected;
		}
		method get-element-attribute ( Str:D $name --> Str:D ) {
			$!result.get-element-attribute:
					$ua.request: $!request.get-element-attribute: self, $name;
		}
		method attribute ( Str:D $name --> Str:D ) {
			self.get-element-attribute: $name;
		}
		method get-element-property ( Str:D $name --> Str:D ) {
			$!result.get-element-property:
					$ua.request: $!request.get-element-property: self, $name;
		}
		method property ( Str:D $name --> Str:D ) {
			self.get-element-property: $name;
		}
		method get-element-css-value ( Str:D $name --> Str:D ) {
			$!result.get-element-css-value:
					$ua.request: $!request.get-element-css-value: self, $name;
		}
		method css-value ( Str:D $name --> Str:D ) {
			self.get-element-css-value;
		}
		method get-element-text ( --> Str:D ) {
			$!result.get-element-text:
					$ua.request: $!request.get-element-text: self;
		}
		method text ( --> Str:D ) {
			self.get-element-text;
		}
		method get-element-tag-name ( --> Str:D ) {
			$!result.get-element-tag-name:
					$ua.request: $!request.get-element-tag-name: self;
		}
		method tag-name ( --> Str:D ) {
			self.get-element-tag-name;
		}
		method get-element-rect {
			$!result.get-element-rect:
					$ua.request: $!request.get-element-rect: self;
		}
		method is-element-enabled ( --> Bool:D ) {
			$!result.is-element-enabled:
					$ua.request: $!request.is-element-enabled: self;
		}
		method enabled ( --> Bool:D ) {
			self.is-element-enabled;
		}
		method get-computed-role ( --> Str:D ) {
			$!result.get-computed-role:
					$ua.request: $!request.get-computed-role: self;
		}
		method get-computed-label ( --> Str:D ) {
			$!result.get-computed-label:
					$ua.request: $!request.get-computed-label: self;
		}
		method element-click ( --> Element:D ) {
			$!result.element-click: $ua.request: $!request.element-click: self;
			self;
		}
		method click ( --> Element:D ) {
			self.element-click;
		}
		method element-clear ( --> Element:D ) {
			$!result.element-clear: $ua.request: $!request.element-clear: self;
			self;
		}
		method clear ( --> Element:D ) {
			self.element-clear;
		}
		method element-send-keys ( Str:D $text -->Element:D ) {
			$!result.element-send-keys:
					$ua.request: $!request.element-send-keys: self, $text;
			self;
		}
		method send-keys ( Str:D $text --> Element:D ) {
			self.element-send-keys: $text;
		}
		
		method switch-to-frame ( --> Element:D ) {
			$!result.switch-to-frame: $ua.request: $!request.switch-to-frame: self;
			self;
		}
		method take-element-screenshot ( --> Str:D ) {
			$!result.take-element-screenshot:
					$ua.request: $!request.take-element-screenshot: self;
		}
		method take-screenshot ( --> Str:D ) {
			self.take-element-screenshot;
		}
	}
	
	role Session does Request::Base does Context does Screenshotable {
		has Str:D $.host is required;
		has Int:D $.port is required;
		# has Str:D $.browser is required;
		has Str:D $!id is built is required;
		has Request::Session-Request $!request is built is required;
		has Result $!result is built is required;
		
		method command ( *@command --> Positional:D ) {
			'session', $!id, |@command
		}
		
		method delete-session { ... }
		
		method get-timeouts { ... }
		
		method set-timeouts (
					Session:D $session,
					Int :$script,
					Int :$pageLoad,
					Int :$implicit
					--> Session:D
		) { ... }
		
		method navigate-to ( Str:D $url --> Session:D ) { ... }
		method get-current-url ( --> Str:D ) { ... }
		method back ( --> Session:D ) { ... }
		method forward ( --> Session:D ) { ... }
		method refresh ( --> Session:D ) { ... }
		method get-title ( --> Str:D ) { ... }
		method get-window-handle ( --> Str:D ) { ... }
		method close-window ( --> Session:D ) { ... }
		method switch-to-window ( Str:D $handle --> Session:D ) { ... }
		method get-window-handles ( --> List:D[ Str:D ] ) { ... }
		method new-window ( Str:D $type? where <tab window>.any ) { ... }
		multi method switch-to-frame ( Session:D $session --> Session:D ) { ... }
		multi method switch-to-frame ( Int $frame --> Session:D ) { ... }
		multi method switch-to-frame ( Str:D $element-id --> Session:D ) { ... }
		method switch-to-parent-frame ( --> Session:D ) { ... }
		method get-window-rect { ... }
		method set-window-rect (
				Int :$width,
				Int :$height,
				Int :$x,
				Int :$y
				--> Session:D
		) { ... }
		method maximize-window ( --> Session:D ) { ... }
		method minimize-window ( --> Session:D ) { ... }
		method fullscreen-window ( --> Session:D ) { ... }
		method get-active-element ( --> Element:D ) { ... }
		
		method find-element ( By:D $locator --> Element:D ) { ... }
		method find-elements ( By:D $locator --> List:D[ Element:D ] ) { ... }
		
		method get-page-source ( --> Str:D ) { ... }
		method execute-script (
				Str:D $script,
				*@args
				--> HTTP::Request:D
		) { ... }
		method execute-async-script (
				Str:D $script,
				*@args
				--> HTTP::Request:D
		) { ... }
		method get-all-cookies ( --> List:D ) { ... }
		method get-named-cookie ( Str:D $name ) { ... }
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
		method add-cookie (
				Str:D $name,
				Str:D $value,
				Str:D $path?,
				Str:D $domain?,
				Bool:D $secure?,
				Bool:D $httpOnly?,
				Int:D $expiry?,
				Bool:D $sameSite?
				--> Session:D
		) { ... }
		method delete-cookie ( Str:D $name --> Session:D ) { ... }
		method delete-all-cookies ( --> Session:D ) { ... }
		method perform-actions ( --> Session:D ) { ... }
		method release-actions ( --> Session:D ) { ... }
		method dismiss-alert ( --> Session:D ) { ... }
		method accept-alert ( --> Session:D ) { ... }
		method get-alert-text ( --> Str:D ) { ... }
		method send-alert-text ( Str:D $text --> Session:D ) { ... }
		method take-screenshot ( --> Str:D ) { ... }
		
		=begin table
			Property       | JSON Key    | Value Type and Valid Values
			==========================================================
			orientation    | orientation | Str : { ... }
			==========================================================
			scale          | scale       | Rat : [ 0.1, 2 ] ( default : 1 )
			==========================================================
			background     | background  | Bool : ( default : False )
			==========================================================
			pageWidth      | width       | Rat : [ 2.54 / 72, Inf ) ( default : 21.59 )
			==========================================================
			pageHeight     | height      | Rat : [ 2.54 / 72, Inf ) ( default : 27.94 )
			==========================================================
			margin         | margin      | JSON Obj : ( default : { ... } )
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
		method print-page ( %args --> Str:D ) { ... }
	}
	
	class Session::Default does Session {
		
		method delete-session {
			$!result.delete-session: $ua.request: $!request.delete-session: self;
			self;
		}
		
		method get-timeouts {
			$!result.get-timeouts: $ua.request: $!request.get-timeouts: self;
		}
		
		method set-timeouts (
					Session:D $session,
					Int :$script,
					Int :$pageLoad,
					Int :$implicit
					--> Session:D
		) {
			my %args = grep *.value.defined, ( :$script, :$pageLoad, :$implicit );
			$!result.get-timeouts: $ua.request: $!request.set-timeouts: %args, self;
			self;
		}
		
		method navigate-to ( Str:D $url --> Session:D ) {
			$!result.navigate-to: $ua.request: $!request.navigate-to: self, $url;
			self;
		}
		method get-current-url ( --> Str:D ) {
			$!result.get-current-url: $ua.request: $!request.get-current-url: self;
		}
		method back ( --> Session:D ) {
			$!result.back: $ua.request: $!request.back: self;
			self;
		}
		method forward ( --> Session:D ) {
			$!result.backforward: $ua.request: $!request.forward: self;
			self;
		}
		method refresh ( --> Session:D ) {
			$!result.refresh: $ua.request: $!request.refresh: self;
			self;
		}
		method get-title ( --> Str:D ) {
			$!result.title: $ua.request: $!request.title: self;
		}
		method get-window-handle ( --> Str:D ) {
			$!result.get-window-handle: $ua.request: $!request.get-window-handle: self;
		}
		method close-window ( --> Session:D ) {
			$!result.close-window: $ua.request: $!request.close-window: self;
			self;
		}
		method switch-to-window ( Str:D $handle --> Session:D ) {
			$!result.switch-to-window:
					$ua.request: $!request.switch-to-window: $handle, self;
			self;
		}
		method get-window-handles ( --> List:D[ Str:D ] ) {
			$!result.get-window-handles: $ua.request: $!request.get-window-handles: self;
		}
		method new-window ( Str:D $type? where <tab window>.any ) {
			my %args = grep *.value.defined: ( :$type );
			$!result.new-window: $ua.request: %args, $!request.close-window: self;
		}
		multi method switch-to-frame ( Session:D $session --> Session:D ) {
			$!result.switch-to-frame: $ua.request: $!request.switch-to-frame: self;
			self;
		}
		multi method switch-to-frame ( Int $frame --> Session:D ) {
			$!result.switch-to-frame:
					$ua.request: $!request.switch-to-frame: $frame, self;
			self;
		}
		multi method switch-to-frame ( Str:D $element-id --> Session:D ) {
			$!result.switch-to-frame:
					$ua.request: $!request.switch-to-frame: $element-id, self;
			self;
		}
		method switch-to-parent-frame ( --> Session:D ) {
			$!result.switch-to-parent-frame:
					$ua.request: $!request.switch-to-parent-frame: self;
			self;
		}
		method get-window-rect {
			$!result.get-window-rect: $ua.request: $!request.get-window-rect: self;
		}
		method set-window-rect (
				Int :$width,
				Int :$height,
				Int :$x,
				Int :$y
				--> Session:D
		) {
			my %args = grep *.value.defined, ( :$width, :$height, :$x, :$y );
			$!result.set-window-rect: $ua.request: $!request.set-window-rect: self, %args;
			self;
		}
		method maximize-window ( --> Session:D ) {
			$!result.maxamize-window: $ua.request: $!request.maxamize-window: self;
			self;
		}
		method minimize-window ( --> Session:D ) {
			$!result.minimize-window: $ua.request: $!request.minimize-window: self;
			self;
		}
		method fullscreen-window ( --> Session:D ) {
			$!result.fullscreen-window: $ua.request: $!request.fullscreen-window: self;
			self;
		}
		method get-active-element ( --> Element:D ) {
			my $data = $!result.get-active-element: $ua.request: $!request.get-active-element: self;
			Element.new:
					:$!host,
					:$!port,
					session => self,
					element-id => $data{ $ELEMENT-IDENTIFIER },
					:$!request,
					:$!result
					;
		}
		
		method find-element ( By:D $locator --> Element:D ) {
			my $data = $!result.find-element:
					$ua.request: $!request.find-element: self, $locator;
			Element.new:
					:$!host,
					:$!port,
					session => self,
					element-id => $data{ $ELEMENT-IDENTIFIER },
					:$!request,
					:$!result
					;
		}
		method find-elements ( By:D $locator --> List:D[ Element:D ] ) {
			my $data = $!result.find-elements:
					$ua.request: $!request.find-elements: self, $locator;
			my Element:D @elements = Array[ Element:D ].new;
			for $data>>.{ $ELEMENT-IDENTIFIER } -> $element-id {
				@elements.push:
						Element.new:
								:$!host,
								:$!port,
								session => self,
								:$element-id,
								:$!request,
								:$!result
						;
			}
			@elements;
		}
		
		method get-page-source ( --> Str:D ) {
			$!result.get-page-source: $ua.request: $!request.get-page-source: self;
		}
		method execute-script (
				Str:D $script,
				*@args
		) {
			$!result.execute-script:
					$ua.request: $!request.execute-script: self, $script, @args;
		}
		method execute-async-script (
				Str:D $script,
				*@args
		) {
			$!result.execute-async-script:
					$ua.request: $!request.execute-async-script: self, $script, @args;
		}
		method get-all-cookies ( --> List:D ) {
			my $data = $!result.get-all-cookies: $ua.request: $!request.get-all-cookies: self;
			Array.new: |$data;
		}
		method get-named-cookie ( Str:D $name ) {
			$!result.get-named-cookie:
					$ua.request: $!request.get-named-cookie: self, $name;
		}
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
		method add-cookie (
				Str:D $name,
				Str:D $value,
				Str:D $path?,
				Str:D $domain?,
				Bool:D $secure?,
				Bool:D $httpOnly?,
				Int:D $expiry?,
				Bool:D $sameSite?
				--> Session:D
		) {
			my %args = grep *.value.defined, (
					:$name,
					:$value,
					:$path,
					:$domain,
					:$secure,
					:$httpOnly,
					:$expiry,
					:$sameSite
			);
			$!result.add-cookie: $ua.request: $!request.add-cookie: self, %args;
			self;
		}
		method delete-cookie ( Str:D $name --> Session:D ) {
			$!result.delete-cookie: $ua.request: $!request.delete-cookie: self, $name;
			self;
		}
		method delete-all-cookies ( --> Session:D ) {
			$!result.delete-all-cookies: $ua.request: $!request.delete-all-cookies: self;
			self;
		}
		method perform-actions ( --> Session:D ) {
			!!! 'nyi'
		}
		method release-actions ( --> Session:D ) {
			!!! 'nyi'
		}
		method dismiss-alert ( --> Session:D ) {
			$!result.dismiss-alert: $ua.request: $!request.dismiss-alert: self;
			self;
		}
		method accept-alert ( --> Session:D ) {
			$!result.accept-alert: $ua.request: $!request.accept-alert: self;
			self;
		}
		method get-alert-text ( --> Str:D ) {
			$!result.get-alert-text: $ua.request: $!request.get-alert-text: self;
		}
		method send-alert-text ( Str:D $text --> Session:D ) {
			$!result.send-alert-text: $ua.request: $!request.send-alert-text: self, $text;
			self;
		}
		method take-screenshot ( --> Str:D ) {
			$!result.take-screenshot: $ua.request: $!request.take-screenshot: self;
		}
		
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
		method print-page ( %args --> Str:D ) {
			$!result.print-page: $ua.request: $!request.print-page: self, %args;
		}
	}
	
	role Driver does Request::Base {
		has Request::Driver-Request $!request is built is required;
		has Result $!result is built is required;
		
		has Str:D $.host is required = '127.0.0.1';
		has Int:D $.port is required;
		has Str:D $.browser is required;
		
		method start { }
		
		method new-session ( %capabilities --> WD2P::Session:D ) { ... }
		method status ( --> WD2P::Status:D ) { ... }
		
		method stop { }
	}
	
	class Driver::Chrome does Driver {
		method new (
				Str:D $host = '127.0.0.1',
				Int:D $port = 9515
		) {
			self.bless:
					browser => 'chrome',
					request => Request::Default,
					result => Result::Chrome,
					:$host,
					:$port,
					;
		}
		
		multi method new-session ( %capabilities --> Session:D ) {
			# my $result = $ua.request: $!request.new-session: self, %capabilities;
			# $result.raku.say;
			# my $data = $!result.new-session: $result;
			my $data = $!result.new-session:
					$ua.request: $!request.new-session: self, %capabilities;
			return
			Session::Default.new:
					:$!host,
					:$!port,
					id => .<sessionId>, # also includes <capabilities>
					:$!request,
					:$!result
			with $data;
			$data.throw;
		}
		
		multi method new-session ( --> Session:D ) {
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
			$!result.status: $ua.request: $!request.status: self;
		}
	}
	
	class Driver::Edge does Driver {
		method new (
				Str:D $host = '127.0.0.1';
				Int:D $port = 9515
		) {
			self.bless:
					browser => 'edge';
					param => Param::Edge,
					result => Result::Edge,
					:$host,
					:$port,
					;
		}
		
		#| returns { :$ready, :$message }
		method status {
			$!result.status: $ua.request: $!request.status: self;
		}
		
		multi method new-session ( %capabilities --> Session:D ) {
			$!result.new-session: $ua.request: $!request.new-session: self, %capabilities;
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
	
	=begin comment
	class Frame is Element {
		
	}
	
	class Page is Frame {
		
		method status {
			$!result.status: $ua.request: $!request.status;
		}
	}
	=end comment
	
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
			Int :$port?
			--> WD2P::Driver:D
	) {
		my %args = :$host;
		%args<port> = $port if $port;
		%driver{ $browser }
		// %driver{ $browser } = %driver{ $browser }.new: |%args;
	}
}
=end comment

use WebDriver2::Command::Result;

module WD2E {
	role Command {
		method url ( *@command --> Str:D ) { ... }
	}
	class Driver does Command {
		has Str:D $.host is required = '127.0.0.1';
		has Int:D $.port is required;
		method url ( *@command --> Str:D ) {
			join '/', "http://$!host:$!port", |@command;
		}
	}
	class Session does Command {
		has Driver:D $.driver is required;
		has Str:D $.session-id is required;
		method url ( *@command --> Str:D ) {
			$!driver.url: 'session', $!session-id, @command;
		}
	}
	class Element does Command {
		our constant $IDENTIFIER = 'element-6066-11e4-a52e-4f735466cecf';
		has Session:D $.session is required;
		has Str:D $.element-id is required;
		method url ( *@command --> Str:D ) {
			$!session.url: 'element', $!element-id, @command;
		}
	}
	class Shadow-Root does Command {
		our constant $IDENTIFIER = 'shadow-6066-11e4-a52e-4f735466cecf';
		has Session:D $.session is required;
		has Str:D $.shadow-id is required;
		method url ( *@command --> Str:D ) {
			$!session.url: 'shadow', $!shadow-id, @command;
		}
	}
	role By {
		has Str:D $.value is built is required;
		method using ( --> Str:D ) { ... }
		method value ( Str:D $value ) { self.bless: :$value }
		method args ( --> Hash:D[ Str:D ] ) {
			{ :$.using, :$!value }
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
	module Endpoint {
		# include debugging
		use HTTP::UserAgent;
		use JSON::Fast;
		
		my HTTP::UserAgent $ua = HTTP::UserAgent.new;
		
		sub request ( Str:D $method, WD2E::Command:D $command, *@command --> HTTP::Request:D ) {
			my Str:D $url = $command.url: @command;
			given $method {
				when 'GET' { return HTTP::Request.new: GET => $url }
				when 'POST' { return HTTP::Request.new: POST => $url }
				when 'DELETE' { return HTTP::Request.new: DELETE => $url }
			}
		}
		sub get-request ( WD2E::Command:D $command, *@command --> HTTP::Request:D ) {
			request 'GET', $command, @command;
		}
		sub post-request ( $data, WD2E::Command:D $command, *@command --> HTTP::Request:D ) {
			my HTTP::Request $req = request 'POST', $command, @command;
			my Str:D $json = to-json $data;
			# debug: Level::extra, $json;
			$req.add-content: $json;
			$req;
		}
		sub delete-request ( WD2E::Command:D $command, *@command --> HTTP::Request:D ) {
			request 'DELETE', $command, @command;
		}
		
		sub check-status ( HTTP::Response $response ) {
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
										data => $data<value><data> // { }
										;
		}
		
		class Driver-Endpoints {
			method status ( WD2E::Driver:D $driver ) {
				my $data = check-status $ua.request: get-request $driver, 'status';
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			method new-session ( %capabilities, WD2E::Driver:D $driver --> WD2E::Session:D ) {
				%capabilities<capabilities> = { } unless %capabilities and %capabilities<capabilities>.isa: Hash;
				my $data = check-status
					$ua.request: post-request %capabilities, $driver, 'session';
				return WD2E::Session.new:
						:$driver,
						session-id => .<value><sessionId>
				with $data;
				$data.handled = False;
				$data;
			}
		}
		class Session-Endpoints is export {
			method delete ( WD2E::Session:D $session --> WD2E::Driver:D ) {
				my $data = check-status $ua.request: delete-request $session;
				return $session.driver with $data;
				$data.handled = False;
				$data;
			}
			method get-timeouts ( WD2E::Session:D $session ) {
				my $data = check-status $ua.request: get-request $session, 'timeouts';
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			method set-timeouts (
					Int $script,
					Int $pageLoad,
					Int $implicit,
					WD2E::Session:D $session
					--> WD2E::Session:D
			) {
				my $data = check-status $ua.request:
						post-request {
							:$script,
							:$pageLoad,
							:$implicit
						},
						$session,
						'timeouts'
				;
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method navigate-to ( Str:D $url, WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status $ua.request: post-request { :$url }, $session, 'url';
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method current-url( WD2E::Session:D $session --> Str:D ) {
				my $data = check-status $ua.request: get-request $session, 'url';
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			method back ( WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status $ua.request: post-request { }, $session, 'back';
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method forward ( WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status $ua.request: post-request { }, $session, 'forward';
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method refresh ( WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status $ua.request: post-request { }, $session, 'refresh';
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method title ( WD2E::Session:D $session --> Str:D ) {
				my $data = check-status $ua.request: get-request $session, 'title';
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			method get-window-handle ( WD2E::Session:D $session --> Str:D ) {
				my $data = check-status $ua.request: get-request $session, 'window';
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			method close-window ( WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status $ua.request: delete-request $session, 'window';
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method switch-to-window ( Str:D $handle, WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status 
						$ua.request: post-request { :$handle }, $session, 'window';
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method get-window-handles ( WD2E::Session:D $session --> List:D[ Str:D ] ) {
				my $data = check-status $ua.request: get-request $session, <window handles>;
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			method new-window ( Str:D $type where <tab window>.any, WD2E::Session:D $session ) {
				my %args = ();
				%args{ 'type hint' } = $type if $type;
				my $data = check-status
						$ua.request: %args, post-request $session, <window new>;
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			multi method switch-to-frame ( WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status $ua.request: post-request { }, $session, 'frame';
				return $session with $data;
				$data.handled = False;
				$data;
			}
			multi method switch-to-frame ( Int $frame, WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status 
						$ua.request: post-request { id => $frame }, $session, 'frame';
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method switch-to-parent-frame ( WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status 
						$ua.request: post-request { }, $session, <frame parent>;
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method get-window-rect ( WD2E::Session:D $session ) {
				my $data = check-status $ua.request: get-request $session, <window rect>;
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			method set-window-rect (
					Int $width,
					Int $height,
					Int $x,
					Int $y,
					WD2E::Session:D $session
					--> WD2E::Session:D
			) {
				my %args = grep *.value.defined, do :$width, :$height, :$x, :$y;
				my $data = check-status
						$ua.request: post-request %args, $session, <window rect>;
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method maximize-window ( WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status
						$ua.request: post-request { }, $session, <window maximize>;
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method minimize-window ( WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status
						$ua.request: post-request { }, $session, <window minimize>;
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method fullscreen-window ( WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status
						$ua.request: post-request { }, $session, <window fullscreen>;
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method active-element ( WD2E::Session:D $session --> WD2E::Element:D ) {
				my $data = check-status $ua.request: get-request $session, <element active>;
				return WD2E::Element.new:
						host => $session.driver.host,
						port => $session.driver.port,
						:$session,
						element-id => $data<value>{ $WD2E::Element::IDENTIFIER }
				with $data;
				$data.handled = False;
				$data;
			}
			
			method find-element ( By:D $locator, WD2E::Session:D $session --> WD2E::Element:D ) {
				my $data = check-status
						$ua.request: post-request $locator.args, $session, 'element';
				return WD2E::Element.new:
						host => $session.driver.host,
						port => $session.driver.port,
						:$session,
						element-id => $data<value>{ $WD2E::Element::IDENTIFIER }
				with $data;
				$data.handled = False;
				$data;
			}
			method find-elements (
					By:D $locator,
					WD2E::Session:D $session
					--> List:D[ WD2E::Element:D ]
			) {
				my $data = check-status
						$ua.request: post-request $locator.args, $session, 'elements';
				without $data {
					$data.handled = False;
					return $data;
				}
				my WD2E::Element:D @elements = Array[ WD2E::Element:D ].new;
				for $data<value>>>.{ $WD2E::Element::IDENTIFIER } -> $element-id {
					@elements.push:
							WD2E::Element.new:
									host => $session.driver.host,
									port => $session.driver.port,
									:$session,
									:$element-id
							;
				}
				@elements;
			}
			
			method page-source ( WD2E::Session:D $session --> Str:D ) {
				my $data = check-status $ua.request: get-request $session, 'source';
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			method execute-script (
					Str:D $script,
					@args,
					WD2E::Session:D $session
			) {
				my $data = check-status
						$ua.request:
								post-request
										{ :$script, :@args }, $session, <execute sync>;
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			method execute-async-script (
					Str:D $script,
					@args,
					WD2E::Session:D $session
			) {
				my $data = check-status
						$ua.request:
								post-request
										{ :$script, :@args }, $session, <execute async>;
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			method get-all-cookies ( WD2E::Session:D $session --> List:D ) {
				my $data = check-status $ua.request: get-request $session, 'cookie';
				return Array.new: |.<value> with $data;
				$data.handled = False;
				$data;
			}
			method get-named-cookie ( Str:D $name, WD2E::Session:D $session ) {
				my $data = check-status 
						$ua.request: get-request $session, 'cookie', $name;
				return $session with $data;
				$data.handled = False;
				$data;
			}
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
			multi method add-cookie (
					Str:D $name,
					Str:D $value,
					%cookie,
					WD2E::Session:D $session
					--> WD2E::Session:D
			) {
				my %args =
					.flat with do grep -> $k, $v { $v.defined and $k, $v },
					.flat with do :$name.kv, :$value.kv,
						%cookie<path domain secure httpOnly expiry sameSite>:kv;
				my $data = check-status
						$ua.request: post-request { cookie => %args }, $session, 'cookie';
				return $session with $data;
				$data.handled = False;
				$data;
			}
			multi method add-cookie (
					Str:D $name,
					Str:D $value,
					WD2E::Session:D $session
					--> WD2E::Session:D
			) {
				my %args = :$name, :$value;
				my $data = check-status
						$ua.request: post-request { cookie => %args }, $session, 'cookie';
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method delete-cookie ( Str:D $name, WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status
						$ua.request: delete-request $session, 'cookie', $name;
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method delete-all-cookies ( WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status $ua.request: delete-request $session, 'cookie';
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method perform-actions ( WD2E::Session:D $session --> WD2E::Session:D ) {
				!!! 'nyi'
			}
			method release-actions ( WD2E::Session:D $session --> WD2E::Session:D ) {
				!!! 'nyi'
			}
			method dismiss-alert ( WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status
						$ua.request: post-request { }, $session, <alert dismiss>;
				$data.handled = False;
				$data;
			}
			method accept-alert ( WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status
						$ua.request: post-request { }, $session, <alert accept>;
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method get-alert-text ( WD2E::Session:D $session --> Str:D ) {
				my $data = check-status $ua.request: get-request $session, <alert text>;
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			method send-alert-text ( Str:D $text, WD2E::Session:D $session --> WD2E::Session:D ) {
				my $data = check-status
						$ua.request: post-request { :$text }, $session, <alert text>;
				return $session with $data;
				$data.handled = False;
				$data;
			}
			method take-screenshot ( WD2E::Session:D $session --> Str:D ) {
				my $data = check-status $ua.request: get-request $session, 'screenshot';
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			
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
			method print-page ( %args, WD2E::Session:D $session --> Str:D ) {
				my $data = check-status $ua.request: post-request %args, $session, 'print';
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
		}
		class Element-Endpoints is export {
			method switch-to ( WD2E::Element:D $element --> WD2E::Session:D ) {
				my $data = check-status
						$ua.request:
								post-request
										{ id => $element.element-id },
										$element.session,
										'frame'
										;
				return $element.session with $data;
				$data.handled = False;
				$data;
			}
			
			method find-sub-element (
					By:D $locator,
					WD2E::Element:D $element
					--> WD2E::Element:D
			) {
				my $data = check-status
						$ua.request: post-request $locator.args, $element, 'element';
				return WD2E::Element.new:
						host => $element.session.driver.host,
						port => $element.session.driver.port,
						session => $element.session,
						element-id => $data<value>{ $WD2E::Element::IDENTIFIER }
				with $data;
				$data.handled = False;
				$data;
			}
			
			method find-sub-elements (
					By:D $locator,
					WD2E::Element:D $element
					--> List:D[ WD2E::Element:D ]
			) {
				my $data = check-status
						$ua.request: post-request $locator.args, $element, 'elements';
				without $data {
					$data.handled = False;
					return $data;
				}
				my WD2E::Element:D @elements = Array[ WD2E::Element:D ].new;
				for $data<value>>>.{ $WD2E::Element::IDENTIFIER } -> $element-id {
					@elements.push:
							WD2E::Element.new:
									host => $element.session.driver.host,
									port => $element.session.driver.port,
									session => $element.session,
									:$element-id
							;
				}
				@elements;
			}
			
			
			
			method shadow-root ( WD2E::Element:D $element --> Shadow-Root:D ) {
				my $data = check-status $ua.request: get-request $element, 'shadow';
				return Shadow-Root.new:
						host => $element.session.driver.host,
						port => $element.session.driver.port,
						session => $element.session,
						shadow-id => $data<value>{ $Shadow-Root::IDENTIFIER }
				with $data;
				$data.handled = False;
				$data;
			}
					
			method is-element-selected ( WD2E::Element:D $element --> Bool:D ) {
				my $data = check-status $ua.request: get-request $element, 'selected';
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			
			method attribute (
					Str:D $name,
					WD2E::Element:D $element
					--> Str:D
			) {
				my $data = check-status $ua.request: get-request $element, 'attribute', $name;
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			
			method property (
					Str:D $name,
					WD2E::Element:D $element
					--> Str:D
			) {
				my $data = check-status $ua.request: get-request $element, 'property', $name;
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			
			method css-value (
					Str:D $name,
					WD2E::Element:D $element
					--> Str:D
			) {
				my $data = check-status $ua.request: get-request $element, 'css', $name;
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			
			method text ( WD2E::Element:D $element --> WD2E::Element:D ) {
				my $data = check-status $ua.request: get-request $element, 'text';
				return .<value> with $data;
				$data.Str = False;
				$data;
			}
			
			method tag-name ( WD2E::Element:D $element --> Str:D ) {
				my $data = check-status $ua.request: get-request $element, 'name';
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			
			method rect ( WD2E::Element:D $element ) {
				my $data = check-status $ua.request: get-request $element, 'rect';
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			
			method is-enabled ( WD2E::Element:D $element --> Bool:D ) {
				my $data = check-status $ua.request: get-request $element, 'enabled';
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			
			method computed-role ( WD2E::Element:D $element --> Str:D ) {
				my $data = check-status $ua.request: get-request $element, 'computedrole';
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			
			method computed-label ( WD2E::Element:D $element --> Str:D ) {
				my $data = check-status $ua.request: get-request $element, 'computedlabel';
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
			
			method click ( WD2E::Element:D $element --> WD2E::Element:D ) {
				my $data = check-status $ua.request: post-request { }, $element, 'click';
				return $element with $data;
				$data.handled = False;
				$data;
			}
			
			method clear ( WD2E::Element:D $element --> WD2E::Element:D ) {
				my $data = check-status $ua.request: post-request { }, $element, 'clear';
				return $element with $data;
				$data.handled = False;
				$data;
			}
			
			method send-keys (
					Str:D $text,
					WD2E::Element:D $element
					--> WD2E::Element:D
			) {
				my $data = check-status $ua.request: post-request { :$text }, $element, 'value';
				return $element with $data;
				$data.handled = False;
				$data;
			}
			
			method take-element-screenshot ( WD2E::Element:D $element --> Str:D ) {
				my $data = check-status $ua.request: get-request $element, 'screenshot';
				return .<value> with $data;
				$data.handled = False;
				$data;
			}
		}
		class Shadow-Endpoints {
			method find-sub-shadow-element (
					By:D $locator,
					Shadow-Root:D $shadow
					--> WD2E::Element:D
			) {
				my $data = check-status
						$ua.request: post-request $locator.args, $shadow, 'element';
				return WD2E::Element.new:
						host => $shadow.session.driver.host,
						port => $shadow.session.driver.port,
						session => $shadow.session,
						element-id => $data<value>{ $WD2E::Element::IDENTIFIER }
				with $data;
				$data.handled = False;
				$data;
			}
			
			method find-sub-shadow-elements (
					By:D $locator,
					Shadow-Root:D $shadow
					--> WD2E::Element:D
			) {
				my $data = check-status
						$ua.request: post-request $locator.args, $shadow, 'elements';
				without $data {
					$data.handled = False;
					return $data;
				}
				my WD2E::Element:D @elements = Array[ WD2E::Element:D ].new;
				for $data<value>>>.{ $WD2E::Element::IDENTIFIER } -> $element-id {
					@elements.push:
							WD2E::Element.new:
									host => $shadow.session.driver.host,
									port => $shadow.session.driver.port,
									session => $shadow.session,
									:$element-id
							;
				}
				@elements;
			}
		}
	}
}

class WD2E::Driver::Provider {
	my WD2E::Driver %driver = (
		chrome => WD2E::Driver,
		edge => WD2E::Driver,
	);
	method get (
			Str:D $browser where %driver.keys.any,
			Str:D :$host = '127.0.0.1',
			Int :$port?
			--> WD2E::Driver:D
	) {
		my %args = :$host;
		%args<port> = $port if $port;
		%driver{ $browser }
		// %driver{ $browser } = %driver{ $browser }.new: |%args;
	}
}

sub EXPORT {
	Map.new:
			Driver => WD2E::Endpoint::Driver-Endpoints,
			Session => WD2E::Endpoint::Session-Endpoints,
			Element => WD2E::Endpoint::Element-Endpoints,
			Shadow => WD2E::Endpoint::Shadow-Endpoints
}

=finish


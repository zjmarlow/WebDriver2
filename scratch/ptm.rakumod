use ptma;

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
	
	role Request-Builder {
		trusts WD2P::Session;
		trusts WD2P::Driver;
		
		
	}
	
	role Driver-Param {
		method status ( --> HTTP::Request:D ) { ... }
		method new-session ( *%capabilities --> HTTP::Request:D ) { ... }
	}
	
	class Driver-Param::Chromium does Driver-Param {
		use JSON::Fast;
		method status ( --> HTTP::Request:D ) { { } }
		
		method new-session ( *%capabilities --> HTTP::Request:D ) {
			{
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
	
	role Session-Request {
		
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
	
	class Session-Param::Default does Session-Param {
		
		method delete-session ( --> HTTP::Request:D ) { { } }
		
		method get-timeouts ( --> HTTP::Request:D ) { { } }
		
		method set-timeouts (
				Int :$script,
				Int :$pageLoad,
				Int :$implicit
				--> HTTP::Request:D
		) {
			{
				:$script,
				:$pageLoad,
				:$implicit
			}
		}
		
		method navigate-to ( Str:D $url --> HTTP::Request:D ) {
			{ :$url }
		}
		
		method get-current-url ( --> HTTP::Request:D ) { { } }
		
		method back ( --> HTTP::Request:D ) { { } }
		
		method forward ( --> HTTP::Request:D ) { { } }
		
		method refresh ( --> HTTP::Request:D ) { { } }
		
		method get-title ( --> HTTP::Request:D ) { { } }
		
		method get-window-handle ( --> HTTP::Request:D ) { { } }
		
		method close-window ( --> HTTP::Request:D ) { { } }
		
		method switch-to-window ( Str:D $handle --> HTTP::Request:D ) {
			{ :$handle }
		}
		
		method get-window-handles ( --> HTTP::Request:D ) { { } }
		
		method new-window ( --> HTTP::Request:D ) {
			{ 'type hint' => 'tab' }
		}
		
		method switch-to-parent-frame ( --> HTTP::Request:D ) { { } }
		
		method get-window-rect ( --> HTTP::Request:D ) { { } }
		
		method set-window-rect (
				Int :$width,
				Int :$height,
				Int :$x,
				Int :$y
				--> HTTP::Request:D
		) {
			{ :$width, :$height, :$x, :$y }
		}
		
		method maximize-window ( --> HTTP::Request:D ) { { } }
		
		method minimize-window ( --> HTTP::Request:D ) { { } }
		
		method fullscreen-window ( --> HTTP::Request:D ) { { } }
		
		method get-active-element ( --> HTTP::Request:D ) { { } }
		
		method find-element ( By $locator --> HTTP::Request:D ) {
			$locator.args;
		}
		
		method find-elements ( By $locator --> HTTP::Request:D ) {
			$locator.args;
		}
		
		
		
		method get-page-source ( --> HTTP::Request:D ) { { } }
		
		method execute-script ( Str:D $script, *@args --> HTTP::Request:D ) {
			{ :$script, :@args }
		}
		
		method execute-async-script ( --> HTTP::Request:D ) {
			{ :$script, :@args }
		}
		
		method get-all-cookies ( --> HTTP::Request:D ) { { } }
		
		method get-named-cookie ( --> HTTP::Request:D ) { { } }
		
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
	
	role Element-Param {
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
	
	class Element-Param::Default does Element-Param {
		
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
	}
	
	role Shadow-Param {
		
		
		method find-sub-shadow-element ( Str:D $sid, Str:D $shadow-id --> HTTP::Request:D ) {
			
		}
		
		method find-sub-shadow-elements ( Str:D $sid, Str:D $shadow-id --> HTTP::Request:D ) {
			
		}
	}
	
	class Shadow-Param::Default does Shadow-Param {
		
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
	
	class Session { ... }
	
	role Driver {
		trusts WD2P::Session;
		
		has Param $!param is built is required;
		has Result $!result is built is required;
		
		has HTTP::UserAgent:D $!ua = HTTP::UserAgent.new;
		has Str:D $.host is required = '127.0.0.1';
		has Int:D $.port is required;
		has Str:D $.browser is required;
		
		
		
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
	
	class Element {
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

use WebDriver2::HTTP::UserAgent;
use WebDriver2::HTTP::Message;
use WebDriver2::HTTP::Request;
use JSON::Fast;
use URI::Encode;
use WebDriver2::Driver::Server;
use WebDriver2;
use WebDriver2::Test::Debugging;

use WebDriver2::Command;
use WebDriver2::Command::Param;
use WebDriver2::Command::Result;
use WebDriver2::Command::Param::Factory;
use WebDriver2::Command::Param::Factory::Chrome;
use WebDriver2::Command::Param::Factory::Edge;
use WebDriver2::Command::Param::Factory::Firefox;
use WebDriver2::Command::Param::Factory::Safari;
use WebDriver2::Command::Result::Factory;
use WebDriver2::Command::Result::Factory::Chrome;
use WebDriver2::Command::Result::Factory::Edge;
use WebDriver2::Command::Result::Factory::Firefox;
use WebDriver2::Command::Result::Factory::Safari;
use WebDriver2::Command::Element::Locator::Tag-Name;

use WebDriver2::Constants;

use WebDriver2::Test::Debugging;
use WebDriver2::Test::Config-From-File;

class WebDriver2::Driver
		does WebDriver2::Driver-Actions
		does WebDriver2::Test::Debugging
		does WebDriver2::Test::Config-From-File
{
	my WebDriver2::HTTP::UserAgent $ua;
	has WebDriver2::Driver::Server:D $.server is required;
#	has Level:D $.debug-level is required;
	
	has WebDriver2::Command::Param::Factory $.param = self.param-factory;
	has WebDriver2::Command::Result::Factory $.result = self.factory;
	
	my class Session { ... }
	my class Session::Internal-Element { ... }
	my class Session::Internal-Frame { ... }
	
	class Chrome { ... }
	class Edge { ... }
	class Firefox { ... }
	class Safari { ... }
	
	my WebDriver2::Driver-Actions %driver = (
			chrome => Chrome,
			edge => Edge,
			firefox => Firefox,
			safari => Safari,
	);
	method new (
			Str:D $browser is copy,
			Level:D :$debug-level = Level::WARN
			--> WebDriver2::Driver-Actions:D
	) {
		return %driver{ $browser } if %driver{ $browser };
		self.set-from-file: $browser, #`[ $.debug-level ];
		$ua ||= WebDriver2::HTTP::UserAgent.new: :$debug-level;
		%driver{ $browser } .=new: :$debug-level;
	}
#	method browser ( --> Str:D ) { ... }
	method ua ( --> WebDriver2::HTTP::UserAgent:D ) { $ua }
	
#	multi method debug {
#		$!debug-level;
#	}
#
#	multi method debug ( Level:D $debug-level ) {
#		$!debug-level = $debug-level;
#	}
	
	method param-factory( --> WebDriver2::Command::Param::Factory ) {...}
	
	method factory( --> WebDriver2::Command::Result::Factory ) {...}
	
	multi method debug ( WebDriver2::Command::PreResult $result, *@data ) {
		self.debug: Level::trace, $result.Str;
		self.debug: Level::trace, .self.Str for @data;
	}
	
	multi method debug ( WebDriver2::Command::Result $result, *@data ) {
		callsame;
		self.debug: $result.execution-status.raku;
	}
	
	method !ready( --> Bool ) {
		my WebDriver2::Command::Result::Status $status =
				WebDriver2::Command::Status.new
				.execute-with: self;
		self.debug: $status, $status.version, $status.ready;
		return $status.ready;
	}
	
	method session {
		for 1 .. 3 {
			#say 'SESSION ATTEMPT';
			.say;
			if self!ready {
				my WebDriver2::Command::Result::Session $session =
						WebDriver2::Command::Session.new
						.execute-with: self;
				self.debug: $session.value;
				self.debug: Level::trace, $session.Str;
				self.debug: Level::trace, 'SESSION RESULT', $session.raku;
				
				my Str:D $session-id = $session.value;
#				$!original-window = self.window-handle;
				
				return Session.new:
						driver => self,
						:$session-id,
						:$!debug-level
						;
#				return $!session-id;
			}
		}
	}
	
	method status {
		my WebDriver2::Command::Result::Status $status =
				WebDriver2::Command::Status.new.execute-with: self;
		self.debug: $status;
		$status;
	}
	
	method start { }
	method stop { }
	
	
	
	# TODO : keep result queue when debugging ?
	
	class Session
			does WebDriver2::Session-Actions
			does WebDriver2::Element-Actions
			does WebDriver2::Test::Debugging
	{
		trusts Internal-Element;
# 		trusts ::WebDriver2::Driver::Session::Internal-Frame;
		trusts Internal-Frame;
		
		has Str:D $!session-id is built is required;
		has Str $!original-window;
		has SetHash[Str:D] $!window-handles = SetHash[Str:D].new;
		
		has WebDriver2::Driver:D $.driver is built is required;
#		has WebDriver2::Command::Param::Factory:D $.param = self.param-factory;
#		has WebDriver2::Command::Result::Factory:D $.result = self.factory;
		has WebDriver2::Model::Frame @!frames;
		# FIXME : make private
		
		method new (
				WebDriver2::Driver:D :$driver,
				Str:D :$session-id,
				Level:D :$debug-level = Level::WARN
		) {
			my $self = self.bless:
				:$driver,
				:$session-id,
				:$debug-level
			;
			$self.window-handle;
			$self;
		}
		
		method browser ( --> Str:D ) { $!driver.browser }
		
		multi method debug ( WebDriver2::Command::PreResult $result, *@data ) {
			self.debug: Level::trace, $result.Str;
			self.debug: Level::trace, .self.Str for @data;
		}
		
		multi method debug ( WebDriver2::Command::Result $result, *@data ) {
			callsame;
			self.debug: Level::trace, $result.execution-status.raku
		}
		
		method start {}
		
		method !curr-frame( --> WebDriver2::Model::Frame ) {
			@!frames ?? @!frames[*- 1] !! WebDriver2::Model::Frame
		}
		
		method !push-frame ( WebDriver2::Model::Frame:D $frame ) {
			self.debug: "pushing $frame onto", @!frames>>.raku.join: "\n";
			@!frames.push: $frame;
		}
		method !pop-frame ( --> WebDriver2::Model::Frame ) {
			@!frames.pop;
		}
		method !clear-frames {
			@!frames = Empty;
		}
		
		method maximize-window {
			my WebDriver2::Command::Result::Maximize-Window $max-win =
					WebDriver2::Command::Maximize-Window.new.execute-with: self, $!session-id;
			self.debug: $max-win;
		}
		
		method set-window-rect( Int $width, Int $height, Int $x, Int $y ) {
			my WebDriver2::Command::Result::Set-Window-Rect $wind-rect =
					WebDriver2::Command::Set-Window-Rect.new( :$width, :$height, :$x, :$y )
					.execute-with: self, $!session-id;
			self.debug: $wind-rect;
		}
		
		method navigate( Str:D $url ) {
			self!clear-frames;
			my WebDriver2::Command::Result::Navigate:D $navigate =
					WebDriver2::Command::Navigate.new( :$url )
					.execute-with: self, $!session-id;
			self.debug: $navigate;
		}
		
		method back {
			my WebDriver2::Command::Result::Back $back =
					WebDriver2::Command::Back.new
					.execute-with: self, $!session-id;
			self.debug: $back;
		}
		
		method forward {
			my WebDriver2::Command::Result::Forward $forward =
					WebDriver2::Command::Forward.new
					.execute-with: self, $!session-id;
			self.debug: $forward;
		}
		
		method refresh {
			my WebDriver2::Command::Result::Refresh $refresh =
					WebDriver2::Command::Refresh.new
					.execute-with: self, $!session-id;
			self.debug: $refresh;
		}
		
		multi method screenshot( WebDriver2::Session-Actions: --> Str:D ) {
			self.debug: 'session screenshot';
			return unless $!session-id;
			self.debug: 'taking session screenshot';
			my WebDriver2::Command::Result::Screenshot $screenshot =
					WebDriver2::Command::Screenshot.new
					.execute-with: self, $!session-id;
			self.debug: Level::extra, $screenshot.value;
			# , $screenshot.value;
			return $screenshot.value;
		}
		
		method !screenshot( Str:D $element --> Str:D ) {
			self.debug: 'element screenshot';
			return unless $!session-id;
			self.debug: 'taking element screenshot';
			my WebDriver2::Command::Result::Element-Screenshot $screenshot =
					WebDriver2::Command::Element-Screenshot.new( :$element )
					.execute-with: self, $!session-id;
			self.debug: Level::extra, $screenshot.value;
			# , $screenshot.value;
			return $screenshot.value;
		}
		
		multi method screenshot( WebDriver2::Model::Element:D $element --> Str:D ) {
			$element.screenshot
		}
		
		method title( --> Str:D ) {
			my WebDriver2::Command::Result::Title $title =
					WebDriver2::Command::Title.new
					.execute-with: self, $!session-id;
			self.debug: $title, $title.value;
			return $title.value;
		}
		
		method alert-text( --> Str:D ) {
			my WebDriver2::Command::Result::Alert-Text $alert-text =
					WebDriver2::Command::Alert-Text.new
					.execute-with: self, $!session-id;
			self.debug: $alert-text, $alert-text.value;
			return $alert-text.value;
		}
		
		method accept-alert {
			my WebDriver2::Command::Result::Accept-Alert $accept-alert =
					WebDriver2::Command::Accept-Alert.new
					.execute-with: self, $!session-id;
			self.debug: $accept-alert;
			# say 'ACCEPT ALERT ', $accept-alert.execution-status.type === WebDriver2::Command::Execution-Status::Type::OK;
			$accept-alert.execution-status.type === WebDriver2::Command::Execution-Status::Type::OK;
		}
		
		method dismiss-alert {
			my WebDriver2::Command::Result::Dismiss-Alert $dismiss-alert =
					WebDriver2::Command::Dismiss-Alert.new
					.execute-with: self, $!session-id;
			self.debug: $dismiss-alert;
			$dismiss-alert === Empty;
		}
		
		method send-alert-text( Str:D $text ) {
			my WebDriver2::Command::Result::Send-Alert-Text $send-alert-text =
					WebDriver2::Command::Send-Alert-Text.new( :$text )
					.execute-with: self, $!session-id;
			self.debug: $send-alert-text
		}
		
		multi method element(
				WebDriver2::Command::Element::Locator:D $locator
				--> WebDriver2::Model::Element:D
		) {
			self.debug: 'session element';
			my WebDriver2::Command::Result::Element $element =
					WebDriver2::Command::Element.new( :$locator )
					.execute-with: self, $!session-id;
			#		$element.raku.say;
			self.debug: $element, $element.value;
			return Internal-Element.new:
					session => self,
					internal-id => $element.value,
					:$!debug-level
					;
		}
		
		method !element(
				Str:D $context,
				WebDriver2::Command::Element::Locator:D $locator
				--> WebDriver2::Model::Element:D
		) {
			self.debug: 'sub-element';
			my WebDriver2::Command::Result::SubElement $element =
					WebDriver2::Command::SubElement.new( :$context, :$locator )
					.execute-with: self, $!session-id;
			self.debug: $element, $element.value;
			return Internal-Element.new(
					session => self,
					internal-id => $element.value
			);
		}
		
		multi method element(
				WebDriver2::Model::Context:D $context,
				WebDriver2::Command::Element::Locator:D $locator
				--> WebDriver2::Model::Element:D
		) {
			$context.element( $locator )
		}
		
		multi method elements(
				WebDriver2::Command::Element::Locator:D $locator
				--> Array of WebDriver2::Model::Element
		) {
			self.debug: 'session elements';
			my WebDriver2::Command::Result::Elements $element =
					WebDriver2::Command::Elements.new( :$locator )
					.execute-with: self, $!session-id;
			self.debug: $element, $element.values;
			my WebDriver2::Model::Element @el;
			@el.push: Internal-Element.new(
					session => self,
					internal-id => $_
					) for $element.values[*];
			return @el;
		}
		
		method !elements(
				Str:D $context,
				WebDriver2::Command::Element::Locator:D $locator
				--> Array of WebDriver2::Model::Element
		) {
			self.debug: 'sub-elements';
			my WebDriver2::Command::Result::SubElements $element =
					WebDriver2::Command::SubElements.new( :$context, :$locator )
					.execute-with: self, $!session-id;
			self.debug: $element, $element.values;
			my WebDriver2::Model::Element @el;
			@el.push: Internal-Element.new(
					session => self,
					internal-id => $_
					) for $element.values[*];
			return @el;
		}
		
		multi method elements(
				WebDriver2::Model::Context:D $context,
				WebDriver2::Command::Element::Locator:D $locator
				--> Array of WebDriver2::Model::Element
		                      ) {
			$context.elements: $locator
		}
		
		method !element-rect( Str:D $element --> Hash of Int ) {
			my WebDriver2::Command::Result::Element-Rect $rect =
					WebDriver2::Command::Element-Rect.new( :$element ).execute-with: self, $!session-id;
			self.debug: $rect.raku, $rect.x.raku, $rect.y.raku, $rect.width.raku, $rect.height.raku;
			my Int %rect;
			%rect<x> = $rect.x;
			%rect<y> = $rect.y;
			%rect<width> = $rect.width;
			%rect<height> = $rect.height;
			%rect
		}
		
		method element-rect( WebDriver2::Model::Element:D $element --> Hash of Int ) {
			$element.rect
		}
		
		method execute-script( Str:D $script, @args ) {
			my WebDriver2::Command::Result::Execute-Script $script-result =
					WebDriver2::Command::Execute-Script.new( :$script, :@args )
					.execute-with: self, $!session-id;
			self.debug: $script-result, $script-result.value.flat;
		}
		
		method active( --> WebDriver2::Model::Element:D ) {
			my WebDriver2::Command::Result::Active $active =
					WebDriver2::Command::Active.new
					.execute-with: self, $!session-id;
			self.debug: $active, $active.value;
			return Internal-Element.new(
					session => self,
					internal-id => $active.value
					);
		}
		
#		method !frame ( Str:D $element --> WebDriver2::Model::Frame:D ) {
#			Internal-Frame.new: self, $element, $!debug-level;
#		}
		
		method frame( WebDriver2::Model::Element:D $element --> WebDriver2::Model::Frame ) {
			self.debug: Level::WARN, 'CALLING FRAME FROM SESSION';
			if $element.tag-name.lc eq 'frame' | 'iframe' {
#				return Internal-Frame.new: $element, $!debug-level;
				return $element.frame;
			}
			note 'no conversion to frame';
			# TODO : raise exception
		}
		
		method !tag-name( Str:D $element --> Str:D ) {
			self.debug: "getting tag name for $element";
			my WebDriver2::Command::Result::Tag-Name $tag-name =
					WebDriver2::Command::Tag-Name.new( :$element )
					.execute-with: self, $!session-id;
			self.debug: $tag-name, $tag-name.value.lc;
			self.debug: $tag-name.value.lc;
			return $tag-name.value.lc;
		}
		
		method tag-name( WebDriver2::Model::Element:D $element --> Str:D ) {
			$element.tag-name
		}
		
		method !property(
				Str:D $element,
				Str:D $property
				--> WebDriver2::Command::Result::Property::Prop-Val
		                 ) {
			my WebDriver2::Command::Result::Property $property-value =
					WebDriver2::Command::Property.new( :$element, :$property )
					.execute-with: self, $!session-id;
			self.debug: $property-value, $property-value.value;
			return $property-value.value;
		}
		
		method property( WebDriver2::Model::Element:D $element, Str:D $property --> Str ) {
			$element.property( $property )
		}
		
		method !attribute( Str:D $element, Str:D $attribute --> Str ) {
			my WebDriver2::Command::Result::Attribute $attribute-value =
					WebDriver2::Command::Attribute.new( :$element, :$attribute )
					.execute-with: self, $!session-id;
			self.debug: $attribute-value, $attribute-value.value;
			return $attribute-value.value;
		}
		
		method attribute( WebDriver2::Model::Element:D $element, Str:D $attribute --> Str ) {
			$element.attribute: $attribute
		}
		
		method !id( Str:D $element --> Str ) {
			self!attribute: $element, 'id'
		}
		
		method id( WebDriver2::Model::Element:D $element --> Str ) {
			$element.id
		}
		
		method !value( Str:D $element --> Str ) {
			self!property: $element, 'value'
		}
		
		method value( WebDriver2::Model::Element:D $element --> Str ) {
			$element.value
		}
		
		method !text( Str:D $element --> Str:D ) {
			my WebDriver2::Command::Result::Text $text =
					WebDriver2::Command::Text.new( :$element )
					.execute-with: self, $!session-id;
			self.debug: $text, $text.value;
			return $text.value;
		}
		
		method text( WebDriver2::Model::Element:D $element --> Str:D ) {
			$element.text
		}
		
		method !displayed( Str:D $element --> Bool ) {
			return Bool if not $.browser or $.browser.Str eq 'safari';
			my WebDriver2::Command::Result::Displayed $displayed =
					WebDriver2::Command::Displayed.new( :$element )
					.execute-with: self, $!session-id;
			self.debug: $displayed, $displayed.value;
			return $displayed.value;
		}
		
		method displayed( WebDriver2::Model::Element:D $element --> Bool ) {
			$element.displayed
		}
		
		method !enabled( Str:D $element --> Bool:D ) {
			my WebDriver2::Command::Result::Enabled $enabled =
					WebDriver2::Command::Enabled.new( :$element )
					.execute-with: self, $!session-id;
			self.debug: $enabled, $enabled.value ~ ' VALUE';
			return $enabled.value;
		}
		
		method enabled( WebDriver2::Model::Element:D $element --> Bool:D ) {
			$element.enabled
		}
		
		method !selected( Str:D $element --> Bool:D ) {
			my WebDriver2::Command::Result::Selected $selected =
					WebDriver2::Command::Selected.new( :$element )
					.execute-with: self, $!session-id;
			self.debug: $selected, $selected.value;
			return $selected.value;
		}
		
		method selected( WebDriver2::Model::Element:D $element --> Bool:D ) {
			$element.selected
		}
		
		method !css-value( Str:D $element, Str:D $property --> Str ) {
			my WebDriver2::Command::Result::CSS-Value $css-value =
					WebDriver2::Command::CSS-Value.new( :$element, :$property )
					.execute-with: self, $!session-id;
			self.debug: $css-value, $css-value.value;
			return $css-value.value;
		}
		
		method css-value( WebDriver2::Model::Element:D $element, Str:D $property --> Str ) {
			$element.css-value: $property
		}
		
		method !send-keys( Str:D $element, Str:D $keys ) {
			my WebDriver2::Command::Result::Send-Keys $send-keys =
					WebDriver2::Command::Send-Keys.new( :$element, :$keys )
					.execute-with: self, $!session-id;
			self.debug: $send-keys;
		}
		
		method send-keys( WebDriver2::Model::Element:D $element, Str:D $keys ) {
			$element.send-keys: $keys;
		}
		
		method timeouts( Int :$script, Int :$pageLoad, Int :$implicit ) {
			my WebDriver2::Command::Result::Timeouts $timeouts =
					WebDriver2::Command::Timeouts.new( :$script, :$pageLoad, :$implicit )
					.execute-with: self, $!session-id;
			self.debug: $timeouts;
		}
		
		method !clear( Str:D $element ) {
			my WebDriver2::Command::Result::Clear $clear =
					WebDriver2::Command::Clear.new( :$element )
					.execute-with: self, $!session-id;
			self.debug: $clear;
		}
		
		method clear( WebDriver2::Model::Element:D $element ) {
			$element.clear
		}
		
		method !click( Str:D $element ) {
			my WebDriver2::Command::Result::Click $click =
					WebDriver2::Command::Click.new( :$element )
					.execute-with: self, $!session-id;
			self.debug: $click;
		}
		
		method click( WebDriver2::Model::Element:D $element ) {
			$element.click
		}
		
		method !switch-to(
				WebDriver2::Model::Frame $the-frame,
				WebDriver2::Command::Param::ID-or-Index:D $frame
		) {
			self.debug: 'SWITCH TO', $the-frame.gist, "\n", |@!frames>>.raku;
			
			my WebDriver2::Command::Result::Switch-To $switch =
					WebDriver2::Command::Switch-To.new( :$frame )
					.execute-with: self, $!session-id;
			self!push-frame: $the-frame;
			self.debug: 'PUSH', @!frames.gist;
			self.debug: $switch;
		}
		
		multi method switch-to( WebDriver2::Model::Frame:D $frame ) {
			$frame.switch-to
		}
		
		# FIXME : how to handle frame by index
		multi method switch-to( Int:D $frame ) {
			self.debug: 'JUMPING TO FRAME', $frame;
			my WebDriver2::Model::Frame $the-frame =
				.[ $frame ].frame with
				self.elements:
						WebDriver2::Command::Element::Locator::Tag-Name.new:
								'iframe';
			self!switch-to: $the-frame, $frame
		}
		
		method switch-to-parent {
			my WebDriver2::Command::Result::Switch-To-Parent $switch =
					WebDriver2::Command::Switch-To-Parent.new
					.execute-with: self, $!session-id;
			if @!frames {
				@!frames.pop;
				self.debug: 'POP', @!frames.raku;
				self.debug: $switch;
				return self;
			} else {
				self.debug: 'no parent frame';
				return WebDriver2::Model::Frame;
			}
		}
		
		method top {
			self.debug: 'TOP';
			self!clear-frames;
			my WebDriver2::Command::Result::Switch-To $switch =
					WebDriver2::Command::Switch-To.new( frame => Str )
					.execute-with: self, $!session-id;
			self.debug: $switch;
			self
		}
		
		method url ( --> Str ) {
			my WebDriver2::Command::Result::URL $url =
					WebDriver2::Command::URL.new
					.execute-with: self, $!session-id;
			self.debug: $url;
			$url.value
		}
		
		method window-handle ( --> Str ) {
			my WebDriver2::Command::Result::Window-Handle $wh =
					WebDriver2::Command::Window-Handle.new.execute-with:
							self,
							$!session-id;
			self.debug: $wh;
			die 'inconsistent window handle state'
				if not $!original-window and $!window-handles.elems;
			$!original-window ||= $wh.value;
			$wh.value;
		}
		
		method window-handles ( --> Array[Str] ) {
			my WebDriver2::Command::Result::Window-Handles $wh =
					WebDriver2::Command::Window-Handles.new.execute-with:
							self, $!session-id;
			self.debug: $wh;
			my Str @wh;
			@wh.push: $_ for $wh.values;
			@wh;
		}
		
		method new-window {
			my WebDriver2::Command::Result::New-Window $nw =
					WebDriver2::Command::New-Window.new.execute-with:
							self,
							$!session-id;
			self.debug: $nw;
			$nw.values;
		}
		
		method close-window {
			my WebDriver2::Command::Result::Close-Window $cw =
					WebDriver2::Command::Close-Window.new.execute-with:
							self,
							$!session-id;
			self.debug: $cw;
			self.switch-to-window: self.window-handles[0];
		}
		
		method switch-to-window ( Str:D $wh ) {
			my WebDriver2::Command::Result::Switch-to-Window $sw =
					WebDriver2::Command::Switch-to-Window.new( handle => $wh ).execute-with: self, $!session-id;
			self.debug: $sw;
		}
		
		
		
		method delete-session {
			return without $!session-id;
			my WebDriver2::Command::Result::Delete-Session $delete-session =
					WebDriver2::Command::Delete-Session.new
						.execute-with: self, $!session-id;
			self.debug: $delete-session;
		}
		
#		method stop {
#		
#		}
		
		
		
		class Internal-Element
				does WebDriver2::Model::Element
				does WebDriver2::Test::Debugging
#				does WebDriver2::Model::Frame
		{
			
			trusts ::WebDriver2::Driver::Session::Internal-Frame;
			trusts Session::Internal-Frame;
			
			has Session $!session is built;
			has Str:D $!internal-id is required is built;
			has Str $!tag-name is built;
#			has Level $.debug-level is built  = Level::WARN;
			
			method !internal-id ( --> Str:D ) { $!internal-id }
			
			method !session( --> Session:D ) {
				$!session
			}
			
			method !is-frame ( --> Bool:D ) {
				so self.tag-name eq 'iframe' | 'frame'
			}
			
			method screenshot( --> Str:D ) {
				$!session!Session::screenshot: $!internal-id
			}
			
			method stale ( --> Bool:D ) {
				#		try { self.enabled }
				my $t;
				try $t = self.selected; # self.tag-name # self.enabled;
				#		$!id.say;
				$!.rethrow if $!
						and (
						( $! !~~ WebDriver2::Command::Result::X )
								or ( $!.execution-status.type !~~
								WebDriver2::Command::Execution-Status::Type::Stale)
						);
				return True if (
						$!
						and $!.execution-status.type
							~~ WebDriver2::Command::Execution-Status::Type::Stale
				);
				so ( ( $t eq 'frame' | 'iframe' )
						and (
								not $!session!Session::curr-frame
								or $!session!Session::curr-frame !~~ $!internal-id
						)
				);
#				so ( $! and $!.execution-status.type ~~ WebDriver2::Command::Execution-Status::Type::Stale)
			}
			
			method element(
					WebDriver2::Command::Element::Locator:D $locator
					--> WebDriver2::Model::Element:D
			) {
				self!is-frame
						?? $!session!Session::element: $locator
						!! $!session!Session::element: $!internal-id, $locator
			}
			method elements(
					WebDriver2::Command::Element::Locator:D $locator
					--> Array of WebDriver2::Model::Element
			) {
				self!is-frame
						?? $!session!Session::elements: $locator
						!! $!session!Session::elements: $!internal-id, $locator
			}
			method rect( --> Hash of Int ) {
				$!session!Session::element-rect: $!internal-id;
			}
			method tag-name( --> Str:D ) {
# 				return $!session!Session::tag-name: $!internal-id if True;
				$!tag-name //= $!session!Session::tag-name: $!internal-id;
				self.debug: 'TAG NAME', $!tag-name;
				return $!tag-name;
				#		return (
				#				$!tag-name
				#				or ( $!tag-name =
				#						$!session!Session::tag-name( $!internal-id )
				#				)
				#		);
			}
			method top( WebDriver2::Model::Context:D ) {
				$!session.top;
			}
			method frame( --> WebDriver2::Model::Frame:D ) {
				die 'self not a frame' unless self!is-frame;
#				Session::Internal-Frame.new: $!session, $!internal-id, $!debug-level;
#				self does Session::Internal-Frame[$!session, $!internal-id];
				Session::Internal-Frame.new:
						:$!session,
						base-element => self,
						:$!internal-id,
						:$!debug-level,
						:$.tag-name
						;
			}
			method property( Str:D $property --> WebDriver2::Command::Result::Property::Prop-Val ) {
				$!session!Session::property: $!internal-id, $property
			}
			method attribute( Str:D $attribute --> Str ) {
				$!session!Session::attribute( $!internal-id, $attribute )
			}
			method id( --> Str ) {
				$!session!Session::id( $!internal-id )
			}
			method value( --> Str ) {
				$!session!Session::value( $!internal-id )
			}
			method text( --> Str:D ) {
				$!session!Session::text( $!internal-id )
			}
			method css-value( Str:D $property --> Str ) {
				$!session!Session::css-value( $!internal-id, $property )
			}
			method enabled( --> Bool:D ) {
				$!session!Session::enabled( $!internal-id )
			}
			method displayed( --> Bool ) {
				$!session!Session::displayed( $!internal-id )
			}
			method selected( --> Bool:D ) {
				$!session!Session::selected( $!internal-id )
			}
			method send-keys( Str:D $text ) {
				$!session!Session::send-keys( $!internal-id, $text )
			}
			method clear( --> WebDriver2::Model::Element:D ) {
				$!session!Session::clear( $!internal-id );
				self
			}
			method click( --> WebDriver2::Model::Element:D ) {
				$!session!Session::click( $!internal-id );
				self
			}
			method execute-script ( Str:D $script, *@args ) {
				my @self-args = @args;
				my Hash[Str] $element = Hash[Str].new: %( ELEMENT-ID, $!internal-id);
				@self-args.unshift: $element;
				$!session.execute-script: $script, @self-args;
			}
			#	method debug ( --> Str ) {
			#		$!internal-id
			#	}
			
			multi method ACCEPTS(
					Session::Internal-Element:D $other
			) {
				$!internal-id eq $other!internal-id;
			}
			
			method switch-to {
#				my Str $iid = $!internal-id;
#				if self.debug {
#					my Str $msg = 'switch to ' ~ $iid.gist;
#					$msg ~= " from { $!session!curr-frame }"
#					if $!session!curr-frame;
#					$msg.say;
#				}
#				
#				#		$driver!switch-to( $iid )
#				if (
#						$!session!curr-frame.defined
#								and $iid
#								and $!session!curr-frame ne $iid
#						or not $!session!curr-frame.defined
#				# and $iid
#				#				or not $iid and $driver!curr-frame.defined;
#				) {
#					$!session!Session::switch-to: $iid;
#				};
				self.debug: 'element switch-to';
				self;
			}
#			method is-curr-frame( --> Bool:D ) {
#				False
#			}
			method context( --> WebDriver2::Model::Context:D ) {
#				self.switch-to unless self.is-curr-frame;
#				$!session;
				self;
			}
		}
		
		class Internal-Frame
#				is Session::Internal-Element
				does WebDriver2::Model::Frame
				does WebDriver2::Test::Debugging
		{
			has Session $!session is built;
			has WebDriver2::Model::Element:D $.base-element is required;
			has Str:D $!internal-id is required is built;
			has Str $.tag-name is built;
			
			method is-curr-frame( --> Bool:D ) {
#				self!session!curr-frame ~~
				$!session!Session::curr-frame ~~ self
			}
			
			method stale ( --> Bool:D ) {
#				my WebDriver2::Driver $driver =
#						self!session;
#				return True if not $driver!curr-frame
#						or $driver!curr-frame !~~ self.internal-id;
#				#		callsame
#				False;
				not self.is-curr-frame
			}
			
			method switch-to( --> WebDriver2::Model::Frame ) {
#				$session!Session::switch-to: $internal-id;
#				callsame;
self.debug: 'switching to frame ',
		$!internal-id,
		' for session ',
		$!session.^name,
		;
self.debug: 'current frame' if self.is-curr-frame;
				return self if self.is-curr-frame;
				$!session!Session::switch-to: self, $!internal-id;
				self;
##				my Session $session = self!session;
#				my Str $iid = $internal-id;
#				if self.debug {
#					my Str $msg = 'switch to ' ~ $iid.gist;
#					$msg ~= " from { $session!curr-frame }"
#						if $session!curr-frame;
#					$msg.say;
#				}
#				
#				#		$driver!switch-to( $iid )
#				if (
#				$session!curr-frame.defined and $iid and $session!curr-frame ne $iid
#						or not $session!curr-frame.defined
#				# and $iid
#				#				or not $iid and $driver!curr-frame.defined;
#				) {
#					$session!Session::switch-to: $iid;
#				};
#				self;
#				#		$driver;
			}
			method top { $!session.top }
			method element(
					WebDriver2::Command::Element::Locator:D $locator
					--> WebDriver2::Model::Element:D
			) {
				self.debug: 'frame element';
				$!session.element: $locator;
			}
			method elements(
					WebDriver2::Command::Element::Locator:D $locator
					--> Array of WebDriver2::Model::Element
			) {
				self.debug: 'frame elements';
				$!session.elements: $locator;
			}
			method tag-name ( --> Str:D ) { $!tag-name }
			
			method context( --> WebDriver2::Model::Context:D ) {
				self.switch-to unless self.is-curr-frame;
				#		self!Internal-Element::driver
				#		self;
#				self!session
#				$session;
				self;
			}
			
			method !internal-id ( --> Str:D ) { $!internal-id }
			
			method ACCEPTS ( WebDriver2::Model::Frame $frame ) {
				$frame and $!internal-id ~~ $frame!internal-id
			}
		}
	}
}



class WebDriver2::Driver::Chrome is WebDriver2::Driver {
	
	#submethod BUILD( :$!browser = 'chrome', :$!debug-level ) { }
	
	method new(
			:$debug-level = Level::WARN,
			:$server = WebDriver2::Driver::Server.new: host => '127.0.0.1', port => 9515
	) {
		self.bless:
				browser => 'chrome',
				:$server,
				:$debug-level;
	}
	
#	method browser ( --> Str:D ) {
#		'chrome'
#	}
	
	method param-factory( --> WebDriver2::Command::Param::Factory ) {
		$.param // WebDriver2::Command::Param::Factory::Chrome.new
	}
	
	method factory( --> WebDriver2::Command::Result::Factory ) {
		$.result // WebDriver2::Command::Result::Factory::Chrome.new
		#	$.result // WebDriver2::Command::Result::Factory.new
	}
}

class WebDriver2::Driver::Edge is WebDriver2::Driver {
	
	method new(
			:$server = WebDriver2::Driver::Server.new( host => 'localhost', port => 9515 ),
			:$debug-level = Level::WARN
	) {
		self.bless:
				browser => 'edge',
				:$server,
				:$debug-level
	}
	
	method param-factory( --> WebDriver2::Command::Param::Factory ) {
		$.param // WebDriver2::Command::Param::Factory::Edge.new
	}
	
	method factory( --> WebDriver2::Command::Result::Factory ) {
		$.result // WebDriver2::Command::Result::Factory::Edge.new
		#	$.result // WebDriver2::Command::Result::Factory.new
	}
}

class WebDriver2::Driver::Firefox is WebDriver2::Driver {
	
	method new(
			:$server = WebDriver2::Driver::Server.new( host => '127.0.0.1', port => 4444 ),
			:$debug-level = Level::WARN
	) {
		self.bless:
				browser => 'firefox',
				:$server,
				:$debug-level
	}
	
	method param-factory( --> WebDriver2::Command::Param::Factory ) {
		$.param // WebDriver2::Command::Param::Factory::Firefox.new
	}
	
	method factory( --> WebDriver2::Command::Result::Factory ) {
		$.result // WebDriver2::Command::Result::Factory::Firefox.new
		#	$.result // WebDriver2::Command::Result::Factory.new
	}
}

class WebDriver2::Driver::Safari is WebDriver2::Driver {
	
	method new(
			:$server = WebDriver2::Driver::Server.new( host => 'localhost', port => 7055 ),
			:$debug-level = Level::WARN
	) {
		self.bless:
				browser => 'safari',
				:$server,
				:$debug-level
	}
	
	method param-factory( --> WebDriver2::Command::Param::Factory ) {
		$.param // WebDriver2::Command::Param::Factory::Safari.new
	}
	
	method factory( --> WebDriver2::Command::Result::Factory ) {
		$.result // WebDriver2::Command::Result::Factory::Safari.new
	}
	
	method displayed ( WebDriver2::Model::Element:D $element --> Bool ) {
		say 'DISPLAYED OVERRIDDEN';
		return Bool;
	}
}

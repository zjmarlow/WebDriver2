use HTTP::UserAgent;

use WebDriver2::Command::Element::Locator;
use WebDriver2::Command::Param;

use WebDriver2::Test::Debugging;

role WebDriver2 { ... }
role WebDriver2::Model::Context { ... }
role WebDriver2::Model::Element does WebDriver2::Model::Context { ... }
role WebDriver2::Model::Frame does WebDriver2::Model::Context { ... }

role WebDriver2::Driver-Actions {
#	has HTTP::UserAgent $!ua;
#	has Level $.debug is rw;
	has Str:D $.browser is required;
#	method browser ( --> Str:D ) { ... }
	
	method start { }
	
	method session { ... }
	method status { ... }
	
	method stop { }
}

role WebDriver2::Session-Actions does WebDriver2::Model::Context {
#	method start { ... }
	
#	method session { ... }
	method browser ( --> Str:D ) { ... }
	method driver ( --> WebDriver2::Driver-Actions:D ) { ... }
	
	method maximize-window { ... }
	method set-window-rect( Int $width, Int $height, Int $x, Int $y ) { ... }
	method window-handles { ... }
	method window-handle { ... }
	method close-window { ... }
	method switch-to-window ( Str:D $handle ) { ... }
	method new-window { ... }
	
	method navigate( Str:D $url ) { ... }
	method refresh { ... }
	method title( --> Str:D ) { ... }
	
	method alert-text( --> Str:D ) { ... }
	method accept-alert ( --> Bool ) { ... }
	method dismiss-alert ( --> Bool ) { ... }
	method send-alert-text( Str:D ) { ... }
	
	multi method screenshot( WebDriver2::Session-Actions: --> Str:D ) { ... }
	
	method execute-script( Str:D, Str @ ) { ... }
	
	multi method switch-to( WebDriver2::Model::Frame:D $frame ) { ... }
	multi method switch-to( Int:D $frame ) { ... }
	method timeouts( Int :$script, Int :$pageLoad, Int :$implicit ) { ... }
	method switch-to-parent { ... }
	method top { ... }
# 	method curr-frame( --> WebDriver2::Command::Param::ID-or-Index ) { ... }

	method active( --> WebDriver2::Model::Element:D ) { ... }

	method url ( --> Str ) { ... }
	
	method delete-session { ... }
	
#	method stop { ... }
}

role WebDriver2::Element-Actions {
	multi method screenshot( WebDriver2::Model::Element:D $element --> Str:D ) { ... }
	
	multi method element(
			WebDriver2::Command::Element::Locator:D $locator
			--> WebDriver2::Model::Element:D
	) { ... }
	multi method element(
			WebDriver2::Model::Context:D $context,
			WebDriver2::Command::Element::Locator:D $locator
			--> WebDriver2::Model::Element:D
	) { ... }
	multi method elements(
			WebDriver2::Command::Element::Locator:D $locator
			--> Array of WebDriver2::Model::Element
	) { ... }
	multi method elements(
			WebDriver2::Model::Context:D $context,
			WebDriver2::Command::Element::Locator:D $locator
			--> Array of WebDriver2::Model::Element
	) { ... }
	method tag-name( WebDriver2::Model::Element:D $element --> Str:D ) { ... }
	method frame( WebDriver2::Model::Element:D $element --> WebDriver2::Model::Frame:D ) { ... }
	method property(
#			WebDriver2::Model::Element:D $element,
			Str:D $property
			--> Str
	) { ... }
	method attribute(
#			WebDriver2::Model::Element:D $element,
			Str:D $attribute
			--> Str
	) { ... }
	method text( WebDriver2::Model::Element:D $element --> Str:D ) { ... }
	method id( WebDriver2::Model::Element:D $element --> Str ) { ... }
	method value( WebDriver2::Model::Element:D $element --> Str ) { ... }
	method enabled( WebDriver2::Model::Element:D $element --> Bool:D ) { ... }
	method selected( WebDriver2::Model::Element:D $element --> Bool:D ) { ... }
	method displayed( WebDriver2::Model::Element:D $element --> Bool:D ) { ... }
	method css-value(
#			WebDriver2::Model::Element:D $element,
			Str:D $property
			--> Str
	) { ... }
	method send-keys( WebDriver2::Model::Element:D $element, Str:D $keys ) { ... }
	method clear ( WebDriver2::Model::Element:D $element ) { ... }
	method click( WebDriver2::Model::Element:D $element ) { ... }
	multi method switch-to( WebDriver2::Model::Frame:D $frame ) { ... }
}

role WebDriver2
		does WebDriver2::Session-Actions
		does WebDriver2::Driver-Actions
		does WebDriver2::Element-Actions
		does WebDriver2::Model::Context
{
#	has Str $.session-id is rw;
#	has Str:D $.browser is required;
	has HTTP::UserAgent $.ua;
#	has Level $.debug is rw;
	
	method browser ( --> Str:D ) { ... }
}

role WebDriver2::Model::Context {
	method top( --> WebDriver2::Model::Context:D ) { ... }
	method element( WebDriver2::Command::Element::Locator:D --> WebDriver2::Model::Element:D ) { ... }
	method elements(
			WebDriver2::Command::Element::Locator:D
			--> Array of WebDriver2::Model::Element
	) { ... }
}

role WebDriver2::Model::Element
		does WebDriver2::Model::Context
		does WebDriver2::Test::Debugging
{
#	has Str:D $!internal-id is required;
	method !internal-id( --> Str:D ) { ... }
	method frame( --> WebDriver2::Model::Frame:D ) { ... }
	method tag-name( --> Str:D ) { ... }
	method stale( --> Bool:D ) { ... }
	method rect( --> Hash of Int ) { ... }
	method property( Str:D --> Str ) { ... }
	method attribute( Str:D --> Str ) { ... }
	method id( --> Str ) { ... }
	method value( --> Str ) { ... }
	method text( --> Str:D ) { ... }
	method displayed( --> Bool:D ) { ... }
	method selected( --> Bool:D ) { ... }
	method enabled( --> Bool:D ) { ... }
	method css-value( --> Str ) { ... }
	method send-keys( Str:D ) { ... }
	method clear( --> WebDriver2::Model::Element:D ) { ... }
	method click( --> WebDriver2::Model::Element:D ) { ... }
	multi method ACCEPTS( WebDriver2::Model::Element:D: $other ) {
		self!internal-id eq $other!internal-id;
	}
}

role WebDriver2::Model::Frame does WebDriver2::Model::Context {
	method is-curr-frame( --> Bool:D ) { ... }
	method switch-to( --> WebDriver2::Model::Frame:D ) { ... }
	method context( --> WebDriver2::Model::Context:D ) { ... }
	method tag-name ( --> Str:D ) { ... }
	method !internal-id ( --> Str:D ) { ... }
}

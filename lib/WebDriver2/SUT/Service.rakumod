use WebDriver2;
use WebDriver2::Test::Debugging;
use WebDriver2::Driver;
use WebDriver2::SUT::Tree;
use WebDriver2::SUT::Navigator;
use WebDriver2::Command::Element::Locator;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;
use WebDriver2::Command::Element::Locator::CSS;

unit role WebDriver2::SUT::Service; # does WebDriver2;

#has WebDriver2::Browser-Actions:D $!browser-actions is required handles <
#		start session maximize-window set-window-rect refresh title
#		alert-text accept-alert dismiss-alert send-alert-text
#		execute-script timeouts switch-to-parent top window-handles
#		curr-frame url delete-session stop
#>;
has WebDriver2::Session-Actions:D $!session is required is built;
#has WebDriver2::SUT::Tree::APage $!page is built;
has WebDriver2::SUT::Tree::SUT $!sut is built;
has WebDriver2::SUT::Tree::ANode %!elements;

has Str:D $.prefix = '';
has Str:D $.key-prefix = '';

#method new (
#		WebDriver2::SUT::Service:U:
#		Str:D $browser,
#		WebDriver2::SUT::Tree::APage :$page,
#		Int:D :$debug = 0,
#		*%rest
#) {
#say 'new service Service 33';
#	self.bless:
#			:$browser,
#			:$page,
#			|%rest,
#			driver => WebDriver2::Driver.new: $browser, :$debug;
#}

method name ( --> Str:D ) { ... }

method elements-loaded ( --> Bool:D ) { so %!elements<>.elems }

method add-element ( Str $k, WebDriver2::SUT::Tree::ANode:D $v ) {
	warn "overwriting $k" if %!elements{ $k }:exists;
	%!elements{ $k } = $v;
}

method get (
		WebDriver2::SUT::Service:D:
		Str:D $name
		--> WebDriver2::SUT::Tree::ANode:D
) {
	die "no element named $name" unless %!elements{ $name }:exists;
	%!elements{ $name };
}

#method locate-element ( WebDriver2::Command::Element::Locator $locator ) {
#	$!driver.element: $locator;
#}
#
#method element-by-id ( Str:D $id ) {
#	self.locate-element: WebDriver2::Command::Element::Locator::ID.new: $id;
#}
#
#method element-by-tag ( Str:D $tag ) {
#	self.locate-element: WebDriver2::Command::Element::Locator::Tag-Name.new: $tag;
#}
#
#method elements-by-tag ( Str:D $tag ) {
#	$!driver.elements: WebDriver2::Command::Element::Locator::Tag-Name.new: $tag;
#}
#
#method element-by-css-selector ( Str:D $selector ) {
#	$!driver.element: WebDriver2::Command::Element::Locator::CSS.new: $selector;
#}
#
#method screenshot {
#	$!driver.session.screenshot;
#}

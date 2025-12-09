use lib <lib t/lib>;

use Test;

plan 52;

use-ok "WebDriver2";
use-ok "WebDriver2::Command";
use-ok "WebDriver2::Command::Element::Locator";
use-ok "WebDriver2::Command::Element::Locator::CSS";
use-ok "WebDriver2::Command::Element::Locator::ID";
use-ok "WebDriver2::Command::Element::Locator::Link-Text";
use-ok "WebDriver2::Command::Element::Locator::Tag-Name";
use-ok "WebDriver2::Command::Element::Locator::Xpath";
use-ok "WebDriver2::Command::Execution-Status";
use-ok "WebDriver2::Command::Keys";
use-ok "WebDriver2::Command::Param";
use-ok "WebDriver2::Command::Param::Factory";
use-ok "WebDriver2::Command::Param::Factory::Chrome";
use-ok "WebDriver2::Command::Param::Factory::Edge";
use-ok "WebDriver2::Command::Param::Factory::Firefox";
use-ok "WebDriver2::Command::Param::Factory::Safari";
use-ok "WebDriver2::Command::Result";
use-ok "WebDriver2::Command::Result::Factory";
use-ok "WebDriver2::Command::Result::Factory::Chrome";
use-ok "WebDriver2::Command::Result::Factory::Chromium";
use-ok "WebDriver2::Command::Result::Factory::Edge";
use-ok "WebDriver2::Command::Result::Factory::Firefox";
use-ok "WebDriver2::Command::Result::Factory::Safari";
use-ok "WebDriver2::Constants";
use-ok "WebDriver2::Driver";
use-ok "WebDriver2::Driver::Server";
use-ok "WebDriver2::SUT::Build";
use-ok "WebDriver2::SUT::Build::Page";
use-ok "WebDriver2::SUT::Navigator";
use-ok "WebDriver2::SUT::Provider";
use-ok "WebDriver2::SUT::Service";
use-ok "WebDriver2::SUT::Service::Loader";
use-ok "WebDriver2::SUT::Tree";
use-ok "WebDriver2::Test";
use-ok "WebDriver2::Test::Adapter";
use-ok "WebDriver2::Test::Config-From-File";
use-ok "WebDriver2::Test::Debugging";
use-ok "WebDriver2::Test::Locating-Test";
use-ok "WebDriver2::Test::PO-Test";
use-ok "WebDriver2::Test::Template";
use-ok "WebDriver2::Until";
use-ok "WebDriver2::Until-C";
use-ok "WebDriver2::Until::Command";
use-ok "WebDriver2::Until::SUT";

throws-like
		q{
			use WebDriver2::Driver;
			Session.raku;
		},
		X::Undeclared::Symbols,
		'Session is private',
		message => rx:s/Undeclared name\: Session/
		;
throws-like
		{
			use WebDriver2::Driver;
			WebDriver2::Driver::Session.raku;
		},
		X::AdHoc,
		'Session is private',
		message => q|Could not find symbol '&Session' in 'WebDriver2::Driver'|
		;
throws-like
		q{
			use WebDriver2::Driver;
			Internal-Element.raku;
		},
		X::Undeclared::Symbols,
		'Internal-Element is private',
		message => rx:s/Undeclared name\: Internal\-Element/
		;
throws-like
		{
			use WebDriver2::Driver;
			Session::Internal-Element.raku;
		},
		X::AdHoc,
		'Internal-Element is private',
		message =>
		q|Could not find symbol '&Internal-Element' in 'GLOBAL::Session'|
		;
throws-like
		{
			use WebDriver2::Driver;
			WebDriver2::Driver::Session::Internal-Element.raku;
		},
		X::AdHoc,
		'Internal-Element is private',
		message =>
		q|Could not find symbol '&Internal-Element' in 'WebDriver2::Driver::Session'|
		;
throws-like
		q{
			use WebDriver2::Driver;
			Session::Internal-Frame.raku;
		},
		X::AdHoc,
		'Internal-Frame is private',
		message =>
		q|Could not find symbol '&Internal-Frame' in 'GLOBAL::Session'|
		;
throws-like
		{
			use WebDriver2::Driver;
			Session::Internal-Frame.raku;
		},
		X::AdHoc,
		'Internal-Frame is private',
		message =>
		q|Could not find symbol '&Internal-Frame' in 'GLOBAL::Session'|
		;
throws-like
		{
			use WebDriver2::Driver;
			WebDriver2::Driver::Session::Internal-Frame.raku;
		},
		X::AdHoc,
		'Internal-Frame is private',
		message =>
		q|Could not find symbol '&Internal-Frame' in 'WebDriver2::Driver::Session'|
		;

done-testing;

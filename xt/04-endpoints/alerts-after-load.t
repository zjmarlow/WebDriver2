use Test;

use lib <lib t/lib>;

use WebDriver2::Test::Template;
use WebDriver2::Test::Locating-Test;

my IO::Path $html-file =
		.add: 'alerts-after-load.html' with $*PROGRAM.parent.parent.add: 'content';

class Alerts does WebDriver2::Test::Template does WebDriver2::Test::Locating-Test {
	
	has Int:D $.plan = 8;
	has Str:D $.name = 'alerts';
	has Str:D $.description = 'js alerts';
	
	submethod BUILD (
			WebDriver2::Driver-Actions:D :$!driver,
			IO::Path:D :$!test-root = 'xt'.IO,
			Int:D :$!close-delay = 3,
			Int:D :$!debug = 0
	) { }
	
	method pre-test { }
	method post-test { }
	
	method test {
		$!session.navigate: 'file://' ~ $html-file.absolute;

#		sleep 1;
		
#		my WebDriver2::Model::Element $h2 = self.element-by-tag: 'h2';
#say $h2.text;
#say 'got h2';
#		$h2.click;
#say 'clicked h2';
#		sleep 1;
#
#say $h2.text;
#		sleep 1;
#
#		say $h2.text;
#		sleep 1;
#
#		say $h2.text;
#		sleep 1;
#
#		say $h2.text;
#		sleep 1;
#
#		say $h2.text;
#		sleep 1;
#
#		say $h2.text;
#		sleep 1;
#
#		say $h2.text;
#		sleep 1;
#
		is $!session.alert-text, 'one', 'alert text one';

		$!session.accept-alert;
		sleep 1;

		is $!session.alert-text, 'two', 'alert text two';

		$!session.dismiss-alert;
		sleep 1;

		is $!session.alert-text, 'yes', 'confirm text yes';

		$!session.accept-alert;
		sleep 1;

		is $!session.alert-text, 'no', 'confirm text no';

		$!session.dismiss-alert;
		sleep 1;

		is $!session.alert-text, 'ok', 'prompt text ok';

		$!session.send-alert-text: 'ok response';
		sleep 1;
		$!session.accept-alert;
		sleep 1;

		is $!session.alert-text, 'ok response', 'response recorded';

		$!session.accept-alert;
		sleep 1;

		is $!session.alert-text, 'cancel', 'prompt text cancel';

		sleep 1;
		$!session.send-alert-text: 'cancel response';
		sleep 1;
		$!session.dismiss-alert;

		sleep 1;

		is $!session.alert-text, 'null', 'response not recorded';

		$!session.dismiss-alert;
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Alerts.new: $browser, :$debug, test-root => 'xt'.IO;
}


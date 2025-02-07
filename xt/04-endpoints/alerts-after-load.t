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
	
	
	
	method pre-test { }
	method post-test { }
	
	method test {
		$.driver.navigate: 'file://' ~ $html-file.absolute;

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
		is $.driver.alert-text, 'one', 'alert text one';

		$.driver.accept-alert;
		sleep 1;

		is $.driver.alert-text, 'two', 'alert text two';

		$.driver.dismiss-alert;
		sleep 1;

		is $.driver.alert-text, 'yes', 'confirm text yes';

		$.driver.accept-alert;
		sleep 1;

		is $.driver.alert-text, 'no', 'confirm text no';

		$.driver.dismiss-alert;
		sleep 1;

		is $.driver.alert-text, 'ok', 'prompt text ok';

		$.driver.send-alert-text: 'ok response';
		sleep 1;
		$.driver.accept-alert;
		sleep 1;

		is $.driver.alert-text, 'ok response', 'response recorded';

		$.driver.accept-alert;
		sleep 1;

		is $.driver.alert-text, 'cancel', 'prompt text cancel';

		sleep 1;
		$.driver.send-alert-text: 'cancel response';
		sleep 1;
		$.driver.dismiss-alert;

		sleep 1;

		is $.driver.alert-text, 'null', 'response not recorded';

		$.driver.dismiss-alert;
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Alerts.new: $browser, :$debug, test-root => 'xt'.IO;
}


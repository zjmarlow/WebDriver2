# use v6.e.PREVIEW;

use experimental :rakuast;

use Test;

use lib <scratch>;

use ptma;

use ptm; # CI.new, CS.new;

.browser.say with WD2P::Session.new: id => 'a', browser => 'chrome';

my WD2P::Driver $driver =
		WD2P::Driver::Provider.get:
				'chrome',
				;
$driver.^name.say;
say $driver.isa: WD2P::Driver;
say join ' ', $driver.host, $driver.port;

# Str.&methods>>.name.sort>>.say;

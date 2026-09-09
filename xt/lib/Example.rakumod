use WD2::Test::Template;

use WD2::Locators;
use WD2::Wait::Common :presence;

class Example does WD2::Test::Template {
	my IO::Path:D $html-file =
		$*PROGRAM.parent.sibling( 'content' ).add: 'test.html';
	
	has Str:D $.name = 'example';
	has Str:D $.description = 'example test description';
	has Int:D $.plan = 3;

	method init {
		if %*ENV<DRIVER_TESTING> {
			self.WD2::Test::Template::init;
		} else {
			self.diag: 'DRIVER_TESTING was not set';
			self.skip: 'DRIVER_TESTING was not set';
			self.done-testing;
			exit;
		}
	}
	
	method test {
		$!session.navigate-to: 'file://' ~ $html-file.absolute;
		self.is: 'title', 'test', $!session.title;
		
		my Duration:D $duration = Duration.new: 5;
		my Duration:D $interval = Duration.new: 1/10;
		my By:D $locator = By.id: 'DNE';
		my &wait-present = present $!session, $locator, :$duration, :$interval, :soft;
		
		self.lives-ok: 'lives but False for element that DNE', {
			my WD2::Component::Element $element = wait-present;
			self.nok: 'no element found', $element;
		}
	}
}

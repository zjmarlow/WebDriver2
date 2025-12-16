use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;

use WebDriver2::SUT::Tree;
use WebDriver2::SUT::Build;
use WebDriver2::SUT::Service;

use WebDriver2::Test::PO-Test;
use WebDriver2::Test::Config-From-File;

my IO::Path $html-file =
		.add: 'lists.html' with $*PROGRAM.parent.parent.add: 'content';

class Frames-Test-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'frames';
	
	method nav {
		my $url = WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file;
		$!session.navigate: $url.Str;
	}

	method page {
		$!sut.get: self.name;
	}

	method page-frame {
		self.get: 'page-frame';
	}

	method page-h2 {
		self.get: 'page-h2';
	}

	method frame-h2 {
		self.get: 'frame-h2';
	}

	method basic-nesting {
		self.get: 'basic';
	}

	method basic-item {
		self.get: 'basic-item';
	}

	method outer-item {
		self.get: 'outer-item';
	}

	method inner-item {
		self.get: 'inner-item';
	}

	method each-basic ( &action ) {
		for self.get( 'basic-item' ).iterator {
			&action( self );
		}
	}

	method each-outer ( &action ) {
		for self.get( 'outer-item' ).iterator {
			&action( self );
		}
	}

	method each-inner ( &action ) {
		for self.get( 'inner-item' ).iterator {
			&action( self );
		}
	}

	method iframe {
		self.get: 'frame-frame';
	}

	method iframe-h2 {
		self.get: 'iframe-h2';
	}

	method iframe-item {
		self.get: 'iframe-item';
	}

	method iframe-list-h2 {
		self.get: 'iframe-list-h2';
	}

	method iframe-item-h2 {
		self.get: 'iframe-list-h2';
	}

	method iframe-item-p {
		self.get: 'iframe-list-p';
	}
	
	method each-iframe-item ( &action ) {
		.resolve.switch-to with self.get: 'frame-frame';
		for self.get( 'iframe-item' ).iterator {
			&action( self );
		}
	}
}

class Frames-Test does WebDriver2::Test::PO-Test {
	has Str:D $.sut-name = 'frames';
	has Int:D $.plan = 29;
	has Str:D $.name = 'frames';
	has Str:D $.description = 'tests nesting frames';
	
	has Frames-Test-Service $!fs = Frames-Test-Service;
	has Str @!expected = <hey hi bye oye hola adios 喂 你好 再見>;
	
	method services {
		$!fs, \( :$!browser, :$!debug-level )
	}
	
	method pre-test { }
	method post-test { }
	
	method test {
		$!fs.nav;

# 		self.is:
# 				'mainline content parent frame is page and context is body element',
# #				$!service.page,
# 				'body',
# 				$!fs.page-h2.parent-frame.resolve.tag-name.lc;
		self.is:
				'page match',
				$!fs.page.raku,
				$!fs.page-h2.parent-frame.raku;
		self.is:
				'basic content parent frame is page and context is body element',
				$!fs.page.raku,
#				'body',
				$!fs.basic-item.parent-frame.raku; # .resolve.tag-name;
		
		self.is:
				'internal node parent frame is page',
				$!fs.page.raku,
#				'body',
				$!fs.basic-nesting.parent-frame.raku; # .resolve.tag-name;
		
		$!fs.each-basic: {
			self.is:
					'basic items',
					$!fs.page.raku,
					.basic-item.parent-frame.raku;
		};
		
		$!fs.each-outer: {
			$!fs.each-inner: {
				self.is:
						'inner frame content correct',
						@!expected.shift,
						.inner-item.resolve.text;
				self.is:
						'inner item parent frame is page',
						$!fs.page.raku,
						.inner-item.parent-frame.raku; # .resolve;

			}
		}
		self.nok: 'all expected seen', +@!expected;
		self.is:
				'basic frame content parent frame is page',
				$!fs.page.raku,
				$!fs.page-frame.parent-frame.raku; # .resolve;
		self.is:
				'subframe content parent is frame',
				$!fs.page-frame.raku,
				$!fs.frame-h2.parent-frame.raku;
		self.is:
				'iframe beneath frame parent frame is frame',
				$!fs.page-frame.raku,
				$!fs.iframe.parent-frame.raku;
		self.is:
				'iframe h2 parent frame is iframe',
				$!fs.iframe.raku,
				$!fs.iframe-h2.parent-frame.raku;
#		$!fs.iframe.resolve.element:
#				WebDriver2::Command::Element::Locator::Tag-Name.new: 'body';
# 		$!fs.iframe.resolve.switch-to;
		$!fs.each-iframe-item: {
			# fix Frame.resolve, Page.resolve, Internal-Frame.switch-to
			# check parent element for AFrame ( APage is also AFrame )
			# assign expected and actual in vars so corrective frame switching
			#   can be done
			# frame
			# - stack per window
			# frame change events
			# - top / default content - clear stack
			# - navigate - clear stack
			# - refresh - TBD
			# - back / forward - TBD
			# - parent frame - pop
			# - switch to
			#   - ID - must be within present context - push
			#   - index - ???
			self.is:
					'iframe list item parent frame is iframe',
					$!fs.iframe.resolve.switch-to.raku,
					.iframe-item.parent-frame.resolve.raku;
			self.is:
					'iframe list item h2 parent frame is iframe',
					$!fs.iframe.resolve.switch-to.raku,
					.iframe-item-h2.parent-frame.resolve.raku;
			self.is:
					'iframe list item p parent frame is iframe',
					$!fs.iframe.resolve.raku,
					.iframe-item-p.parent-frame.resolve.raku;
		};
	}
}

constant &MAIN = po-test Frames-Test;

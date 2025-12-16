use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;
use WebDriver2::Command::Element::Locator::Xpath;
use WebDriver2::Test::Template;
use WebDriver2::Test::Locating-Test;
use WebDriver2::SUT::Tree;

# can be file path or web address
my WebDriver2::SUT::Tree::URL:D $page =
		WebDriver2::SUT::Tree::URL.new: 'file://xt/content/lists.html';

class Frames-Test does WebDriver2::Test::Template {
	has Int $.plan = 3;
	has Str:D $.name = 'nested frames';
	has Str:D $.description = 'basic frame navigation test';
	
	method pre-test { }
	method post-test { }
	method test {
		$!session.navigate: $page.Str;

# 		.tag-name.say for self.elements-by-xpath: '//*';

		my WebDriver2::Model::Element $el = self.element-by-tag: 'iframe';
		$el.frame.switch-to;
		self.is:
				'in first frame',
				'list frame test',
				.text
		with self.element-by-tag: 'h2'
		;
		$el = self.element-by-tag: 'iframe';
		$el.frame.switch-to;
		$el = self.element-by-tag: 'h2';
		self.is: 'in deepest frame', 'internal frame', $el.text;
		$!session.switch-to-parent;
		$el = self.element-by-tag: 'h2';
		self.is: 'up one frame', 'list frame test', $el.text;
	}
	
	method element-by-id( Str:D $id ) {
		$!session.element:
				WebDriver2::Command::Element::Locator::ID.new: $id;
	}
	method element-by-tag( Str:D $tag-name ) {
		$!session.element:
				WebDriver2::Command::Element::Locator::Tag-Name.new: $tag-name;
	}
	method elements-by-xpath ( Str:D $xpath ) {
		$!session.elements:
				WebDriver2::Command::Element::Locator::Xpath.new: $xpath;
	}
}

constant &MAIN = driver-test Frames-Test;

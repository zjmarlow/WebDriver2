use Test;

use lib <lib t/lib>;

#use WebDriver2::Test::Template;
use WebDriver2::Test::PO-Test;
#use WebDriver2::SUT::Service::Loader;
use WebDriver2::SUT::Service;
use WebDriver2::SUT::Tree;

class Login-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'doc-login';
	
	my IO::Path:D $html-file = $*CWD.add: <xt content doc-login.html>;
	
	has WebDriver2::SUT::Tree::URL:D $.root-url =
			WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file.Str;
	method page { $!sut.get: self.name }
	method log-in ( Str:D $username, Str:D $password ) {
		$!session.navigate: $!root-url.Str;
		.resolve.send-keys: $username with self.get: 'username';
		.resolve.send-keys: $password with self.get: 'password';
		.resolve.click with self.get: 'login-button';
	}
}

class Main-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'doc-main';
	
	method question ( --> Str:D ) {
		.resolve.text with self.get: 'question';
	}
	
	method interesting-text ( --> Str:D ) {
		my Str @text;
		@text.push: .resolve.text with self.get: 'heading';
		@text.push: .resolve.text with self.get: 'pf';
		@text.push: .resolve.text with self.get: 'pl';
		@text.join: "\n";
	}
	
}

class Form-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'doc-form';
	
	method value ( --> Str:D ) {
		.resolve.value with self.get: 'input';
	}
	method first ( &cb ) {
		for self.get('form').iterator {
			return self if &cb( self );
		}
		return Form-Service;
	}
	method each ( &action ) {
		for self.get( 'form' ).iterator {
			&action( self );
		}
	}
}

class Frame-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'doc-frame';
	
	method each-outer ( &cb ) {
		for self.get( 'outer' ).iterator {
			&cb( self );
		}
	}
	
	method each-inner ( &cb ) {
		for self.get( 'inner' ).iterator {
			&cb( self );
		}
	}
	
	method item-text ( --> Str:D ) {
		.resolve.text with self.get: 'inner';
	}
}

class Readme-Test does WebDriver2::Test::PO-Test {
	has Str:D $.sut-name = 'doc-site';
	has Int:D $.plan = 27;
	has Str:D $.name = 'readme example';
	has Str:D $.description = 'service / page object test example';
#	has IO::Path:D $.test-root = $*CWD.add: 'xt';
	has Login-Service $!ls = Login-Service;
	has Main-Service $!ms = Main-Service;
	has Form-Service $!fs-main = Form-Service;
	has Form-Service $!fs-frame = Form-Service;
	has Form-Service $!fs-div = Form-Service;
	has Frame-Service $!frs;
	
	method services {
		$!ls, \( :$!browser, :$!debug ),
		$!ms, \( :$!browser, :$!debug ),
		$!fs-main, \( :$!browser, prefix => '', :$!debug ),
		$!fs-frame, \( :$!browser, prefix => '/iframe', :$!debug ),
		$!fs-div, \( :$!browser, prefix => '/iframe/div', :$!debug ),
		$!frs, \( :$!browser, :$!debug )
	}
	
	method test {
		self.ok: 'page defined', $!ls.page;
		$!ls.log-in: 'user', 'pass';
		
		self.is:
				'sub xpath',
				'subelement test',
				.resolve.text
		with $!ms.get: 'subelement';
		
		my Int:D $i = 3;
		self.is:
				'correct object returned by find first',
				'main-3',
				.value with $!fs-main.first: { not --$i };
		
		self.is:
				'interesting text',
				q:to /END/.trim,
				simple example
				text
				more text
				END

				$!ms.interesting-text;
		
		my Str:D @results =
				'Mirzakhani',
				'Noether',
				'Oh',
				'Delta',
				'Echo',
				'Foxtrot',
				'apple',
				'banana',
				'cantaloupe',
				;
		my Int $els = 9;
		my Bool:D $list-seen = False;
		$!frs.each-outer: {
			$list-seen = True;
			self.is: "correct number of elements left", $els, @results.elems;
			$!frs.each-inner: {
				self.is: "correct inner element : @results[0]", @results.shift,
						.item-text;
			}
			$els -= 3;
		}
		self.ok: 'outer', $list-seen;
		self.is: '$els decremented', 0, $els;
		self.is: '@results empty', 0, @results.elems;
		
		@results = 'main-1', 'main-2', 'main-3', 'main-4';
		
		$!fs-main.each: { self.is: 'correct form element', @results.shift, .value };
		self.is: '@results empty', 0, @results.elems;
		
		self.is: 'first frame form is head', 'head', $!fs-frame.value;
		self.is: 'main page form', 'main-1', $!fs-main.first({ True; }).value;
		self.is: 'final frame form is foot', 'foot', $!fs-div.value;
	}
}

constant &MAIN = po-test Readme-Test;

use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Test::Config-From-File;

use WebDriver2::Test::Template;
use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;

class Browser-Window-Test does WebDriver2::Test::Template does WebDriver2::Test::Config-From-File {
	has Int:D $.plan = 10;
	has Str:D $.name = 'window';
	has Str:D $.description = 'multi-window test';
	
	submethod BUILD (
			WebDriver2::Driver-Actions:D :$!driver,
			IO::Path:D :$!test-root = 'xt'.IO,
			Int:D :$!close-delay = 3,
			Int:D :$!debug = 0
	) { }
	
	method pre-test { }
	method post-test { }
	
	method test {
		my Str $original-window = $!session.window-handle;
		self.is: 'current handle matches original', $original-window, $!session.window-handle;
		my Str @windows = $!session.window-handles;
		self.is: 'only one open', 1, @windows.elems;
		self.is: 'only one open matches original', $original-window, @windows[0];
		my %new-window = $!session.new-window;
		self.is: 'new tab', 'tab', %new-window<type>;
		self.ok: 'new handle different from original',
				%new-window<handle> && ( %new-window<handle> ne $original-window );
		@windows = $!session.window-handles;
		self.is: 'number of handles', 2, @windows.elems;
		my %windows = @windows.map: * => True;
		self.ok: 'original included', %windows{ $original-window }:exists;
		self.ok: 'new one included', %windows{ %new-window<handle> }:exists;
		$!session.switch-to-window: %new-window<handle>;
		# TODO : check content
		$!session.close-window;
		@windows = $!session.window-handles;
		self.is: 'only one open again', 1, @windows.elems;
		self.is: 'only one open matches original', $original-window, @windows[0];
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Browser-Window-Test.new: $browser, :$debug, test-root => 'xt'.IO;
}

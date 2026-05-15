use WD2::Test::Template;

class Example does WD2::Test::Template {
	my IO::Path:D $html-file =
		$*PROGRAM.parent.sibling( 'content' ).add: 'test.html';
	
	has Str:D $.name = 'example';
	has Str:D $.description = 'example test description';
	has Int:D $.plan = 1;
	
	method test {
		$!session.navigate-to: 'file://' ~ $html-file.absolute;
		self.is: 'title', 'test', $!session.title;
	}
}

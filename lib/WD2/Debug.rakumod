enum Level ( OFF => -3, ERR => -1, WARN => 0, Info => 1, trace => 2, extra => 3 );

unit role WebDriver2::Test::Debugging;

has Level:D $.debug-level is rw is built = Level::WARN;

method !frame ( --> Backtrace::Frame ) {
	my Backtrace:D $b = Backtrace.new: 4;
	my Int:D $i = 0;
	my Backtrace::Frame $f;
	Nil while $f =
		$b.list[$i = $b.next-interesting-index: $i, :named, :noproto, :setting]
				and do $f.subname ~~ /debug/ or $f.file ~~ /SETTING/
				;
	$f;
}

method !debug ( Level:D $sev, Str:D $msg, *@msg ) {
	return unless $sev <= $!debug-level;
	say join ' ', .file, .subname, .line with self!frame;
	say "\t", $sev.Str, "\t",
		join ' ', $msg, |@msg.map: { .defined ?? .Str !! .raku };
}

multi method debug ( Level:D $sev, Str:D $msg, *@msg ) {
	self!debug: $sev, $msg, |@msg;
}

multi method debug ( Str:D $msg, *@msg ) {
	self!debug: Level::Info, $msg, |@msg;
}

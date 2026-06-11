use Test;

unit role WD2::Test::Adapter;

method subtest ( Pair $test ) {
	my Bool $result = ? subtest $test;
	self.handle-test-failure: $test.key unless $result;
	$result;
}

method ok ( Str:D $descr, $val ) is test-assertion {
	my Bool $result = ok $val, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method nok ( Str:D $descr, $val ) is test-assertion {
	my Bool $result = nok $val, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method is ( Str:D $descr, $exp, $got ) is test-assertion {
	my Bool $result = is $got, $exp, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method isnt ( Str:D $descr, $exp, $got ) is test-assertion {
	my Bool $result = isnt $got, $exp, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method is-deeply ( Str:D $descr, $exp, $got ) is test-assertion {
	my Bool $result = is-deeply $got, $exp, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method isa-ok ( Str:D $descr, $exp, $got ) is test-assertion {
	my Bool $result = isa-ok $got, $exp, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method cmp-ok ( Str:D $descr, $exp, &op, $got ) is test-assertion {
	my Bool $result = cmp-ok $got, &op, $exp, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method does-ok ( Str:D $descr, $exp, $got ) is test-assertion {
	my Bool $result = does-ok $got, $exp, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method lives-ok ( Str:D $descr, &cb ) is test-assertion {
	my Bool $result = lives-ok &cb, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method dies-ok ( Str:D $descr, &cb ) is test-assertion {
	my Bool $result = dies-ok &cb, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method throws-like ( Str:D $reason, $ex-type, $code, *%matcher ) is test-assertion {
	my $result = throws-like $code, $ex-type, $reason, |%matcher;
	self.handle-test-failure: $reason unless $result;
	$result;
}

method fails-like ( Str:D $reason, $ex-type, $code, *%matcher ) is test-assertion {
	my $result = fails-like $code, $ex-type, $reason, |%matcher;
	self.handle-test-failure: $reason unless $result;
	$result;
}

method diag ( Str:D $msg ) {
	diag $msg;
}

method skip ( Str $reason, Int $count? ) {
	skip ( !$count.defined ?? $reason !! ( $reason, $count ) );
}

method skip-rest ( Str $reason ) {
	skip-rest $reason;
}

method todo ( Str $reason, Int $count = 1 ) {
	todo $reason, $count;
}

method pass ( Str $reason? ) {
	$reason.defined ?? pass $reason !! pass;
}

method flunk ( Str:D $descr ) {
#	self.handle-test-failure: $descr;
	flunk $descr;
}

method bail ( Str:D $descr ) {
#	self.handle-test-failure: $descr;
	bail-out $descr;
}

method done-testing {
	done-testing;
}

method handle-test-failure ( Str:D $descr ) { ... }

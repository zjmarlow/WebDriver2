use WD2::Wait :ALL;

our sub present ( @types, &operation ) is export(:present) {
	sub {
		my $result = .() with throwable &operation;
		return $result unless $result ~~ Exception;
		$result.rethrow unless $result ~~ WD2::Endpoints::Result::X;
		$result.rethrow unless $result.execution-status.type ~~ @types.any;
#		return WD2::Endpoints::Result::X; # False;
		$result;
	}
}

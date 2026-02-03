use WD2::Wait :ALL;
use WD2::Debug;
use WD2::Endpoints;
use WD2::Locators;
use WD2::Component::Element;
use WD2::Component::Session;

our sub present (
		$context where .defined,
		By:D $locator,
		:&cleanup,
		Duration :$duration,
		Duration :$interval,
		Bool :$soft,
		Level :$debug-level
) is export(:presence) {
	my &operation = { $context.present: $locator; };
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	;
	basic &operation, |%args;
}

our sub absent (
		$context where .defined,
		By:D $locator,
		:&cleanup,
		Duration :$duration,
		Duration :$interval,
		Bool :$soft,
		Level :$debug-level
) is export(:presence) {
	my &operation = { so $context.present: $locator; };
	my &expect = <-> $val {
		$val === False
				?? ( $val = True )
				!! ( $val = False )
	};
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	;
	basic &operation, :&expect, |%args;
}

our sub stale (
		WD2::Component::Element:D $element,
		:&cleanup,
		Duration :$duration,
		Duration :$interval,
		Bool :$soft,
		Level :$debug-level
) is export(:presence) {
	my &operation =
			expect-throw-type -> { $element.tag-name }, Array[ Error-Code:D ].new: Stale;
    my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level
	;
	basic &operation, |%args;
}

our sub displayed (
		WD2::Component::Element:D $element,
		:&cleanup,
		Duration :$duration,
		Duration :$interval,
		Bool :$soft,
		Level :$debug-level
) is export(:presence) {
	my &operation = { $element.displayed };
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	;
	basic &operation, |%args;
}

our sub hidden (
		WD2::Component::Element:D $element,
		:&cleanup,
		Duration :$duration,
		Duration :$interval,
		Bool :$soft,
		Level :$debug-level
) is export(:presence) {
	my &operation = { so $element.displayed };
	my &expect = <-> $val {
		$val === False
				?? ( $val = True )
				!! ( $val = False )
	};
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	;
	basic &operation, |%args;
}

our sub value-not-empty (
		WD2::Component::Element:D $element,
		:&cleanup,
		Duration :$duration,
		Duration :$interval,
		Bool :$soft,
		Level :$debug-level
) is export(:value) {
	my &operation = { $element.value; };
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	;
	basic &operation, |%args;
}

our sub value-to-be (
		WD2::Component::Element:D $element,
		Str $value,
		:&cleanup,
		Duration :$duration,
		Duration :$interval,
		Bool :$soft,
		Level :$debug-level
) is export(:value) {
	my &operation = { $element.value eq $value; };
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	;
	basic &operation, |%args;
}

our sub text-to-be (
		WD2::Component::Element:D $element,
		Str $text,
		:&cleanup,
		Duration :$duration,
		Duration :$interval,
		Bool :$soft,
		Level :$debug-level
) is export(:value) {
	my &operation = { $element.text eq $text; };
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	;
	basic &operation, |%args;
}

our sub title-to-be (
		WD2::Component::Session:D $session,
		Str $title,
		:&cleanup,
		Duration :$duration,
		Duration :$interval,
		Bool :$soft,
		Level :$debug-level
) is export(:value) {
	my &operation = { $session.title eq $title; };
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	;
	basic &operation, |%args;
}

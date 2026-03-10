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
	base-wait &operation, |%args;
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
	my &operation = { $context.present: $locator; };
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	;
	basic-to-true &operation, |%args;
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
	base-wait &operation, |%args;
}

our sub displayed (
		WD2::Component::Element:D $element,
		:&cleanup,
		Duration :$duration,
		Duration :$interval,
		Bool :$soft,
		Level :$debug-level
) is export(:presence) {
	my &operation = { $element.is-displayed };
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	;
	basic-so-true &operation, |%args;
}

our sub hidden (
		WD2::Component::Element:D $element,
		:&cleanup,
		Duration :$duration,
		Duration :$interval,
		Bool :$soft,
		Level :$debug-level
) is export(:presence) {
	my &operation = { $element.is-displayed };
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	;
	basic-to-true &operation, |%args;
}

our sub value-not-empty (
		WD2::Component::Element:D $element,
		:&cleanup,
		Duration :$duration,
		Duration :$interval,
		Bool :$soft,
		Level :$debug-level
) is export(:value) {
	my &operation = { $element.value };
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	;
	basic-so-true &operation, |%args;
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
	my &operation = { $element.value };
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	;
	basic-equals &operation, $value, |%args;
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
	my &operation = { $element.text };
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	;
	basic-equals &operation, $text, |%args;
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
	my &operation = { $session.title };
	my %args =
		grep *.value.defined,
		do :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
	;
	basic-eq &operation, $title, |%args;
}

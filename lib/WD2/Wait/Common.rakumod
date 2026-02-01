use WD2::Wait :ALL;
use WD2::Debug;
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
	basic &operation, :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
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
	    expect-throw-type { $element.tag-name; },
            'stale element reference';
    basic &operation, :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
}

our sub displayed (
		WD2::Component::Element:D $element,
		:&cleanup,
		Duration :$duration,
		Duration :$interval,
		Bool :$soft,
		Level :$debug-level
) is export(:presence) {
	my &operation = { $element.displayed; };
	basic &operation, :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
}

our sub not-displayed (
		WD2::Component::Element:D $element,
		:&cleanup,
		Duration :$duration,
		Duration :$interval,
		Bool :$soft,
		Level :$debug-level
) is export(:presence) {
	my &operation = { not $element.displayed; };
	basic &operation, :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
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
	basic &operation, :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
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
	basic &operation, :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
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
	basic &operation, :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
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
	basic &operation, :&cleanup, :$duration, :$interval, :$soft, :$debug-level;
}

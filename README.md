# WebDriver2

WebDriver level 2 bindings implementing
[W3C's specification](https://www.w3.org/TR/webdriver2/).
Current implementation status is
[documented below](#implementation-status).

## Usage

### Using a driver directly

To use a driver directly for driver-level [endpoint commands](#implementation-status), request a `WD2::Component::Driver`
with `Provider.get-driver: $browser, :$port`.  The test class
will need to specify the browser and port upon instantiation:

	use WD2;
	use WD2::Component::Driver;
	
	my WD2::Component::Driver:D $driver =
		Provider.get-driver: 'chrome', port => 9515;

Most commands are Session or Element endpoints, though:

	use WD2::Component::Session;
	
	my WD2::Component::Session:D $session =
		$driver.new-session: %optional-capabilities-options;
	
	$session.navigate-to: $url-as-Str; # can be file path or web address

If no capabilities are given, the minimum, empty default will be supplied: `{ capabilities => { } }`.  Please see specification(s) for capability availability and format.

Some Element endpoints:

	use WD2::Component::Element;
	
	use WD2::Locators;
	
	my WD2::Component::Element:D $element =
		$session.find-element: By::ID.value: 'identifier';
	$element.click;

In addition to locating Elements by ID, the standard locators are available:

	$element = $session.find-element: By::Tag.value: 'input';
	$element = $session.find-element: By::CSS.value: 'body > div.head'; # by CSS selector
	# also By::Link-Text, By::Partial-Link-Text, By::XPath

When finished:

	$session.delete;

### Convenience Methods and Routines

#### Methods

Some Session and Element convenience methods have been provided that are not part of the WebDriver2 specification.  They are [listed below](#implementation-status) at the end of the implementation status section.

#### Wait Routines

Since waiting for a condition to be true before moving to the next step is useful, several routines that poll state have also been provided:

	# relevant imports and declarations completed above
	use WD2::Wait::Common :ALL;
	
	my &wait-present = present $session, $locator, duration => 5, interval => 1/10, :soft;
	# do something...
	# then wait for 5 seconds, polling every .1 second,
	#   for an element to appear; don't throw an exception if it doesn't
	&wait-present();
	
	my WD2::Component::Element $element =
		$session.find-element: By::ID.value: 'gets-removed';
	my &wait-stale = stale $element;
	# do something...
	# then wait for the element to be removed using default values;
	#   throw Timeout exception if it isn't
	&wait-stale();
	
	my WD2::Component::Element $updatable =
		$session.find-element: By::ID.value: 'updatable';
	my WD2::Component::Element $input =
		$session.find-element: By::ID.value: 'text-input';
	my WD2::Component::Element $updater =
		$session.find-element: By::Tag.value: 'button';
	my &wait-updated = text-to-be $updatable, 'new text';
	$input.send-keys: 'new text';
	$updater.click;
	&wait-updated();

[List](#wait-status) with implementation status given below the endpoints table.

## TODO

- [ ] cover all implemented endpoints with unit tests
- [ ] add Rakudoc
- [ ] browser support
- [ ] implement the rest of the endpoints

### Feedback

Suggestions, design recommendations, and feature requests
welcome.

### Implementation Status
- "" - Planned
- NYI - will throw exception
- I - Implemented
- &check; - Implemented and tested

<table><tbody>
	<tr class="os">
		<th>&nbsp;</th>
		<th class="browser">Windows</th>
		<th class="browser" colspan="2">Windows / Linux</th>
		<th class="browser">MacOS</th>
		<th>&nbsp;</th>
	</tr>
	<tr class="header">
		<th>endpoint</th>
		<th class="browser">edge</th>
		<th class="browser">chrome</th>
		<th class="browser">firefox</th>
		<th class="browser">safari</th>
		<th>method</th>
	</tr>
	<tr><td>new session</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">&check; (W), I (L)</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$driver.new-session: { capabilities => { ... } }</code></td>
	</tr>
	<tr><td>delete session</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">&check; (W), I (L)</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.delete</code></td>
	</tr>
	<tr><td>status</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$driver.status</code></td>
	</tr>
	<tr><td>get timeouts</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.get-timeouts</code></td>
	</tr>
	<tr><td>set timeouts</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.set-timeouts: Int $script, Int $page-load, Int $implicit</code></td>
	</tr>
	<tr><td>navigate to</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">&check; (W), I (L)</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.navigate-to: Str $url</code></td>
	</tr>
	<tr><td>get current url</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.current-url</code></td>
	</tr>
	<tr><td>back</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.back</code></td>
	</tr>
	<tr><td>forward</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.forward</code></td>
	</tr>
	<tr><td>refresh</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.refresh</code></td>
	</tr>
	<tr><td>get title</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">&check; (W), I (L)</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.title</code></td>
	</tr>
	<tr><td>get window handle</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.get-window-handle</code></td>
	</tr>
	<tr><td>close window</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.close-window</code></td>
	</tr>
	<tr><td>switch to window</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.switch-to-window: $handle</code></td>
	</tr>
	<tr><td>get window handles</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.window-handles</code></td>
	</tr>
	<tr><td>new window</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.new-window: Str $type? where &lt;tab window&gt;.any</code></td>
	</tr>
	<tr><td>switch to frame</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">&check; (W), I (L)</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.switch-to: Int $frame-id</code>
			<code>$frame-element.switch-to</code>
		</td>
	</tr>
	<tr><td>switch to parent frame</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.switch-to-parent-frame</code></td>
	</tr>
	<tr><td>get window rect</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.get-window-rect</code></td>
	</tr>
	<tr><td>set window rect</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.set-window-rect: Int $width, Int $height, Int $x, Int $y</code></td>
	</tr>
	<tr><td>maximize window</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.maximize-window</code></td>
	</tr>
	<tr><td>minimize window</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.minimize-window</code></td>
	</tr>
	<tr><td>fullscreen window</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.fullscreen-window</code></td>
	</tr>
	<tr><td>get active element</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.active-element</code></td>
	</tr>
	<tr><td>get element shadow root</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td class="not-started">&nbsp;</td>
		<td class="not-started">&nbsp;</td>
		<td><code>$element.shadow-root</code></td>
	</tr>
	<tr><td>find element</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">&check; (W), I (L)</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.find-element: By $locator</code></td>
	</tr>
	<tr><td>find elements</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.find-elements: By $locator</code></td>
	</tr>
	<tr><td>find element from element</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.find-element: By $locator</code></td>
	</tr>
	<tr><td>find elements from element</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.find-elements: By $locator</code></td>
	</tr>
	<tr><td>find element from shadow root</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td class="not-started">&nbsp;</td>
		<td class="not-started">&nbsp;</td>
		<td><code>$shadow-root.find-element: By $locator</code></td>
	</tr>
	<tr><td>find elements from shadow root</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td class="not-started">&nbsp;</td>
		<td class="not-started">&nbsp;</td>
		<td><code>$shadow-root.find-elements: By $locator</code></td>
	</tr>
	<tr><td>is element selected</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.is-element-selected</code></td>
	</tr>
	<tr><td>get element attribute</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">&check; (W), I (L)</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.attribute: Str $name</code></td>
	</tr>
	<tr><td>get element property</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.property: Str $name</code></td>
	</tr>
	<tr><td>get element css value</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.css-value: Str $css-prop</code></td>
	</tr>
	<tr><td>get element text</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.text</code></td>
	</tr>
	<tr><td>get element tag name</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.tag-name</code></td>
	</tr>
	<tr><td>get element rect</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.rect</code></td>
	</tr>
	<tr><td>is element enabled</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.is-enabled</code></td>
	</tr>
	<tr><td>get computed role</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.computed-role</code></td>
	</tr>
	<tr><td>get computed label</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.computed-label</code></td>
	</tr>
	<tr><td>element click</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.click</code></td>
	</tr>
	<tr><td>element clear</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.clear</code></td>
	</tr>
	<tr><td>element send keys</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.send-keys: Str $text</code></td>
	</tr>
	<tr><td>get page source</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.page-source</code></td>
	</tr>
	<tr><td>execute script</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.execute-script: Str $scr, @args</code></td>
	</tr>
	<tr><td>execute async script</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.execute-async-script: Str $scr, @args</code></td>
	</tr>
	<tr><td>get all cookies</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.get-all-cookies</code></td>
	</tr>
	<tr><td>get named cookie</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.get-named-cookie: Str $name</code></td>
	</tr>
	<tr><td>add cookie</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.add-cookie: %cookie-spec</code>
		<p>keys:</p>
		<code>name</code>*
		<code>value</code>*
		<code>path</code>
		<code>domain</code>
		<code>secure</code>
		<code>httpOnly</code>
		<code>expiry</code>
		<code>sameSite</code>
		<p>* required</p>
		</td>
	</tr>
	<tr><td>delete cookie</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.delete-cookie: Str $name</code></td>
	</tr>
	<tr><td>delete all cookies</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.delete-all-cookies</code></td>
	</tr>
	<tr><td>perform actions</td>
		<td align="center" class="not-started">NYI</td>
		<td align="center" class="not-started">NYI</td>
		<td align="center" class="not-started">NYI</td>
		<td align="center" class="not-started">NYI</td>
		<td><code>$session.perform-actions</code></td>
	</tr>
	<tr><td>release actions</td>
		<td align="center" class="not-started">NYI</td>
		<td align="center" class="not-started">NYI</td>
		<td align="center" class="not-started">NYI</td>
		<td align="center" class="not-started">NYI</td>
		<td><code>$session.release-actions</code></td>
	</tr>
	<tr><td>dismiss alert</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.dismiss-alert</code></td>
	</tr>
	<tr><td>accept alert</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">&check; (W), I (L)</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.accept-alert</code></td>
	</tr>
	<tr><td>get alert text</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">&check; (W), I (L)</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.alert-text</code></td>
	</tr>
	<tr><td>send alert text</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.send-alert-text: Str $text</code></td>
	</tr>
	<tr><td>take screenshot</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.take-screenshot</code></td>
	</tr>
	<tr><td>take element screenshot</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.take-element-screenshot</code></td>
	</tr>
	<tr><td>print page</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.print-page</code></td>
	</tr>
	<tr><td>displayed ( optional endpoint )</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.displayed</code></td>
	</tr>
	<tr><td>present ( convenience method - not spec'd )</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$session.presen: By $locator; $element.present: By $locator</code></td>
	</tr>
	<tr><td>id ( convenience method - not spec'd )</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$element.id</code></td>
	</tr>
	<tr><td>switch-to ( convenience method - not spec'd )</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$frame-element.switch-to</code></td>
	</tr>
	<tr><td>select ( convenience method - not spec'd )</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$select-element.select: Str $option-text</code></td>
	</tr>
	<tr><td>selected-option ( convenience method - not spec'd )</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$select-element.selected-option</code></td>
	</tr>
	<tr><td>selected-value ( convenience method - not spec'd )</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="complete">I</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$select-element.selected-value</code></td>
	</tr>
</tbody></table>

### Wait Status

- "" - Planned
- I - Implemention completed
- X - Broken / not passing tests
- &check; - Passing

<table>
	<thead>
		<tr>
			<th>routine</th>
			<th>status</th>
			<th>import with</th>
			<th>notes</th>
		</tr>
	</thead>
	<tbody>
		<tr><td>basic</td><td>&check;</td><td><code>use WD2::Wait :basic</code></td><td>base wait routine.  can be used to wait for arbitrary conditions</td></tr>
		<tr><td>present</td><td>&check;</td><td><code>use WD2::Wait::Common :presence</code></td><td></td></tr>
		<tr><td>absent</td><td>&check;</td><td><code>use WD2::Wait::Common :presence</code></td><td></td></tr>
		<tr><td>stale</td><td>&check;</td><td><code>use WD2::Wait::Common :presence</code></td><td></td></tr>
		<tr><td>displayed</td><td>X</td><td><code>use WD2::Wait::Common :presence</code></td><td></td></tr>
		<tr><td>hidden</td><td>X</td><td><code>use WD2::Wait::Common :presence</code></td><td></td></tr>
		<tr><td>value-not-empty</td><td></td><td><code>use WD2::Wait::Common :value</code></td><td></td></tr>
		<tr><td>value-to-be</td><td></td><td><code>use WD2::Wait::Common :value</code></td><td></td></tr>
		<tr><td>text-to-be</td><td></td><td><code>use WD2::Wait::Common :value</code></td><td></td></tr>
		<tr><td>title-to-be</td><td></td><td><code>use WD2::Wait::Common :value</code></td><td></td></tr>
	</tbody>
</table>

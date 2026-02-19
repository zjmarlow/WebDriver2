use WD2::Endpoints;
use WD2::Locators;

class WD2::Component::Element { ... }

class WD2::Component::Shadow does WD2::Endpoints {
	our constant $IDENTIFIER = 'shadow-6066-11e4-a52e-4f735466cecf';

	has WD2::Endpoints:D $.session is required;
	has Str:D $.shadow-id is required;
	method url ( *@command --> Str:D ) {
		$!session.url: 'shadow', $!shadow-id, @command;
	}

	method find-element ( By:D $locator --> WD2::Component::Element:D ) {
		self.find-sub-shadow-element: $locator;
	}
	method find-elements ( By:D $locator --> List:D[ WD2::Component::Element:D ] ) {
		self.find-sub-shadow-elements: $locator;
	}

	multi method find-sub-shadow-element (
			WD2::Component::Shadow:D:
			By:D $locator
			--> WD2::Component::Element:D
	) { WD2::Component::Shadow.find-sub-shadow-element: $locator, self }

	multi method find-sub-shadow-element (
			WD2::Component::Shadow:U:
			By:D $locator,
			WD2::Component::Shadow:D $shadow --> WD2::Component::Element:D
	) {
		my $return = self.check-status:
				self.request: self.post-request: $locator.args, $shadow, 'element';
		return WD2::Component::Element.new:
				host => $shadow.host,
				port => $shadow.port,
				:$locator,
				session => $shadow.session,
				element-id => $return<value>{ $WD2::Component::Element::IDENTIFIER }
		with $return;
		$return.throw;
	}

	multi method find-sub-shadow-elements (
			WD2::Component::Shadow:D:
			By:D $locator,
			--> WD2::Component::Element:D
	) { WD2::Component::Shadow.find-sub-shadow-elements: $locator, self }

	multi method find-sub-shadow-elements (
			WD2::Component::Shadow:U:
			By:D $locator,
			WD2::Component::Shadow:D $shadow
			--> List:D[ WD2::Component::Element:D ]
	) {
		my $return = self.check-status:
				self.request: self.post-request: $locator.args, $shadow, 'elements';
		without $return {
			$return.handled = False;
			return $return;
		}
		my WD2::Component::Element:D @elements = Array[ WD2::Component::Element:D ].new;
		for $return<value>>>.{ $WD2::Component::Element::IDENTIFIER } -> $element-id {
			@elements.push:
					WD2::Component::Element.new:
							host => $shadow.host,
							port => $shadow.port,
							:$locator,
							session => $shadow.session,
							:$element-id
					;
		}
		@elements;
	}
	
	method present (
			WD2::Component::Shadow:D:
			By:D $locator
			--> WD2::Component::Element
	) {
		my WD2::Component::Element:D @elements = self.find-elements: $locator;
		@elements ?? @elements[0] !! WD2::Component::Element;
	}
}

class WD2::Component::Element does WD2::Endpoints is export {
	our constant $IDENTIFIER = 'element-6066-11e4-a52e-4f735466cecf';
	
	has By $.locator;
	has WD2::Endpoints:D $.session is required;
	has Str:D $.element-id is required;
	method url ( *@command --> Str:D ) {
		$!session.url: 'element', $!element-id, @command;
	}
	
	submethod TWEAK {
		unless $!locator {
			with self.attribute: 'id' {
				$!locator = By::ID.value: .self;
			} orwith self.attribute: 'class' {
				$!locator = By::CSS.value: join '.', '', .self.trim.split: /\s+/;
			} else {
				my Str:D $tag = self.tag-name;
				if $tag.lc = 'a' {
					$!locator = By::Link-Text.value: self.text;
				} else {
					$!locator = By::Tag.value: $tag;
				}
			}
		}
	}
	
	method ACCEPTS ( WD2::Component::Element:D: $other ) {
		return False unless $other.defined;
		$!element-id eq $other.element-id;
	}
	
	multi method switch-to (
			WD2::Component::Element:D:
			--> WD2::Endpoints:D
	) { WD2::Component::Element.switch-to: self }
	multi method switch-to (
			WD2::Component::Element:U:
			WD2::Component::Element:D $element
			--> WD2::Endpoints:D
	) {
		my $return = self.check-status:
				self.request:
						self.post-request:
								{
									id => Pair.new:
												$WD2::Component::Element::IDENTIFIER,
												$element.element-id
								},
								$element.session,
								'frame'
								;
		return $element.session with $return;
		$return.throw;
	}
	
	method find-element ( By:D $locator --> WD2::Component::Element:D ) {
		self.find-sub-element: $locator;
	}
	method find-elements ( By:D $locator --> List:D[ WD2::Component::Element:D ] ) {
		self.find-sub-elements: $locator;
	}
	multi method find-sub-element (
			WD2::Component::Element:D:
			By:D $locator,
			--> WD2::Component::Element:D
	) { WD2::Component::Element.find-sub-element: $locator, self }
	
	multi method find-sub-element (
			WD2::Component::Element:U:
			By:D $locator,
			WD2::Component::Element:D $element
			--> WD2::Component::Element:D
	) {
		my $return = self.check-status:
				self.request: self.post-request: $locator.args, $element, 'element';
		return WD2::Component::Element.new:
				host => $element.host,
				port => $element.port,
				:$locator,
				session => $element.session,
				element-id => $return<value>{ $WD2::Component::Element::IDENTIFIER }
		with $return;
		$return.throw;
	}
	
	multi method find-sub-elements (
			WD2::Component::Element:D:
			By:D $locator,
			--> List:D[ WD2::Component::Element:D ]
	) { WD2::Component::Element.find-sub-elements: $locator, self }
	
	multi method find-sub-elements (
			WD2::Component::Element:U:
			By:D $locator,
			WD2::Component::Element:D $element
			--> List:D[ WD2::Component::Element:D ]
	) {
		my $return = self.check-status:
				self.request: self.post-request: $locator.args, $element, 'elements';
		without $return {
			$return.handled = False;
			return $return;
		}
		my WD2::Component::Element:D @elements = Array[ WD2::Component::Element:D ].new;
		for $return<value>>>.{ $WD2::Component::Element::IDENTIFIER } -> $element-id {
			@elements.push:
					WD2::Component::Element.new:
							host => $element.host,
							port => $element.port,
							:$locator,
							session => $element.session,
							:$element-id
					;
		}
		@elements;
	}
	#| checks SUB-element
	method present (
			WD2::Component::Element:D:
			By:D $locator
			--> WD2::Component::Element
	) {
		my WD2::Component::Element:D @elements = self.find-elements: $locator;
		@elements ?? @elements[0] !! WD2::Component::Element;
	}
	
	multi method shadow-root (
			WD2::Component::Element:D:
			--> WD2::Component::Shadow:D
	) { WD2::Component::Element.shadow-root: WD2::Component::Element }
	
	multi method shadow-root (
			WD2::Component::Element:U:
			WD2::Component::Element:D $element --> WD2::Component::Shadow:D
	) {
		my $return = self.check-status: self.request: self.get-request: $element, 'shadow';
		return WD2::Component::Shadow.new:
				host => $element.host,
				port => $element.port,
				session => $element.session,
				shadow-id => $return<value>{ $WD2::Component::Shadow::IDENTIFIER }
		with $return;
		$return.throw;
	}
			
	multi method is-element-selected (
			WD2::Component::Element:D:
			--> Bool:D
	) { WD2::Component::Element.is-element-selected: self }
			
	multi method is-element-selected (
			WD2::Component::Element:U:
			WD2::Component::Element:D $element --> Bool:D
	) {
		my $return = self.check-status: self.request: self.get-request: $element, 'selected';
		return $return<value> unless $return.isa: Exception;
		$return.throw;
	}
	
	multi method is-displayed (
			WD2::Component::Element:D:
			--> Bool:D
	) { WD2::Component::Element.is-displayed: self }
			
	multi method is-displayed (
			WD2::Component::Element:U:
			WD2::Component::Element:D $element --> Bool:D
	) {
		my $return = self.check-status: self.request: self.get-request: $element, 'displayed';
		return $return<value> unless $return.isa: Exception;
		$return.throw;
	}
	
	multi method attribute (
			WD2::Component::Element:D:
			Str:D $name
	) { WD2::Component::Element.attribute: $name, self }
	
	multi method attribute (
			WD2::Component::Element:U:
			Str:D $name,
			WD2::Component::Element:D $element
	) {
		my $return = self.check-status: self.request: self.get-request: $element, 'attribute', $name;
		return $return<value> unless $return.isa: Exception;
		$return.throw;
	}
	method id ( WD2::Component::Element:D: --> Str ) {
		self.attribute: 'id';
	}
	
	multi method property (
			WD2::Component::Element:D:
			Str:D $name
	) { WD2::Component::Element.property: $name, self }
	
	multi method property (
			WD2::Component::Element:U:
			Str:D $name,
			WD2::Component::Element:D $element
	) {
		my $return = self.check-status: self.request: self.get-request: $element, 'property', $name;
		return $return<value> unless $return.isa: Exception;
		$return.throw;
	}
	
	multi method css-value (
			WD2::Component::Element:D:
			Str:D $name,
			--> Str:D
	) { WD2::Component::Element.css-value: $name, self }
	
	multi method css-value (
			WD2::Component::Element:U:
			Str:D $name,
			WD2::Component::Element:D $element --> Str:D
	) {
		my $return = self.check-status: self.request: self.get-request: $element, 'css', $name;
		return $return<value> unless $return.isa: Exception;
		$return.throw;
	}
	
	multi method text (
			WD2::Component::Element:D:
			--> Str:D
	) { WD2::Component::Element.text: self }
	
	multi method text (
			WD2::Component::Element:U:
			WD2::Component::Element:D $element --> Str:D
	) {
		my $return = self.check-status: self.request: self.get-request: $element, 'text';
		return $return<value> unless $return.isa: Exception;
		$return.throw;
	}
	
	multi method tag-name (
			WD2::Component::Element:D:
			--> Str:D
	) { WD2::Component::Element.tag-name: self }
	
	multi method tag-name (
			WD2::Component::Element:U:
			WD2::Component::Element:D $element --> Str:D
	) {
		my $return = self.check-status: self.request: self.get-request: $element, 'name';
		return $return.<value> unless $return.isa: Exception;
		$return.throw;
	}
	
	multi method rect (
			WD2::Component::Element:D:
	) { WD2::Component::Element.rect: self }
	
	multi method rect (
			WD2::Component::Element:U:
			WD2::Component::Element:D $element ) {
		my $return = self.check-status: self.request: self.get-request: $element, 'rect';
		return $return<value> unless $return.isa: Exception;
		$return.throw;
	}
	
	multi method is-enabled (
			WD2::Component::Element:D:
			--> Bool:D
	) { WD2::Component::Element.is-enabled: self }
	
	multi method is-enabled (
			WD2::Component::Element:U:
			WD2::Component::Element:D $element --> Bool:D
	) {
		my $return = self.check-status: self.request: self.get-request: $element, 'enabled';
		return $return<value> unless $return.isa: Exception;
		$return.throw;
	}
	
	multi method computed-role (
			WD2::Component::Element:D:
			--> Str:D
	) { WD2::Component::Element.computed-role: self }
	
	multi method computed-role (
			WD2::Component::Element:U:
			WD2::Component::Element:D $element --> Str:D
	) {
		my $return = self.check-status: self.request: self.get-request: $element, 'computedrole';
		return $return<value> unless $return.isa: Exception;
		$return.throw;
	}
	
	multi method computed-label (
			WD2::Component::Element:D:
			--> Str:D
	) { WD2::Component::Element.computed-label: self }
	
	multi method computed-label (
			WD2::Component::Element:U:
			WD2::Component::Element:D $element --> Str:D
	) {
		my $return = self.check-status: self.request: self.get-request: $element, 'computedlabel';
		return $return<value> unless $return.isa: Exception;
		$return.throw;
	}
	
	multi method click (
			WD2::Component::Element:D:
			--> WD2::Component::Element:D
	) { WD2::Component::Element.click: self }
	
	multi method click (
			WD2::Component::Element:U:
			WD2::Component::Element:D $element --> WD2::Component::Element:D
	) {
		my $return = self.check-status: self.request: self.post-request: { }, $element, 'click';
		return $element unless $return.isa: Exception;
		$return.throw;
	}
	
	multi method clear (
			WD2::Component::Element:D:
			--> WD2::Component::Element:D
	) { WD2::Component::Element.clear: self }
	
	multi method clear (
			WD2::Component::Element:U:
			WD2::Component::Element:D $element --> WD2::Component::Element:D
	) {
		my $return = self.check-status: self.request: self.post-request: { }, $element, 'clear';
		return $element unless $return.isa: Exception;
		$return.throw;
	}
	
	multi method send-keys (
			WD2::Component::Element:D:
			Str:D $text,
			--> WD2::Component::Element:D
	) { WD2::Component::Element.send-keys: $text, self }
	
	multi method send-keys (
			WD2::Component::Element:U:
			Str:D $text,
			WD2::Component::Element:D $element --> WD2::Component::Element:D
	) {
		my $return = self.check-status: self.request: self.post-request: { :$text }, $element, 'value';
		return $element unless $return.isa: Exception;
		$return.throw;
	}
	
	method select ( WD2::Component::Element:D: Str:D $text --> Bool:D ) {
		self.click;
		for self.find-elements: By::Tag.value: 'option' {
			if .text eq $text {
				.click;
				return True;
			}
		}
		False;
	}
	method selected-option ( WD2::Component::Element:D: --> Str ) {
		for self.find-elements: By::Tag.value: 'option' {
			return .text if .is-element-selected;
		}
		Str;
	}
	method selected-value ( WD2::Component::Element:D: --> Str ) {
		for self.find-elements: By::Tag.value: 'option' {
			return .attribute: 'value' if .is-element-selected;
		}
		Str;
	}
	
	method take-screenshot ( --> Str:D ) {
		self.take-element-screenshot;
	}
	
	multi method take-element-screenshot (
			WD2::Component::Element:D:
			--> Str:D
	) { WD2::Component::Element.take-element-screenshot: self }
	
	multi method take-element-screenshot (
			WD2::Component::Element:U:
			WD2::Component::Element:D $element
			--> Str:D
	) {
		my $return = self.check-status: self.request: self.get-request: $element, 'screenshot';
		return $return<value> unless $return.isa: Exception;
		$return.throw;
	}
}

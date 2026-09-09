use JSON::Fast;

class Action::Pause { ... }
class Action::Key { ... }
class Action::Pointer { ... }
class Action::Wheel { ... }

role Action {
	has @.actions;
	
	method args { ... }
}

role Action::Origin {
	method struct { ... }
}

# sub typed-sequence ( ::T Action:U $, T:D @queue --> Array:D[ T:D ] ) { # eventually Array[ T ]
# 	return @queue if @queue < 2;
# 	my T $action = @queue.shift;
# 	my T @sequence;
# 	my @actions = $action.actions;
# 	for @queue -> Action:D $curr {
# 		@actions.append: $curr.actions;
# 	}
# 	say 'pushing final with ', to-json @actions;
# 	@sequence.push: T.new: :@actions;
# 	@sequence;
# }

our proto sub sequence ( ::T Action:D @queue ) {*}

# eventually typed-sequence above
multi sub sequence ( Action::Key:D @queue --> Array:D[ Action::Key:D ] ) {
	return @queue if @queue < 2;
	my Action::Key $action = @queue.shift;
	my Action::Key @sequence;
	my @actions = $action.actions;
	@actions.append: .actions for @queue;
	@sequence.push: Action::Key.new: :@actions;
	@sequence;
}

# eventually typed-sequence above
multi sub sequence ( Action::Pointer:D @queue --> Array:D[ Action::Pointer:D ] ) {
	return @queue if @queue < 2;
	my Action::Pointer $action = @queue.shift;
	my Action::Pointer @sequence;
	my @actions = $action.actions;
	@actions.append: .actions for @queue;
	@sequence.push: Action::Pointer.new: :@actions;
	@sequence;
}

our sub seq-as-arg ( Action:D @seq ) {
	{ actions => [ @seq>>.args ] }
}

# $!wdb.input.performActions: $!context, [ self!click ];
class Action-Factory {
	has Str $.context;
	
	method move ( Int:D :$x, Int:D :$y ) {
		Action::Pointer.new:
				actions => [
					{
						type => 'pointerMove',
						:$x,
						:$y,
					},
				]
		;
	}
	
	method mouse-down {
		Action::Pointer.new:
				actions => [
					{
						type => 'pointerDown',
						button => 0
					},
				]
	}
	
	method mouse-up {
		Action::Pointer.new:
				actions => [
					{
						type => 'pointerUp',
						button => 0
					},
				]
	}
	method click {
		sequence Array[ Action::Pointer:D ].new:
				self.mouse-down,
				self.mouse-up
		andthen .[0];
	}
	
	method scroll (
			Int :$x = 0,
			Int :$y = 0,
			Int :$deltaX = 0,
			Int :$deltaY = 0
	) {
		Action::Wheel.new:
				actions => [
					{
						type => 'scroll',
						:$x,
						:$y,
						:$deltaX,
						:$deltaY
					},
				]
	}
	
	method press { ... }
	method key-down { ... }
	method key-up { ... }
	method type { ... }
	
	method pause {
		
	}
	
	method cmd {
		
	}
}

class Action::Pause does Action {
	method args {
		
	}
}

class Action::Key does Action {
	method args {
		{
			type => 'key',
			id => 'auto-keyboard',
			:@!actions
		}
	}
}

class Action::Pointer does Action {
	method args {
		{
			type => 'pointer',
			id => 'auto-mouse',
			:@!actions
		}
	}
}

class Action::Wheel does Action {
	method args {
		{
			type => 'wheel',
			id => 'auto-wheel',
			:@!actions
		}
	}
}

# $!wdb.input.performActions: $!context, [ self!click ];
class Action-Factory::Element is Action-Factory {
	has Action::Origin:D $.origin is required;
	
	method move ( Int :$x = 0, Int :$y = 0 ) {
		Action::Pointer.new:
				actions => [
					{
						type => 'pointerMove',
						:$x,
						:$y,
						origin => $!origin.struct,
					},
				]
		;
	}
	
	method click ( Int :$x, Int :$y ) {
		my %args = grep *.value.defined, do :$x, :$y;
		sequence Array[ Action::Pointer:D ].new:
				self.move( |%args ),
				self.mouse-down,
				self.mouse-up,
		;
	}
	
	
	
	method key-down ( Str:D $value ) {
		Action::Key.new:
				actions => [
					{
						type => 'keyDown',
						:$value,
					},
				]
	}
	
	method key-up ( Str:D $value ) {
		Action::Key.new:
				actions => [
					{
						type => 'keyUp',
						:$value,
					},
				]
	}
	
	method press ( Str:D $value ) {
		sequence Array[ Action::Key:D ].new:
				self.key-down( $value ),
				self.key-up( $value ),
		;
	}
	
	method type ( Str:D $text ) {
		my Action::Key:D @type := Array[ Action::Key:D ].new;
		@type.append: ( self.key-down: $_ ), ( self.key-up: $_ ) for $text.comb;
		sequence @type;
	}
	
	method scroll ( Int :$x = 0, Int :$y = 0, Int :$deltaX = 0, Int :$deltaY = 0 ) {
		Action::Wheel.new:
				actions => [
					{
						type => 'scroll',
						:$x,
						:$y,
						:$deltaX,
						:$deltaY,
						origin => $!origin.struct,
					},
				]
	}
}

# class Action::Composite does Action {
	
# }

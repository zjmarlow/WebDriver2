# use v6.e.PREVIEW;

use experimental :rakuast;

use Test;

use lib <scratch>;

use ptma;

use ptm; # CI.new, CS.new;

.browser.say with WD2P::Session.new: id => 'a', browser => 'chrome';

my WD2P::Driver $driver = WD2P::Driver::Provider.get: 'chrome', host => 'localhost', port => 3000;
$driver.^name.say;
say $driver.isa: WD2P::Driver;
say join ' ', $driver.host, $driver.port;

# CORE::<::Str>::<&lc>.('LC').say;

# role RSM { # Role from Start to Middle layer
# 	method i ( Int:D $i --> Str:D ) { ... }
# 	method s ( Str:D $s --> Int:D ) { ... }
# }
# class CSM does RSM { # implementation
# 	method i ( Int:D $i --> Str:D ) { $i.base: 16 }
# 	method s ( Str:D $s --> Int:D ) { $s.Int }
# }
# role RMF { # Role from Middle to Final layer
# 	method i ( Str:D $s --> Bool:D ) { ... }
# 	method s ( Int:D $i --> Bool:D ) { ... }
# }
# class CMF does RMF { # implementation
# 	method i ( Str:D $s --> Bool:D ) { $s.say }
# 	method s ( Int:D $i --> Bool:D ) { so $i }
# }
# role RSF { # Role from Start to Final layer
# 	method i ( Int:D $i --> Bool:D ) { ... }
# 	method s ( Str:D $s --> Bool:D ) { ... }
# }
# 
# # role for generating adapter
# role AG[ ::TSF, ::TSM, TSM:D $dsm, ::TMF, TMF:D $dmf ] {
# 	method generate {
# 		class {
# 			# stub for syntax check
# 		} does TSF;
# 	}
# }
# 
# # example needed to inspect generated syntax tree
# class A does RSF {
# 	has RSM:D $!dsm is built is required;
# 	has RMF:D $!dmf is built is required;
# 	
# 	method i ( Int:D $i --> Bool:D ) { $!dmf.i: $!dsm.i: $i }
# 	method s ( Str:D $s --> Bool:D ) { $!dmf.s: $!dsm.s: $s }
# }
# 
# # check that composition works
# my A:D $a = A.new: dsm => CSM.new, dmf => CMF.new;
# $a.i: 161;
# $a.i: 43;
# .raku.say with $a.s: '161';
# .raku.say with $a.s: '0';
# .raku.say with $a.s: '';

# named class
# RakuAST::StatementList.new(
# 	RakuAST::Statement::Expression.new(
# 		expression => RakuAST::Class.new(
# 			name => RakuAST::Name.from-identifier("C"),
# 			body => RakuAST::Block.new(
# 				body => RakuAST::Blockoid.new(
# 					RakuAST::StatementList.new()
# 				)
# 			)
# 		)
# 	)
# );

my $c = RakuAST::StatementList.new(
	RakuAST::Statement::Expression.new(
		expression => RakuAST::Class.new(
			scope => "my",
			body  => RakuAST::Block.new(
				body => RakuAST::Blockoid.new(
					RakuAST::StatementList.new(
						RakuAST::Statement::Expression.new(
							expression => RakuAST::Method.new(
								name => RakuAST::Name.from-identifier("greet"),
								body => RakuAST::Blockoid.new(
									RakuAST::StatementList.new(
										RakuAST::Statement::Expression.new(
											expression => RakuAST::Call::Name::WithoutParentheses.new(
												name => RakuAST::Name.from-identifier("say"),
												args => RakuAST::ArgList.new(
													RakuAST::QuotedString.new(
														segments	 => (
															RakuAST::StrLiteral.new("HI"),
														)
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
		)
	)
).EVAL;

$c.^methods.grep( *.name eq 'greet' ).first.raku.say;

my $d = my class {
	method despedir { say 'adiós' }
}

$d.despedir;

$d.^methods;

# .AST.raku.say with
q:to/CODE/;
my class {
	method greet { say 'HI' }
}
# # role RSM { # Role from Start to Middle layer
# # 	method i ( Int:D $i --> Str:D ) { ... }
# # 	method s ( Str:D $s --> Int:D ) { ... }
# # }
# class CSM #`[ does RSM ] { # implementation
# 	method i ( Int:D $i --> Str:D ) { $i.base: 16 }
# 	method s ( Str:D $s --> Int:D ) { $s.Int }
# }
# # role RMF { # Role from Middle to Final layer
# # 	method i ( Str:D $s --> Bool:D ) { ... }
# # 	method s ( Int:D $i --> Bool:D ) { ... }
# # }
# class CMF #`[ does RMF ] { # implementation
# 	method i ( Str:D $s --> Bool:D ) { $s.say }
# 	method s ( Int:D $i --> Bool:D ) { so $i }
# }
# role RSF { # Role from Start to Final layer
# 	method i ( Int:D $i --> Bool:D ) { ... }
# 	method s ( Str:D $s --> Bool:D ) { ... }
# }
# 
# # role for generating adapter
# role AG[ ::TSF, ::TSM, TSM:D $dsm, ::TMF, TMF:D $dmf ] {
# 	method generate {
# 		my class {
# 			# stub for syntax check
# 		} does TSF;
# 	}
# }
# 
# class A #`[ does RSF ] {
# 	has CSM:D $!dsm is built is required;
# 	has CMF:D $!dmf is built is required;
# 	
# 	method i ( Int:D $i --> Bool:D ) { $!dmf.i: $!dsm.i: $i }
# 	method s ( Str:D $s --> Bool:D ) { $!dmf.s: $!dsm.s: $s }
# }
# 
# # check that composition works
# my A:D $a = A.new: dsm => CSM.new, dmf => CMF.new;
# $a.i: 161;
# $a.i: 43;
# .raku.say with $a.s: '161';
# .raku.say with $a.s: '0';
# .raku.say with $a.s: '';
CODE

# # role RSM { # Role from Start to Middle layer
# # 	method i ( Int:D $i --> Str:D ) { ... }
# # 	method s ( Str:D $s --> Int:D ) { ... }
# # }
# class CSM #`[ does RSM ] { # implementation
# 	method i ( Int:D $i --> Str:D ) { $i.base: 16 }
# 	method s ( Str:D $s --> Int:D ) { $s.Int }
# }
# # role RMF { # Role from Middle to Final layer
# # 	method i ( Str:D $s --> Bool:D ) { ... }
# # 	method s ( Int:D $i --> Bool:D ) { ... }
# # }
# class CMF #`[ does RMF ] { # implementation
# 	method i ( Str:D $s --> Bool:D ) { $s.say }
# 	method s ( Int:D $i --> Bool:D ) { so $i }
# }
# role RSF { # Role from Start to Final layer
# 	method i ( Int:D $i --> Bool:D ) { ... }
# 	method s ( Str:D $s --> Bool:D ) { ... }
# }
# 
# # role for generating adapter
# role AG[ ::TSF, ::TSM, TSM:D $dsm, ::TMF, TMF:D $dmf ] {
# 	method generate {
# 		my class {
# 			# stub for syntax check
# 		} does TSF;
# 	}
# }
# 
# class A #`[ does RSF ] {
# 	has CSM:D $!dsm is built is required;
# 	has CMF:D $!dmf is built is required;
# 	
# 	method i ( Int:D $i --> Bool:D ) { $!dmf.i: $!dsm.i: $i }
# 	method s ( Str:D $s --> Bool:D ) { $!dmf.s: $!dsm.s: $s }
# }
# 
# # check that composition works
# my A:D $a = A.new: dsm => CSM.new, dmf => CMF.new;
# $a.i: 161;
# $a.i: 43;
# .raku.say with $a.s: '161';
# .raku.say with $a.s: '0';
# .raku.say with $a.s: '';

# .AST.say with
# q:to/CODE/;
# use experimental :rakuast;
# 	class { }
# CODE

enum WebDriver2::Command::Execution-Status::Type
	# 200 400 404 405 500 other
	<OK
		Click-Intercepted Not-Interactable
		Insecure-Cert
		Invalid-Arg Invalid-Cookie-Domain Invalid-Element-State
		Invalid-Selector
		
		Invalid-Session-ID No-Alert No-Such-Cookie
		No-Such-Element No-Such-Frame No-Such-Window No-Such-Shadow-Root
		Stale Detached-Shadow-Root
		Unknown-Command
		
		Unknown-Method
		
		JavaScript Target-Bounds Script-Timeout Session-Not-Created
		Unexpected-Alert
		Timeout Cant-Cookie Cant-Screen
		Unknown-Error Unsupported-Operation
	Other>;

class WebDriver2::Command::Execution-Status {
	
	has Cool $.code;
	# TODO : implement OS data ?
	has WebDriver2::Command::Execution-Status::Type:D $.type is required;
	has Str:D $.message is required;
	
	method Str( --> Str:D ) {
		"$!type\n$!message";
	}
	
}

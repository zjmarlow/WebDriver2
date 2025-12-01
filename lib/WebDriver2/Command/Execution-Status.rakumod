enum WebDriver2::Command::Execution-Status::Type
	<OK
		Method
		Intercepted Interactable
		Alert No-Alert Element Frame Window
		Stale Timeout Unexpected
		Session
	Unimplemented
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

our Str enum Error-Code (
		# 200
		OK => 'OK',
		
		# 400
		Click-Intercepted => 'element click intercepted',
		Not-Interactable => 'element not interactable',
		Insecure-Cert => 'insecure certificate',
		Invalid-Arg => 'invalid argument',
		Invalid-Cookie-Domain => 'invaid cookie domain',
		Invalid-Element-State => 'invalid element state',
		Invalid-Selector => 'invalid selector',
		
		# 404
		Invalid-Session-ID => 'invalid session id',
		No-Alert => 'no such alert',
		No-Such-Cookie => 'no such cookie',
		No-Such-Element => 'no such element',
		No-Such-Frame => 'no such frame',
		No-Such-Window => 'no such window',
		No-Such-Shadow-Root => 'no such shadow root',
		Stale => 'stale element reference',
		Detached-Shadow-Root => 'detached shadow root',
		Unknown-Command => 'unknown command',
		
		# 405
		Unknown-Method => 'unknown method',
		
		# 500
		JavaScript => 'javascript error',
		Target-Bounds => 'move target out of bounds',
		Script-Timeout => 'script timeout error',
		Session-Not-Created => 'session not created',
		Unexpected-Alert => 'unexpected alert open',
		Timeout => 'timeout',
		Cant-Cookie => 'unable to set cookie',
		Cant-Screen => 'unable to capture screen',
		Unknown-Error => 'unknown error',
		Unsupported-Operation => 'unsupported operation',
		
		# other
		Other => 'other',
);

class WD2::Endpoints::Execution-Status {
	has Int:D $.status is required;
	# TODO : implement OS data ?
	# has WD2::Endpoints::Execution-Status::Type:D $.type is required;
	has Str:D $.message is required;
	has Str:D %.data;
	
	method Str( --> Str:D ) {
		join "\n",
			$!message,
			%!data ?? %!data.Str !! ''
			;
	}
	
}

class WD2::Endpoints::Error
		is WD2::Endpoints::Execution-Status
{
	has Error-Code:D $.error is required;
	has Str:D $.stacktrace is required;
	
	method Str( --> Str:D ) {
		say 'Error.Str ', $!error.Str;
		join "\n",
			$.status,
			$!error.Str,
			$.message,
			%.data ?? |( $!stacktrace, %.data.Str ) !! $!stacktrace,
			;
	}
}


class WD2::Endpoints::Result::X is Exception {
	has WD2::Endpoints::Error:D $.execution-error is required;
	method message( WD2::Endpoints::Result::X:D: --> Str ) {
		$!execution-error.message
	}
	method ACCEPTS ( $topic ) {
		return False unless $topic.isa: WD2::Endpoints::Result::X;
		$topic.execution-error.status == $!execution-error.status
		and
		$topic.execution-error.error === $!execution-error.error;
	}
}



role WD2::Endpoints {
	use JSON::Fast;
	use HTTP::UserAgent::Strict;
	my HTTP::UserAgent::Strict:D $ua = HTTP::UserAgent::Strict.new;
	
	has Str:D $.host is required = '127.0.0.1';
	has Int:D $.port is required;
	
	method url ( *@command --> Str:D ) { ... }
	
	multi method request ( HTTP::Request::Strict:D $req --> HTTP::Response::Strict:D ) {
		$ua.request: $req;
	}
	
	method check-status ( HTTP::Response::Strict $response ) {
		my $return = from-json $response.content;
		#| as specified in https://w3c.github.io/webdriver/
		#| success for endpoints without natural return values return json null
		return $return // True if $response.code.Int == 200;
		
		fail
				WD2::Endpoints::Result::X.new:
						execution-error =>
							WD2::Endpoints::Error.new:
									status => $response.code,
									error => Error-Code( $return<value><error> ),
									message => $return<value><message> // '',
									stacktrace => $return<value><stacktrace> // '',
									data => $return<value><data> // { }
									;
	}
	
	multi method request ( Str:D $method, WD2::Endpoints:D $endpoint, *@endpoint --> HTTP::Request::Strict:D ) {
		my Str:D $url = $endpoint.url: @endpoint;
		given $method {
			when 'GET' { return HTTP::Request::Strict.new: GET => $url }
			when 'POST' { return HTTP::Request::Strict.new: POST => $url }
			when 'DELETE' { return HTTP::Request::Strict.new: DELETE => $url }
		}
	}
	method get-request ( WD2::Endpoints:D $endpoint, *@endpoint --> HTTP::Request::Strict:D ) {
		self.request: 'GET', $endpoint, @endpoint;
	}
	method post-request ( $data, WD2::Endpoints:D $endpoint, *@endpoint --> HTTP::Request::Strict:D ) {
		my HTTP::Request::Strict $req = self.request: 'POST', $endpoint, @endpoint;
		# $req.field: Connection => 'keep-alive';
		my Str:D $json = to-json $data;
		# debug: Level::extra, $json;
		$req.add-content: $json;
		$req;
	}
	method delete-request ( WD2::Endpoints:D $endpoint, *@endpoint --> HTTP::Request::Strict:D ) {
		self.request: 'DELETE', $endpoint, @endpoint;
	}
}

use HTTP::UserAgent;
use JSON::Fast;

use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;

use WD2::Component;
use WD2::Locators;

my HTTP::UserAgent $ua = HTTP::UserAgent.new;

sub request ( Str:D $method, Command:D $command, *@command --> HTTP::Request:D ) {
    my Str:D $url = $command.url: @command;
    given $method {
        when 'GET' { return HTTP::Request.new: GET => $url }
        when 'POST' { return HTTP::Request.new: POST => $url }
        when 'DELETE' { return HTTP::Request.new: DELETE => $url }
    }
}
sub get-request ( Command:D $command, *@command --> HTTP::Request:D ) {
    request 'GET', $command, @command;
}
sub post-request ( $data, Command:D $command, *@command --> HTTP::Request:D ) {
    my HTTP::Request $req = request 'POST', $command, @command;
    my Str:D $json = to-json $data;
    # debug: Level::extra, $json;
    $req.add-content: $json;
    $req;
}
sub delete-request ( Command:D $command, *@command --> HTTP::Request:D ) {
    request 'DELETE', $command, @command;
}

sub check-status ( HTTP::Response $response ) {
    my $data = from-json $response.content;
    return $data if $response.code.Int == 200;
    
    Failure.new:
            WebDriver2::Command::Result::X.new:
                    execution-status =>
                        WebDriver2::Command::Execution-Status.new:
                                status => $response.code,
                                error => $data<value><error>,
                                message => $data<value><message> // '',
                                stacktrace => $data<value><stacktrace> // '',
                                data => $data<value><data> // { }
                                ;
}

class Driver-Endpoints {
    method status ( Driver:D $driver ) {
        my $data = check-status $ua.request: get-request $driver, 'status';
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    method new-session ( %capabilities, Driver:D $driver --> Session:D ) {
        %capabilities<capabilities> = { } unless %capabilities and %capabilities<capabilities>.isa: Hash;
        my $data = check-status
            $ua.request: post-request %capabilities, $driver, 'session';
        return Session.new:
                :$driver,
                session-id => .<value><sessionId>
        with $data;
        $data.handled = False;
        $data;
    }
}
class Session-Endpoints is export {
    method delete ( Session:D $session --> Driver:D ) {
        my $data = check-status $ua.request: delete-request $session;
        return $session.driver with $data;
        $data.handled = False;
        $data;
    }
    method get-timeouts ( Session:D $session ) {
        my $data = check-status $ua.request: get-request $session, 'timeouts';
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    method set-timeouts (
            Int $script,
            Int $pageLoad,
            Int $implicit,
            Session:D $session
            --> Session:D
    ) {
        my $data = check-status $ua.request:
                post-request {
                    :$script,
                    :$pageLoad,
                    :$implicit
                },
                $session,
                'timeouts'
        ;
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method navigate-to ( Str:D $url, Session:D $session --> Session:D ) {
        my $data = check-status $ua.request: post-request { :$url }, $session, 'url';
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method current-url( Session:D $session --> Str:D ) {
        my $data = check-status $ua.request: get-request $session, 'url';
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    method back ( Session:D $session --> Session:D ) {
        my $data = check-status $ua.request: post-request { }, $session, 'back';
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method forward ( Session:D $session --> Session:D ) {
        my $data = check-status $ua.request: post-request { }, $session, 'forward';
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method refresh ( Session:D $session --> Session:D ) {
        my $data = check-status $ua.request: post-request { }, $session, 'refresh';
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method title ( Session:D $session --> Str:D ) {
        my $data = check-status $ua.request: get-request $session, 'title';
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    method get-window-handle ( Session:D $session --> Str:D ) {
        my $data = check-status $ua.request: get-request $session, 'window';
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    method close-window ( Session:D $session --> Session:D ) {
        my $data = check-status $ua.request: delete-request $session, 'window';
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method switch-to-window ( Str:D $handle, Session:D $session --> Session:D ) {
        my $data = check-status 
                $ua.request: post-request { :$handle }, $session, 'window';
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method get-window-handles ( Session:D $session --> List:D[ Str:D ] ) {
        my $data = check-status $ua.request: get-request $session, <window handles>;
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    method new-window ( Str:D $type where <tab window>.any, Session:D $session ) {
        my %args = ();
        %args{ 'type hint' } = $type if $type;
        my $data = check-status
                $ua.request: %args, post-request $session, <window new>;
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    multi method switch-to-frame ( Session:D $session --> Session:D ) {
        my $data = check-status $ua.request: post-request { }, $session, 'frame';
        return $session with $data;
        $data.handled = False;
        $data;
    }
    multi method switch-to-frame ( Int $frame, Session:D $session --> Session:D ) {
        my $data = check-status 
                $ua.request: post-request { id => $frame }, $session, 'frame';
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method switch-to-parent-frame ( Session:D $session --> Session:D ) {
        my $data = check-status 
                $ua.request: post-request { }, $session, <frame parent>;
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method get-window-rect ( Session:D $session ) {
        my $data = check-status $ua.request: get-request $session, <window rect>;
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    method set-window-rect (
            Int $width,
            Int $height,
            Int $x,
            Int $y,
            Session:D $session
            --> Session:D
    ) {
        my %args = grep *.value.defined, do :$width, :$height, :$x, :$y;
        my $data = check-status
                $ua.request: post-request %args, $session, <window rect>;
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method maximize-window ( Session:D $session --> Session:D ) {
        my $data = check-status
                $ua.request: post-request { }, $session, <window maximize>;
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method minimize-window ( Session:D $session --> Session:D ) {
        my $data = check-status
                $ua.request: post-request { }, $session, <window minimize>;
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method fullscreen-window ( Session:D $session --> Session:D ) {
        my $data = check-status
                $ua.request: post-request { }, $session, <window fullscreen>;
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method active-element ( Session:D $session --> Element:D ) {
        my $data = check-status $ua.request: get-request $session, <element active>;
        return Element.new:
                host => $session.driver.host,
                port => $session.driver.port,
                :$session,
                element-id => $data<value>{ $Element::IDENTIFIER }
        with $data;
        $data.handled = False;
        $data;
    }
    
    method find-element ( By:D $locator, Session:D $session --> Element:D ) {
        my $data = check-status
                $ua.request: post-request $locator.args, $session, 'element';
        return Element.new:
                host => $session.driver.host,
                port => $session.driver.port,
                :$session,
                element-id => $data<value>{ $Element::IDENTIFIER }
        with $data;
        $data.handled = False;
        $data;
    }
    method find-elements (
            By:D $locator,
            Session:D $session
            --> List:D[ Element:D ]
    ) {
        my $data = check-status
                $ua.request: post-request $locator.args, $session, 'elements';
        without $data {
            $data.handled = False;
            return $data;
        }
        my Element:D @elements = Array[ Element:D ].new;
        for $data<value>>>.{ $Element::IDENTIFIER } -> $element-id {
            @elements.push:
                    Element.new:
                            host => $session.driver.host,
                            port => $session.driver.port,
                            :$session,
                            :$element-id
                    ;
        }
        @elements;
    }
    
    method page-source ( Session:D $session --> Str:D ) {
        my $data = check-status $ua.request: get-request $session, 'source';
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    method execute-script (
            Str:D $script,
            @args,
            Session:D $session
    ) {
        my $data = check-status
                $ua.request:
                        post-request
                                { :$script, :@args }, $session, <execute sync>;
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    method execute-async-script (
            Str:D $script,
            @args,
            Session:D $session
    ) {
        my $data = check-status
                $ua.request:
                        post-request
                                { :$script, :@args }, $session, <execute async>;
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    method get-all-cookies ( Session:D $session --> List:D ) {
        my $data = check-status $ua.request: get-request $session, 'cookie';
        return Array.new: |.<value> with $data;
        $data.handled = False;
        $data;
    }
    method get-named-cookie ( Str:D $name, Session:D $session ) {
        my $data = check-status 
                $ua.request: get-request $session, 'cookie', $name;
        return $session with $data;
        $data.handled = False;
        $data;
    }
    =begin table :caption<cookie object structure>
        RFC 6265 Field   | JSON Key | Attribute Key
        =========================================
        name             | name     |
        value            | value    |
        path             | path     | Path
        domain           | domain   | Domain
        secure-only-flag | secure   | Secure
        http-only-flag   | httpOnly | HttpOnly
        expiry-time      | expiry   | Max-Age
        samesite         | sameSite | SameSite
    =end table
    multi method add-cookie (
            Str:D $name,
            Str:D $value,
            %cookie,
            Session:D $session
            --> Session:D
    ) {
        my %args =
            .flat with do grep -> $k, $v { $v.defined and $k, $v },
            .flat with do :$name.kv, :$value.kv,
                %cookie<path domain secure httpOnly expiry sameSite>:kv;
        my $data = check-status
                $ua.request: post-request { cookie => %args }, $session, 'cookie';
        return $session with $data;
        $data.handled = False;
        $data;
    }
    multi method add-cookie (
            Str:D $name,
            Str:D $value,
            Session:D $session
            --> Session:D
    ) {
        my %args = :$name, :$value;
        my $data = check-status
                $ua.request: post-request { cookie => %args }, $session, 'cookie';
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method delete-cookie ( Str:D $name, Session:D $session --> Session:D ) {
        my $data = check-status
                $ua.request: delete-request $session, 'cookie', $name;
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method delete-all-cookies ( Session:D $session --> Session:D ) {
        my $data = check-status $ua.request: delete-request $session, 'cookie';
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method perform-actions ( Session:D $session --> Session:D ) {
        !!! 'nyi'
    }
    method release-actions ( Session:D $session --> Session:D ) {
        !!! 'nyi'
    }
    method dismiss-alert ( Session:D $session --> Session:D ) {
        my $data = check-status
                $ua.request: post-request { }, $session, <alert dismiss>;
        $data.handled = False;
        $data;
    }
    method accept-alert ( Session:D $session --> Session:D ) {
        my $data = check-status
                $ua.request: post-request { }, $session, <alert accept>;
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method get-alert-text ( Session:D $session --> Str:D ) {
        my $data = check-status $ua.request: get-request $session, <alert text>;
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    method send-alert-text ( Str:D $text, Session:D $session --> Session:D ) {
        my $data = check-status
                $ua.request: post-request { :$text }, $session, <alert text>;
        return $session with $data;
        $data.handled = False;
        $data;
    }
    method take-screenshot ( Session:D $session --> Str:D ) {
        my $data = check-status $ua.request: get-request $session, 'screenshot';
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    
    =begin table
        Property       | JSON Key    | Value Type and Valid Values
        ==========================================================
        orientation    | orientation | Str : { portrait ( default ), landscape }
        ==========================================================
        scale          | scale       | Rat : [ 0.1, 2 ] ( default : 1 )
        ==========================================================
        background     | background  | Bool : ( default : False )
        ==========================================================
        pageWidth      | width       | Rat : [ 2.54 / 72, Inf ) ( default : 21.59 )
        ==========================================================
        pageHeight     | height      | Rat : [ 2.54 / 72, Inf ) ( default : 27.94 )
        ==========================================================
        margin         | margin      | JSON Obj : ( default : { } )
        ----------------------------------------------------------
        - marginTop    | top         | Rat : [ 0, Inf ) ( default : 1 )
        ----------------------------------------------------------
        - marginBottom | bottom      | Rat : [ 0, Inf ) ( default : 1 )
        ----------------------------------------------------------
        - marginLeft   | left        | Rat : [ 0, Inf ) ( default : 1 )
        ----------------------------------------------------------
        - marginRight  | right       | Rat : [ 0, Inf ) ( default : 1 )
        ==========================================================
        shrinkToFit    | shrinkToFit | Bool : ( default : True )
        ==========================================================
        pageRanges     | pageRanges  | Array:D[ Int:D ] : ( default : [ ] )
    =end table
    method print-page ( %args, Session:D $session --> Str:D ) {
        my $data = check-status $ua.request: post-request %args, $session, 'print';
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
}
class Element-Endpoints is export {
    method switch-to ( Element:D $element --> Session:D ) {
        my $data = check-status
                $ua.request:
                        post-request
                                { id => $element.element-id },
                                $element.session,
                                'frame'
                                ;
        return $element.session with $data;
        $data.handled = False;
        $data;
    }
    
    method find-sub-element (
            By:D $locator,
            Element:D $element
            --> Element:D
    ) {
        my $data = check-status
                $ua.request: post-request $locator.args, $element, 'element';
        return Element.new:
                host => $element.session.driver.host,
                port => $element.session.driver.port,
                session => $element.session,
                element-id => $data<value>{ $Element::IDENTIFIER }
        with $data;
        $data.handled = False;
        $data;
    }
    
    method find-sub-elements (
            By:D $locator,
            Element:D $element
            --> List:D[ Element:D ]
    ) {
        my $data = check-status
                $ua.request: post-request $locator.args, $element, 'elements';
        without $data {
            $data.handled = False;
            return $data;
        }
        my Element:D @elements = Array[ Element:D ].new;
        for $data<value>>>.{ $Element::IDENTIFIER } -> $element-id {
            @elements.push:
                    Element.new:
                            host => $element.session.driver.host,
                            port => $element.session.driver.port,
                            session => $element.session,
                            :$element-id
                    ;
        }
        @elements;
    }
    
    
    
    method shadow-root ( Element:D $element --> Shadow-Root:D ) {
        my $data = check-status $ua.request: get-request $element, 'shadow';
        return Shadow-Root.new:
                host => $element.session.driver.host,
                port => $element.session.driver.port,
                session => $element.session,
                shadow-id => $data<value>{ $Shadow-Root::IDENTIFIER }
        with $data;
        $data.handled = False;
        $data;
    }
            
    method is-element-selected ( Element:D $element --> Bool:D ) {
        my $data = check-status $ua.request: get-request $element, 'selected';
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    
    method attribute (
            Str:D $name,
            Element:D $element
            --> Str:D
    ) {
        my $data = check-status $ua.request: get-request $element, 'attribute', $name;
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    
    method property (
            Str:D $name,
            Element:D $element
            --> Str:D
    ) {
        my $data = check-status $ua.request: get-request $element, 'property', $name;
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    
    method css-value (
            Str:D $name,
            Element:D $element
            --> Str:D
    ) {
        my $data = check-status $ua.request: get-request $element, 'css', $name;
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    
    method text ( Element:D $element --> Element:D ) {
        my $data = check-status $ua.request: get-request $element, 'text';
        return .<value> with $data;
        $data.Str = False;
        $data;
    }
    
    method tag-name ( Element:D $element --> Str:D ) {
        my $data = check-status $ua.request: get-request $element, 'name';
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    
    method rect ( Element:D $element ) {
        my $data = check-status $ua.request: get-request $element, 'rect';
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    
    method is-enabled ( Element:D $element --> Bool:D ) {
        my $data = check-status $ua.request: get-request $element, 'enabled';
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    
    method computed-role ( Element:D $element --> Str:D ) {
        my $data = check-status $ua.request: get-request $element, 'computedrole';
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    
    method computed-label ( Element:D $element --> Str:D ) {
        my $data = check-status $ua.request: get-request $element, 'computedlabel';
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
    
    method click ( Element:D $element --> Element:D ) {
        my $data = check-status $ua.request: post-request { }, $element, 'click';
        return $element with $data;
        $data.handled = False;
        $data;
    }
    
    method clear ( Element:D $element --> Element:D ) {
        my $data = check-status $ua.request: post-request { }, $element, 'clear';
        return $element with $data;
        $data.handled = False;
        $data;
    }
    
    method send-keys (
            Str:D $text,
            Element:D $element
            --> Element:D
    ) {
        my $data = check-status $ua.request: post-request { :$text }, $element, 'value';
        return $element with $data;
        $data.handled = False;
        $data;
    }
    
    method take-element-screenshot ( Element:D $element --> Str:D ) {
        my $data = check-status $ua.request: get-request $element, 'screenshot';
        return .<value> with $data;
        $data.handled = False;
        $data;
    }
}
class Shadow-Endpoints {
    method find-sub-shadow-element (
            By:D $locator,
            Shadow-Root:D $shadow
            --> Element:D
    ) {
        my $data = check-status
                $ua.request: post-request $locator.args, $shadow, 'element';
        return Element.new:
                host => $shadow.session.driver.host,
                port => $shadow.session.driver.port,
                session => $shadow.session,
                element-id => $data<value>{ $Element::IDENTIFIER }
        with $data;
        $data.handled = False;
        $data;
    }
    
    method find-sub-shadow-elements (
            By:D $locator,
            Shadow-Root:D $shadow
            --> Element:D
    ) {
        my $data = check-status
                $ua.request: post-request $locator.args, $shadow, 'elements';
        without $data {
            $data.handled = False;
            return $data;
        }
        my Element:D @elements = Array[ Element:D ].new;
        for $data<value>>>.{ $Element::IDENTIFIER } -> $element-id {
            @elements.push:
                    Element.new:
                            host => $shadow.session.driver.host,
                            port => $shadow.session.driver.port,
                            session => $shadow.session,
                            :$element-id
                    ;
        }
        @elements;
    }
}

sub EXPORT {
	Map.new:
			Driver-Actions => WD2E::Endpoint::Driver-Endpoints,
			Session-Actions => WD2E::Endpoint::Session-Endpoints,
			Element-Actions => WD2E::Endpoint::Element-Endpoints,
			Shadow-Actions => WD2E::Endpoint::Shadow-Endpoints
}

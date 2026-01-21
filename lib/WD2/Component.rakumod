role Command is export {
    method url ( *@command --> Str:D ) { ... }
}
class Driver does Command is export {
    has Str:D $.host is required = '127.0.0.1';
    has Int:D $.port is required;
    method url ( *@command --> Str:D ) {
        join '/', "http://$!host:$!port", |@command;
    }
}
class Session does Command is export {
    has Driver:D $.driver is required;
    has Str:D $.session-id is required;
    method url ( *@command --> Str:D ) {
        $!driver.url: 'session', $!session-id, @command;
    }
}
class Element does Command is export {
    our constant $IDENTIFIER = 'element-6066-11e4-a52e-4f735466cecf';
    has Session:D $.session is required;
    has Str:D $.element-id is required;
    method url ( *@command --> Str:D ) {
        $!session.url: 'element', $!element-id, @command;
    }
}
class Shadow-Root does Command is export {
    our constant $IDENTIFIER = 'shadow-6066-11e4-a52e-4f735466cecf';
    has Session:D $.session is required;
    has Str:D $.shadow-id is required;
    method url ( *@command --> Str:D ) {
        $!session.url: 'shadow', $!shadow-id, @command;
    }
}

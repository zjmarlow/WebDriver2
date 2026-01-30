use WD2::Component::Driver;

unit class Provider;

my WD2::Component::Driver %driver = (
    chrome => WD2::Component::Driver,
    edge => WD2::Component::Driver,
);
method get-driver (
        Str:D $browser where %driver.keys.any,
        Str:D :$host = '127.0.0.1',
        Int :$port?
        --> WD2::Component::Driver:D
) {
    my %args = :$host;
    %args<port> = $port if $port;
    %driver{ $browser } // %driver{ $browser } = %driver{ $browser }.new: |%args;
}

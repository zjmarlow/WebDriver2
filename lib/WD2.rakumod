use WD2::Component;

unit class Provider;

my Driver %driver = (
    chrome => Driver,
    edge => Driver,
);
method get-driver (
        Str:D $browser where %driver.keys.any,
        Str:D :$host = '127.0.0.1',
        Int :$port?
        --> Driver:D
) {
    my %args = :$host;
    %args<port> = $port if $port;
    %driver{ $browser }
    // %driver{ $browser } = %driver{ $browser }.new: |%args;
}

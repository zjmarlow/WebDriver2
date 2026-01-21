role By {
    has Str:D $.value is built is required;
    method using ( --> Str:D ) { ... }
    method value ( Str:D $value ) { self.bless: :$value }
    method args ( --> Hash:D[ Str:D ] ) {
        { :$.using, :$!value }
    }
}
class By::Tag does By {
    has Str:D $.using = 'tag name';
}
class By::CSS does By {
    has Str:D $.using = 'css selector';
}
class By::ID is By::CSS {
    method value ( Str:D $value ) {
        callwith "#$value";
    }
}
class By::Link-Text does By {
    has Str:D $.using = 'link text';
}
class By::Partial-Link-Text does By {
    has Str:D $.using = 'partial link text';
}
class By::XPath does By {
    has Str:D $.using = 'xpath';
}

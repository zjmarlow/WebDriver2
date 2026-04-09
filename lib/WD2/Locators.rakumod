class By::Tag { ... }
class By::CSS { ... }
class By::ID { ... }
class By::Link-Text { ... }
class By::Partial-Link-Text { ... }
class By::XPath { ... }

class By {
    has Str:D $.value is required is rw;
    method new ( Str:D $value ) { self.bless: :$value }
    method using ( --> Str:D ) { ... }
    method args ( --> Hash:D[ Str:D ] ) {
        { :$.using, :$!value }
    }
    method ACCEPTS ( $o ) {
        $o.isa: By
        and $o.using eq self.using
        and $o.value eq self.value
        ;
    }
    
    submethod tag ( By:U: Str:D $value --> By::Tag:D ) {
        By::Tag.new: $value;
    }
    submethod css ( By:U: Str:D $value --> By::CSS:D ) {
        By::CSS.new: $value;
    }
    submethod id ( By:U: Str:D $value --> By::ID:D ) {
        By::ID.new: $value;
    }
    submethod link-text ( By:U: Str:D $value --> By::Link-Text:D ) {
        By::Link-Text.new: $value;
    }
    submethod partial-link-text ( By:U: Str:D $value --> By::Partial-Link-Text:D ) {
        By::Partial-Link-Text.new: $value;
    }
    submethod xpath ( By:U: Str:D $value --> By::XPath:D ) {
        By::XPath.new: $value;
    }
}
class By::Tag is By {
    has Str:D $.using = 'tag name';
}
class By::CSS is By {
    has Str:D $.using = 'css selector';
}
class By::ID is By::CSS {
    method new ( Str:D $value ) {
        callwith "#$value";
    }
}
class By::Link-Text is By {
    has Str:D $.using = 'link text';
}
class By::Partial-Link-Text is By {
    has Str:D $.using = 'partial link text';
}
class By::XPath is By {
    has Str:D $.using = 'xpath';
}

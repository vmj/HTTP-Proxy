use Test::More tests => 10;

use HTTP::Proxy;
use HTTP::Proxy::HeaderFilter;
use HTTP::Proxy::BodyFilter;

my $stack;
my $hf  = [ sub { 1 }, HTTP::Proxy::HeaderFilter->new() ];
my $hf2 = [ sub { 1 }, HTTP::Proxy::HeaderFilter->new() ];
my $bf  = [ sub { 1 }, HTTP::Proxy::BodyFilter->new() ];

# test general stack workings
$stack = HTTP::Proxy::FilterStack->new();

# all, push
is( scalar $stack->all, 0, "FilterStack is empty" );
$stack->push($hf);
is( scalar $stack->all, 1, "FilterStack has one element" );
$stack->push($hf, $hf);
is( scalar $stack->all, 3, "FilterStack has three elements" );

# insert
$stack->insert(1, $hf2);
is_deeply( [ $stack->all ], [ $hf, $hf2, $hf, $hf ], "FilterStack is correct");

# remove
my $elem = $stack->remove(1);
is( $elem, $hf2, "Got back what was in the stack");

# check insertion in header FilterStack
eval { $stack->push( $bf ); };
like( $@, qr/is not a HTTP::Proxy::HeaderFilter/, "Incorrect Filter class" );

eval { $stack->insert( 0, $bf ); };
like( $@, qr/is not a HTTP::Proxy::HeaderFilter/, "Incorrect Filter class" );

{
   package Foo;
   use base qw( HTTP::Proxy::HeaderFilter );
}

my $foo = [ sub { 1 }, Foo->new() ];
eval { $stack->push( $foo ); };
is( $@, '', "Can push derived Filters" );

# same test for body FilterStack
my $bstack = HTTP::Proxy::FilterStack->new(1);
eval { $bstack->push( $hf ); };
like( $@, qr/is not a HTTP::Proxy::BodyFilter/, "Incorrect Filter class" );

eval { $bstack->insert( 0, $hf ); };
like( $@, qr/is not a HTTP::Proxy::BodyFilter/, "Incorrect Filter class" );

# current
# filter
# filter_last

#!/usr/bin/perl -w
use HTTP::Proxy qw( :log );
use HTTP::Proxy::HeaderFilter::simple;
use strict;

# the encoded user:password pair
my $token = "Basic " . encode_base64( "http:proxy" );
chomp $token;    # grr

# a very simple proxy that requires authentication
# login/password: http/proxy
my $proxy = HTTP::Proxy->new;
$proxy->logmask( shift || NONE );

# the authentication filter
$proxy->push_filter(
    request => HTTP::Proxy::HeaderFilter::simple->new(
        sub {
            my ( $self, $headers, $request ) = @_;
            my $auth = $self->proxy->hop_headers->header('Proxy-Authorization')
              || "";

            # check the credentials
            if ( $auth ne $token ) {
                my $response = HTTP::Response->new(407);
                $response->header(
                    Proxy_Authenticate => 'Basic realm="HTTP::Proxy"' );
                $self->proxy->response($response);
            }
        }
    )
);

$proxy->start;


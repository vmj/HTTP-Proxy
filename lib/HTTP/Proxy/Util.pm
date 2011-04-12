package HTTP::Proxy::Util;

use strict;
use Carp;
use File::Spec;

our %FILENAME_TEMPLATE_ARGS = (
    template => File::Spec->catfile( '%h', '%P' ),
    no_host  => 0,
    no_dirs  => 0,
    cut_dirs => 0,
    prefix   => ''
);

# filename_from_uri( $uri, ... )
sub filename_from_uri {
    my ($uri, %args) = @_;

    my @segs = $uri->path_segments; # starts with an empty string
    shift @segs;
    splice(@segs, 0, $args{cut_dirs} >= @segs
                     ? @segs - 1 : $args{cut_dirs} );
    my %vars = (
        '%' => '%',
        h   => $args{no_host} ? '' : $uri->host,
        f   => $segs[-1] || 'index.html', # same default as wget
        p   => $args{no_dirs} ? $segs[-1] || 'index.html'
                              : File::Spec->catfile(@segs),
        q   => $uri->query,
    );
    pop @segs;
    $vars{d}
        = $args{no_dirs} ? ''
        : @segs          ? File::Spec->catfile(@segs)
        :                '';
    $vars{P} = $vars{p} . ( $vars{q} ? "?$vars{q}" : '' );

    # create the filename
    my $file = File::Spec->catfile( $args{prefix} || (), $args{template} );
    $file =~ s/%(.)/$vars{$1}/g;

    return $file;
}

1;

__END__

=head1 NAME

HTTP::Proxy::Util - Internal utilities

=head1 DESCRIPTION

These procedures are used internally by filters.

=head1 METHODS

The module provides the following methods:

=over 4

=item filename_from_uri( $uri,  )



=back

=head1 AUTHOR

Philippe "BooK" Bruhat, E<lt>book@cpan.orgE<gt>.

=head1 COPYRIGHT

Copyright 2002-2006, Philippe Bruhat.

=head1 LICENSE

This module is free software; you can redistribute it or modify it under
the same terms as Perl itself.

=cut


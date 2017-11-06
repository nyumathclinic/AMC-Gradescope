#!perl -T
=head1 NAME

00-load.t - Test loading of all library modules

=head1 AUTHOR

Matthew Leingang <leingang@nyu.edu>

=cut

use 5.006;
use strict;
use warnings;
use Test::More;

my @modules = qw(AMC::Gradescope Gradescope::Scoresfile 
                       AMC::Import AMC::Import::Gradescope);

plan tests => $#modules + 1;

diag( "Testing AMC::Gradescope $AMC::Gradescope::VERSION, Perl $], $^X" );
foreach (@modules) {
    use_ok $_;
}


#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'AMC::Gradescope' ) || print "Bail out!\n";
}

diag( "Testing AMC::Gradescope $AMC::Gradescope::VERSION, Perl $], $^X" );

#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Data::Dumper;

use Gradescope::ScoresFile;

plan tests => 3;

BEGIN {
    isa_ok(my $gs = Gradescope::ScoresFile::new('t/gs.csv'), 
           'Gradescope::ScoresFile',
           'Object creation');
    is(    $gs->data('total score',23),
           undef,
           'ScoresFile::data returns error on non-unique');
    ok(    $gs->data('total score',23,'all'=>1) == 6,
           'ScoresFile::data with kw all returns all records');
}

# diag( "Testing AMC::Gradescope $AMC::Gradescope::VERSION, Perl $], $^X" );


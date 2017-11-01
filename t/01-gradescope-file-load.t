#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Data::Dumper;

use Gradescope::ScoresFile;

plan tests => 5;

BEGIN {
    isa_ok(my $gs = Gradescope::ScoresFile::new('t/gs.csv'), 
           'Gradescope::ScoresFile',
           'Object creation');
    my $method = 'ScoresFile::data';
    my @result = ();
    is($gs->data('total score',23),
       undef,
       '$method returns error on non-unique');
    @result = $gs->data('email','et1449abc.edu');
    ok(($#result == 0) && ($result[0]->{'name'} eq 'Evanne Ternouth'),
       "$method with unique key returns a single record");
    @result = $gs->data('total score',23,'all'=>1);
    is($#result, 5,
       "$method with keyword 'all' returns all records");
    @result = $gs->data('email','et1449abc.edu','i'=>1);
    ok($#result == 0 && $result[0] == 14,
       "$method with kw 'i' returns an index");
}

diag( "Testing AMC::Gradescope $AMC::Gradescope::VERSION, Perl $], $^X" );

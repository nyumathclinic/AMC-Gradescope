#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Data::Dumper;


plan tests => 6;

BEGIN {
    use Gradescope::ScoresFile;
}

diag( "Testing AMC::Gradescope $AMC::Gradescope::VERSION, Perl $], $^X" );
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

@result = $gs->question_heads;
my @heads = map lc, ('1: Q23 (Canadian postal codes with no restrictions) (5.0 pts)',
                   '2: Q24 (Canadian postal codes with no 0O allowed) (5.0 pts)',
                   '3: Q25 (proposition when n=3 and 4) (4.0 pts)',
                   '4: Q26 (proposition in formal language) (5.0 pts)',
                   '5: Q27 (proof) (5.0 pts)',
                   '6: Q28 (Venn diagram proof of identity) (5.0 pts)',
                   '7: Q29 ($C \subseteq D$ iff what?) (5.0 pts)');
is_deeply(\@result,\@heads);

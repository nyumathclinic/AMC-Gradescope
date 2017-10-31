#!/usr/bin/env perl -w

use Data::Dumper;
use File::Basename qw(dirname);
use FindBin qw($Bin);
use lib dirname($Bin) . '/lib';

use Gradescope::ScoresFile;

my $gs = Gradescope::ScoresFile::new($Bin . "/Midterm_I_Free_Response_scores.csv");
# print Dumper($gs);
print Dumper($gs->data('email','kd1730@nyu.edu'));
print Dumper($gs->data('email','kd1730@nyu.edu','i'=>1)); # (16)
print Dumper($gs->{'heads'});
print Dumper($gs->data('total score','23.0')); # error (6 records)
print Dumper($gs->data('total score','23.0','all'=>1)); # 6 records

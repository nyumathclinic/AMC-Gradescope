package AMC::Import::Gradescope;
# our @ISA=qw(AMC::Import);
use parent 'AMC::Import';

=head1 Name

AMC::Import::Gradescope - Package to import Gradecope scores to an AMC project

=head1 SYNOPSIS

    $importer = AMC::Import::Gradescope::new(\%options);
    $gs = Gradescope::ScoresFile::parse($path)
    $importer->import($gs,$amc_key,$gs_key,$qname_map,\%options)

=cut

=head1 DESCRIPTION

=cut

use strict;
use warnings;
use Data::Dumper;

use AMC::DataModule::capture qw(ZONE_BOX);
# My subclass with a couple of extra methods
use AMC::DataModule::captureplus;

=head2 Constructors

=over 12

=item C<new>

Same as in parent

=cut

# sub new {
#     # FIXME: call super constructor
#     my $class = shift;
#     return $class->SUPER::new(@_);
# }

sub load {
    my $self = shift;
    $self->SUPER::load;
    # rebless attribute to enhanced version.
    bless $self->{'_capture'}, 'AMC::DataModule::captureplus';
    return $self;
}

=back

=head2 Methods

=over 12

=item C<import>

This might be the right way to do it.  Fits an interface.  Literally, the GUI pane I drew up.

args:
  $gs (ref to array of hashrefs): Gradescope data
  $gs_key (string): Gradescope key to be joined
  $amc_key (string): AMC student key to be joined
  $qnames_map (hashref): ref to hash mapping gradescope question titles to AMC question titles

returns: void?

=cut

sub do_import {
    my ($self, $gs, $gs_key, $amc_key, $qnames_map) = @_;
    if (!$self->{'noms'}) { $self->load; }
    my $students = $self->{'noms'};
    my $capture = $self->{'_capture'};
    my $scoring = $self->{'_scoring'};
    my $assoc = $self->{'_assoc'};
    my $qname_map_rev = {};
    # Reverse the hash that $qnames_map points to.
    # There is probably a better way with the reverse function
    # but it's not working for me now.
    while (my($k,$v) = each (%{$qnames_map})) { 
        $qname_map_rev->{$v} = $k;
    }
    # this ought to be lookedup from project options. But it may not even be
    # necessary since we aren't checking whether any boxes are ticked by the
    # student.
    my $darkness_threshold=0.5;

    # Looks weird, but $capture->student_copies does return an array, not a
    # reference to an array.
    for my $sc ($capture->student_copies) {
        my ($sheet, $copy) = @$sc;
        my $ssb=$scoring->student_scoring_base(@$sc,$darkness_threshold,1); 
        my $questions = $ssb->{'questions'};
        while ( my ($amc_qid, $q) = each %{$questions}) {
            # $amc_qid is the question numerical ID, and
            # $q is the question scoring data (see AMC::DataModule::scoring)
            # skip if this question if it's not in the Gradescope question names map
            my $amc_qname = $q->{'title'};
            next unless my $gs_qname = $qname_map_rev->{$amc_qname};

            # Look up the student's score and tick the correct box:
            #
            # 1. Get their AMC numeric id
            # 2. Look up the record in the AMC names file
            # 3. Get their $amc_key value
            # 4. Look up the same value for the $gs_key in the Gradescope scores file
            # 5. Get the score from the Gradescope record
            # 6. Look up the answer id from the question record by matching the score
            # 7. Tick the box corresponding for the corresponding student sheet, copy,
            #    question, and answer.
            my $amcid = $assoc->get_real(@$sc);
            # print "amcid: ", $amcid, "\n";
            # print "gs_qname: ", $gs_qname, "\n";
            my ($student) = $students->data('id' ,$amcid);
            # print "student: ", Dumper($student);
            my ($gs_rec) = $gs->data($gs_key,$student->{$amc_key});
            # print "gs_rec:", Dumper($gs_rec);
            my $score = $gs_rec->{lc($gs_qname)};
            # print "score: ", $score, "\n";
            my $aid = score_to_answerid($q,$score);
            # print "answer id: ", $aid, "\n";
            $capture->set_zone_manual_nopage($sheet, $copy, ZONE_BOX, $amc_qid, $aid, 1);
        }
    }
}


# Look up a questions's answer index from the given score
#
# args:
#   $q (AMC::DataModule::scoring): question
#   $s (number): score
# returns (string): 
#   index of the answer corresponding to that score, or undef if not found
# 
# maybe should extend AMC::DataModule::scoring
# 
# In either case, a private method not for EXPORTing.
sub score_to_answerid {
    my ($q,$s) = @_;
    my $result = -1;
    my @results = grep 
        {substr($_->{'strategy'}, 1) == $s}   
        @{$q->{'answers'}};
    if (!@results) {
        warn "Score '%s' out of range for question '%s'", $s, $q->{'title'};
    }
    else {
        my $r = shift(@results);
        # print "score_to_answerid:r: ", Dumper($r), "\n";
        $result = $r->{'answer'};
    }
    return $result;
}

# This project uses Semantic Versioning <http://semver.org>. Major versions
# introduce significant changes to the API, and backwards compatibility is not
# guaranteed. Minor versions are for new features and backwards-compatible
# changes to the API. Patch versions are for bug fixes and internal code
# changes that do not affect the API. Version 0.x should be considered a
# development version with an unstable API, and backwards compatibility is not
# guaranteed for minor versions.
#
# David Golden's recommendations for version numbers <http://bit.ly/1g8EbKi> 
# are used, e.g. v0.1.2 is "0.001002" and v1.2.3dev4 is "1.002002_004".

our $VERSION = '0.000000_001';
$VERSION = eval $VERSION;  # runtime conversion to numeric value

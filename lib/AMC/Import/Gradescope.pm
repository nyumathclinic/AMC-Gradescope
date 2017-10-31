package AMC::Import::Gradescope;
@ISA=qw(AMC::Import);

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

# My subclass with a couple of extra methods
use AMC::DataModule::capture::plus;

=head2 Constructors

=over 12

=item C<new>

Same as in parent

=cut

sub new {
    # FIXME: call super constructor
}

sub load {
    # FIXME: call super
    # rebless attributes to enhanced versions.
    bless $self->{'_capture'}, 'AMC::DataModule::capture::plus';
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

sub import {
    my ($self, $gs, $gs_key, $amc_key, $qnames_map) = @_;
    my $students = $self->{'noms'};
    my $capture = $self->{'_capture'};
    my $scoring = $self->{'_scoring'}
    my $assoc = $self->{'_assoc'};
    my $qname_map_rev = \{reverse %{$qnames_map}};
    # this ought to be lookedup from project options
    my $darkness_threshold=0.5;

    for my $sc (@{$capture->student_copies}) {
        my ($sheet, $copy) = @$sc;
        my $ssb=$scoring->student_scoring_base(@$sc,$darkness_threshold); 
        my $questions = $ssb->{'questions'};
        while ( my ($amc_qid, $q) = each %{$questions}) {
            # $amc_qid is the question numerical ID, and
            # $q is the question scoring data (see AMC::DataModule::scoring)
            $amc_qname = $q->{'title'};
            $gs_qname = $qname_map_rev->{$amc_qname};
            $amcid = $assoc->get_real(@$sc);
            $student = $students->data('id',$amcid);
            $gs_rec = $gs->data($gs_key,$student->{$amc_key});
            $score = $gs_rec->{$gs_qname};
            $aid = score_to_answerid($q,$score);
            $capture->set_zone_manual_nopage($sheet, $page_num, $copy, ZONE_BOX, $amc_qid, $aid, 1);
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
sub score_to_answerid {
    my ($q,$s) = @_;
    $result = -1;
    @results = grep 
        {substr($_->{'strategy'}, 1) == $s}   
        @{$q->{'answers'}};
    if (!@results) {
        warn "Score '%s' out of range for question '%s'", $score, $q->{'title'};
    }
    return shift(@results);
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

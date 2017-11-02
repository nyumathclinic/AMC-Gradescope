package AMC::DataModule::captureplus;

=head1 NAME

AMC::DataModule::capture::plus - add a few methods to AMC::DataModule::capture

=head1 DESCRIPTION

=cut

use parent "AMC::DataModule::capture";

use strict;
use warnings;
# use Log::Message::Simple qw(warn debug msg); # not in core distro

=head2 Methods

=over 12

=item C<set_zone_manual_nopage($sheet, $copy, $type, $id_a, $id_b, 0):
Set the manual value (ticked or not) for a particular zone.

Same as L<AMC::DataModule::capture> except the page is not supplied.

Arguments: 
=over 18

=item C<$sheet>: string
exam sheet number

=item C<$copy>: string
exam copy number (in case sheets are duplicated)

=item C<$type>: constant
e.g., C<ZONE_BOX> for a box to be ticked

=item C<$id_a>, C<$id_b>: strings 

IDs specifying the zone.  Depends on zone
type. In the case of ticked boxes, C<$id_a> is the question id and C<$id_b> is
the answer index.

=back C<$manual>: int
1 if the box is to be ticked, 0 if not.

=cut

sub set_zone_manual_nopage {
    my ($self,$sheet,$copy,$type,$id_a,$id_b,$manual)=@_;
    my $zoneid = $self->get_zoneid_nopage($sheet, $copy, $type, $id_a, $id_b);
    $self->statement('setZoneManual')->execute($manual,$zoneid);
}

=item C<get_zoneid_nopage>
Get zoneid without knowing page

=cut 

sub get_zoneid_nopage {
    my ($self,$sheet,$copy,$type,$id_a,$id_b,$create)=@_;
    my $pages = $self->get_student_pages($sheet,$copy);
    my $result = undef;
    foreach (@$pages) {
        if (my $zone = $self->get_zoneid($sheet, $_->{'page'}, $copy, $type, $id_a, $id_b)) {
            $result = $zone;
            last; 
        }
    }
    if (!$result) {
        warn "Page not found";
    }
    return $result;
}

=back

=head1 COPYRIGHT

Copyright 2017.

Since AMC is GPL, I guess this package is, too.

=head1 AUTHOR

Matthew Leingang, leingang@nyu.edu

=cut

1;

__END__
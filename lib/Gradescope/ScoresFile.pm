package Gradescope::ScoresFile;

=head1 NAME

Gradescope::ScoresFile - package to parse a Gradescope scores file.

=head1 SYNOPSIS

    gs = Gradescope::ScoresFile::new($path)

=head1 DESCRIPTION

=head2 Constructors

=over 12

=item C<new($file, %opts)>

Arguments:

C<$file>: string path to scores file

C<%opts>: hash of options.  Not sure which are relevant

Returns: reference to an object of this class.

=cut

use strict;
use warnings;
use Data::Dumper;

use Text::CSV;

sub new {
    my ($f,%o)=@_;
    my $self={'fichier'=>$f,
	      'encodage'=>'utf-8',
	      'separateur'=>',',
	      'identifiant'=>'(sid)',

	      # reference to list of column headers
          'heads'=>[],

          # another register for errors
	      'problems'=>{},

	      'numeric.content'=>{},
	      'simple.content'=>{},
	      'err'=>[0,0],
	  };
    for (keys %o) {
	    $self->{$_}=$o{$_} if(defined($self->{$_}));
    }

    bless $self;

    @{$self->{'err'}}=($self->load());

    return($self);

}

=back

=head2 Properties

=over 12

=item C<heads>: array of strings

Column heads from the CSV file

=cut

sub heads {
    my $self = shift;
    return @{$self->{'heads'}};
}


=item C<errors>: array of ... strings?

Get a list of errors, perhaps registered by other methods.

=cut 

sub errors {
    my ($self)=@_;
    return(@{$self->{'err'}});
}


=back

=head2 Methods

=over 12

=item C<load($path,%opts)>

Populates several properties from the file at the specified path.
There may be a need to for public methods getting these properties.

=over 18

=item C<records>: reference to an array of hashrefs

Each hashref is keyed on a column in the CSV file

=item C<heads>: reference to an array of strings

One for each column head in the CSV file

=back 

Modeled on C<AMC::NamesFile::load()>.  That method sets some more
properties, which seem useful but not needed yet:

=over 18

=item C<simple.content>: reference to list of strings

Column heads that have "simple" values useful for keying the 
list of students.

=item C<numeric.content>: reference to a list of strings

Column heads that have numeric values.

=item C<keys>: reference to a list of strings.

Column heads that can serve as keys for the list.

=back

Since the Gradescope File conains both student directory information
and educational information (scores), we might want to add a propety
containing the list of heads which contain those scores

Arguments: none

Returns: C<undef>
    
=cut

sub load {
    my $self = shift;
    my $path = $self->{'fichier'};
    $self->{'records'} = ();
    my $csv = Text::CSV->new({binary=>1, auto_diag=>1});
    open my $fh, "<", $path;
    $csv->header($fh);
    my @heads = $csv->column_names;
    $self->{'heads'} = \@heads;
    while (my $row = $csv->getline_hr($fh)) {
        push @{$self->{'records'}}, $row;
    }
    close $fh;
}

=item C<data($head, $val, %opts)>

Look up records where C<$head> is equal to C<$val>.

Warns and returns C<()> if this doesn't specify a single record.
Setting C<$opts{'all'}> to something true overrides this and 
returns all records matching.

If C<$opts{'i'}> is true, the record indices are returned.
Otherwise, the records (hasrefs) are returned.

See L<AMC::NamesFile::data()>.

Note: Needs testing!

=cut

sub data {
    my ($self, $head, $val, %opts)=@_;
    return() unless defined($val);
    # The implementation is copied from AMC::NamesFile, too.
    # I don't know why a lookup hash isn't used.
    # More space, but less time, right?
    my @k=grep { 
        defined($self->{'records'}->[$_]->{$head})
		&& ($self->{'records'}->[$_]->{$head} eq $val) 
    }
        (0..$#{$self->{'records'}});
    if (($#k!=0) && !$opts{'all'}) {
	    print STDERR "Error: non-unique name (".(1+$#k)." records)\n";
	    return();
	} 
    if($opts{'i'}) {
        return(@k);
    } else {
        return(map { $self->{'records'}->[$_] } @k);
    }
}


=back

=head1 COPYRIGHT

Copyright 2017.

Since AMC is GPL, I guess this package is, too.

=head1 AUTHOR

Matthew Leingang, leingang@nyu.edu

=cut

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

1;

__END__
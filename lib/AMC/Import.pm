package AMC::Import;

=head1 Name

AMC::Import - Package to import scores to an AMC project

=head1 SYNOPSIS

Abstract class.  Here's an example of a descendant package.

    $importer = AMC::Import::Gradescope::new(\%options);
    $gs = Gradescope::ScoresFile::parse($path)
    $importer->import($gs,$amc_key,$gs_key,$qname_map,\%options)

=cut

use strict;
use warnings;

use AMC::Basic;
use AMC::Data;
use AMC::NamesFile;
use AMC::Messages;

use Data::Dumper;
# our @ISA=("AMC::Messages");

=head1 DESCRIPTION

This package is for importing scores to the AMC database "manually"; that is,
not by ticking boxes

=head2 Constructors

=over 12

=item C<new>

Constructor. copied from AMC::Export

Keeping the same interface as that module, must be called by the arrow
operator.

    $importer = AMC::Import->new(%opts)

Important keywords:

=over 18

=item C<datadir>: directory where the data is to be found

=back

=cut 

sub new {
    my $class = shift;
    my %options = @_;

    # some keyval options.  I don't know what most of these do yet,
    # but I'm going to leave them in for now.
    my $self  = {
        # path to the data directory
        'fich.datadir'=>'',

        # path to the names file
        'fich.noms'=>'',

        # names data structure
        'noms'=>'',
        'noms.encodage'=>'',
        'noms.separateur'=>'',
        'noms.useall'=>1,
        'noms.postcorrect'=>'',
        'noms.abs'=>'ABS',
        'noms.identifiant'=>'',

        # This is only needed if we inherit from AMC::Messages
        'messages'=>[],
        };
    bless $self, $class;
    # Translate constructor arguments to object attributes
    my %opts_map = ('datadir'=>'fich.datadir',
                    'students_list'=>'fich.noms');
    while (my ($k,$v) = each(%options)) {
        if (defined $opts_map{$k}) {
            $self->{$opts_map{$k}} = $v;
        }
    }    
    return $self;
}

sub set_options {
    my ($self,$domaine,%f)=@_;
    for(keys %f) {
        my $k=$domaine.'.'.$_;
        if(defined($self->{$k})) {
            debug "Option $k = $f{$_}";
            $self->{$k}=$f{$_};
        } else {
            debug "Unusable option <$domaine.$_>\n";
        }
    }
}

sub opts_spec {
    my ($self,$domaine)=@_;
    my @o=();
    for my $k (grep { /^$domaine/ } (keys %{$self})) {
        my $kk=$k;
        $kk =~ s/^$domaine\.//;
        push @o,$kk,$self->{$k} if($self->{$k});
    }
    return(@o);
}

sub load {
    my ($self)=@_;
    die "Needs data directory" if(!-d $self->{'fich.datadir'});

    $self->{'_data'}=AMC::Data->new($self->{'fich.datadir'});
    $self->{'_scoring'}=$self->{'_data'}->module('scoring');
    $self->{'_assoc'}=$self->{'_data'}->module('association');
    $self->{'_capture'}=$self->{'_data'}->module('capture');
    $self->{'_layout'}=$self->{'_data'}->module('layout');

    if($self->{'fich.noms'} && ! $self->{'noms'}) {
	$self->{'noms'}=AMC::NamesFile::new($self->{'fich.noms'},
					    $self->opts_spec('noms'),
					   );                
    }
}

=back

=head2 Methods

=over 12

=item C<do_import()>

Do the importing (Abstract method.  Needs to be implemented in dependents.)

A better name would be C<import> but that's not allowed!

=cut

sub do_import {
    my $self = shift;
    print "AMC::Import::import is an abstract method. Needs to be implemented\n";
}

=back


=head1 CAVEATS

How to plugin? From Alexis:

There are only two kinds of module:

* Filter modules, to convert an exam from a given format to LaTeX format (such as the plain one, that converts the AMC-TXT source file to a LaTeX file using the automultiplechoice package)
* Export module, that exports marks to a given format (such as the ods, CSV or List ones, that exports marks to a ODS or CSV sheet file, or builds a PDF list with final grades)

In the GUI, an Export module will be accessible in the Reports tab, within the Marks export frame. You could use this kind of modules for your task, but the user will have to build the annotated answer sheets before going back to the Marks export frame to send them, that can be rather misleading. Unfortunately, there are no 'Send' modules…
If you want to go on this way however, you will have to define the following perl modules (assuming you will name your Export module 'webdav'):

C<AMC::Export::register::webdav>, that will define methods to return general information about your module, including fields to be added to the GUI
C<AMC::Export::webdav>, that will define methods to actually do the job sending annotated papers via Webdav.

You can have a look at the corresponding files for the CSV Export module to see how it works — unfortunately I did not write documentation about this process.
You can place your two files at C<~/.AMC.d/plugins/webdav/perl/AMC/Export/register/webdav.pm> and C<~/.AMC.d/plugins/webdav/perl/AMC/Export/webdav.pm> for testing. 

A 'plugin' that can be used by other users is a zip file containing these two files from the C<~/.AMC.d/plugins/> directory point of view.


=head1 COPYRIGHT

Copyright 2017.

Since AMC is GPL, I guess this package is, too.

=head1 AUTHOR

Matthew Leingang, leingang@nyu.edu

=cut

1;

__END__
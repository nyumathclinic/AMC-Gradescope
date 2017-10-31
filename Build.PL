use 5.008;
use strict;
use warnings;

use Module::Build;


my $builder = Module::Build->new(
    module_name => 'AMC::Gradescope',
    license => 'artistic_2',
    dist_author => q(Matthew Leingang <leingang@nyu.edu>),
    dist_version_from => 'lib/AMC/Gradescope.pm',
    release_status => 'unstable',
    recursive_test_files => 1,
    add_to_cleanup => ['_build/', 'blib/', 'MYMETA.*', 'AMC-Gradescope-*'],
);

$builder->create_build_script();

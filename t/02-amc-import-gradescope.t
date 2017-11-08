#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use File::Temp 'tempdir';
use File::Copy 'cp';
use Data::Dumper;

plan tests => 8;

use AMC::Import::Gradescope;
use Gradescope::ScoresFile;

# copy data to temporary directory so we don't spoil it
my $datadir = 't/mc-project/data';
my $students_list = 't/mc-project/amc.csv';


# Yes a glob would be cleaner but it taints.
my $tmpdir = tempdir(CLEANUP=>1);
foreach (qw(association capture layout report scoring)) {
    cp ($datadir . '/' . $_ . '.sqlite', $tmpdir) || BAIL_OUT "Copying $_ to $tmpdir failed: $!";
}

my $noms = AMC::NamesFile::new($students_list);
isa_ok($noms,"AMC::NamesFile") || BAIL_OUT;
is($noms->liste, 44, "AMC::NamesFile::new Loaded 44 names");

my $gs = Gradescope::ScoresFile::new('t/gs.csv');
isa_ok($gs,'Gradescope::ScoresFile') || BAIL_OUT;

my $importer = AMC::Import::Gradescope->new('datadir'=>$tmpdir,'students_list'=>$students_list);
isa_ok($importer, 'AMC::Import::Gradescope');
$importer->load;
isa_ok($importer->{'_capture'},'AMC::DataModule::captureplus');
is($importer->{'noms'}->liste,44,"Importer loaded names file");

my $qmap = {
    '1: Q23 (Canadian postal codes with no restrictions) (5.0 pts)'=>'FR-Canada-ZIP-a',
    '2: Q24 (Canadian postal codes with no 0O allowed) (5.0 pts)'  =>'FR-Canada-ZIP-b',
    '3: Q25 (proposition when n=3 and 4) (4.0 pts)'                =>'FR-proof-a',
    '4: Q26 (proposition in formal language) (5.0 pts)'            =>'FR-proof-b',
    '5: Q27 (proof) (5.0 pts)'                                     =>'FR-proof-c',
    '6: Q28 (Venn diagram proof of identity) (5.0 pts)'            =>'FR-symdiff-vd',
    '7: Q29 ($C \subseteq D$ iff what?) (5.0 pts)'                 =>'FR-inclusion-proof'
};

my $sql_get_manual = "select manual from capture_zone where student=? and copy=0 and id_a=? and id_b=?";
is($importer->{'_capture'}->sql_single($sql_get_manual,28,33,5), -1);
$importer->do_import($gs,'email','email',$qmap);
is($importer->{'_capture'}->sql_single($sql_get_manual,28,33,5), 1);



TODO: {
    local $TODO = "Still working out implementation";
    # skip this if the last test didn't succeed
    todo_skip "Too much output", 2 if ($importer->{'noms'}->liste != 44);

    

}
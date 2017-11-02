#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Data::Dumper;

use AMC::Data;
use AMC::DataModule::captureplus;

my $class = "AMC::DataModule::captureplus";

plan tests => 5;

diag("Testing $class");
use_ok($class);

my $data = AMC::Data->new('t/mc-project/data');
isa_ok ($data, "AMC::Data");

$data->require_module('capture');
my $capture = $data->module('capture');
isa_ok ($capture, 'AMC::DataModule::capture') || diag explain $capture;
bless $capture, $class;
isa_ok ($capture, $class) || diag explain $capture;

my $zone = $capture->get_zoneid_nopage(2,0,AMC::DataModule::capture::ZONE_BOX,31,4);
is($zone,22855) || diag explain "zone: ", $zone;


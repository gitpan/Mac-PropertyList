# $Id: Makefile.PL,v 1.3 2002/08/16 14:37:05 comdog Exp $
use ExtUtils::MakeMaker;

my @Tests = map { "t/$_" } qw(
load.t
parse.t
);

WriteMakefile
	(
    'NAME'	    => 'Mac::PropertyList',
    'VERSION'   => '0.02',
	'PREREQ_PM' => { 'Text::Balanced' => undef },
     'PM'       => {
        'lib/PropertyList.pm'     => '$(INST_LIBDIR)/PropertyList.pm',
         },
     test => { TESTS => join( " ", @Tests ) },
	);


# $Id: Makefile.PL,v 1.4 2002/08/16 17:03:31 comdog Exp $
use ExtUtils::MakeMaker;

my @Tests = map { "t/$_" } qw(
load.t
parse.t
write.t
);

WriteMakefile
	(
    'NAME'	    => 'Mac::PropertyList',
    'VERSION'   => '0.03',
	'PREREQ_PM' => { 'Text::Balanced' => undef },
     'PM'       => {
        'lib/PropertyList.pm'     => '$(INST_LIBDIR)/PropertyList.pm',
         },
     test => { TESTS => join( " ", @Tests ) },
	);


# $Id: Makefile.PL,v 1.12 2004/01/31 17:02:42 petdance Exp $
use ExtUtils::MakeMaker;

WriteMakefile
	(
	'NAME'	         => 'Mac::PropertyList',
	'VERSION_FROM'   => 'lib/PropertyList.pm',
	'PREREQ_PM' => { 
		'File::Find::Rule' => '0',
		'MIME::Base64'     => '0',
		'Test::More'       => '0',
		'Time::HiRes'      => '0',
		},
	'MAN3PODS'		       => {
		'lib/PropertyList.pm'    => '$(INST_MAN3DIR)/Mac::PropertyList.3',
		},
	'PM'        => {
		'lib/PropertyList.pm'     => '$(INST_LIBDIR)/PropertyList.pm',
        },
   
   	clean => { FILES => 'Mac-PropertyList-*' },
   	 
	);


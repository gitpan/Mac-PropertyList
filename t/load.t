# $Id: load.t 1105 2004-02-03 13:08:50Z comdog $

BEGIN { @classes = qw(Mac::PropertyList) }

use Test::More tests => scalar @classes;

foreach my $class ( @classes )
	{
	print "bail out! $class did not compile\n" unless use_ok( $class );
	}

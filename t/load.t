# $Id: load.t,v 1.3 2002/09/02 04:06:11 comdog Exp $
BEGIN {
	use File::Find::Rule;
	@classes = map { my $x = $_;
		$x =~ s|^blib/lib/||;
		$x =~ s|/|::|g;
		$x =~ s|\.pm$||;
		$x;
		} File::Find::Rule->file()->name( '*.pm' )->in( 'blib/lib' );
	}

use Test::Builder;
use Test::More tests => scalar @classes;

foreach my $class ( @classes )
	{
	use_ok( $class ) or Test::Builder->BAILOUT();
	}

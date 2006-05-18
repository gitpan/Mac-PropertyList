# $Id: pod_coverage.t,v 1.3 2006/01/18 02:49:45 comdog Exp $

use Test::More;
eval "use Test::Pod::Coverage";

if( $@ )
	{
	plan skip_all => "Test::Pod::Coverage required for testing POD";
	}
else
	{
	plan tests => 1;

	pod_coverage_ok( "Mac::PropertyList", {
		trustme => [ qr/^read_/, qr/indent/ ],
		},
		);      
	}

# $Id: pod_coverage.t 1728 2006-01-18 02:49:45Z comdog $

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

# $Id: pod.t,v 1.1 2002/08/31 22:17:26 comdog Exp $

BEGIN {
	use File::Find::Rule;
	@files = File::Find::Rule->file()->name( '*.pm' )->in( 'blib/lib' );
	}
	
use Test::Pod tests => scalar @files;

foreach my $file ( @files )
	{
	pod_ok($file);
	}

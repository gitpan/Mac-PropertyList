# $Id: plists.t,v 1.1 2002/09/09 17:30:00 comdog Exp $
BEGIN {
	use File::Find::Rule;
	@plists = File::Find::Rule->file()->name( '*.plist' )->in( 'plists' );
	}

use Test::Builder;
use Test::More tests => scalar @plists;
use Time::HiRes qw(tv_interval gettimeofday);

use Mac::PropertyList;

foreach my $file ( @plists )
	{
	local @ARGV = ($file);
	my $data = do { local $/; <> };
	my $b = length $data;

	my $time1 = [ gettimeofday ];
	my $plist = Mac::PropertyList::parse_plist( $data );
	my $time2 = [ gettimeofday ];

	my $elapsed = tv_interval( $time1, $time2 );
	print STDERR "\n$file [$b bytes] parsed in $elapsed seconds\n";

	isa_ok( $plist, 'HASH' );
	}

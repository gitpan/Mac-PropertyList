# $Id: time.t,v 1.1 2002/09/09 17:30:10 comdog Exp $

use Test::More tests => 1;

use Mac::PropertyList;
use Time::HiRes qw(tv_interval gettimeofday);

my $data = do {
	local @ARGV = qw(plists/com.apple.iTunes.plist);
	do { local $/; <> };
	};

my $time1 = [ gettimeofday ];
my $plist = Mac::PropertyList::parse_plist( $data );
my $time2 = [ gettimeofday ];

my $elapsed = tv_interval( $time1, $time2 );
print STDERR "Elapsed time is $elapsed\n";

ok($elapsed < 3, "Parsing time test");

# $Id: import.t,v 1.1 2004/12/02 09:16:38 comdog Exp $

use Test::More tests => 10;

require_ok( 'Mac::PropertyList' );

ok( ! defined( &parse_plist ), "parse_plist is not defined yet" );
my $result = Mac::PropertyList->import( 'parse_plist' );
ok( defined( &parse_plist ), "parse_plist is now defined" );


foreach my $name ( @Mac::PropertyList::EXPORT_OK )
	{
	next if $name eq 'parse_plist';
	ok( ! defined( &$name ), "$name is not defined yet" );
	}
	
Mac::PropertyList->import( ":all" );

foreach my $name ( @Mac::PropertyList::EXPORT_OK )
	{
	ok( defined( &$name ), "$name is now defined yet" );
	}


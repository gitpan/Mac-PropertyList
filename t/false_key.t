# $Id: false_key.t,v 1.1 2003/01/31 17:20:11 comdog Exp $
BEGIN {
	use File::Find::Rule;
	@plists = File::Find::Rule->file()->name( '*.plist' )->in( 'plists' );
	}

use Test::More tests => scalar @plists;

use Mac::PropertyList;

my $good_dict =<<"HERE";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>0</key>
	<string>Roscoe</string>
	<key> </key>
	<string>Buster</string>
</dict>
</plist>
HERE

my $bad_dict =<<"HERE";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key></key>
	<string>Roscoe</string>
</dict>
</plist>
HERE

my $ok = eval {
	my $plist = Mac::PropertyList::parse_plist( $good_dict );
	};
ok( $ok, "Zero and space are valid key values" );


my $ok = eval {
	my $plist = Mac::PropertyList::parse_plist( $good_dict );
	};
like( $@, 'key not defined', "Empty key causes parse_plist to die" );


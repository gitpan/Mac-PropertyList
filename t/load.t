# $Id: load.t,v 1.1.1.1 2002/08/16 02:26:13 comdog Exp $
BEGIN { $| = 1; print "1..1\n"; }
END   {print "not ok\n" unless $loaded;}

# Test it loads
use Mac::PropertyList;
$loaded = 1;
print "ok\n";

# $Id: container.t,v 1.2 2004/02/03 21:26:40 comdog Exp $

use Test::More tests => 2;

use Mac::PropertyList;

########################################################################
# Test the dict bits
my $dict = Mac::PropertyList::dict->new();
isa_ok( $dict, "Mac::PropertyList::dict" );

########################################################################
# Test the array bits
my $array = Mac::PropertyList::array->new();
isa_ok( $array, "Mac::PropertyList::array" );

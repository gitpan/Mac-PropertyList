use strict;
use warnings;

use Test::More tests => 16;

use File::Spec::Functions;

my $class = 'Mac::PropertyList::ReadBinary';
my @methods = qw( new plist );

use_ok( $class );
can_ok( $class, @methods ); 

my $test_file = catfile( qw( plists the_perl_review.abcdp ) );
ok( -e $test_file, "Test file for binary plist is there" );

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Use it directly
{
my $parser = $class->new( $test_file );
isa_ok( $parser, $class );

my $plist = $parser->plist;
isa_ok( $plist, 'Mac::PropertyList::dict' );

my %keys_hash = map { $_, 1 } $plist->keys;

foreach my $key ( qw(UID URLs Address Organization) )
	{
	ok( exists $keys_hash{$key}, "$key exists" );
	}
	
is(
	$plist->value( 'Organization' ),
	'The Perl Review',
	'Organization returns the right value'
	);
	
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Use it indirectly
{
use Mac::PropertyList qw(parse_plist_file);

my $plist = parse_plist_file( $test_file );
isa_ok( $plist, 'Mac::PropertyList::dict' );

my %keys_hash = map { $_, 1 } $plist->keys;

foreach my $key ( qw(UID URLs Address Organization) )
	{
	ok( exists $keys_hash{$key}, "$key exists" );
	}
	
is(
	$plist->value( 'Organization' ),
	'The Perl Review',
	'Organization returns the right value'
	);
	
}
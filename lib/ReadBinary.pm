package Mac::PropertyList::ReadBinary;
use strict;
use warnings;

use vars qw( $VERSION );

use Carp;
use Data::Dumper;
use Encode qw(decode);
use Mac::PropertyList;
use Math::BigInt;
use MIME::Base64 qw(decode_base64);
use POSIX qw(SEEK_END SEEK_SET);

$VERSION = '1.32';

__PACKAGE__->_run( @ARGV ) unless caller;

=head1 NAME

Mac::PropertyList::ReadBinary - read binary property list files

=head1 SYNOPSIS

	# use directly
	use Mac::PropertyList::ReadBinary;

	my $parser = Mac::PropertyList::ReadBinary->new( $file );
	
	my $plist = $parser->plist;


	# use indirectly, automatically selects right reader
	use Mac::PropertyList;
	
	my $plist = parse_plist_file( $file );
	
=head1 DESCRIPTION

This module is a low-level interface to the Mac OS X Property List
(plist) format.  You probably shouldn't use this in
applications---build interfaces on top of this so you don't have to
put all the heinous multi-level object stuff where people have to look
at it.

You can parse a plist file and get back a data structure. You can take
that data structure and get back the plist as XML (but not binary
yet).  If you want to change the structure inbetween that's your
business. :)

See C<Mac::PropertyList> for more details. 

=head2 Methods

=over 4

=cut

sub _run
	{
	my $parser = $_[0]->new( $_[1] );
	
	print Dumper( $parser->plist );
	}
	
=item new( FILENAME | SCALAR_REF | FILEHANDLE )

Opens the data source, doing the right thing for filenames,
scalar references, or a filehandle.

=cut

sub new {
	my( $class, $source ) = @_;
	
	my $self = bless { source => $source }, $class;
	
	$self->_read;
	
	$self;
	}

sub _source          { $_[0]->{source}             }
sub _fh              { $_[0]->{fh}                 }
sub _trailer         { $_[0]->{trailer}            }
sub _offsets         { $_[0]->{offsets}            }
sub _object_ref_size { $_[0]->_trailer->{ref_size} }

=item plist

Returns the C<Mac::PropertyList> data structure.

=cut

sub plist            { $_[0]->{parsed}             }

sub _object_size 
	{   
	$_[0]->_trailer->{object_count} * $_[0]->_trailer->{offset_size} 
	}

sub _read
	{
	my( $self, $thingy ) = @_;
			
	$self->{fh} = $self->_get_filehandle;
	$self->_read_plist_trailer;
	
	$self->_get_offset_table;
	
    my $top = $self->_read_object_at_offset( $self->_trailer->{top_object} );
    
    $self->{parsed} = $top;
	}

sub _get_filehandle
	{
	my( $self, $thingy ) = @_;

	my $fh;
	
	unless( ref $self->_source ) # filename
		{
		open $fh, "<", $self->_source or croak "Could not open source! $!";
		}
	elsif( ref $self->_source eq ref \ ''  ) # scalar ref
		{
		open $fh, "<", $self->_source or croak "Could not open file! $!";		
		}
	elsif( ref $self->_source ) # filehandle
		{
		$fh = $self->_source;
		}
		
	$fh;
	}

sub _read_plist_trailer
	{
	my $self = shift;
	
	seek $self->_fh, -32, SEEK_END;

	my $buffer;
	read $self->_fh, $buffer, 32;
	my %hash;
	
	@hash{ qw( offset_size ref_size object_count top_object table_offset ) }
		= unpack "x6 C C (x4 N)3", $buffer;

	$self->{trailer} = \%hash;
	}	
	
sub _get_offset_table
	{
	my $self = shift;
	
    seek $self->_fh, $self->_trailer->{table_offset}, SEEK_SET;

	my $try_to_read = $self->_object_size;

    my $raw_offset_table;
    my $read = read $self->_fh, $raw_offset_table, $try_to_read;
    
	croak "reading offset table failed!" unless $read == $try_to_read;

    my @offsets = unpack ["","C*","n*","(H6)*","N*"]->[$self->_trailer->{offset_size}], $raw_offset_table;

	$self->{offsets} = \@offsets;
	
    if( $self->_trailer->{offset_size} == 3 ) 
    	{
		@offsets = map { hex } @offsets;
   	 	}
	
	}

sub _read_object_at_offset {
	my( $self, $offset ) = @_;

	my @caller = caller(1);
	
    seek $self->_fh, ${ $self->_offsets }[$offset], SEEK_SET;
    
    $self->_read_object;
	}

# # # # # # # # # # # # # #

BEGIN {
my $type_readers = {

	0 => sub { # the odd balls
		my( $self, $length ) = @_;
		
		my %hash = (
			 0 => [ qw(null  0) ],
			 8 => [ qw(false 0) ],
			 9 => [ qw(true  1) ],
			15 => [ qw(fill 15) ],
			);
	
		return $hash{ $length } || [];
    	},

	1 => sub { # integers
		my( $self, $length ) = @_;
		croak "Integer > 8 bytes = $length" if $length > 3;

		my $byte_length = 1 << $length;

		my( $buffer, $value );
		read $self->_fh, $buffer, $byte_length;

		my @formats = qw( C n N NN );
		my @values = unpack $formats[$length], $buffer;
		
		if( $length == 3 )
			{
			my( $high, $low ) = @values;
			
			my $b = Math::BigInt->new($high)->blsft(32)->bior($low);
			if( $b->bcmp(Math::BigInt->new(2)->bpow(63)) > 0) 
				{
				$b -= Math::BigInt->new(2)->bpow(64);
				}
				
			@values = ( $b );
			}
	
		return Mac::PropertyList::integer->new( $values[0] );
		},

	2 => sub { # reals
		my( $self, $length ) = @_;
		croak "Real > 8 bytes" if $length > 3;
		croak "Bad length [$length]" if $length < 2;
		
		my $byte_length = 1 << $length;
	
		my( $buffer, $value );
		read $self->_fh, $buffer, $byte_length;

		my @formats = qw( a a f d );
		my @values = unpack $formats[$length], $buffer;
	
		return Mac::PropertyList::real->new( $values[0] );
		},

	3 => sub { # date
		my( $self, $length ) = @_;
		croak "Real > 8 bytes" if $length > 3;
		croak "Bad length [$length]" if $length < 2;
	
		my $byte_length = 1 << $length;
	
		my( $buffer, $value );
		read $self->_fh, $buffer, $byte_length;

		my @formats = qw( a a f d );
		my @values = unpack $formats[$length], $buffer;

		$self->{MLen} += 9;	

		return Mac::PropertyList::date->new( $values[0] );
		},

	4 => sub { # binary data
		my( $self, $length ) = @_;
	
		my( $buffer, $value );
		read $self->_fh, $buffer, $length;
		
		return Mac::PropertyList::data->new( $buffer );
		},


	5 => sub { # utf8 string
		my( $self, $length ) = @_;
	
		my( $buffer, $value );
		read $self->_fh, $buffer, $length;
		
		# pack to make it unicode
		$buffer = pack "U0C*", unpack "C*", $buffer;
	
		return Mac::PropertyList::string->new( $buffer );
		},

	6 => sub { # unicode string
		my( $self, $length ) = @_;
	
		my( $buffer, $value );
		read $self->_fh, $buffer, 2 * $length;
		
		$buffer = decode( "UTF-16BE", $buffer );
		
		return Mac::PropertyList::ustring->new( $buffer );
		},

	a => sub { # array
		my( $self, $elements ) = @_;
		
		my @objects = do {
			my $buffer;
			read $self->_fh, $buffer, $elements * $self->_object_ref_size;
			unpack( 
				($self->_object_ref_size == 1 ? "C*" : "n*"), $buffer 
				);
			};
	
		my @array = 
			map { $self->_read_object_at_offset( $objects[$_] ) } 
			0 .. $elements - 1; 
	
		return Mac::PropertyList::array->new( \@array );
		},

	d => sub { # dictionary
		my( $self, $length ) = @_;
		
		my @key_indices = do {
			my $buffer;
			my $s = $self->_object_ref_size;
			read $self->_fh, $buffer, $length * $self->_object_ref_size;
			unpack( 
				($self->_object_ref_size == 1 ? "C*" : "n*"), $buffer 
				);
			};
		
		my @objects = do {
			my $buffer;
			read $self->_fh, $buffer, $length * $self->_object_ref_size;
			unpack(
				($self->_object_ref_size == 1 ? "C*" : "n*"), $buffer 
				);
			};

		my %dict = map {
			my $key   = $self->_read_object_at_offset($key_indices[$_])->value;
			my $value = $self->_read_object_at_offset($objects[$_]);
			( $key, $value );
			} 0 .. $length - 1;
		
		return Mac::PropertyList::dict->new( \%dict );
		},
	};

sub _read_object 
	{
	my $self = shift;

    my $buffer;
    croak "read() failed while trying to get type byte! $!" 
    	unless read( $self->_fh, $buffer, 1) == 1;

    my $length = unpack( "C*", $buffer ) & 0x0F;
    
    $buffer    = unpack "H*", $buffer;
    my $type   = substr $buffer, 0, 1;    
    
	$length = $self->_read_object->value if $type ne "0" && $length == 15;

	my $sub = $type_readers->{ $type };
	my $result = eval { $sub->( $self, $length ) };
	croak "$@" if $@;	

    return $result;
	}
	
}

=back

=head1 SOURCE AVAILABILITY

This project is in Github:

	git://github.com/briandfoy/mac-propertylist.git

=head1 CREDITS

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2004-2009 brian d foy.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

"See why 1984 won't be like 1984";

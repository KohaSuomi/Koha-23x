package C4::Barcodes::preyyyymmincr;

# Copyright 2022 Koha Development team
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;

use Carp qw( carp );

use C4::Context;

use Koha::DateUtils qw( dt_from_string output_pref );
use POSIX qw( strftime );

use vars qw(@ISA);

BEGIN {
    @ISA = qw(C4::Barcodes);
}

sub new_object {
    my $class = shift;
	my $type = ref($class) || $class;
	my $self = $type->default_self('preyyyymmincr');

    my $branchcode = C4::Context->userenv->{'branch'};
    my $branchPrefixes = C4::Context->preference("BarcodePrefix");
    my $yaml = YAML::XS::Load(
                    Encode::encode(
                        'UTF-8',
                        $branchPrefixes,
                        Encode::FB_CROAK
                    )
                );
    my $prefix = $yaml->{$branchcode} || $yaml->{'Default'};

    $self->{prefix} = $prefix;
    $self->{datetime} = output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 });

	return bless $self, $type;
}

sub initial {
    my $self = shift;

    return get_head($self).'1';
}

sub db_max {
    my $self = shift;

    my $barcode = get_head($self);

    my $query = "SELECT MAX(CAST(SUBSTRING(barcode,-1) AS signed)) from items where barcode REGEXP ?";
    my $sth=C4::Context->dbh->prepare($query);
    $sth->execute("^$barcode");

    my $nextnum;
    while (my ($count)= $sth->fetchrow_array) {
        $nextnum = $count if $count;
        $nextnum = 0 if $nextnum && $nextnum == 9;
    }

    return $nextnum;
}

sub parse {
    my $self = shift;

    my $head = get_head($self);
    my $incr = (@_) ? shift : $self->value;
    my $barcode = $head.$incr;
    unless ($incr){
        carp "Barcode '$barcode' has no incrementing part!";
		return ($barcode,undef,undef);
    }

    return ($head, $incr, '');
}

sub get_head {
    my $self = shift;

    my $prefix = $self->{prefix};
    my ($year, $month, $day) = split('-', $self->{datetime});
    $year = substr($year, -2);
    my $date = strftime "%H%M%S", localtime;

    my $barcode = $prefix.$year.$month.$day.$date;

    return $barcode;
}

BEGIN {
    @ISA = qw(C4::Barcodes);
}

1;
__END__
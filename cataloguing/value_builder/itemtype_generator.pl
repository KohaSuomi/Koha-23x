#!/usr/bin/perl

# Copyright 2024 Koha-Suomi Oy
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use CGI;
use JSON::XS;

use C4::Context;

my $input = new CGI;
my $itemtype = $input->param("itemtype");
my $loc = $input->param("loc");
my $sub_loc = $input->param("subloc");
my $ccode = $input->param("ccode");

my $dbh = C4::Context->dbh;
my @params = ($itemtype);
push( @params, $loc ) if ($loc);
push( @params, $sub_loc ) if ($sub_loc);
push( @params, $ccode ) if ($ccode);

my $query = "SELECT i.itype, count(*) AS count FROM items i
    LEFT JOIN biblioitems bi on(i.biblionumber = bi.biblionumber)
    WHERE bi.itemtype = ?";
$query .= "AND i.location = ?" if $loc;
$query .= "AND i.sub_location = ?" if $sub_loc;
$query .= "AND i.ccode = ?" if $ccode;
$query .= "GROUP BY i.itype
    ORDER BY count DESC";

my $sth=$dbh->prepare($query);
$sth->execute(@params);

my $row = $sth->fetchrow_hashref();

my $itype = $row->{itype};
$itype = {'itype' => $itype};

my $json = JSON::XS->new()->encode($itype);

binmode STDOUT, ":encoding(UTF-8)";

print $input->header(
    -type => 'application/json',
    -charset => 'UTF-8'
);

print $json;

#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2024 Koha Development Team
#
# Koha is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General
# Public License along with Koha; if not, see
# <http://www.gnu.org/licenses>

use Modern::Perl;

use CGI;

use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::DateUtils qw( dt_from_string );
use Koha::Holds;

my $input = CGI->new;
my $op = $input->param('op') // q|form|;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => 'tools/batch_modify_holds.tt',
        query           => $input,
        type            => "intranet",
        flagsrequired   => { tools => 'batch_modify_holds.tt' },
    }
);

my @hold_ids;

if ( $op eq 'form' ) {
    $template->param( view => 'form', );
}
elsif ( $op eq 'list' ) {

    my @reserve_ids         = $input->multi_param('reserve_ids');
    my $expirationdate_from = $input->param('expirationdate_from');
    my $expirationdate_to   = $input->param('expirationdate_to');
    my @branchcodes         = $input->multi_param('branchcodes');
    my @found_status        = $input->multi_param('found_status');
    my $suspend_status      = $input->param('suspend_status');
    my $suspend_until_from  = $input->param('suspend_until_from');
    my $suspend_until_to    = $input->param('suspend_until_to');
    my $reservenotes        = $input->param('reservenotes');

    my $search_params;

    if( @reserve_ids ){
        $search_params->{'me.reserve_id'} = { -in => \@reserve_ids };
    } else {
        if( $expirationdate_from && $expirationdate_to ){
            my $expirationdate_params = { -or => {
                patron_expiration_date => {
                    -between => [
                        $expirationdate_from,
                        $expirationdate_to
                    ]
                },
                expirationdate => {
                    -between => [
                        $expirationdate_from,
                        $expirationdate_to
                    ]
                }
            }};

            $search_params = $expirationdate_params;
        }

        if ( @branchcodes ) {
            $search_params->{'me.branchcode'} = { -in => \@branchcodes };
        }

        if ( @found_status ) {
            my $found_params = {};
            # if NULL is used as filter, use it as "is" param
            if( grep {$_ eq "NULL"} @found_status ) {
                $found_params->{'-or'}{'-is'} = undef;
                $found_params->{'-or'}{'-in'} = \@found_status;
            } else {
                $found_params = { -in => \@found_status };
            }

            $search_params->{'me.found'} = $found_params;
        }

        if( $suspend_status ne "none" ){
            $search_params->{'me.suspend'} = $suspend_status;
        }

        if( $suspend_until_from && $suspend_until_to ){
            $search_params->{'me.suspend_until'} = {
                -between => [
                    $suspend_until_from,
                    $suspend_until_to,
                ]
            };
        }

        if( $reservenotes ){
            $search_params->{'me.reservenotes'} = { -like => "%".$reservenotes."%" }
        }
    }

    my $holds = Koha::Holds->search(
        $search_params,
        {
            join => ["item"]
        }
    );

    $template->param(
        holds => $holds,
        view  => 'list',
    );
}

if ( $op eq 'modify' ) {

    my $new_expiration_date = $input->param('new_expiration_date');
    my $new_pickup_loc      = $input->param('new_pickup_loc');
    my $new_suspend_status  = $input->param('new_suspend_status');
    my $new_suspend_date    = $input->param('new_suspend_date');
    my $new_reserve_note    = $input->param('new_reserve_note');

    @hold_ids = $input->multi_param('hold_id');

    my $holds_to_update = Koha::Holds->search( { reserve_id => { -in => \@hold_ids } } );

    while ( my $hold = $holds_to_update->next ) {

        if( $new_expiration_date ){
            $hold->expirationdate($new_expiration_date)->store;
        }

        if($new_pickup_loc && ($hold->branchcode ne $new_pickup_loc)){
            $hold->branchcode($new_pickup_loc)->store;
        }

        if( $new_suspend_status && !$hold->is_found ){
            if( $new_suspend_status eq "suspend" ){
                $hold->suspend(1)->store;
                if( $new_suspend_date ){
                    $hold->suspend_until( $new_suspend_date )->store;
                } else {
                    $hold->suspend_until( undef )->store;
                }
            } else {
                $hold->suspend(0)->store;
                $hold->suspend_until( undef )->store;
            }
        }

        if( $new_reserve_note ){
            $hold->reservenotes($new_reserve_note)->store;
        }
    }

    $template->param(
        updated_holds => $holds_to_update,
        view          => 'report',
    );

}

output_html_with_http_headers $input, $cookie, $template->output;

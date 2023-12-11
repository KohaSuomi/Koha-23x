#!/usr/bin/perl

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

=head1 NAME

es_indexer_daemon.pl - Worker script that will process background Elasticsearch jobs

=head1 SYNOPSIS

./es_indexer_daemon.pl --batch_size=X

Options:

   -b --batch_size          how many jobs to commit (default: 10)
   --help                   brief help message

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<--batch_size>

How many jobs to commit per batch. Defaults to 10, will commit after .1 seconds if no more jobs incoming.

=back

=head1 DESCRIPTION

This script will poll the database every 10s for new jobs in the Elasticsearch queue and process them in batches every second.

=cut

use Modern::Perl;
use JSON qw( decode_json );
use Try::Tiny;
use Pod::Usage;
use Getopt::Long;

use C4::Context;
use Koha::Logger;
use Koha::BackgroundJobs;
use Koha::SearchEngine;
use Koha::SearchEngine::Indexer;


my ( $help, $batch_size );
GetOptions(
    'h|help' => \$help,
    'b|batch_size=s' => \$batch_size
) || pod2usage(1);

pod2usage(0) if $help;

$batch_size //= 10;

warn "Not using Elasticsearch" unless C4::Context->preference('SearchEngine') eq 'Elasticsearch';

my $logger = Koha::Logger->get({ interface =>  'worker' });

my $biblio_indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
my $auth_indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::AUTHORITIES_INDEX });
my @jobs = ();

while (1) {

        @jobs = Koha::BackgroundJobs->search(
            { status => 'new', queue => 'elastic_index' } )->as_list;
        commit(@jobs);
        @jobs = ();
        sleep 10;

}

sub commit {
    my (@jobs) = @_;

    my @bib_records;
    my @auth_records;

    my $jobs = Koha::BackgroundJobs->search( { id => [ map { $_->id } @jobs ] });
    # Start
    $jobs->update({
        progress => 0,
        status => 'started',
        started_on => \'NOW()',
    });

    for my $job (@jobs) {
        my $args = try {
            $job->json->decode( $job->data );
        } catch {
            $logger->warn( sprintf "Cannot decode data for job id=%s", $job->id );
            $job->status('failed')->store;
            return;
        };
        next unless $args;
        if ( $args->{record_server} eq 'biblioserver' ) {
            push @bib_records, @{ $args->{record_ids} };
        } else {
            push @auth_records, @{ $args->{record_ids} };
        }
    }

    if (@auth_records) {
        try {
            $auth_indexer->update_index( \@auth_records );
        } catch {
            $logger->warn( sprintf "Update of elastic index failed with: %s", $_ );
        };
    }
    if (@bib_records) {
        try {
            $biblio_indexer->update_index( \@bib_records );
        } catch {
            $logger->warn( sprintf "Update of elastic index failed with: %s", $_ );
        };
    }

    # Finish
    $jobs->update({
        progress => 1,
        status => 'finished',
        ended_on => \'NOW()',
    });
}

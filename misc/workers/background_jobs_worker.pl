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

background_jobs_worker.pl - Worker script that will process background jobs

=head1 SYNOPSIS

./background_jobs_worker.pl [--queue QUEUE] [-m|--max-processes MAX_PROCESSES]

=head1 DESCRIPTION

This script will poll the database every 10s for new jobs in the passed queue (or the 'default' queue).

You can specify some queues only (using --queue, which is repeatable) if you want to run several workers that will handle their own jobs.

--m --max-processes specifies how many jobs to process simultaneously

Max processes will be set from the command line option, the environment variable MAX_PROCESSES, or the koha-conf file, in that order of precedence.
By default the script will only run one job at a time.

=head1 OPTIONS

=over

=item B<--queue>

Repeatable. Give the job queues this worker will process.

The different values available are:

    default
    long_tasks

=back

=cut

use Modern::Perl;
use JSON qw( decode_json );
use Try::Tiny;
use Pod::Usage;
use Getopt::Long;
use Parallel::ForkManager;

use C4::Context;
use Koha::Logger;
use Koha::BackgroundJobs;
use C4::Context;

$SIG{'PIPE'} = 'IGNORE';    # See BZ 35111; added to ignore PIPE error when connection lost on Ubuntu.

my ( $help, @queues );

my $max_processes = $ENV{MAX_PROCESSES};
$max_processes ||= C4::Context->config('background_jobs_worker')->{max_processes} if C4::Context->config('background_jobs_worker');
$max_processes ||= 1;

GetOptions(
    'm|max-processes=i' => \$max_processes,
    'h|help' => \$help,
    'queue=s' => \@queues,
) || pod2usage(1);


pod2usage(0) if $help;

unless (@queues) {
    push @queues, 'default';
}

my $pm = Parallel::ForkManager->new($max_processes);

while (1) {
    my $jobs = Koha::BackgroundJobs->search({ status => 'new', queue => \@queues });
    while ( my $job = $jobs->next ) {
        my $args = try {
            $job->json->decode($job->data);
        } catch {
            Koha::Logger->get({ interface => 'worker' })->warn(sprintf "Cannot decode data for job id=%s", $job->id);
            $job->status('failed')->store;
            return;
        };

        next unless $args;

        $pm->start and next;
        srand();    # ensure each child process begins with a new seed
        process_job( $job, { job_id => $job->id, %$args } );
        $pm->finish;

    }
    sleep 10;
}
$pm->wait_all_children;

sub process_job {
    my ( $job, $args ) = @_;
    try {
        $job->process( $args );
    } catch {
        $job->status('failed')->store;
    };
}

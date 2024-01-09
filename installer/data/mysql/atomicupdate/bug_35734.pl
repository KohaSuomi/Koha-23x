use Modern::Perl;

return {
    bug_number => "35734",
    description => "Message queue table lock will crash Koha",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{
            ALTER TABLE message_queue
            MODIFY COLUMN status ENUM('pending','sent','failed','deleted','processing') NOT NULL DEFAULT 'pending'
        });
        # Print useful stuff here
        say $out "Added new status 'processing' to message_queue table";
    },
};

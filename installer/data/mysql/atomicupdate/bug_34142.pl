use Modern::Perl;

return {
    bug_number => "34142",
    description => "Add column sub_location to (deleted)items table",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        if( !column_exists( 'items', 'sub_location' ) ) {
            $dbh->do(q{ALTER TABLE items ADD COLUMN sub_location VARCHAR(80) DEFAULT NULL AFTER permanent_location});
            say $out "Added new column items.sub_location";
        }
        if( !column_exists( 'deleteditems', 'sub_location' ) ) {
            $dbh->do(q{ALTER TABLE deleteditems ADD COLUMN sub_location VARCHAR(80) DEFAULT NULL AFTER permanent_location});
            say $out "Added new column deleteditems.sub_location";
        }
    },
};

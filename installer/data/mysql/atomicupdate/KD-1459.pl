use Modern::Perl;

return {
    bug_number  => "KD-1459",
    description => "kohasuomi-class-sort-rules",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do("INSERT IGNORE INTO class_sort_rules (class_sort_rule, description, sort_routine) VALUES ('outi', 'Outi järjestelysääntö', 'OUTI');");
        $dbh->do("INSERT IGNORE INTO class_sort_rules (class_sort_rule, description, sort_routine) VALUES ('lumme', 'Lumme järjestelysääntö', 'LUMME');");

        # Print useful stuff here
        # tables
        say $out "Added new class sor rules outi and lumme.";
    },
};

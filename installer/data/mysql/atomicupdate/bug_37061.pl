use Modern::Perl;

return {
    bug_number  => "37061",
    description => "Add a new system preference PrepareHostField",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(q{
            INSERT INTO systempreferences (variable, value, options, type, explanation)
            VALUES ('PrepareHostField', '', '', 'Textarea', 'Define YAML rules for copying host data to component parts.');});

        say $out "Added new system preference 'PrepareHostField'";
    },
};

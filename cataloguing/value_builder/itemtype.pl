#!/usr/bin/perl

# Copyright 2023 Koha-Suomi Oy
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
use JSON;

my $builder = sub {
    my ( $params ) = @_;
    my $function_name = $params->{id};

    my $res  = <<END_OF_JS;
        <script type="text/javascript">
            //<![CDATA[

            function Click$function_name(event) {
                var bn = \$('input[name="biblionumber"]').val();
                if (!bn) return false;
                \$('#' + event.data.id).prop('disabled', true);

                var url = '../cataloguing/plugin_launcher.pl?plugin_name=fi_JSON_942khm.pl&biblionumber=' + bn;
                var req = \$.get(url);
                req.fail(function(jqxhr, text, error){
	                alert(error);
                    \$('#' + event.data.id).prop('disabled', false);
	            });

                req.done(function(resp){

                    var itemtype = resp.f942c;

                    var shelving_loc = "";
                    if(\$("select[id^='tag_952_subfield_c']").val()){
                        shelving_loc = \$("select[id^='tag_952_subfield_c']").val();
                    } else if (\$('div[id^="subfield"][id*="c"]:not([id*="NEW"]').find("select").val()){
                        shelving_loc = \$('div[id^="subfield"][id*="c"]:not([id*="NEW"]').find("select").val();
                    } else if (\$('div[id^="subfield"][id*="NEW"][id*="c"]').find("select").val()){
                        shelving_loc = \$('div[id^="subfield"][id*="NEW"][id*="c"]').find("select").val();
                    } else {
                        shelving_loc = \$("div[id^='subfieldc']").find("select").val()
                    }

                    var sublocation = "";
                    if(\$("select[id^='tag_952_subfield_j']").val()){
                        sublocation = \$("select[id^='tag_952_subfield_j']").val();
                    } else if (\$('div[id^="subfield"][id*="j"]:not([id*="NEW"]').find("select").val()){
                        sublocation = \$('div[id^="subfield"][id*="j"]:not([id*="NEW"]').find("select").val();
                    } else if (\$('div[id^="subfield"][id*="NEW"][id*="j"]').find("select").val()){
                        sublocation = \$('div[id^="subfield"][id*="NEW"][id*="j"]').find("select").val();
                    } else {
                        sublocation = \$("div[id^='subfieldj']").find("select").val()
                    }

                    var collection_code = "";
                    if(\$("select[id^='tag_952_subfield_8']").val()){
                        collection_code = \$("select[id^='tag_952_subfield_8']").val();
                    } else if (\$('div[id^="subfield"][id*="8"]:not([id*="NEW"]').find("select").val()){
                        collection_code = \$('div[id^="subfield"][id*="8"]:not([id*="NEW"]').find("select").val();
                    } else if (\$('div[id^="subfield"][id*="NEW"][id*="8"]').find("select").val()){
                        collection_code = \$('div[id^="subfield"][id*="NEW"][id*="8"]').find("select").val();
                    } else {
                        collection_code = \$("div[id^='subfield8']").find("select").val()
                    }

                    var itemtype_url = '../cataloguing/value_builder/itemtype_generator.pl?itemtype=' + itemtype;
                    itemtype_url += shelving_loc ? '&loc=' + shelving_loc : '';
                    itemtype_url += sublocation ? '&subloc=' + sublocation : '';
                    itemtype_url += collection_code ? '&ccode=' + collection_code : '';

                    var req = \$.get(itemtype_url);
                    req.fail(function(jqxhr, text, error){
                        alert(error);
                    });

                    req.done(function(resp){
                       \$('#' + event.data.id).val(resp.itype);
                       \$('#' + event.data.id).prop('disabled', false);
                    });
                });
                return false;
            }
        //]]>
        </script>
END_OF_JS

    return $res;
};

return { builder => $builder };
#!/usr/bin/perl

# Copyright 2021 KohaSuomi Oy
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

use Modern::Perl;
use utf8;

use CGI qw ( -utf8 );

use C4::Context;
use C4::Output qw( output_html_with_http_headers output_with_http_headers);
use C4::Auth qw( get_template_and_user);
use Encode qw( decode encode is_utf8 );
use JSON;

use Mojo::UserAgent;
use XML::LibXML;

use C4::AuthoritiesMarc;
use Koha::SearchEngine::Search;
use Koha::SearchEngine::QueryBuilder;

my $builder = sub {
    my ( $params ) = @_;
    my $function_name = $params->{id};
    my %args;

    my $vocab = "seko";

    my $language = C4::Languages::getlanguage() || 'fi';
    $language = (split(/-/, $language))[0];

    my $langcode = "fin";
    $langcode = "eng" if ($language eq 'en');
    $langcode = "swe" if ($language eq 'sv');


    my $js  = <<END_OF_JS;
<script type="text/javascript">
//<![CDATA[
     
	\$( document ).ready(function() {
	 		\$($function_name).css("margin-bottom", "5px");
	 	\$($function_name).after('<select class="$function_name"></select>');
	 	selectBox$function_name(\$($function_name).attr('id'));
	});

	
	function selectBox$function_name(selecttag) {
		\$('.' + selecttag).select2({
			ajax: {
				url: 'https://api.finto.fi/rest/v1/search',
				dataType: 'json',
				data: function(params) {
					var query = {
                    vocab: '$vocab',
                    query: '*' + params.term + '*',
                    lang: '$language',
                    type: 'skos:Concept',
                    unique: 1,
                    }
					return query;
				},
				processResults: function(data) {
					var tmp = \$.map(data.results, function(obj){
									var sl = obj.prefLabel;
									if (obj.altLabel) { sl += " <i>("+obj.altLabel+")</i>" };
						if (obj.vocab && / /.test("$vocab")) { sl += " <i>("+obj.vocab+")</i>" }
									return { id: obj.prefLabel,
											text: sl,
											uri: obj.uri,
											vocab: obj.vocab,
											localname: obj.localname,
											field: selecttag }
							});
					return { results: tmp };
				},
				cache: true
			},
			minimumInputLength: 2,
			templateSelection: formatSelection$function_name,
			escapeMarkup: function(m) { return m; },
		});
    
	}

	function formatSelection$function_name (data) {
        
		if (data.id === '') {
			return 'Etsi Fintosta';
		}
		
		if(data.localname) {
			
		}
        
        if(data.id !== '') {

            var id = data.field;
            
            var fid = id;
            var re = /^(tag_..._)/;
            var found = fid.match(re);

            var sfid2 = found[1] + 'subfield_2_';
                       
            \$('#'+data.field).val(data.id);
            
            var potentials = document.querySelectorAll("[name*="+sfid2+"]");

            var fieldarray = [];

            for (var i = 0; i < potentials.length; i++) {
                fieldarray.push(potentials[i]);
            }
            fieldarray[fieldarray.length-1].value="seko";
	
        }
 
		\$('.'+data.field).empty();
        
	}

	function click$function_name(event) {
		
		event.preventDefault();
		var tag = event.data.id;
		\$("#"+tag).next().attr('class', tag);
		selectBox$function_name(tag);
	}
    
    

//]]>
</script>
END_OF_JS
    return $js;
};

return { builder => $builder };

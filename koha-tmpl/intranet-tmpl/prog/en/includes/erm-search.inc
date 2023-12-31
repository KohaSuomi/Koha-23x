[% USE Koha %]
<!-- erm-search.inc -->
<div id="header_search" role="tablist">
    <div class="tab-content">
        <div id="agreement_search" role="tabpanel" class="tab-pane active">
            <form action="/cgi-bin/koha/erm/agreements" method="get">
                <div class="form-title">
                    <label class="control-label" for="agreement_filter"><span class="control-text">Agreement search</span> <i class="fa fa-fw fa-check-circle" aria-hidden="true"></i></label>
                </div>
                <div class="form-content">
                    <input type="text" name="q" id="agreement_filter" class="head-searchbox form-control" placeholder="Enter search keywords" size="40" />
                </div>
                <button type="submit" aria-label="Search"><i class="fa fa-arrow-right"></i></button>
            </form>
        </div>

        <div id="license_search" role="tabpanel" class="tab-pane">
            <form action="/cgi-bin/koha/erm/licenses" method="get">
                <div class="form-title">
                    <label class="control-label" for="license_filter"><span class="control-text">License search</span> <i class="fa fa-fw fa-gavel" aria-hidden="true"></i></label>
                </div>
                <div class="form-content">
                    <input type="text" name="q" id="license_filter" class="head-searchbox form-control" placeholder="Enter search keywords" size="40" />
                </div>
                <button type="submit" aria-label="Search"><i class="fa fa-arrow-right"></i></button>
            </form>
        </div>

        <div id="package_search" role="tabpanel" class="tab-pane">
            <form action="/cgi-bin/koha/erm/eholdings/local/packages" method="get">
                <div class="form-title">
                    <label class="control-label" for="package_name_filter"><span class="control-text">Package search</span> <i class="fa fa-fw fa-archive" aria-hidden="true"></i></label>
                </div>
                <div class="form-content">
                    <input type="text" name="package_name" id="package_name_filter" class="head-searchbox form-control" placeholder="Enter search keywords" size="40" />
                </div>
                <button type="submit" aria-label="Search"><i class="fa fa-arrow-right"></i></button>
            </form>
        </div>

        <div id="title_search" role="tabpanel" class="tab-pane">
            <form action="/cgi-bin/koha/erm/eholdings/local/titles" method="get">
                <div class="form-title">
                    <label class="control-label" for="title_filter"><span class="control-text">Title search</span> <i class="fa-solid fa-fw fa-arrow-down-a-z" aria-hidden="true"></i></label>
                </div>
                <div class="form-content">
                    <input type="text" name="publication_title" id="title_filter" class="head-searchbox form-control" placeholder="Enter search keywords" size="40" />
                </div>
                <button type="submit" aria-label="Search"><i class="fa fa-arrow-right"></i></button>
            </form>
        </div>
    </div><!-- /.tab-content -->

    <ul class="nav nav-tabs" role="tablist">
        <li role="presentation" class="active">
            <a id="agreement_search_tab" title="Search agreements" href="#agreement_search" aria-controls="agreement_search" role="tab" aria-expanded="true" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-check-circle" aria-hidden="true"></i> <span class="tab-title">Search agreements</span></a>
        </li>
        <li role="presentation">
            <a id="license_search_tab" title="Search licenses" href="#license_search" aria-controls="license_search" role="tab" aria-expanded="true" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-gavel" aria-hidden="true"></i> <span class="tab-title">Search licenses</span></a>
        </li>
        <li role="presentation">
            <a id="package_search_tab" title="Search packages" href="#package_search" aria-controls="package_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-fw fa-archive" aria-hidden="true"></i> <span class="tab-title">Search packages</span></a>
        </li>
        <li role="presentation">
            <a id="title_search_tab" title="Search titles" href="#title_search" aria-controls="title_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa-solid fa-fw fa-arrow-down-a-z" aria-hidden="true"></i> <span class="tab-title">Search titles</span></a>
        </li>
    </ul>
</div><!-- /#header_search -->
<!-- /erm-search.inc -->

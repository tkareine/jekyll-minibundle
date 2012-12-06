# Jekyll Minibundle plugin

A minimalistic plugin for bundling assets to
[Jekyll](https://github.com/mojombo/jekyll)'s site generation
directory.

_The project is in it's early draft phase. The primary motivation is
to investigate an alternative approach to asset bundling with Jekyll._

# Features and usage

There are two features: asset stamping with MD5 hash over the contents
of the asset, and asset bundling combined with the first feature (you
still need a separate bundling tool, such as
[UglifyJS2](https://github.com/mishoo/UglifyJS2)).

Why is this good? Well, a unique content specific identifier in asset
filename is the best way to handle web caches, because you can allow
caching the asset forever. Calculating MD5 digest over the contents of
the asset is fast and the resulting digest is reasonably unique to be
generated automatically.

Asset bundling is good for reducing the number of requests to server
upon page load. It also allows minification for stylesheets and
JavaScript sources, which results in faster source file reading in
browsers.

## Asset stamping

Asset stamping is intended to be used together with
[Compass](http://compass-style.org/) and other similar asset
generation tools where you do not want to include unprocessed input
assets in the generated site.

Configure Compass to take inputs from `_assets/styles/*.scss` and to
put output to `_tmp/site.css`. Use `ministamp` tag in Jekyll to copy
the processed style asset to the generated site:

    <link href="{% ministamp _tmp/site.css assets/site.css %}" rel="stylesheet" media="screen, projection">

Output, containing the MD5 digest in the filename:

    <link href="assets/site-390be921ee0eff063817bb5ef2954300.css" rel="stylesheet" media="screen, projection">

## Asset bundling

A straightforward way to bundle assets with any tool that supports
reading input files from STDIN and writing the output to STDOUT. The
bundled file has MD5 digest in the filename:

    {% minibundle js %}
    source_dir: _assets/scripts
    destination_path: assets/site
    assets:
      - dependency
      - app
    {% endminibundle %}

Output:

    <script type="text/javascript" src="assets/site-8e764372a0dbd296033cb2a416f064b5.js"></script>

For this to work, specify your favorite bundling tool in
`$JEKYLL_MINIBUNDLE_CMD_JS` environment variable. For example, when
launching Jekyll:

    $ JEKYLL_MINIBUNDLE_CMD_JS="./node_modules/.bin/uglifyjs --" jekyll

# Example site

See the contents of `test/fixture/site` directory.

# TODO

* Increase test coverage.

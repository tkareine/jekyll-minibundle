# Jekyll Minibundle plugin

A minimalistic plugin for bundling assets to
[Jekyll](https://github.com/mojombo/jekyll)'s site generation
directory.

In addition to the plugin itself, you need an asset bundling tool that
supports standard unix input and output. There are no gem dependencies
at runtime.

Tested with Ruby MRI 1.9.3. Ruby 1.8 is *not* supported.

[![Build Status](https://secure.travis-ci.org/tkareine/jekyll-minibundle.png)](http://travis-ci.org/tkareine/jekyll-minibundle)

# Features

There are two features: asset fingerprinting with MD5 digest over the
contents of the asset, and asset bundling combined with the first
feature.

You still need a separate bundling tool, such as
[UglifyJS2](https://github.com/mishoo/UglifyJS2) to do the actual work
of bundling (concatenation and minification).

Why is this good? Well, a fingerprint in asset filename is the
[recommended way](https://developers.google.com/speed/docs/best-practices/caching)
to handle caching of static resources, because you can allow caching
the asset forever. Calculating MD5 digest over the contents of the
asset is fast and the resulting digest is reasonably unique to be
generated automatically.

Asset bundling is good for reducing the number of requests to the
backend upon page load. Minification of stylesheets and JavaScript
sources makes asset sizes smaller and thus faster to load over
network.

# Usage

The plugin is shipped as a
[RubyGem](https://rubygems.org/gems/jekyll-minibundle):

    gem install jekyll-minibundle

Add file `_plugins/minibundle.rb` to your Jekyll site project with
this line:

    require 'jekyll/minibundle'

## Asset fingerprinting

Asset fingerprinting is intended to be used together with
[Compass](http://compass-style.org/) and other similar asset
generation tools that have their own configuration for input sources.

Configure Compass to take inputs from `_assets/styles/*.scss` and to
put output to `_tmp/site.css`. Use `ministamp` tag to copy the
processed style asset to the generated site:

    <link href="{% ministamp _tmp/site.css assets/site.css %}" rel="stylesheet" media="screen, projection">

Output, containing the MD5 digest of the file in the filename:

    <link href="assets/site-390be921ee0eff063817bb5ef2954300.css" rel="stylesheet" media="screen, projection">

This feature does not require any external tools.

## Asset bundling

This is a straightforward way to bundle assets with any tool that
supports reading input from STDIN and writing the output to STDOUT.
You write the configuration for input sources directly into the
content file where you want the markup tag for the bundle file to
appear. The outcome will be a markup tag containing the path to the
bundle file, and the generated site will have the bundle file in that
path. The MD5 digest of the file will be included in the filename.

Place `minibundle` block with configuration into your content file
where you want the generated markup to appear. For example, to bundle
a set of JavaScript sources:

    {% minibundle js %}
    source_dir: _assets/scripts
    destination_path: assets/site
    assets:
      - dependency
      - app
    attributes:
      id: my-scripts
    {% endminibundle %}

Then, specify the command for launching your favorite bundling tool in
`$JEKYLL_MINIBUNDLE_CMD_JS` environment variable. For example, when
launching Jekyll:

    $ JEKYLL_MINIBUNDLE_CMD_JS='./node_modules/.bin/uglifyjs --' jekyll

You can pass custom attributes to the generated markup with
`attributes` map in the configuration.

Output in the content file:

    <script src="assets/site-8e764372a0dbd296033cb2a416f064b5.js" type="text/javascript" id="my-scripts"></script>

For bundling CSS assets, you use `css` as the argument to `minibundle` block:

    {% minibundle css %}
    source_dir: _assets/styles
    destination_path: assets/site
    assets:
      - reset
      - common
    attributes:
      media: screen
    {% endminibundle %}

And then specify the command for launching bundling in
`$JEKYLL_MINIBUNDLE_CMD_CSS` environment variable.

## Development mode

For your development workflow, asset bundling gets in the way because
you will not see the contents and line numbers of the original assets.
To remedy this, you can instruct the library into development mode.
Then, `minibundle` block will not bundle assets, but copy each asset
as-is to the destination directory under the path specified in
`destination_path` configuration setting.

    $ JEKYLL_MINIBUNDLE_MODE=development jekyll --auto --server

# Example site

See the contents of `test/fixture/site` directory.

# License

MIT. See `License.txt`.

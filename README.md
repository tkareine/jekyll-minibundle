# Jekyll Minibundle plugin

A straightforward asset bundling plugin for [Jekyll][Jekyll],
utilizing external minification tool of your choice. It provides asset
concatenation for bundling and asset fingerprinting with MD5 digest
for cache busting.

There are no runtime dependencies, expect for the minification tool
used for bundling. Asset fingerprinting has no dependencies.

Tested with Ruby MRI 1.9.3, 2.0, and 2.1. Ruby 1.8 is *not* supported.

The plugin works with Jekyll's watch (auto-regeneration) mode.

[![Build Status](https://secure.travis-ci.org/tkareine/jekyll-minibundle.png)](http://travis-ci.org/tkareine/jekyll-minibundle)

# Features

There are two features: asset fingerprinting with MD5 digest over the
contents of the asset, and asset bundling combined with the first
feature.

Asset bundling consists of concatenation and minification. The plugin
implements concatenation and leaves choosing the minification tool up
to you. [UglifyJS2](https://github.com/mishoo/UglifyJS2) is a good and
fast minifier, for example. The plugin connects to the minifier with
standard unix pipe, feeding asset file contents to it in desired order
via standard input, and reads the result from standard output.

Why is this good? A fingerprint in asset's path is the
[recommended way](https://developers.google.com/speed/docs/best-practices/caching)
to handle caching of static resources, because you can allow caching
the asset forever. Calculating MD5 digest over the contents of the
asset is fast and the resulting digest is reasonably unique to be
generated automatically.

Asset bundling is good for reducing the number of requests to the
backend upon page load. The minification of stylesheets and JavaScript
sources makes asset sizes smaller and thus faster to load over
network.

# Usage

The plugin is shipped as a
[RubyGem](https://rubygems.org/gems/jekyll-minibundle):

``` bash
$ gem install jekyll-minibundle
```

Add file `_plugins/minibundle.rb` to your Jekyll site project with
this line:

``` ruby
require 'jekyll/minibundle'
```

You must allow Jekyll to use custom plugins. In
[Jekyll's configuration][JekyllConf], do not enable `safe` setting.

## Asset fingerprinting

If you just want to have fingerprint in your asset's path, use
`ministamp` tag:

``` html
<link href="{% ministamp _assets/site.css assets/site.css %}" rel="stylesheet" media="screen, projection">
```

Output, containing the MD5 digest of the file in the filename:

``` html
<link href="assets/site-390be921ee0eff063817bb5ef2954300.css" rel="stylesheet" media="screen, projection">
```

The generated site will have the asset file at that path.

This feature is useful when combined with asset generation tools
external to Jekyll. For example, you can configure
[Compass](http://compass-style.org/) to take inputs from
`_assets/styles/*.scss` and to produce output to
`_tmp/site.css`. Then, you use `ministamp` tag to copy the file to the
generated site with fingerprint:

``` html
<link href="{% ministamp _tmp/site.css assets/site.css %}" rel="stylesheet">
```

## Asset bundling

This is a straightforward way to bundle assets with any minification
tool that supports reading input from STDIN and writing the output to
STDOUT. You write the configuration for input sources directly into
the content file where you want the markup tag for the bundle file to
appear. The outcome will be a markup tag containing the path to the
bundle file, and the generated site will have the bundle file in that
path. The path will contain a fingerprint.

Place `minibundle` block with configuration into your content file
where you want the generated markup to appear. For example, to bundle
a set of JavaScript sources:

``` text
{% minibundle js %}
source_dir: _assets/scripts
destination_path: assets/site
assets:
  - dependency
  - app
attributes:
  id: my-scripts
{% endminibundle %}
```

Then, specify the command for launching your favorite minifier in
`$JEKYLL_MINIBUNDLE_CMD_JS` environment variable. For example, when
launching Jekyll:

``` bash
$ JEKYLL_MINIBUNDLE_CMD_JS='./node_modules/.bin/uglifyjs --' jekyll
```

You can pass custom attributes to the generated markup with
`attributes` map in the configuration.

Output in the content file:

``` html
<script src="assets/site-8e764372a0dbd296033cb2a416f064b5.js" type="text/javascript" id="my-scripts"></script>
```

For bundling CSS assets, you use `css` as the argument to `minibundle` block:

``` text
{% minibundle css %}
source_dir: _assets/styles
destination_path: assets/site
assets:
  - reset
  - common
attributes:
  media: screen
{% endminibundle %}
```

And then specify the command for launching bundling in
`$JEKYLL_MINIBUNDLE_CMD_CSS` environment variable.

## Recommended directory layout

It's recommended that you exclude the files you use as asset sources
from Jekyll itself. Otherwise, you end up with duplicate files in the
output directory.

For example, in the following snippet we're using `assets/src.css` as
asset source to `ministamp` tag:

``` html
<link href="{% ministamp assets/src.css assets/dest.css %}" rel="stylesheet" media="screen, projection">
```

By default, Jekyll includes this file to the output directory. As a
result, there will be both `src.css` and `dest-<md5>.css` files in
`_site/assets/` directory, which you probably do not want.

In order to avoid this, exclude the asset source file from
Jekyll. Because Jekyll excludes directories beginning with underscore
character (`_`), consider the following directory layout:

* `_assets/` for JS and CSS assets handled by the plugin that are in
  version control
* `_tmp/` for temporary JS and CSS assets handled by the plugin that
  are not in version control (for example, Compass output files)
* `assets/` for images and other assets handled by Jekyll directly

See [Jekyll configuration][JekyllConf] for more about excluding files
and directories.

## Development mode

The plugin has one more trick in its sleeves. If you set environment
variable `$JEKYLL_MINIBUNDLE_MODE` to `development`, then the plugin
will copy asset files as is to the destination directory (using
`destination_path` as directory for `minibundle` block), and omit
fingerprinting. This is useful in development workflow, where you need
the filenames and line numbers of the original asset sources.

``` bash
$ JEKYLL_MINIBUNDLE_MODE=development jekyll serve --watch
```

# Example site

See the contents of `test/fixture/site` directory.

# License

MIT. See `LICENSE.txt`.

[Jekyll]: http://jekyllrb.com/
[JekyllConf]: http://jekyllrb.com/docs/configuration/

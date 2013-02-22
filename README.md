# Jekyll Minibundle plugin

A minimalistic plugin for bundling assets to
[Jekyll](https://github.com/mojombo/jekyll)'s site generation
directory.

In addition to the plugin itself, you need a minification tool
supporting standard unix input and output. There are no gem
dependencies at runtime.

Tested with Ruby MRI 1.9.3. Ruby 1.8 is *not* supported.

[![Build Status](https://secure.travis-ci.org/tkareine/jekyll-minibundle.png)](http://travis-ci.org/tkareine/jekyll-minibundle)

# Features

There are two features: asset fingerprinting with MD5 digest over the
contents of the asset, and asset bundling combined with the first
feature.

Asset bundling consists of concatenation and minification. The plugin
implements concatenation and leaves up to you to choose the
minification tool. [UglifyJS2](https://github.com/mishoo/UglifyJS2) is
a good and fast minifier. The plugin connects to the minifier with
standard unix pipe, feeding asset file contents to it in desired order
via standard input, and reads the result from standard output.

Why is this good? Well, a fingerprint in asset's path is the
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

## Asset fingerprinting

Asset fingerprinting is intended to be used together with
[Compass](http://compass-style.org/) and other similar asset
generation tools that have their own configuration for input sources.

Configure Compass to take inputs from `_assets/styles/*.scss` and to
put output to `_tmp/site.css`. Use `ministamp` tag to copy the
processed style asset to the generated site:

``` html
<link href="{% ministamp _tmp/site.css assets/site.css %}" rel="stylesheet" media="screen, projection">
```

Output, containing the MD5 digest of the file in the filename:

``` html
<link href="assets/site-390be921ee0eff063817bb5ef2954300.css" rel="stylesheet" media="screen, projection">
```

This feature does not require any external tools.

## Asset bundling

This is a straightforward way to bundle assets with any minification
tool that supports reading input from STDIN and writing the output to
STDOUT. You write the configuration for input sources directly into
the content file where you want the markup tag for the bundle file to
appear. The outcome will be a markup tag containing the path to the
bundle file, and the generated site will have the bundle file in that
path. The MD5 digest of the file will be included in the filename.

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

## Development mode

The plugin has one more trick in its sleeves. If you set environment
variable `JEKYLL_MINIBUNDLE_MODE` to `development`, then the plugin
will copy asset files as is to the destination directory (using
`destination_path` as directory for `minibundle` block), and omit
fingerprinting. This is useful in development workflow, where you need
the filenames and line numbers of the original asset sources.

``` bash
$ JEKYLL_MINIBUNDLE_MODE=development jekyll --auto --server
```

# Example site

See the contents of `test/fixture/site` directory.

# License

MIT. See `LICENSE.txt`.

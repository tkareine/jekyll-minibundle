# Jekyll Minibundle plugin

A minimalistic plugin for bundling assets to
[Jekyll](https://github.com/mojombo/jekyll)'s site generation
directory.

In addition to the plugin, you need your asset bundling tool of choice
only. The plugin needs no other configuration than setting an
environment variable.

Tested with Ruby MRI 1.9.3. Ruby 1.8 is *not* supported.

# Features

There are two features: asset stamping with MD5 digest over the
contents of the asset, and asset bundling combined with the first
feature.

You still need a separate bundling tool, such as
[UglifyJS2](https://github.com/mishoo/UglifyJS2) to do the actual work
of bundling (concatenation, minification). There are no other
dependencies.

Why is this good? Well, a unique content specific identifier in asset
filename is the best way to handle web caching, because you can allow
caching the asset for forever. Calculating MD5 digest over the
contents of the asset is fast and the resulting digest is reasonably
unique to be generated automatically.

Asset bundling is good for reducing the number of requests to server
upon page load. It also allows minification for stylesheets and
JavaScript sources, which makes asset sizes smaller and thus faster to
load over network.

# Usage

The plugin is shipped as a
[RubyGem](https://rubygems.org/gems/jekyll-minibundle):

    gem install jekyll-minibundle

Add file `_plugins/minibundle.rb` to your Jekyll site project with
this line:

    require 'jekyll/minibundle'

## Asset stamping

Asset stamping is intended to be used together with
[Compass](http://compass-style.org/) and other similar asset
generation tools where you do not want to include unprocessed input
assets in the generated site.

Configure Compass to take inputs from `_assets/styles/*.scss` and to
put output to `_tmp/site.css`. Use `ministamp` tag to copy the
processed style asset to the generated site:

    <link href="{% ministamp _tmp/site.css assets/site.css %}" rel="stylesheet" media="screen, projection">

Output, containing the MD5 digest in the filename:

    <link href="assets/site-390be921ee0eff063817bb5ef2954300.css" rel="stylesheet" media="screen, projection">

This feature does not require any external tools.

## Asset bundling

A straightforward way to bundle assets with any tool that supports
reading input files from STDIN and writing the output to STDOUT. The
bundled file has MD5 digest in the filename.

Place `minibundle` block with configuration to your content file where
you want the generated markup to appear. For example, for bundling
JavaScript sources:

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

    $ JEKYLL_MINIBUNDLE_CMD_JS="./node_modules/.bin/uglifyjs --" jekyll

You can pass custom attributes to the generated markup with
`attributes` map in the configuration.

Output:

    <script type="text/javascript" src="assets/site-8e764372a0dbd296033cb2a416f064b5.js" id="my-scripts"></script>

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

# Example site

See the contents of `test/fixture/site` directory.

# License

Copyright (c) 2012 Tuomas Kareinen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
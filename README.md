# Jekyll Minibundle plugin

A straightforward asset bundling plugin for [Jekyll][Jekyll], utilizing
external minification tool of your choice. It provides asset
concatenation for bundling and asset fingerprinting with MD5 digest for
cache busting.

There are no runtime dependencies, except for the minification tool used
for bundling (fingerprinting has no dependencies).

The plugin requires Jekyll version 3.x. It is tested with Ruby MRI
2.x. Ruby 1.8 and 1.9 are *not* supported.

The plugin works with Jekyll's watch mode (auto-regeneration, Jekyll
option `--watch`), but not with incremental feature enabled (Jekyll
option `--incremental`).

[![Gem version](https://badge.fury.io/rb/jekyll-minibundle.svg)][MinibundleGem]
[![Build status](https://secure.travis-ci.org/tkareine/jekyll-minibundle.svg)][MinibundleBuild]

## Features

There are two features: asset fingerprinting with [MD5 digest][MD5] over
the contents of the asset, and asset bundling combined with the first
feature.

Asset bundling consists of concatenation and minification. The plugin
implements concatenation and leaves choosing the minification tool up to
you. [UglifyJS2][UglifyJS2] is a good and fast minifier, for
example. The plugin connects to the minifier with standard unix pipe,
feeding asset file contents to it in desired order via standard input,
and reads the result from standard output.

Why is this good? A fingerprint in asset's path is
the [recommended way][GoogleWebFundamentalsHttpCaching] to handle
caching of static resources, because you can allow browsers and
intermediate proxies to cache the asset for a very long
time. Calculating MD5 digest over the contents of the asset is fast and
the resulting digest is reasonably unique to be generated automatically.

Asset bundling is good for reducing the number of requests to the
backend upon page load. The minification of stylesheets and JavaScript
sources makes asset sizes smaller and thus faster to load over network.

## Usage

The plugin ships as a [RubyGem][MinibundleGem]. To install:

``` bash
$ gem install jekyll-minibundle
```

(You should use [Bundler][Bundler] to manage the gems in your project.)

Then, instruct Jekyll to load the gem by adding this line to the
[configuration file][JekyllConf] of your Jekyll site project
(`_config.yml`):

``` yaml
gems: ['jekyll/minibundle']
```

An alternative to using the `gems` configuration option is to add
`_plugins/minibundle.rb` file to your site project with this line:

``` ruby
require 'jekyll/minibundle'
```

You must allow Jekyll to use custom plugins. That is, do not enable
Jekyll's `safe` option.

### Asset fingerprinting

If you just want to have an MD5 fingerprint in your asset's path, use
`ministamp` [Liquid][Liquid] tag in a Liquid template file. For example:

``` liquid
<link rel="stylesheet" href="{{ site.baseurl }}/{% ministamp _assets/site.css assets/site.css %}" media="screen, projection">
```

When it's time to render the `ministamp` tag, the plugin copies the
source file (`_assets/site.css`, the first tag argument) to the
specified destination path (`assets/site.css`, the second tag argument)
in Jekyll's site destination directory. The filename will contain a
fingerprint.

The tag outputs the asset destination path, encoded for HTML, into
Liquid's template rendering outcome. For example, when `site.baseurl` is
empty:

``` html
<link rel="stylesheet" href="/assets/site-390be921ee0eff063817bb5ef2954300.css" media="screen, projection">
```

This feature is useful when combined with asset generation tools
external to Jekyll. For example, you can configure [Sass][Sass] to take
input files from `_assets/styles/*.scss` and to produce output to
`_tmp/site.css`. Then, you use `ministamp` tag to copy the file with a
fingerprint to Jekyll's site destination directory:

``` liquid
<link rel="stylesheet" href="{{ site.baseurl }}/{% ministamp _tmp/site.css assets/site.css %}">
```

#### `ministamp` call syntax

The argument for `ministamp` tag must be in [YAML][YAML] syntax, and
parsing the argument as YAML must result either in a String or a
Hash. What you saw previously was the argument being parsed as a String;
it's effectively a shorthand version of passing the argument as a Hash
with certain keys. That is, in the following call:

``` liquid
{% ministamp _tmp/site.css assets/site.css %}
```

the argument is a String: `"_tmp/site.css assets/site.css"`. The call is
equivalent to the following call with Hash argument:

``` liquid
{% ministamp { source_path: _tmp/site.css, destination_path: assets/site.css } %}
```

The Hash argument allows expressing more options and quoting
`source_path` and `destination_path` values, if needed.

The supported keys for the Hash argument are:

| Key | Required? | Value type | Value example | Default value | Description |
| --- | --- | --- | --- | --- | --- |
| `source_path` | yes | string | `'_tmp/site.css'` | - | The source path of the asset file, relative to the site directory. |
| `destination_path` | yes | string | `'assets/site.css'` | - | The destination path of the asset file, relative to Jekyll's site destination directory. If the value begins with `/` and `render_basename_only` is `false`, `ministamp`'s output will begin with `/`. |
| `render_basename_only` | no | boolean | `true` | `false` | If `true`, `ministamp`'s rendered URL will be the basename of the asset destination path. See [Separating asset destination path from generated URL](#separating-asset-destination-path-from-generated-url) for more. |

With Hash argument, the plugin processes `source_path` and
`destination_path` values through a tiny template engine. This allows
you to use Liquid's variables as input to `ministamp` tag. An example
with Liquid's [`assign`][LiquidAssignTag] tag:

``` liquid
{% assign asset_dir = 'assets' %}
<link rel="stylesheet" href="{% ministamp { source_path: _tmp/site.css, destination_path: '{{ asset_dir }}/site.css' } %}">
```

The above would use `assets/site.css` as the destination path.

Note that you must quote `destination_path`'s value, otherwise YAML does
not recognize it as a proper string.

To refer to Jekyll's configuration options ([`_config.yml`][JekyllConf])
in the template, prefix the variable name with `site.`. For example, to
refer to `baseurl` option, use syntax `{{ site.baseurl }}` in the
template.

See [Variable templating](#variable-templating) for details about the
template syntax.

### Asset bundling

This is a straightforward way to bundle assets with any minification
tool that supports reading input from STDIN and writing the output to
STDOUT. You write the configuration for input sources directly into the
content file where you want the markup tag for the bundle file to
appear. The markup tag contains the path to the bundle file, and the
Jekyll's site destination directory will have the bundle file at that
path. The path will contain an MD5 fingerprint.

Place `minibundle` [Liquid][Liquid] block into the Liquid template file
where you want the block's generated markup to appear. Write bundling
configuration inside the block in [YAML][YAML] syntax. For example, to
bundle a set of JavaScript sources:

``` text
{% minibundle js %}
source_dir: _assets/scripts
destination_path: assets/site
baseurl: '{{ site.baseurl }}/'
assets:
  - dependency
  - app
attributes:
  id: my-scripts
  async:
{% endminibundle %}
```

Then, specify the command for launching your favorite minifier in
`_config.yml`:

``` yaml
baseurl: ''

minibundle:
  minifier_commands:
    js: node_modules/.bin/uglifyjs -
```

When it's time to render the `minibundle` block, the plugin launches the
minifier and connects to it with a Unix pipe. The plugin feeds the
contents of the asset files in `source_dir` directory as input to the
minifier (STDIN). The feeding order is the order of the files in the
`assets` key in the block configuration. The plugin expects the minifier
to produce output (STDOUT) and writes it to the file at
`destination_path` in Jekyll's site destination directory. The filename
will contain a fingerprint.

The block outputs `<link>` (for `css` type) or `<script>` (for `js`
type) HTML element into Liquid's template rendering outcome. Continuing
the example above, the block's output will be:

``` html
<script src="/assets/site-8e764372a0dbd296033cb2a416f064b5.js" type="text/javascript" id="my-scripts" async></script>
```

You can pass custom attributes, like `id="my-scripts"` and `async`
above, to the generated markup with `attributes` map inside the
`minibundle` block.

As shown above for the `baseurl` key, you can use Liquid template syntax
inside the contents of the block. Liquid renders block contents before
`minibundle` block gets the turn to render itself. Just ensure that
block contents will result in valid YAML.

For bundling CSS assets, use `css` as the argument to the `minibundle`
block:

``` text
{% minibundle css %}
source_dir: _assets/styles
destination_path: assets/site
baseurl: '{{ site.baseurl }}/'
assets:
  - reset
  - common
attributes:
  media: screen
{% endminibundle %}
```

And then specify the minifier command in `_config.yml`:

``` yaml
minibundle:
  minifier_commands:
    css: _bin/remove_whitespace
    js: node_modules/.bin/uglifyjs -
```

#### `minibundle` call syntax

Use `css` or `js` as the argument to the opening tag, for example `{% minibundle css %}`.

The block contents must be in [YAML][YAML] syntax. The supported keys are:

| Key | Value type | Value example | Default value | Description |
| --- | --- | --- | --- | --- |
| `source_dir` | string | - | `'_assets'` | The source directory of `assets`, relative to the site directory. |
| `destination_path` | string | - | `'assets/site'` | The destination path of the bundle file, without type extension, relative to Jekyll's site destination directory. If the value begins with `/` and `baseurl` is empty, `baseurl` will be set to `'/'` implicitly. |
| `baseurl` | string | `{{ site.baseurl }}/` | `''` | If nonempty, the bundle destination URL inside `minibundle`'s rendered HTML element will be this value prepended to the destination path of the bundle file. Ignored if `destination_baseurl` is nonempty. |
| `destination_baseurl` | string | `'{{ site.cdn_baseurl }}/'` | `''` | If nonempty, the bundle destination URL inside `minibundle`'s rendered HTML element will be this value prepended to the basename of the bundle destination path. See [Separating asset destination path from generated URL](#separating-asset-destination-path-from-generated-url) for more. |
| `assets` | array of strings | `['dependency', 'app']` | `[]` | Array of the basenames of assets in `source_dir` directory, without type extension. These are the asset files to be bundled, in order, into one bundle destination file. |
| `attributes` | map of keys to string values | `{id: my-link, media: screen}` | `{}` | Custom HTML element attributes to be added to `minibundle`'s rendered HTML element. |

### Minifier command specification

You can specify minifier commands in three places:

1. in `_config.yml` (as shown earlier):

   ``` yaml
   minibundle:
     minifier_commands:
       css: _bin/remove_whitespace
       js: node_modules/.bin/uglifyjs -
   ```

2. as environment variables:

   ``` bash
   export JEKYLL_MINIBUNDLE_CMD_CSS=_bin/remove_whitespace
   export JEKYLL_MINIBUNDLE_CMD_JS="node_modules/.bin/uglifyjs -"
   ```

3. inside the `minibundle` block with `minifier_cmd` option, allowing
   blocks to have different commands from each other:

   ``` text
   {% minibundle js %}
   source_dir: _assets/scripts
   destination_path: assets/site
   minifier_cmd: node_modules/.bin/uglifyjs -
   assets:
     - dependency
     - app
   attributes:
     id: my-scripts
   {% endminibundle %}
   ```

These ways of specification are listed in increasing order of
specificity. Should multiple commands apply to a block, the most
specific one wins. For example, the `minifier_cmd` option inside `{%
minibundle js }%` block overrides the setting in
`$JEKYLL_MINIBUNDLE_CMD_JS` environment variable.

### Recommended directory layout

It's recommended that you exclude the files you use as asset sources
from Jekyll itself. Otherwise, you end up with duplicate files in the
site destination directory.

For example, in the following snippet we're using `assets/src.css` as
asset source to `ministamp` tag:

``` liquid
<!-- BAD: unless assets dir is excluded, both src.css and dest.css will be copied to site destination directory -->
<link rel="stylesheet" href="{{ site.baseurl }}/{% ministamp assets/src.css assets/dest.css %}" media="screen, projection">
```

By default, Jekyll includes this file to the site destination
directory. As a result, there will be both `src.css` and
`dest-<md5>.css` files in `_site/assets/` directory, which you probably
do not want.

In order to avoid this, exclude the asset source file from Jekyll.
Because Jekyll's site generation excludes underscore directories (that
is, directories whose name begins with underscore character), consider
using the following directory layout:

* `_assets/` for JavaScript and CSS assets handled by the plugin that
  are in version control
* `_tmp/` for temporary JavaScript and CSS assets handled by the plugin
  that are not in version control (for example, Sass output files)
* `assets/` for images and other assets handled by Jekyll directly

However, Jekyll's watch mode (auto-regeneration) does monitor files
inside underscore directories. If such a file is modified, the watch
mode triggers site generation. For Minibundle's functionality, this is
beneficial: it allows the plugin to check if assets need to be updated
to the site destination directory.

The `exclude` [Jekyll configuration][JekyllConf] option affects Jekyll's
watch mode. Given the recommended directory layout above, if you set the
following in `_config.yml`:

``` yaml
exclude:
  - _assets
  - _tmp
```

Then Jekyll won't see if files inside those directories have changed and
the plugin won't get the chance to update assets to the site destination
directory. So, don't explicitly exclude `_assets` and `_tmp`
directories.

See [Jekyll configuration][JekyllConf] for more about excluding files
and directories.

### Development mode

If you set `$JEKYLL_MINIBUNDLE_MODE` environment variable to
`development`, then the plugin will copy asset files as is to Jekyll's
site destination directory and omit fingerprinting.

The development mode changes `minibundle` block's `destination_path`
option to be the base directory for files mentioned in `assets`
option. This is useful in development workflow, where you need the
filenames and line numbers of the original asset sources.

``` bash
$ JEKYLL_MINIBUNDLE_MODE=development jekyll serve --watch
```

Alternatively, you can enable development mode from `_config.yml`:

``` yaml
minibundle:
  mode: development
```

Should both be defined, the setting from the environment variable wins.

### Variable templating

The template engine used by `ministamp` tag's Hash argument has syntax
resembling the ones of [Liquid][Liquid] and [Mustache][Mustache], with
`{{` and `}}` tags surrounding the variable to be substituted into the
output string. For example, given Liquid variable `var = 'foo'`, the
template `begin{{ var }}end` results in `beginfooend`.

The engine supports variable substitution only. It does not support
other expressions. If you need to, you can write complex expressions in
Liquid, store the result to a variable, and use the variable in the
template.

If you need literal `{` or `}` characters in the template, you can
escape them with backslash. For example, `\{` results in `{` in the
output. To output backslash character itself, write it twice: `\\`
results in `\` in the output.

Inside variable subsitution (between `{{` and `}}`), anything before the
closing `}}` tag is interpreted as part of the variable name, except
that the engine removes any leading and trailing whitespace from the
name. For example, in the template `{{ var } }}`, `var }` is treated as
the name of the variable.

A reference to undefined variable results in empty string. For example,
`begin{{ nosuch }}end` will output `beginend` if there's no variable
named `nosuch`.

### Separating asset destination path from generated URL

Use `render_basename_only: true` option of `ministamp` tag and
`destination_baseurl` option of `minibundle` block to separate the
destination path of the asset file from the generated URL of the
asset. This allows you to serve the asset from a separate domain, for
example.

Example usage, with the following content in `_config.yml`:

``` yaml
cdn_baseurl: 'https://cdn.example.com'
```

For `ministamp` tag:

``` liquid
<link rel="stylesheet" href="{{ site.cdn_baseurl }}/css/{% ministamp { source_path: '_tmp/site.css', destination_path: assets/site.css, render_basename_only: true } %}">
```

The asset file will be in Jekyll's site destination directory with path
`assets/site-ff9c63f843b11f9c3666fe46caaddea8.css`, and Liquid's
rendering will result in:

``` html
<link rel="stylesheet" href="https://cdn.example.com/css/site-ff9c63f843b11f9c3666fe46caaddea8.css">
```

For `minibundle` block:

``` liquid
{% minibundle js %}
source_dir: _assets/scripts
destination_path: assets/site
destination_baseurl: '{{ site.cdn_baseurl }}/js/'
assets:
  - dependency
  - app
{% endminibundle %}
```

The bundle file will be in Jekyll's site destination directory with path
`assets/site-4782a1f67803038d4f8351051e67deb8.js`, and Liquid's
rendering will result in:

``` html
<script type="text/javascript" src="https://cdn.example.com/js/site-4782a1f67803038d4f8351051e67deb8.js"></script>
```

### Capturing Liquid output

Use Liquid's [`capture`][LiquidCaptureBlock] block to store output
rendered inside the block to a variable, as a string. Then you can
process the string as you like.

For example:

``` liquid
{% capture site_css %}{% ministamp _assets/site.css assets/site.css %}{% endcapture %}
<link rel="stylesheet" href="{{ site_css | remove_first: "assets/" }}">
```

Liquid's rendering outcome:

``` html
<link rel="stylesheet" href="site-390be921ee0eff063817bb5ef2954300.css">
```

## Example site

See the sources of [an example site][JekyllMinibundleExampleSite].

## Known caveats

The plugin does not work with Jekyll's incremental rebuild feature
(Jekyll option `--incremental`).

## License

MIT. See `LICENSE.txt`.

[Bundler]: http://bundler.io/
[GoogleWebFundamentalsHttpCaching]: https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/http-caching#invalidating-and-updating-cached-responses
[JekyllConf]: https://jekyllrb.com/docs/configuration/
[JekyllMinibundleExampleSite]: https://github.com/tkareine/jekyll-minibundle-example
[Jekyll]: https://jekyllrb.com/
[Liquid]: https://shopify.github.io/liquid/
[LiquidAssignTag]: https://shopify.github.io/liquid/tags/variable/#assign
[LiquidCaptureBlock]: https://shopify.github.io/liquid/tags/variable/#capture
[MD5]: https://en.wikipedia.org/wiki/MD5
[MinibundleBuild]: https://travis-ci.org/tkareine/jekyll-minibundle
[MinibundleGem]: https://rubygems.org/gems/jekyll-minibundle
[Mustache]: https://mustache.github.io/
[Sass]: http://sass-lang.com/
[UglifyJS2]: https://github.com/mishoo/UglifyJS2
[YAML]: http://www.yaml.org/

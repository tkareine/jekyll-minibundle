# 1.4.6 / 2014-05-10

* Handle compatibility issues with safe_yaml and logger flexibly. This
  should allow using the plugin with Jekyll 1.0 and 2.0.

# 1.4.5 / 2014-05-10

* Use SafeYAML to load user input from `minibundle` block for
  consistent behavior with Jekyll and for security
* Clean log messages: show relative paths when bundling assets
* Add missing implementations of `relative_path` and `to_liquid`
  methods from Jekyll's StaticFile API (introduced in Jekyll v1.5.0),
  allowing Minibundle to behave better with other Jekyll plugins (#3,
  @mmistakes)
* Fix Ruby deprecation warnings (use `File.exist?` instead of
  `File.exists?`)

# 1.4.4 / 2014-01-16

* Conserve memory when calculating fingerprint for an asset.
  Previously, we read the whole asset file into memory and then
  calculated the MD5 digest. This is bad for big assets. Now, we read
  the file in chunks.

# 1.4.3 / 2014-01-16

* Do not leak read pipe file descriptor upon minifier command failure
* Loosen version constraints for development gem dependencies
* Clarify documentation
* Fix some Ruby coding style issues
* Minor internal state handling improvements
* Clarify tests, increase test coverage

# 1.4.2 / 2013-12-28

* Ensure touching asset source triggers destination write. This was an
  unintentional edge case earlier. Now the behavior of touching the
  asset source is consistent with when changing the contents of the
  source.
* Separate tags produced by `minibundle` in development mode with
  newlines
* Clarify tests, increase coverage

# 1.4.1 / 2013-12-27

* Add missing files to gem package

# 1.4.0 / 2013-12-27

* Fix bug causing exception to be thrown when `ministamp` or
  `minibundle` is called twice with same asset source argument. Allow
  handling asset source files that are already static files in Jekyll
  (remove the restriction introduced in 1.3.0). (#2, @agrigg)

# 1.3.0 / 2013-12-25

* Disallow handling asset source files that are already static files
  in Jekyll. Otherwise, we would potentially get to inconsistencies in
  Jekyll's watch mode. See "Jekyll static file restriction" in
  README.md. (#2, @agrigg)
* Upgrade development dependencies

# 1.2.0 / 2013-09-29

* If Jekyll's logger is available, use it for nice output when bundling
* Upgrade development dependencies
* Simplify `BundleFile` class implementation

# 1.1.0 / 2013-02-27

* `ministamp` tag omits fingerprint in development mode
* Clarify documentation
* Comply with (Gemnasium) conventions for changelogs (#1, @tmatilai)
* Bug fix: do not bundle assets when nonrelated files change
* Bug fix: do not bundle assets twice upon startup

# 1.0.0 / 2013-02-15

* Add development mode, where `minibundle` block will copy each asset
  as-is to the destination directory
* Clarify documentation
* Increase test coverage

# 0.2.0 / 2012-12-15

* Escape the values of custom attributes given in `minibundle` block
* Add semicolons between each JavaScript asset in bundling
* Show error in page output if asset bundling command failed

# 0.1.0 / 2012-12-07

* Add `ministamp` tag and `minibundle` block for Jekyll
* First release

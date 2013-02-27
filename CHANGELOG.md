# 1.1.0 / 2013-02-27

* `ministamp` tag omits fingerprint in development mode
* Clarify documentation
* Comply with (Gemnasium) conventions for changelogs (@tmatilai)
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

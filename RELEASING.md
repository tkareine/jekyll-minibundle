# Releasing

1. Check that [CI] is green.

2. Double check that tests pass:

   ```shell
   BUNDLE_GEMFILE=Gemfile-jekyll4 bundle exec rake
   BUNDLE_GEMFILE=Gemfile-jekyll3 bundle exec rake
   ```

3. Update version number in `Jekyll::Minibundle::VERSION`:

   ```shell
   $EDITOR lib/jekyll/minibundle/version.rb
   ```

4. Update gem version in Gemfile locks:

   ```shell
   BUNDLE_GEMFILE=Gemfile-jekyll4 bundle install
   BUNDLE_GEMFILE=Gemfile-jekyll3 bundle install
   ```

5. Describe a summary of changes since the last release:

   ```shell
   $EDITOR CHANGELOG.md
   ```

6. Review your changes, commit them, tag the release, and push:

   ```shell
   git diff
   git commit --all --message="Release v$version"
   git tag v$version
   git push origin master v$version
   ```

   Make sure that the version string in
   `lib/jekyll/minibundle/version.rb` and the git tag name match. Note
   that the git tag name uses the `v` prefix.

   After pushing, the [CI] publishes npm package automatically.

[CI]: https://github.com/tkareine/jekyll-minibundle/actions/workflows/ci.yml

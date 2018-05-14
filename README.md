# Geocollider

This is a Ruby Gem for gazetteer alignment. It aims to provide generic functionality for finding potential matches between two placename datasets. In addition to allowing you to compare two different datasets, it can also help you find duplicates within one list.

**WARNING:** This project is still under active initial development, and may still be subject to changes and API breakage.

## Usage

To use this library as a gem, add the following line to your [`Gemfile`](https://bundler.io):

    gem 'geocollider', :git => 'https://github.com/isawnyu/geocollider.git'

Then run `bundle update`, and add `require geocollider` to your ruby scripts.

There are some sample command-line ruby scripts in the `bin/` directory that use Geocollider for aligning various kinds of data. You can run them using `bundle exec <scriptname> <parameters>`. You may find that the scripts won't run until you use `bundle update` to update the Gemfile.lock that bundler creates in order to get more up-to-date version numbers of dependencies. Find it via `bundle show geocollider`.

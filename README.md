# Geocollider

This is a Ruby Gem for gazetteer alignment. It aims to provide generic functionality for finding potential matches between two placename datasets.

**WARNING:** This project is still under active initial development, and may still be subject to changes and API breakage.

## Usage

To use this library as a gem, add the following line to your [`Gemfile`](https://bundler.io):

    gem 'geocollider', :git => 'https://github.com/isawnyu/geocollider.git'

Then run `bundle update`, and add `require geocollider`.

There are some sample command-line ruby scripts in the `bin/` directory that use Geocollider for aligning various kinds of data.

# Geocollider

This is a Ruby program/framework for gazetteer alignment. It aims to provide generic functionality for finding potential matches between two placename datasets.

## Organization

Superclass:

- provides interface
- does name normalization
- does geospatial comparison

Subclass:

- does geospatial normalization

Example subclasses:

- PleiadesParser
- TGNParser
- GeoNamesParser
- OSMParser

Parser:

- `parse(filename)` - returns hash of `names->places` and `places->data`
- `compare(names, places, filename, csv)` - returns matches against names/places from parsing filename
- `download(filename)` - eventually, so this won't be in Makefiles and the like

Place:

- `id` - identifier string
- `point` - eventually also have `polygon`
- `additional_metadata` - hash, each key will be a column in CSV output
- `type` - type of place? for type filtering inside `compare`?

Driver:

- takes two instances
- runs .parse(filename) on first
- passes results of first to second so we can parse-and-compare (instead of having to do full parse on each and keep both in memory)

Levels of geospatial comparison complexity:

1. point<->point distance threshold
2. bbox<->point containment
3. polygon<->point containment
4. polygon<->polygon relationships

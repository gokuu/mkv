MKV
===

Simple wrapper around MKVToolNix's mkvinfo utility to get data from MKV movies, and mkvextract to extract subtitles.

Installation
------------

    (sudo) gem install mkv

This version is tested against MKVToolNix 5.8.0 build 2012-09-02-6920. So no guarantees with earlier versions.

Usage
-----

### Require the gem

``` ruby
require 'rubygems'
require 'mkv'
```

### Reading Metadata

``` ruby
movie = MKV::Movie.new("path/to/movie.mkv")

track = movie.tracks.first # Contains all streams

track.type # video, audio, or subtitles
track.uid 
track.number
track.mkv_info_id
track.lacing 
track.codec_id

# For video tracks
track.width 
track.height

# For audio
track.sampling_frequency
track.channels

# For subtitle & audio tracks
track.language # ISO 639-3
track.enabled
track.default
track.forced

```

Specify the path to mkvinfo and mkvextract
--------------------------

By default, streamio assumes that the mkvinfo and mkvextract binaries are available in the default installation paths:

On Mac OSX:
``` ruby
MKV.mkvinfo_binary = "/Applications/Mkvtoolnix.app/Contents/MacOS/mkvinfo"
MKV.mkvextrack_binary = "/Applications/Mkvtoolnix.app/Contents/MacOS/mkvextract"
```

On Windows:
TODO!

Copyright
---------

Copyright (c) 2012 Pedro Rodrigues. See LICENSE for details.

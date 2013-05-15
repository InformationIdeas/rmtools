### RMTools
[github](https://github.com/tinbka/rmtools)

Collection of helpers for any need: strings, enumerables, modules... hundreds of bicycles and shortcuts you ever wanted to implement are here, optimized for performance.
Small dev library (constantly in progress): fast and smart logger, binding explorer, backtrace formatter, each is console-colored.
Started from basic classes, now it contains low-level helpers for ActiveRecord and makes LibXML more jqueryish.

RMTools helps to throw away some boiler-plate making a code more intuitive. It comes with almost no (<< 10%) performance penalty:
* `hash[:id]` -> `hash.id`
* `ary.map(&:id)` -> `ary.ids`
* `ary.map {|h| h[:id]}` -> `ary.ids`
* `comments.posts.sorted_uniq_by_id.select_by_user_id(user_id).sum_points` -> `comments.map {|c| c.post}.sort_by {|p| p.id}.uniq_by {|p| p.id}.select {|p| p.user_id == user_id}.sum {|p| p.points}`

---

It's still randomly documented since it's just my working tool.

#### Wanted to implement

* Ruby code parser (StringScanner-based) reading an array of loaded ruby-files and making accurate hash-table of defined methods {"Class#method" => "def ... end"}
* JSON-formatter for output ruby objects content in HTML presentation in order to inspect big objects using browser graphic abilities
* Set theory based Range extension with support of both begin and end exclusion, and satisfying the next rules:
  * `size(0..1) = size(0...1) = 1`
  * `A = A - B | B`
  *   `A ⊃ B -> size(A - B) = size(A) - size(B)`


### CHANGES

##### Version 2.0.0

* Array Meta-iterators
  * Pattern has became a class variable. New names can be added to pattern by Array::add_iterator_name
  * Speed has been drastically boosted by evaluating of every proper missing method. (Read comments in /enumerable/array_iterators.rb)
  * Using meta-iterators in the new behaviour can smudge Array instance_methods namespace. Although it's not something that bad, that's possible to turn on the old behaviour by Array::fallback_to_clean_iterators!

* Hash#method_missing
  * hash.something gets hash[:something] || hash['something'], not other way
  * hash.something= sets hash['something'] as did it before
  * This change has been caused by large amounts of symbolic options keys and json decode returning symbolic keys (at least with a yajl library).
  * Set behaviour, on the other hand, will not be changed since 1) it will be too hard to debug hashes in an old code; 2) it's not that frequently used; 3) setting hash key directly by :[]= makes a code clearer
  
* Class
  * Added private #alias_constant

* Array
  * #avg and #avg_by for an empty array now return 0
  * Added #intersects? aliased as #x?

* Symbol
  * Added #+, #split and #method_missing to proxy all possible methods to #to_s

* Range
  * Described concept of the extension (/enumerable/range.rb)
  * Changed default Range#include? the way it can take range as argument
  * Added XRange#first(count) and #last(count), analogically to Range#first and #last

* ActiveRecord
  * Moved declarative.rb from Rhack project. ::Base::declarative is a way of making tables like by migrations but on the fly
  * Added ::Base#with_same(<column_name>)
  * ::Base::non_null_scopes ignores non-nullable columns

* Development kit
  * RMTools::timer now resets $quiet and $log.mute_warn to previous values in case of ^C or another exception raised
  * Fixed all potential problems with /dev, so require "rmtools_dev" is deprecated in favour of require "rmtools" and will be removed in the next update
  * Read comments about format_trace in /dev/trace_format.rb
  * BlackHole class is aliased as Void
  * Added :detect_comments and :precede_comments options to ::RMLogger to automatically highlight comment blocks get logged

* Structural changes
  * Moved /b.rb into /core since #b is proved usability through some years
  * Renamed /db into /active_record
  * Merged /ip into /conversions
  * The gem is now being produced in the bundle style: added Gemfile, .gemspec, etc

##### Version 1.3.3

* Added to Array: #sort_along_by, #indices_map, #each_two
* Added Enumerable#map_hash
* Range
  * Fixed #size for backward ranges
  * Fixed #x? and #-@ for neighbor numbers and non-integers in general
  * added XRange#x?
  * aliased #x? as #intersects?
* Class#__init__ accepts block, auto__init__ed Thread and Proc

##### Version 1.3.0

* Added ::ValueTraversal and ::KeyValueTraversal modules for treeish dir/enumerable search
* String
  * Cyrillic support: #fupcase, #fdowncase and instant up/down versions
  * #to_search, #squeeze_newlines, #recordize
  * key :js_caller to #parse for JS stacktrace lines as it given by stacktrace.js library
* Added ActiveRecord::Base::boolean_scopes! and ::non_null_scopes!
* Added Object#ifndef for ivars caching
* Fixed bugs
  * Class#__init__ (case with nested classes)
  * ActiveRecord::Base::select_rand (case with :where query)
  * ::rw and ::write (cases with encoding fail and non-string argument)
* Described the library and *marked down* this readme

##### Version 1.2.14

* Smartified Array bicycles: #index_where, #indices_where, #set_where, #set_all_where, #del_where, #del_all_where
* Added #arrange_by to Array enumerators
* Added AR::Base::enum for virtual "enum" type support
* Updated detecting of xml charset encoding for ruby 1.9
* Fixed bug with empty trace formatting and Array#get_args with non-equalable argument

##### Version 1.2.11

* Added Array#select_by and #reject_by pattern-iterators
* Fixed ActiveRecord::Base.select_rand
* Restricted RMTools.format_trace to use with Rails because of hard slowdown
* Updated Proc constants for ruby 1.9

##### Version 1.2.10

* Update String#parse:caller to parse ruby 1.9 "block level". Now block level processes in RMLogger and RMTools.format_trace
* lib/dev/traceback.rb now applies to ruby > 1.9 as well
* Support of Yajl or (if not installed) JSON for #to_json and #from_json. Overwrites ActiveSupport's ::encode and ::decode since they're so damn slow.

##### Version 1.2.8

* StringScanner#each changed to compare `cbs' keys with @matched by number in ruby 1.8 and by first character in ruby 1.9, since ?x in 1.9 returns string instead of a charcode
* Updated LibXML::XML::XPath to search elements with multiple classes

##### Version 1.2.7

* String#hl and #ghl: console-highlight pattern in string
* True#call and False#call in order to pass boolean values as callable argument
* ActiveRecord::Relation#any? and #empty?, ActiveRecord::Base.insert_unless_exist (using execute) and .select_rand 
* Added couple of handlers into Array#method_missing
* File.modify now can process files by glob-patterns and correctly use multiple gsub! inside passed block
* RMTools.read now can read from list of files in order
* Upped RMTools.timer accuracy
* Optimized Array#-, #+, #& and #| for when one of arrays is empty; added Array#diff
* Optimized Object#to_json and String#from_json: use JSON stdlib for ruby 1.9. Object#to_json_safe: timeout'ed conversion
* String#cut_line and #split_to_lines optimized for use in Ruby 1.9
* Removed String#bytes because it duplicate ruby 1.9 method
* static VALUE rb_ary_count_items moved from Array#count to Array#arrange
* Fixed Module#self_name
* RMTools::CodeReader is still unstable though

##### Version 1.2.0

* Renamed debug/ to dev/, slightly restructured lib/rmtools/ and require handlers: requrie 'rmtools' for common applications and 'rmtools_dev' for irb and maybe dev environment
* Slightly extended StringScanner
* Proof of concept: Regexp reverse (wonder if someone did it earlier in Ruby)
* Kernel#whose? to find classes and/or modules knowing some method
* Method code lookup over all loaded libs (it can't handle evals yet), see dev/code_reading.rb
* Coloring is now made by singleton `Painter' and have option for transparent coloring

##### Version 1.1.14

* Added caller level option (:caller => <int>) for Logger
* Fixed trace formatting (for sure for this time)
* Array iterator #sum_<method> now takes argument for #sum as first argument
* Completed Binding#inspect_env components

##### Version 1.1.11

* Fixed Hash#unify_keys for 1.9.2
* Speeded Array#uniq_by up
* Added some shortcut methods for ActiveRecord::Base

##### Version 1.1.10

* Deleted String#to_proc. It's anyway inconsistent and causes bug in ActiveRecord 3.0.5 Base#interpolate_and_sanitize_sql and potentially somewhere else
* Solved problem with String#sub methods in 1.9: that's associated with String#to_hash in some mystic way. #to_hash is now #to_params
* Some bugfixes for previous updates

##### Version 1.1.7

* Cosmetic fixes for txts here

##### Version 1.1.6

* Rewrited few functions
* Fixed bug with RDoc and RI
* Compatible with 1.9
* Binding#start_interaction and RMTools::Observer for debugging purposes
* To require any file from lib/rmtools now RMTools::require is used
* In order to not overload Rails apps initialization tracing is lightened and gem now may be also required as "rmtools_nodebug" and "rmtools_notrace"

##### Version 1.1.0

* Fixed some bugs
* Divided by semantics
* Compatible with ruby 1.8.7 (2010-08-16 patchlevel 302)

##### Version 1.0.0

* Divided by classes and packed as gem

### License

RMTools is copyright (c) 2010-2013 Sergey Baev <tinbka@gmail.com>, and released under the terms of the Ruby license. 
SCRIPT_LINES__ = {} unless defined? SCRIPT_LINES__
$__MAIN__ = self
require 'rmtools/init'
RMTools::require 'dev'

unless defined? Rails; class Object; include RMTools end end
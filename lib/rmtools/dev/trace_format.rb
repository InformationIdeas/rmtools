# encoding: utf-8
RMTools::require 'dev/highlight'
RMTools::require 'dev/logging'

module RMTools

	# Python-like traceback for exceptions; uses ANSI coloring.
  # In case of any low-level ruby error it may hang up interpreter
  # (although you must have done VERY creepy things for that). If you find 
  # interpreter in hanging up, require 'rmtools_notrace' instead of 'rmtools'
  # or run "Exception.trace_format false" right after require
  #
  #   1:0> def divbyzero
  #   2:1< 10/0 end
  #   => nil
  #   3:0> divbyzero
  #   ZeroDivisionError: divided by 0
  #          from (irb):2:in `divbyzero' <- `/'
  #     >>  10/0 end
  #          from (irb):3
  #     >>  divbyzero
  def format_trace(a)
    bt, calls, i = [], [], 0
    m = a[0].parse:caller
    while i < a.size
      m2 = a[i+1] && a[i+1].parse(:caller)
      if m and m.func and m2 and [m.path, m.line] == [m2.path, m2.line]
        calls << " -> `#{m.func}'"
      elsif m and m.line != 0 and line = RMTools.highlighted_line(m.path, m.line)
        bt << "#{a[i]}#{calls.join}\n#{line}"
        calls = []
      else bt << a[i]
      end
      i += 1
      m = m2
    end
    bt
  end
  
  # disclaimer: Firefox (at least 3.6+) on Windoze does not allow to use file:// protocol T_T
  def format_trace_to_html(a)
    a.map! do |lines|
      caller_string, snippet = lines/"\n"
      caller = caller_string.parse(:caller)
      if caller
        path = caller.path
        lines = ["<a href='#{CGI.escape 'file://'+path}'>#{path}</a>:#{caller.line} in #{caller.func}"]
        lines << RMTools::Painter.clean(snippet) if snippet
        lines * "\n"
      else
        lines
      end
    end
  end
  
  module_function :format_trace, :format_trace_to_html
end

class Class
  
private
  def trace_format method
    if Exception.in ancestors
      class_attribute :__trace_format
      self.__trace_format = method
    else
      raise NoMethodError, "undefined method `trace_format' for class #{self}"
    end
  end
  
end
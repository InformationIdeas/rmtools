# encoding: utf-8
RMTools::require 'fs/file'
RMTools::require 'enumerable/traversal'

class Dir
  # included in order to use treeish search in directory content tree
  include RMTools::ValueTraversal
  
  def to_traversable
    RMTools::ValueTraversable.new(children)
  end
  
  def include?(name)
    to_a.include? name
  end
  
  def recursive_content(flat=true, opts={})
    if opts[:recursive] = flat
      return content(opts)
    end
    content(opts).map {|p|
      if File.directory?(p)
             Dir.new(p).recursive_content(false)
      else p
      end
    }
  end
  
  def content(opts={})
    Dir["#{path}/#{'**/' if opts.recursive}#{'{.,}' if opts.include_dot}*"].
    reject {|p| p =~ %r{/\.\.?$}}.map! {|p| p.sub(/^\.\//, '')}
  end
  
  def parent
    newpath = File.dirname(path)
    Dir.new(newpath) if newpath != path 
  end
  
  def child(idx)
    df = content[idx]
    if File.file?(df)
      File.new(df)
    elsif File.directory?(df)
      Dir.new(df)
    end
  end
  
  def children
    content.map {|df| 
      if File.file?(df)
        File.new(df)
      elsif File.directory?(df)
        Dir.new(df)
      end                    
    }
  end
  
  def refresh
    return if !File.directory?(path)
    Dir.new(path)
  end
  
  def inspect
    displaypath = case path
          when /^(\/|\w:)/ then path
          when /^\./ then File.join(Dir.pwd, path[1..-1])
          else File.join(Dir.pwd, path)
        end
    "<#Dir \"#{displaypath}\" #{to_a.size - 2} elements>"
  end
  
  def name
    File.basename(path)
  end
  
  # Fixing windoze path problems
  # requires amatch gem for better performance
  def real_name
    n, p, count = name, parent, []
    return n if !p
    pp, pc, sc = parent.path, parent.to_a[2..-1], to_a
    if defined? Amatch
      ms = pc.sizes.max
      count = [:hamming_similar, :levenshtein_similar, :jaro_similar].sum {|m| pc.group_by {|_| _.upcase.ljust(ms).send(m, n)}.max[1]}.count.to_a
      max = count.lasts.max
      res = count.find {|c|
        c[1] == max and File.directory?(df=File.join(pp, c[0])) and Dir.new(df).to_a == sc
      }
      return res[0] if res
    end
    (pc - count).find {|c|
      File.directory?(df=File.join(pp, c)) and Dir.new(df).to_a == sc
    }
  end
  
  def self.threadify(threads=4, &block)
    RMTools::threadify(Dir['*'], threads, &block)
  end
  
end

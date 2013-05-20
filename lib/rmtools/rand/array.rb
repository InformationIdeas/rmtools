# encoding: utf-8
RMTools::require 'rand/enum'

module RMTools
  
  def randarr(len, &b)
    a = (0...len).to_a.shuffle
    block_given? ? a.map!(&b) : a
  end

  module_function :randarr
end

class Array
  
  def self.rand(len)
    RMTools.randarr(len)
  end
  
  def rand
    self[Kernel.rand(size)]
  end
  
  def rand!
    delete_at Kernel.rand size
  end
  
  def rand_by
    return if empty?
    set, ua = Set.new, uniq
    s = ua.size
    loop {
      i = Kernel.rand size
      if set.include? i
        return if set.size == s
      elsif yield(e = ua[i])
        return e
      else set << i
      end
    }
  end
  
  def randdiv(int)
    dup.randdiv!(int)
  end
  
  def randdiv!(int)
    len = 2*int.to_i+1
    return [self] if len <= 1
    newarr = []
    while size > 0
      lenn = Kernel.rand(len)
      next if lenn < 1
      newarr << slice!(0, lenn)
    end
    newarr
  end

end
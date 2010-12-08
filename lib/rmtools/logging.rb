# encoding: utf-8
module RMTools

    class RMLogger
        __init__
        attr_accessor :mute_info, :mute_warn, :mute_log, :mute_debug
        
        RE = /^\(?(.*?([^\/\\]+?))\)?:(\d+)(?::in `([^']+)')?$/
        Modes = %w{debug log info warn}.to_syms
        NOPRINT = 4
        NOLOG = 2
        INLINE = 1
  
        def initialize format={}
            @clr = Coloring.new
            @highlight = {
                :warn => @clr.red_bold("WARN"),
                :log => @clr.cyan("INFO"),
                :info => @clr.cyan_bold("INFO"),
                :debug => @clr.gray_bold("DEBUG")
            }
            @file_formats = Hash.new(@default_format = {})
            set_format format, :global
        end
          
        def _set_format file, format
            file.print = !format.q
            file.out = format.out
                
            file.path_format = '%'.in file.out if file.out
            file.tf   = (format.time || ["%H:%M:%S", "%03d"]).to_a
            file.cf0 = format.caller || "#{@clr.gray('%f:%l')} #{@clr.red_bold(':%m')}"
            file.cf = file.cf0.sub('%F'){'\1'}.sub('%f'){'\2'}.sub('%l'){'\3'}.sub('%m'){'\4'}
            file.fmt = format.format || "%time %mode [%caller]: %text"
            file._time, file._caller = '%time'.in(file.fmt), '%caller'.in(file.fmt)
        end
          
        def set_format format={}, global=nil
            if global
                _set_format @default_format, format
            else
                _set_format(file_format={}, format)
                @file_formats[File.expand_path(caller[0].till ':')] = file_format
            end
        end
          
        def get_format file=nil
            cfg = @file_formats[file && File.expand_path(file)]
            modes = Modes.reject {|m| send :"mute_#{m}"}
            %{<Logger #{cfg.fmt.sub('%time', "%time(#{cfg.tf*'.'})").sub('%caller', "%caller(#{cfg.cf0})")}#{' -> '+cfg.out if cfg.out} #{modes.b ? modes.inspect : 'muted'}>}
        end
            
        def _print mode, text, opts, caler, bind, cfg
            log_ = opts&NOLOG==0
            print_ = opts&NOPRINT==0
            str = cfg.fmt.dup
            str.sub! "%mode", @highlight[mode]
            if bind
              text = text.reports bind
            elsif !text.is(String)
              text = text.inspect
            end
            str.sub! "%text", text
            str << "\n" if opts&INLINE==0
            out = cfg.out
            if cfg._time or cfg.path_format
                now = Time.now
                if cfg._time
                    time = now.strftime cfg.tf[0]
                    time << ".#{cfg.tf[1]%[now.usec/1000]}" if cfg.tf[1]
                    str.sub! "%time", time
                end
                out = now.strftime cfg.out if cfg.path_format
            end
            str.sub! "%caller", caler.sub(RE, cfg.cf) if caler
            log_str = @clr.clean str
            RMTools.write out, log_str if log_
            Kernel.print str if print_
        end
          
        def check_binding a
            a[0].is(Binding) ? [a[0], a[1] || 0] : [nil, a[0] || 0]
        end
        
        def get_config!
            @file_formats.empty? ? @default_format : @file_formats[File.expand_path(caller[1].till ':')]
        end
        
        # controllers:
        # - $panic: print debug messages
        # - $verbose: print log messages
        # - $quiet: print only warn messages regardless of other globals
        # - @mute_warn, @mute_info, @mute_log: do not print
        #                       this messages regardless of any globals
        # - @out_all: write to file any messages
        
        def warn text=nil, *a
            cfg = get_config!
            if (cfg.out or cfg.print) && !@mute_warn
                bind, opts = check_binding a
                opts |= NOLOG if !cfg.out
                opts |= NOPRINT if !cfg.print
                text ||= yield if block_given?
                _print(:warn, text, opts, cfg._caller && caller[0], bind, cfg)
            end  
        end
        
        def log text=nil, *a
            cfg = get_config!
            if (cfg.out or cfg.print && !$quiet && $verbose) && !@mute_log
               bind, opts = check_binding a
                opts |= NOLOG if !cfg.out
                opts |= NOPRINT if !(cfg.print && !$quiet && $verbose)
                text ||= yield if block_given?
                _print(:log, text, opts, cfg._caller && caller[0], bind, cfg)
            end
        end
            
        def info text=nil, *a
            cfg = get_config!
            if (cfg.print && !$quiet or cfg.out && cfg.out_all) && !@mute_info
                bind, opts = check_binding a
                opts |= NOLOG if !(cfg.out && cfg.out_all)
                opts |= NOPRINT if !(cfg.print && !$quiet)
                text ||= yield if block_given?
                _print(:info, text, opts, cfg._caller && caller[0], bind, cfg)
            end 
        end
          
        def debug text=nil, *a
            cfg = get_config!
            if (cfg.print && $panic && !$quiet or cfg.out && cfg.out_all) && !@mute_debug
                bind, opts = check_binding a
                opts |= NOLOG if !(cfg.out && cfg.out_all)
                opts |= NOPRINT if !(cfg.print && $panic && !$quiet)
                text ||= yield if block_given?
                _print(:debug, text, opts, cfg._caller && caller[0], bind, cfg)
            end 
        end
          
        alias << info
        alias <   warn
        
        Modes.each {|m| define_method("#{m}=") {|b| send :"mute_#{m}=", !b}}
          
        def outall=(x) @default_format.out_all = x end
        def print=(x) @default_format.print = x end  
        def out=(x) @default_format.out = x end
        
        def out_all() @default_format.out_all end
        def print() @default_format.print end  
        def out() @default_format.out end
        
        def inspect() get_format end
          
    end
  
end
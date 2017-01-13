require "ult"

module LimitedBuildWorks
  module Mcs
    extend self
    
    def build( options = {}, command = "" )
      option_strings = []
      options.each{|key, value|
        option_strings.push "#{key}:#{value}"
      }
      Ult.execute( "mcs #{option_strings.join( ' ' )} #{command}" )
    end
    
    def build_lib( output, srcs, add_options = {} )
      options = {
        "/target" => "library",
        "/out"    => output,
      }
      status, outputs, errors, command = build( options.merge( add_options ), srcs.join( " " ) )
      puts command
      if 0 != status
        puts outputs
        puts errors
        output = ""
      end
      output
    end
  end
end

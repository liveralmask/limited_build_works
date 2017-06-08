require "ult"

module LimitedBuildWorks
  module Mcs
    extend self
    
    def build( options = {}, args = [] )
      options.each{|key, value|
        args.push "#{key}:#{value}"
      }
      Ult.execute( "mcs #{args.join( ' ' )}" ){|type, io, msg|
        io.puts msg
      }
    end
    
    def build_lib( output, options = {}, args = [] )
      build( {
        "/target" => "library",
        "/out"    => output,
      }.merge( options ), args )
    end
  end
end

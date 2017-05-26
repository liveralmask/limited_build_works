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
    
    def build_lib( output, srcs, add_options = {}, &callback )
      options = {
        "/target" => "library",
        "/out"    => output,
      }
      status, outputs, errors, command = build( options.merge( add_options ), srcs.join( " " ) )
      puts command
      callback.call( status, outputs, errors, command ) if ! callback.nil?
      puts outputs if ! outputs.empty?
      STDERR.puts errors if ! errors.empty?
      status
    end
  end
end

require "ult"

module LimitedBuildWorks
  module Xcode
    extend self
    
    def build( options = {}, command = "" )
      option_strings = []
      options.each{|key, value|
        option_strings.push "#{key} #{value}"
      }
      Ult.execute( "xcodebuild #{option_strings.join( ' ' )} #{command}" )
    end
    
    def build_ios_arch( project, target, configuration, output_dir, arch, add_options = {}, &callback )
      case arch
      when /arm*/
        sdk = "iphoneos"
      when "i386", "x86_64"
        sdk = "iphonesimulator"
      else
        puts "Unknown arch=#{arch}"
        return ""
      end
      
      options = {
        "-project"       => project,
        "-target"        => target,
        "-configuration" => configuration,
        "-sdk"           => sdk,
        "-arch"          => arch,
      }
      status, outputs, errors, command = build( options.merge( add_options ), "clean build CONFIGURATION_BUILD_DIR=#{output_dir}/#{arch}" )
      puts "[#{arch}] #{command}"
      puts outputs if ! outputs.empty?
      STDERR.puts errors if ! errors.empty?
      callback.call( status, outputs, errors, command ) if ! callback.nil?
      outputs.each{|line|
        return $2 if /^(Libtool|Ld)\s(.+?)\s/ =~ line
      }
      ""
    end
    
    def build_ios_archs( project, target, configuration, output_dir, archs, add_options = {}, &callback )
      callback = lambda{|status, outputs, errors, command|} if callback.nil?
      results = []
      archs.each{|arch|
        result = build_ios_arch( project, target, configuration, output_dir, arch, add_options ){|status, outputs, errors, command|
          callback.call( status, outputs, errors, command )
        }
        return "" if ! Ult.file?( result )
        
        results.push result
      }
      lipo_create( "#{output_dir}/#{Ult.filename( results[ 0 ] )}", results )
    end
    
    def lipo_create( dst, srcs )
      status, outputs, errors, command = Ult.execute( "lipo -create #{srcs.join( ' ' )} -output #{dst}" )
      puts command
      puts outputs if ! outputs.empty?
      STDERR.puts errors if ! errors.empty?
      ( 0 == status ) ? dst : ""
    end
  end
end

require "ult"

module LimitedBuildWorks
  module Xcode
    extend self
    
    def build( options = {}, action = "" )
      option_strings = []
      options.each{|key, value|
        option_strings.push "#{key} #{value}"
      }
      Ult.execute( "xcodebuild #{option_strings.join( ' ' )} #{action}" )
    end
    
    def build_ios_arch( project, target, configuration, output_dir, arch, add_options = {} )
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
      action = "clean build CONFIGURATION_BUILD_DIR=#{output_dir}/#{arch}"
      status, outputs, errors, command = build( options.merge( add_options ), action )
      puts "[#{arch}] #{command}"
      if 0 == status
        outputs.each{|line|
          return $2 if /^(Libtool|Ld)\s(.+?)\s/ =~ line
        }
      else
        puts errors
      end
      ""
    end
    
    def build_ios_archs( project, target, configuration, output_dir, archs, add_options = {} )
      results = []
      archs.each{|arch|
        result = build_ios_arch( project, target, configuration, output_dir, arch, add_options )
        return "" if ! Ult.file?( result )
        
        results.push result
      }
      lipo_create( "#{output_dir}/#{Ult.filename( results[ 0 ] )}", results )
    end
    
    def lipo_create( dst, srcs )
      status, outputs, errors, command = Ult.execute( "lipo -create #{srcs.join( ' ' )} -output #{dst}" )
      return dst if 0 == status
      
      puts command
      puts errors
      ""
    end
  end
end

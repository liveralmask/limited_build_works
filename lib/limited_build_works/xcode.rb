require "ult"

module LimitedBuildWorks
  module Xcode
    extend self
    
    def build( options = {}, args = [] )
      options.each{|key, value|
        args.push "#{key} #{value}"
      }
      output = ""
      status = Ult.execute( "xcodebuild #{args.join( ' ' )}" ){|type, io, msg|
        io.puts msg
        case type
        when :out
          output = $2 if /^(Libtool|Ld)\s(.+?)\s/ =~ msg
        end
      }
      [ status, output ]
    end
    
    def build_ios_arch( project, target, configuration, output_dir, arch, options = {}, args = [] )
      case arch
      when /arm*/
        sdk = "iphoneos"
      when "i386", "x86_64"
        sdk = "iphonesimulator"
      else
        sdk = "unknown"
      end
      
      print "[#{arch}] "
      build( {
        "-project"       => project,
        "-target"        => target,
        "-configuration" => configuration,
        "-sdk"           => sdk,
        "-arch"          => arch,
      }.merge( options ), [ "clean build CONFIGURATION_BUILD_DIR=#{output_dir}/#{arch}" ] )
    end
    
    def build_ios_archs( project, target, configuration, output_dir, archs, options = {}, args = [] )
      outputs = []
      archs.each{|arch|
        status, output = build_ios_arch( project, target, configuration, output_dir, arch, options, args )
        return [ status, "" ] if 0 != status
        outputs.push output
      }
      lipo_create( "#{output_dir}/#{Ult.filename( outputs[ 0 ] )}", outputs )
    end
    
    def lipo_create( dst, srcs )
      status = Ult.execute( "lipo -create #{srcs.join( ' ' )} -output #{dst}" ){|type, io, msg|
        io.puts msg
      }
      [ status, dst ]
    end
  end
end

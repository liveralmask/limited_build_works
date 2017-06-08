require "ult"

module LimitedBuildWorks
  module Android
    extend self
    
    def build_ndk( ndk_root, project_path, options = {}, args = [] )
      {
        "NDK_PROJECT_PATH" => project_path,
      }.merge( options ).each{|key, value|
        args.push "#{key}=#{value}"
      }
      Ult.execute( "#{ndk_root}/ndk-build -B #{args.join( ' ' )}" ){|type, io, msg|
        io.puts msg
      }
    end
  end
end

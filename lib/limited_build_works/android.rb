require "ult"

module LimitedBuildWorks
  module Android
    extend self
    
    def build_ndk( ndk_root, project_path, add_options = {}, &callback )
      options = {
        "NDK_PROJECT_PATH" => project_path,
      }.merge!( add_options )
      option_strings = []
      options.each{|key, value|
        option_strings.push "#{key}=#{value}"
      }
      status, outputs, errors, command = Ult.execute( "#{ndk_root}/ndk-build -B #{option_strings.join( ' ' )} #{command}" )
      puts command
      callback.call( status, outputs, errors, command ) if ! callback.nil?
      puts outputs if ! outputs.empty?
      STDERR.puts errors if ! errors.empty?
      status
    end
  end
end

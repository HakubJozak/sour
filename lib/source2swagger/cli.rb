module Source2Swagger
  class CLI < Thor

    include Thor::Actions

    default_task :docs

    desc "docs", "generate documentation from the processing a file/directory supplied"
    method_option :comment, :default => '##~', :desc => 'comment prefix', :aliases => '-c'
    def docs(glob)
      files = Dir[glob]

      buffer = []
      comment = options[:comment]

      if files.size > 0
        #  builder = Source2Swagger::Builder.new(&EXAMPLE_DOC)
        #  puts Source2Swagger::Builder.new(&TEMPLATE_DOC).to_json
        files.each do |file|
          if File.exist?(file)
            whisper "Reading #{file}"

            File.new(file).lines.each do |line|
              stripped = line.strip

              if stripped.start_with?(comment)
                buffer << stripped[comment.size..-1]
              end
            end
          else
            whisper "#{file} does not exist"
          end
        end
      else
        say "No such file or directory: #{glob}"
        return
      end

      builder = Source2Swagger::Builder.new
      builder.parse_documentation(buffer.join("\n"))
      puts builder.to_json

      # user_alias = options[:alias]
      # if options.force?
      # end
    end

    private

    def whisper(*args)
      $stderr.puts(*args)
    end
  end
end

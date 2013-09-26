module Sour
  class CLI < Thor

    include Thor::Actions

    default_task :docs

    desc "docs PATH", "generate documentation from a file,directory or standard input"
    method_option :comment, :default => '##~', :desc => 'comment prefix', :aliases => '-c'
    def docs(*args)
      files = case args.size
              when 1 then Dir[args.first]
              when 0 then [ STDIN ]
              else args
              end

      whisper("#{args.inspect} does not exist") and return if files.empty?

      buffer = []
      comment = options[:comment]

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

      builder = Sour::Builder.new
      builder.parse_documentation(buffer.join("\n"))
      puts JSON.pretty_generate(builder)
    end

    private

    def whisper(*args)
      $stderr.puts(*args)
    end
  end
end

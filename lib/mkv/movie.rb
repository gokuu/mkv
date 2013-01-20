require 'time'

module MKV
  class Movie
    @@timeout = 200

    attr_reader :path
    attr_reader :tracks

    def initialize(path)
      raise Errno::ENOENT, "the file '#{path}' does not exist" unless File.exists?(path)

      @path = path

      # mkvinfo will output to stdout
      command = "#{MKV.mkvinfo_binary} #{Shellwords.escape(path)}"
      MKV.logger.info(command)
      output = Open3.popen3(command) { |stdin, stdout, stderr| stdout.read}

      match = output.gsub(/\n/, '$$').match /\|\+\ssegment tracks(.*?)\|\+\s(?:chapters|cluster)/i
      tracks = match[1].gsub(/\$\$/, "\n")
      match_tracks = tracks.gsub(/\n/, '$$').scan(/a track(.*?)(?:\|\s\+|$)/i)
      match_tracks = match_tracks.map { |x| x.first.gsub(/\$\$/, "\n") }

      @tracks = match_tracks.map do |track_data|
        MKV::Track.new track_data
      end

      @invalid = true unless @tracks.any?
      @invalid = true if output.include?("is not supported")
      @invalid = true if output.include?("could not find codec parameters")
    end

    def valid?
      not @invalid
    end

    def has_video? ; tracks.select { |t| t.type == 'video' }.any? ; end
    def has_audio? ; tracks.select { |t| t.type == 'audio' }.any? ; end

    def has_subtitles?(language = nil)
      language = [language].flatten if language
      tracks.any? { |t| t.type == 'subtitles' && (language.nil? || language.empty? || language.include?(t.language)) }
    end

    def extract_subtitles(options={})
      # Compatibility with legacy method accepting a String for destination_dir (deprecated)
      if options.class == String
        options = { :destination_dir => options }
      end

      options[:language] ||= []
      options[:language] = [options[:language]].flatten.map(&:to_sym) if options[:language]
      options[:language] << :und if options[:language].any?

      track_filter = lambda { |t| t.type == 'subtitles' && (options[:language].include?(t.language.to_sym) || options[:language].empty?) }

      tracks.select(&track_filter).each do |track|
        destination_fileextension = (options[:language].count == 1 ? "" : ".#{track.mkv_info_id}.#{track.language}") + ".srt"
        destination_filename = File.basename(@path).gsub(/\.mkv$/i, destination_fileextension)
        destination_dir = options[:destination_dir] || File.dirname(@path)

        command = %Q[#{MKV.mkvextract_binary} tracks "#{@path}" #{track.mkv_info_id}:"#{File.join(destination_dir, destination_filename)}"]
        MKV.logger.info(command)

        output = ""
        start_time = Time.now.to_i
        Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
          begin
            yield(0.0, 0, destination_filename) if block_given?
            next_line = Proc.new do |line|
              output << line
              if line =~ /(\d+)%/
                progress = $1.to_i

                yield(progress, Time.now.to_i - start_time, destination_filename) if block_given?
              end

              if line =~ /Unsupported codec/
                MKV.logger.error "Failed encoding...\nCommand\n#{command}\nOutput\n#{output}\n"
                raise "Failed encoding: #{line}"
              end
            end

            if @@timeout
              stdout.each_with_timeout(wait_thr.pid, @@timeout, "r", &next_line)
            else
              stdout.each("r", &next_line)
            end

          rescue Timeout::Error => e
            MKV.logger.error "Process hung...\nCommand\n#{command}\nOutput\n#{output}\n"
            raise MKV::Error, "Process hung. Full output: #{output}"
          end
        end
      end
    end
  end
end

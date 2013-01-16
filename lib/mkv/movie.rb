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
      
      @invalid = true if @tracks.any?
      @invalid = true if output.include?("is not supported")
      @invalid = true if output.include?("could not find codec parameters")
    end
    
    def valid?
      not @invalid
    end

    def has_subtitles? ; tracks.select { |t| t.type == 'subtitles' }.any? ; end
    def has_video? ; tracks.select { |t| t.type == 'video' }.any? ; end
    def has_audio? ; tracks.select { |t| t.type == 'audio' }.any? ; end

    def extract_subtitles(destination_dir)
      tracks.select { |t| t.type == 'subtitles' }.each do |track|
        destination_filename = File.basename(@path).gsub(/\.mkv$/i, %Q[.#{track.mkv_info_id}.#{track.language || 'und'}.srt])
        command = %Q[#{MKV.mkvextract_binary} tracks "#{@path}" #{track.mkv_info_id}:"#{File.join(destination_dir, destination_filename)}"]

        output = ""
        Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
          begin
            yield(0.0) if block_given?
            next_line = Proc.new do |line|
              output << line
              if line =~ /(\d+)%/
                progress = $1.to_i 

                yield(progress) if block_given?
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

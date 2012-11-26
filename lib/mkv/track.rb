module MKV
  class Track
    # Video, Audio & Subtitle
    attr_reader :type, :uid, :number, :mkv_info_id, :lacing, :codec_id
    # Video
    attr_reader :width, :height
    # Audio
    attr_reader :sampling_frequency, :channels
    # Subtitle & Audio
    attr_reader :language, :enabled, :default, :forced

    def initialize(data)
      (@number, @mkv_info_id) = data.match(/track number:\s(\d+)\s\(track ID for mkvmerge & mkvextract: (\d+)\)/i)[1..2]
      @uid = data.match(/track uid: (\d+)/i)[1]
      @lacing = (data.match(/lacing flag: (\d+)/i) || [0, 0])[1] != '0'
      @type = data.match(/track type: (\w+)/i)[1]
      @codec_id = data.match(/codec id: (.*)/i)[1]

      if @type == 'video'
        @width = data.match(/pixel width: (\d+)/i)[1].to_i
        @height = data.match(/pixel height: (\d+)/i)[1].to_i
      end

      if @type == 'audio'
        @sampling_frequency = data.match(/sampling frequency: (\d+)/i)[1].to_i
        @channels = data.match(/channels: (\d+)/i)[1].to_i
      end

      if @type == 'audio' || @type == 'subtitles'
        @language = (data.match(/language: (\w+)/i) || ['eng'])[1]
        @enabled = (data.match(/enabled: (\d+)/i) || [0, 1])[1] != '0'
        @default = (data.match(/default flag: (\d+)/i) || [0, 0])[1] != '0'
        @forced = (data.match(/forced flag: (\d+)/i) || [0, 0])[1] != '0'
      end
    end

  end
end
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'logger'
require 'stringio'
require 'shellwords'
require 'open3'
require 'awesome_print'

require 'mkv/version'
require 'mkv/error'
require 'mkv/io_patch'
require 'mkv/movie'
require 'mkv/track'

module MKV
  # MKV logs information about its progress when it's transcoding.
  # Jack in your own logger through this method if you wish to.
  #
  # @param [Logger] log your own logger
  # @return [Logger] the logger you set
  def self.logger=(log)
    @logger = log
  end
  
  # Get MKV logger.
  #
  # @return [Logger]
  def self.logger
    return @logger if @logger
    log = Logger.new(STDOUT)
    log.level = Logger::INFO
    @logger = log
  end

  # Set the path of the mkvinfo binary.
  # Can be useful if you need to specify a path such as /usr/local/bin/MKV
  #
  # @param [String] path to the mkvinfo binary
  # @return [String] the path you set
  def self.mkvinfo_binary=(bin)
    @mkvinfo_binary = bin
  end

  # Get the path to the mkvinfo binary, defaulting to an OS-dependent path
  #
  # @return [String] the path to the MKV binary
  def self.mkvinfo_binary
    @mkvinfo_binary.nil? ? default_mkvinfo_binary : @mkvinfo_binary
  end

  # Set the path of the mkvextract binary.
  # Can be useful if you need to specify a path such as /usr/local/bin/MKV
  #
  # @param [String] path to the mkvextract binary
  # @return [String] the path you set
  def self.mkvextract_binary=(bin)
    @mkvextract_binary = bin
  end

  # Get the path to the mkvextract binary, defaulting to an OS-dependent path
  #
  # @return [String] the path to the mkvextract binary
  def self.mkvextract_binary
    @mkvextract_binary.nil? ? default_mkvextract_binary : @mkvextract_binary
  end

  private 

    def self.default_mkvinfo_binary
      if is_macosx?
        "/Applications/Mkvtoolnix.app/Contents/MacOS/mkvinfo"
      else
      end
    end

    def self.default_mkvextract_binary
      if is_macosx?
        "/Applications/Mkvtoolnix.app/Contents/MacOS/mkvextract"
      else
      end
    end

    def self.is_windows? ; RUBY_PLATFORM =~/.*?mingw.*?/i ; end
    def self.is_macosx? ; RUBY_PLATFORM =~/.*?darwin.*?/i ; end
end

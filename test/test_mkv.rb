require 'test/unit'
require 'mkv'

# Put your own test mkv file path here
TEST_MOVIE_FILE = "/Users/Alex/Downloads/rj/rj.mkv"

class MkvTest < Test::Unit::TestCase
  def test_open_movie
    movie = MKV::Movie.new(TEST_MOVIE_FILE)
    assert_equal movie.valid?, true
  end

  def test_extract_eng_subtitles
    movie = MKV::Movie.new(TEST_MOVIE_FILE)
    assert movie.has_subtitles?('eng')
    movie.extract_subtitles(language: 'eng')
  end

end
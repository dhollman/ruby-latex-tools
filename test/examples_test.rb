

$LOAD_PATH.unshift(File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), "lib"))
$LOAD_PATH.unshift(File.join(File.dirname(File.expand_path(__FILE__)),"lib"))

require "test/unit"
require 'latex_table'
require 'custom_assertions'
include LatexTools


class LatexTableTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end

  def test_table_example1

    assert_example_works("table/example1.rb")
  end

  def assert_example_works(example_file)
    example_dir = File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), "examples")
    result = eval(IO.read("#{example_dir}/#{example_file}"))
    assert_equal_ignore_spaces(
        IO.read("#{example_dir}/#{example_file}.out"),
        result
    )
  end

end

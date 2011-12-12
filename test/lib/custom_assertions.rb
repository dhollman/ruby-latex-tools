
require 'test/unit'

module Test::Unit::Assertions

    def assert_equal_ignore_spaces(expected, actual, message = nil)
        # Also ignore trailing newlines
        full_message = build_message(message, "<?> expected (ignoring spaces), but was actually <?>.  With whitespace removed:\n  expected: <?>\n    actual: <?>", expected, actual, expected.gsub(" ", '').chomp, actual.gsub(" ", '').chomp)
        assert_block(full_message) do 
            expected.gsub(" ", '').chomp == actual.gsub(" ", '').chomp
        end
    end


    def assert_equal_ignore_whitespace(expected, actual, message = nil)
        full_message = build_message(message, "<?> expected (ignoring whitespace), but was actually <?>", expected, actual)
        assert_block(full_message) do 
            expected.gsub(/\s+/, '') == actual.gsub(/\s+/, '')
        end
    end

end



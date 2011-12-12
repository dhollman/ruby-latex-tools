

$LOAD_PATH.unshift(File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), "lib"))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"lib"))

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

  # Build a simple set of tables for testing
  def make_table(name)
    case(name)
      when "empty"
        @table = LatexTable.new
      when "simple 3x3"
        @table = LatexTable.new
        @table.add_column
        @table.add_column
        @table.add_column
        @table.add_row
        @table.add_element("1")
        @table.add_element("2")
        @table.add_element("3")
        @table.add_row
        @table.add_element("4")
        @table.add_element("5")
        @table.add_element("6")
        @table.add_row
        @table.add_element("7")
        @table.add_element("8")
        @table.add_element("9")
      when "hlines"
        @table = LatexTable.new(5)
        @table << :hline
        @table << :hline
        @table << 1 << 2 << 3 << 4 << 5 << :endl
        @table << :hline
        @table << 1 << 2 << 3 << 4 << 5 << :endl
        @table << :hline
        @table << :hline
      when "autoadd"
        @table = LatexTable.new
        @table.auto_add_columns = true
        @table << 1 << 2 << 3 << :endl
        @table << hline
        @table << 1 << 2 << 3 << 4 << :endl
        @table << :hline
        @table << 1 << 2 << 3 << 4 << 5 << :endl
      when "multicol"
        @table = LatexTable.new(4)
        @table << 1 << 2 << 3 << 4 << :endl
        @table << :hline
        @table << multicol(3, "hello") << 4 << :endl
        @table << :hline
        @table << 1 << fill_to_end(:r, "world") << :endl
        @table << 1 << fill_to_end("world") << :endl
        @table << 1 << multicol(2, :l, 3.14) << 4 << :endl
        @table << :hline
        @table << :hline
        @table.add_element_spanning(3, "hello")
        @table.add_element(4)
        @table.add_spanning_row("full row")
        @table << :hline
        @table.add_spanning_row("full row")
        @table.add_element(1)
        @table.add_element_spanning_to_end("world", :r)
        @table.add_row
        @table << 1
        @table.add_element_spanning(2, 3.14, :l)
        @table.add_element(4)
      when "cline"
        @table = LatexTable.new(4)
        @table << 1 << 2 << 3 << 4 << :endl
        @table << cline(1,3) << :endl
        @table << 1 << 2 << 3 << 4 << :endl
        @table << cline(1,2) << cline(3,4) << :endl
        @table << 1 << 2 << 3 << 4 << :endl
        @table << :hline
      else
        raise "Unknown table requested for testing in LatexTableTest#make_table"
    end

  end

  def test_stupidity
    # Misalign stuff...
    assert_raise RuntimeError do
      t = LatexTable.new(3)
      t << 1 << 2 << :endl
    end
    assert_raise IndexError do
      t = LatexTable.new(3)
      t << 1 << 2 << 3 << 4 << :endl
    end
    assert_raise IndexError do
      t = LatexTable.new(3)
      t.add_element_spanning(4, "text")
    end

    # Invalid argument counts and types
    assert_raise(ArgumentError) { LatexTable.new(1,2,3) }
    assert_raise(TypeError) { LatexTable.new("hello") }



  end

  def test_not_implemented
  end

  def test_to_str_etc
    make_table("simple 3x3")
    assert_equal(@table.to_str, @table.to_s)
  end

  def test_divider_raises
    make_table("empty")
    assert_raise(ArgumentError) { @table.col_divider = "|||" }
    make_table("empty")
    assert_raise(ArgumentError) { @table.col_divider = "something_weird" }
    make_table("simple 3x3")
    assert_raise(ArgumentError) { @table.col_dividers = ["|","something_weird"] }
    make_table("simple 3x3")
    assert_raise(ArgumentError) { @table.col_dividers = ["|","|","|","|","|"] }
    make_table("simple 3x3")
    assert_raise(ArgumentError) { @table.col_dividers = ["|","|","|"] }
  end

  def test_simple_3x3_num_rows
    make_table("simple 3x3")
    assert_equal(3, @table.rows)
  end

  def test_hlines_num_rows
    make_table("hlines")
    assert_equal(7, @table.rows)
  end

  def test_simple_3x3_tabular_string
    make_table("simple 3x3")
    assert_equal("ccc", @table.tabular_string)
    @table.col_divider = "|"
    assert_equal("c|c|c", @table.tabular_string)
    @table.col_divider = "||"
    assert_equal("c||c||c", @table.tabular_string)
    @table.col_dividers = ["||","|"]
    assert_equal("c||c|c", @table.tabular_string)
    @table.col_dividers = ["|","||","|","||"]
    assert_equal("|c||c|c||", @table.tabular_string)
    @table.col_dividers = ["||","","","||"]
    assert_equal("||ccc||", @table.tabular_string)
    @table.col_dividers = ["",""]
    assert_equal("||ccc||", @table.tabular_string)
    @table.col_dividers = ["","","",""]
    assert_equal("ccc", @table.tabular_string)
    @table.add_v_border
    assert_equal("|ccc|", @table.tabular_string)
    @table.col_dividers = ["|","|"]
    assert_equal("|c|c|c|", @table.tabular_string)
    @table.add_v_double_border
    assert_equal("||c|c|c||", @table.tabular_string)
    @table.col_dividers = ["","","",""]
    assert_equal("ccc", @table.tabular_string)
    @table.add_v_border
    @table.add_v_border
    assert_equal("||ccc||", @table.tabular_string)
    @table.col_dividers = ["|","","","|"]
    assert_equal("|ccc|", @table.tabular_string)
  end

  def test_simple_3x3_fragment
    make_table("simple 3x3")
    assert_equal_ignore_spaces(
        '\begin{table}
           \begin{tabular}{ccc}
              1 & 2 & 3 \\\\
              4 & 5 & 6 \\\\
              7 & 8 & 9
           \end{tabular}
        \end{table}',
        @table.to_latex
    )
    @table.add_v_double_border
    assert_equal_ignore_spaces(
        '\begin{table}
           \begin{tabular}{||ccc||}
              1 & 2 & 3 \\\\
              4 & 5 & 6 \\\\
              7 & 8 & 9
           \end{tabular}
        \end{table}',
        @table.to_latex
    )
    @table.float_number_format = "%.2f"
    assert_equal_ignore_spaces(
        '\begin{table}
           \begin{tabular}{||ccc||}
              1.00 & 2.00 & 3.00 \\\\
              4.00 & 5.00 & 6.00 \\\\
              7.00 & 8.00 & 9.00
           \end{tabular}
        \end{table}',
        @table.to_latex
    )
  end

  def test_borders
    make_table("simple 3x3")
    @table.add_v_border
    assert_equal_ignore_spaces(
        '\begin{table}
           \begin{tabular}{|ccc|}
              1 & 2 & 3 \\\\
              4 & 5 & 6 \\\\
              7 & 8 & 9
           \end{tabular}
        \end{table}',
        @table.to_latex
    )
    @table.add_h_border
    assert_equal_ignore_spaces(
        '\begin{table}
           \begin{tabular}{|ccc|}
              \hline
              1 & 2 & 3 \\\\
              4 & 5 & 6 \\\\
              7 & 8 & 9 \\\\
              \hline
           \end{tabular}
        \end{table}',
        @table.to_latex
    )
    @table.add_border
    assert_equal_ignore_spaces(
        '\begin{table}
           \begin{tabular}{||ccc||}
              \hline
              \hline
              1 & 2 & 3 \\\\
              4 & 5 & 6 \\\\
              7 & 8 & 9 \\\\
              \hline
              \hline
           \end{tabular}
        \end{table}',
        @table.to_latex
    )

  end

  def test_quick_add
    tmp = LatexTable.new(3)
    tmp << 1 << 2 << 3 << :endl
    tmp << 4 << 5 << 6 << :endl
    tmp << 7 << 8 << 9 << :endl
    make_table("simple 3x3")
    assert_equal(@table.to_s, tmp.to_s)
  end

  def test_hlines
    make_table("hlines")
    assert_equal_ignore_spaces(
        '\hline
         \hline
         1 & 2 & 3 & 4 & 5 \\\\
         \hline
         1 & 2 & 3 & 4 & 5 \\\\
         \hline
         \hline
        ',
        @table.to_latex_fragment
    )
  end

  def test_auto_add
    make_table("autoadd")
    assert_equal_ignore_spaces(
        '1 & 2 & 3 & & \\\\
         \hline
         1 & 2 & 3 & 4 & \\\\
         \hline
         1 & 2 & 3 & 4 & 5
        ',
        @table.to_latex_fragment
    )
    @table.add_v_border
    @table.col_divider = "||"
    @table << 1 << 2 << 3 << 4 << 5 << 6 << :endl
    assert_equal("|c||c||c||c||c||c|", @table.tabular_string)
    @table.add_element_spanning(7, "test", :l)
    assert_equal("|c||c||c||c||c||c||c|", @table.tabular_string)

  end

  def test_multicol
    make_table("multicol")
    assert_equal_ignore_spaces(
        '1 & 2 & 3 & 4 \\\\
         \hline
         \multicolumn{3}{c}{hello} & 4 \\\\
         \hline
         1 & \multicolumn{3}{r}{world} \\\\
         1 & \multicolumn{3}{c}{world} \\\\
         1 & \multicolumn{2}{l}{3.14} & 4 \\\\
         \hline
         \hline
         \multicolumn{3}{c}{hello} & 4 \\\\
         \multicolumn{4}{c}{full row} \\\\
         \hline
         \multicolumn{4}{c}{full row} \\\\
         1 & \multicolumn{3}{r}{world} \\\\
         1 & \multicolumn{2}{l}{3.14} & 4
        ', @table.to_latex_fragment
    )
  end

  def test_row_num_columns
    r = LatexTable::Row.new
    r << 1 << 2 << 3
    assert_equal(3, r.num_columns)

    r = LatexTable::Row.new
    r << multicol(3, "hello")
    r << 1
    assert_equal(4, r.num_columns)

    r << multicol(:fill, "test")
    assert_equal(-1, r.num_columns)
  end

  def test_cline
    make_table("cline")
    assert_equal_ignore_spaces(
        '1 & 2 & 3 & 4 \\\\
         \cline{1-3}
         1 & 2 & 3 & 4 \\\\
         \cline{1-2} \cline{3-4}
         1 & 2 & 3 & 4 \\\\
         \hline
        ', @table.to_latex_fragment
    )
    @table.auto_add_columns = true
    @table << 1 << 3 << 5 << 6 << endl
    @table << cline(1,6)
    @table << 1 << 3 << 5 << 6 << 8 << 9 << endl
    assert_equal_ignore_spaces(
        '1 & 2 & 3 & 4 & & \\\\
         \cline{1-3}
         1 & 2 & 3 & 4 & & \\\\
         \cline{1-2} \cline{3-4}
         1 & 2 & 3 & 4 & & \\\\
         \hline
         1 & 3 & 5 & 6 & & \\\\
         \cline{1-6}
         1 & 3 & 5 & 6 & 8 & 9
        ', @table.to_latex_fragment
    )

  end

  def test_cline_fail
    @table = LatexTable.new(3)
    assert_raise ArgumentError do
      @table << cline(1,2) << cline(2,3)
    end

    @table = LatexTable.new(3)
    assert_raise RuntimeError do
      @table << 1 << cline(2,3) << endl
    end

    @table = LatexTable.new(3)
    assert_raise RuntimeError do
      @table << 1 << cline(2,4) << endl
    end

    @table = LatexTable.new(3)
    assert_raise RuntimeError do
      @table << cline(0,1)
    end
  end

end
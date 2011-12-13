# --
# Copyright (c) 2011-2012 David Hollman
# This file is part of the LatexTools rubygem.
#
# The LatexTools rubygem is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# The LatexTools rubygem is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser Public License for more details.
#
# You should have received a copy of the GNU Lesser Public License
# along with the LatexTools rubygem.  If not, see <http://www.gnu.org/licenses/>.
# ++


require 'forwardable'

#--
#TODO Document this whole thing
#++

##
#--
# (This module is documented in latex_tools.rb)
#++
module LatexTools


  ##
  # The LatexTable class represents a table in Latex.  It provides multiple means of creating, formatting, and
  # outputting Latex tables.
  #
  # == Basic Examples
  # The easiest way to create tables programmatically is to use the #<< method.
  #   :include:examples/table/example1.rb
  # This produces
  #   :include:examples/table/example1.rb.out
  #
  # More documentation to come in the future, but hopefully this is enough to get you started.
  #
  class LatexTable
    attr_reader(
        :columns,
        :rows,
        :float_number_format,
        :col_divider,
        :col_dividers,
        :v_bordered,
        :v_double_bordered,
        :h_borders,
        :format
    )

    attr_accessor(
        # if strict is true, don't allow adding of rows when the previous row hasn't been filled
        :strict, #TODO move this to reader and implement a writer that goes back and checks
        :auto_add_columns
    )


    class Row # :nodoc: all

      extend Forwardable

      attr_reader(
          :special_tag
      )

      TAGS = [
          :cline,
          :hline,
          :provisional
      ]

      def_delegators :@entries, :push, :size, :pop, :<<, :[], :[]=, :each, :each_with_index, :last

      def initialize(tag = nil)
        @entries = Array.new
        if(tag)
          raise ArgumentError unless TAGS.include?(tag)
          @special_tag = tag
        end
      end

      def num_columns
        if(@special_tag == :cline)
          return @entries.last.end_col
        end
        ret_val = 0
        @entries.each do |entry|
          add_val = entry.kind_of?(MultiColumn) ? entry.width : 1
          if add_val == :fill
            return -1
          end
          ret_val += add_val
        end
        return ret_val
      end

      def special_tag=(tag)
        raise ArgumentError unless tag.nil? || TAGS.include?(tag)
        @special_tag = tag
      end
      alias :tag :special_tag
      alias :tag= :special_tag=
    end

    class MultiColumn # :nodoc: all
      attr_accessor(
          :width,
          :alignment,
          :content
      )

      ALIGNMENTS = [:r, :c, :l]

      def initialize(nc, aln, cont)
        @width = nc
        @alignment = aln.to_sym
        raise "Invalid alignment specification" unless ALIGNMENTS.include?(@alignment)
        @content = cont
      end

    end

    class Cline # :nodoc: all
      attr_accessor(:begin_col, :end_col)

      def initialize(firstcol, lastcol)
        @begin_col = firstcol
        @end_col = lastcol
      end

    end

    def initialize(*args)
      @col_dividers = Array.new
      @v_bordered = false
      @h_borders = 0
      @auto_add_columns = false
      @format = Hash.new{ Array.new }
      @strict = true
      case args.size
        when 0
          @rows = 0
          @columns = 0
          @data = Array.new
          add_row(:provisional)
        when 1
          arg = args.shift
          if(arg.kind_of?(Integer))
            @columns = arg
            @rows = 0
            @data = Array.new
            add_row(:provisional)
          else
            raise TypeError, "Invalid argument type in LatexTable#initialize"
          end
        else
          raise ArgumentError, "Invalid argument count"
      end
    end

    def tabular_string
      ret_val = ""
      unless(@col_dividers.empty?)
        ret_val += @col_dividers[0]
      end
      1.upto(@columns) do |i|
        ret_val += "c"
        if(@col_dividers.empty?)
          unless(@col_divider.nil? || i == @columns)
            ret_val += @col_divider
          end
        else
          ret_val += @col_dividers[i]
        end
      end
      return ret_val
    end

    def to_latex(fontsize = "")
      ret_val = ""
      ret_val = ret_val + "\\begin{table}#{fontsize}\n  \\begin{tabular}{"
      ret_val += tabular_string
      ret_val = ret_val + "}\n"
      1.upto(@h_borders) { ret_val = ret_val + "    \\hline\n" }
      ret_val += "    "
      ret_val += to_latex_fragment
      if(@h_borders != 0)
        ret_val += "\\\\"
      end
      1.upto(@h_borders) { ret_val = ret_val + "    \n \\hline" }
      ret_val = ret_val + "\n  \\end{tabular}\n"
      ret_val = ret_val + "\\end{table}\n"
      ret_val
    end

    def to_latex_fragment
      ret_val = ""
      indent = "    "
      @data.each_with_index do |row, row_num|
        cols_so_far = 0
        if(row.tag == :hline)
          ret_val = ret_val + "\\hline"
          ret_val += " \n" + indent unless row_num == @rows - 1
        elsif(row.tag == :cline)
          row.each do |cline|
            ret_val += "\\cline{" + cline.begin_col.to_s + "-" + cline.end_col.to_s + "}  "
          end
          ret_val += " \n" + indent unless row_num == @rows - 1
        elsif(row.tag == :provisional)
          raise RuntimeError, "Programmer needs more coffee: Unhandled provisional" unless row_num == @data.size - 1
        else
          row.each_with_index do |entry, index|
            if(entry)
              content = entry.kind_of?(MultiColumn) ? entry.content : entry
              if(!@format[row_num].nil? && !@format[row_num][index].nil? && content.respond_to?(:to_f))
                content = @format[row_num][index] % content.to_f
              elsif(content.respond_to?(:to_f) && (content.to_f.to_s == content.to_s || content.to_i.to_s == content.to_s) && !@float_number_format.nil?)
                content = @float_number_format % content.to_f
              end
              val = content

              if(entry.kind_of?(MultiColumn))
                if(entry.width == :fill)
                  val = "\\multicolumn{#{@columns - cols_so_far}}{#{entry.alignment.to_s}}{#{val}}"
                  raise "Columns spanning to the end must be the last entry in a row." unless entry === row.last
                  cols_so_far = @columns
                else
                  val = "\\multicolumn{#{entry.width}}{#{entry.alignment.to_s}}{#{val}}"
                  cols_so_far += entry.width
                end
              else
                cols_so_far += 1
              end

              ret_val = ret_val + val.to_s + ((cols_so_far == @columns) ? _end_of_line(row_num, indent) : " & ")
            end
          end
          (cols_so_far + 1).upto(@columns) do |index|
            ret_val = ret_val + " " + ((index == @columns) ? _end_of_line(row_num, indent) : " & ")
          end
        end
      end
      return ret_val
    end

    def add_row(tag = nil)
      if(@strict)
        spot = @rows - 1
        lastrow = nil
        lastrow = @data[spot] if spot >= 0
        skip_tags = [:hline,:cline,:provisional]
        while(lastrow && skip_tags.include?(lastrow.tag))
          spot -= 1
          if(spot >= 0)
            lastrow = @data[spot]
          else
            lastrow = nil
          end
        end
        ncols = nil
        if(lastrow && (ncols = lastrow.num_columns) != @columns && ncols != -1)
          last_non = _last_non_provisional_row
          unless(last_non && last_non.tag == :cline && @auto_add_columns && lastrow.num_columns < last_non.num_columns)
            raise RuntimeError, "Tried to add new row when previous row had #{ncols} columns which is not the same as #{@columns} columns.  Turn #strict off to ignore this, although your latex output may not compile."
          end
        end
      end
      add = !_provisional_remove
      if(add)
        @data.push(Row.new(tag))
      else
        @data.last.tag = tag
      end
      unless(tag == :provisional)
        @rows += 1 if(add)
      end
    end

    def add_column
      @columns = @columns + 1
      if(!@col_dividers.empty?)
        border = @col_dividers.pop
        @col_dividers.push(@col_divider.nil? ? "" : @col_divider)
        @col_dividers.push(border)
      end
    end

    def add_spanning_row(text, alignment = :c)
      _cline_check
      tmp = nil
      add = !(_provisional_remove)
      if(!add)
        tmp = @data.last
      else
        tmp = Row.new
        @rows += 1
        @data.push(tmp)
      end
      tmp.push(MultiColumn.new(:fill, alignment, text))
      add_row(:provisional)
    end

    def add_element_spanning_to_end(text, alignment = :c)
      _cline_check
      _provisional_remove
      @data.last.push(MultiColumn.new(:fill, alignment, text))
      add_row(:provisional)
    end

    def add_element_spanning(num, text, alignment = :c)
      _cline_check
      _provisional_remove
      raise TypeError.new unless num.kind_of?(Integer) || num == :fill
      if(@data.last.num_columns + num >= @columns)
        if(@auto_add_columns)
          @columns.upto(@data.last.num_columns + num - 1) { add_column }
        else
          _cant_add_column("add_element_spanning")
        end
      end
      @data.last.push(MultiColumn.new(num, alignment, text))
    end

    def add_element(element)
      _cline_check
      _provisional_remove

      @data.last.push(element)
      if(@data.last.size > @columns)
        if(@auto_add_columns)
          add_column
        else
          _cant_add_column("add_element")
        end
      end
    end

    def << (element)
      if(element == :endl)
        add_row(:provisional)
      elsif(element.kind_of?(Cline))
        lastnon = _last_non_provisional_row
        if(lastnon && lastnon.tag != :cline && @data.last.tag != :provisional)
          raise "Invalid cline addition:  Can't add a cline to a row that already has non-cline content.  Use #add_row or #<<(:endl)"
        end
        self.c_line(element.begin_col, element.end_col)
      elsif(element == :hline || element == :h_line)
        h_line
      else
        add_element(element)
      end
      return self
    end

    def float_number_format=(format)
      #TODO Check to make sure it is an okay format
      @float_number_format = format
    end
    alias :set_float_number_format :float_number_format=

    #Note: This method overwrites any non-border changes to the #col_dividers array
    def col_divider=(divider)
      raise ArgumentError, "Invalid column divider" unless _is_valid_col_divider(divider)
      @col_divider = divider
      unless(@col_dividers.nil? || @col_dividers.empty?)
        1.upto(@col_dividers.size - 2) do |i|
          col_dividers[i] = @col_divider
        end
      end
    end
    alias :set_col_divider :col_divider=

    #Note: This method resets #col_divider
    def col_dividers=(div_array)
      raise ArgumentError, "Invalid column divider array size. Must either be #columns - 1 (for dividers only) or #columns + 1 (for dividers and borders)" unless ([@columns - 1, @columns + 1].include?(div_array.size))
      raise ArgumentError, "Invalid column divider." unless div_array.all? { |div| _is_valid_col_divider(div) }
      @col_dividers = div_array
      @col_divider = nil
      if(@col_dividers.size == @columns - 1)
        if(@v_double_bordered)
          @col_dividers.unshift("||")
          @col_dividers.push("||")
        elsif(@v_bordered)
          @col_dividers.unshift("|")
          @col_dividers.push("|")
        else
          @col_dividers.unshift('')
          @col_dividers.push('')
        end
      else
        if(@col_dividers[0] == '||' && @col_dividers.last == "||")
          @v_bordered = true
          @v_double_bordered = true
        elsif(@col_dividers[0] == '|' && @col_dividers.last == "|")
          @v_bordered = true
        else # Border will not be preserved in next "internal divider" col_dividers assignment
          @v_bordered = false
          @v_double_bordered = false
        end
      end
    end
    alias :set_col_dividers :col_dividers=

    # This method ends the current row
    def h_line
      add_row(:hline)
      add_row(:provisional)
    end
    alias :hline :h_line

    # This method ends the current row
    # NOTE that the numbering is 1 based, just as in Latex itself
    def c_line(begincol, endcol)
      last_row = _last_non_provisional_row
      if(last_row.nil? || last_row.tag != :cline)
        add_row(:cline)
      end
      last_row = _last_non_provisional_row

      last_element = last_row.last
      if(last_element)
        if(last_element.end_col >= begincol)
          raise ArgumentError, "Overlapping clines.  Check the start of the LatexTable#cline call in your code and the end of the previous call"
        end
      end
      if(endcol > @columns)
        if(@auto_add_columns)
          (@columns + 1).upto(endcol) { add_column }
        else
          _cant_add_column("c_line")
        end
      end

      if(begincol < 1)
        raise "Invalid cline specification (Begin column less than 1).  Note that the cline column specification is one-based, just as in Latex"
      end

      last_row.push(Cline.new(begincol, endcol))
    end
    alias :cline :c_line

    def to_s
      to_latex
    end

    def to_str
      to_latex
    end

    def add_v_border
      if(@v_bordered)
        add_v_double_border
      elsif(@col_dividers.empty?)
        @col_dividers[0] = "|"
        1.upto(@columns - 1) do |i|
          @col_dividers[i] = @col_divider.nil? ? " " : @col_divider
        end
        @col_dividers[@columns] = "|"
      else
        @col_dividers[0] = "|"
        @col_dividers[@columns] = "|"
      end
      @v_bordered = true
    end

    def add_v_double_border
      raise "Too many vertical borders.  A maximum of two is allowed" if @v_bordered && @col_dividers[0] == "||"
      if(@col_dividers.empty?)
        @col_dividers[0] = "||"
        1.upto(@columns - 1) do |i|
          @col_dividers[i] = @col_divider.nil? ? '' : @col_divider
        end
        @col_dividers[@columns] = "||"
      else
        @col_dividers[0] = "||"
        @col_dividers[@columns] = "||"
      end
      @v_double_bordered = true
    end
    alias :add_double_v_border :add_v_double_border

    def add_h_border
      @h_borders = @h_borders + 1
    end

    def add_border
      add_h_border
      add_v_border
    end
    alias :add_borders :add_border


    private

    def _last_non_provisional_row
      if(@data.last.nil?)
        return nil
      elsif(@data.last.tag == :provisional)
        return nil if(@data.size == 1)
        if @data[@data.size - 2].tag == :provisional
          raise "Internal error.  Programmer needs more coffee:  Two provisional rows at end of table.  This should never happen"
        end
        return @data[@data.size - 2]
      else
        return @data.last
      end
    end

    def _provisional_remove
      if(@data.last && @data.last.tag == :provisional)
        @data.last.tag = nil
        @rows += 1
        return true
      end
      return false
    end

    def _cline_check
      if(@data.last && @data.last.tag == :cline)
        add_row(:provisional)
      end
    end

    def _cant_add_column(method_name)
      raise IndexError, "Columns will not be automatically added in LatexTable##{method_name} when LatexTable#auto_add_columns is set to false."
    end

    def _end_of_line(row, indent)
      if(row == @rows - 1)
        return " "
      else
        return "\\\\ \n" + indent
      end
    end

    def _is_valid_col_divider(div)
      #TODO @{} dividers and such
      ['','|','||'].include?(div)
    end

  end


  def multicolumn(ncol, alignment_or_content, content = nil)
    if(content.nil?)
      return LatexTable::MultiColumn.new(ncol, :c, alignment_or_content)
    else
      return LatexTable::MultiColumn.new(ncol, alignment_or_content, content)
    end
  end
  alias :multicol :multicolumn

  def fill_to_end(alignment_or_content, content = nil)
    if(content.nil?)
      return LatexTable::MultiColumn.new(:fill, :c, alignment_or_content)
    else
      return LatexTable::MultiColumn.new(:fill, alignment_or_content, content)
    end
  end

  def hline
    :hline
  end

  def endl
    :endl
  end

  def cline(begincol, endcol)
    return LatexTable::Cline.new(begincol, endcol)
  end


end

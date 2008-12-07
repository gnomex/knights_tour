module KnightsTour
  module Meta #:nodoc:
    module VERSION #:nodoc:
      MAJOR = 0
      MINOR = 0
      TINY  = 1

      def self.to_s
        [ MAJOR, MINOR, TINY ].join('.')
      end
    end

    COPYRIGHT = 'Copyright (c) Tuomas Kareinen'

    LICENSE = 'Licensed under the terms of MIT license.'

    def self.version
      "#{File.basename($0)} #{Meta::VERSION}\n#{Meta::COPYRIGHT}\n#{Meta::LICENSE}"
    end
  end

  class Application
    def initialize(dimension, start_position = [0, 0])
      dimension = dimension.to_i
      unless dimension > 0
        raise ArgumentError, "Dimension must be integer, greater than zero"
      end

      start_position = start_position.to_a
      if ((start_position.size != 2) or
          !(0...dimension).include?(start_position[0]) or
          !(0...dimension).include?(start_position[1]))
        raise ArgumentError, "Invalid start position value"
      end

      @dimension = dimension
      @start_position = start_position
      @solution = nil
    end

    def solve
      unless @solution
        grid = Grid.new(@dimension, @start_position)
        @solution = StringResult.new(grid.traverse)
      end
      @solution
    end
  end

  class Grid
    ## as [x, y] pairs
    LEGAL_STEPS = [ [-2, -1], [-1, -2], [-2,  1], [-1,  2],
                    [ 1,  2], [ 2,  1], [ 1, -2], [ 1, -2] ]

    def initialize(dimension, start_position)
      @grid = Array.new(dimension) { Array.new(dimension, nil) }
      @num_steps = 0
      @dimension_range = (0...dimension)
      traverse_to(start_position)
    end

    def is_traversed
      @grid.find { |row| row.include?(nil) } == nil
    end

    def traverse
      #puts StringResult.new(@grid)   # debug

      unless is_traversed
        next_positions = find_next_positions
        preferred_positions = find_preferred_next_positions(next_positions)

        unless preferred_positions.empty?
          next_position = choose_position(preferred_positions)
        else
          next_position = choose_position(next_positions)
        end

        traverse_to(next_position)

        traverse
      else
        @grid
      end
    end

    private

    def traverse_to(new_position)
      @num_steps += 1
      @position = new_position
      @grid[@position[0]][@position[1]] = @num_steps
    end

    def choose_position(positions)
      positions[rand(positions.size)]
    end

    def find_next_positions
      positions = LEGAL_STEPS.map { |step| find_position(@position, step) }
      positions.reject { |pos| pos.nil? }
    end

    def find_preferred_next_positions(next_positions)
      # prefer positions where we have not visited yet
      next_positions.reject do |pos|
        @grid[pos[0]][pos[1]] != nil
      end
    end

    def find_position(from, step)
      x_pos = from[0] + step[0]
      y_pos = from[1] + step[1]

      if (@dimension_range.include?(x_pos) and
          @dimension_range.include?(y_pos))
        [x_pos, y_pos]
      else
        nil
      end
    end
  end

  class StringResult
    def initialize(result)
      @result = result.to_a
      @field_width = find_last_step.to_s.length + 1
    end

    def to_s
      output = ""

      @result.each do |row|
        output += separator
        row_output = row.map { |step| "%#{@field_width}s" % step }.join("|")
        output += "|#{row_output}|\n"
      end

      output += separator
    end

    private

    def separator
      ("+" + "-" * @field_width) * @result[0].size + "+\n"
    end

    def find_last_step
      @result.map { |row| row.max }.max
    end
  end
end
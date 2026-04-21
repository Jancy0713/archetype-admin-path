module WorkflowProgressBoard
  class Board
    META_PREFIX = "- ".freeze
    ROW_COLUMNS = {
      status: 2,
      attempt: 3,
      input: 4,
      output: 5,
      reviewer: 6,
      human_confirmation: 7,
      next_step: 8
    }.freeze

    def initialize(path)
      @path = path
      @lines = File.readlines(path, chomp: true)
    end

    def set_meta(field, value)
      prefix = "#{META_PREFIX}#{field}:"
      replacement = value.to_s.strip.empty? ? prefix : "#{prefix} #{value}"
      replace_line(prefix, replacement)
    end

    def update_row(step_id, updates = {})
      index = @lines.index { |line| line.start_with?("| `#{step_id}` |") }
      return unless index

      cells = parse_row(@lines[index])
      updates.each do |key, value|
        next unless ROW_COLUMNS.key?(key)
        next if value.nil?

        cells[ROW_COLUMNS.fetch(key)] = format_cell(value)
      end

      @lines[index] = "| #{cells.join(' | ')} |"
    end

    def save
      File.write(@path, @lines.join("\n") + "\n")
    end

    private

    def replace_line(prefix, replacement)
      index = @lines.index { |line| line.start_with?(prefix) }
      @lines[index] = replacement if index
    end

    def parse_row(line)
      line.split("|", -1)[1..-2].map(&:strip)
    end

    def format_cell(value)
      "`#{value}`"
    end
  end
end

require "kronparser/version"

class KronParser
  def self.parse(cron_time_format)
    return KronParser.new(cron_time_format)
  end

  def next(time = Time.now)
    Time.now
  end

  def last(time = TIme.now)
    Time.now
  end

#  private

  def initialize(cron_time_format)
  end
  
  def parse_elems(format, range)
    format.split(",").inject([]) { |t, x| t += parse_elem(x, range); t }.sort.uniq
  end

  def parse_elem(format, range)
    case format
    when "*"
      range.to_a
    when /^\d+$/
      [format.to_i]
    when /^(\d+)-(\d+)$/
      ($1.to_i..$2.to_i).to_a
    when /^(.+)\/(\d+)$/
      targets = parse_elem($1.to_s, range)
      num = $2.to_i
      
      result = []
      i = targets.first
      while i <= targets.last
        result << i
        i += num
      end

      result
    end
  end
end

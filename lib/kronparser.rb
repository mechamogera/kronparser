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
  
  def parse_elem(format, range)
    case format
    when /,/
      return format.split(",").inject([]) { |t, x| t += parse_elem(x, range); t }.sort.uniq
    when "*"
      return range.to_a
    when /^\d+$/
      return [format.to_i]
    when /^(\d+)-(\d+)$/
      first = $1.to_i
      last = $2.to_i
      if first <= last
        return ($1.to_i..$2.to_i).to_a
      else
        return (range.first..last).to_a + (first..range.last).to_a
      end
    when /^(.+)\/(\d+)$/
      targets = parse_elem($1.to_s, range)
      num = $2.to_i
      
      result = []
      i = targets.first
      while i <= targets.last
        result << i
        i += num
      end

      return result
    end
  end
end

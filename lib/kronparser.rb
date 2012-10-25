require "kronparser/version"

class KronParser
  TIME_RANGE = {
    :min => 0..59,
    :hour => 0..23,
    :day => 1..31,
    :mon => 1..12,
    :wday => 0..6,
  }
    
  def self.parse(cron_time_format)
    return KronParser.new(cron_time_format)
  end

  def next(time = Time.now)
    forward = 0
    min = @data[:min].find { |x| x > (time.min + forward) }
    forward = min.nil? ? 1 : 0
    min = @data[:min].first unless min
    
    hour = @data[:hour].find { |x| x >= (time.hour + forward) }
    forward = hour.nil? ? 1 : 0
    if hour.nil? || hour != time.hour
      min = @data[:min].first
    end
    hour = @data[:hour].first unless hour

    day = @data[:day].find { |x| x >= (time.day + forward) }
    forward = day.nil? ? 1 : 0
    if day.nil? || day != time.day
      min = @data[:min].first
      hour = @data[:hour].first
    end
    day = @data[:day] unless day

    mon = @data[:mon].find { |x| x >= (time.mon + forward) }
    forward = mon.nil? ? 1 : 0
    if mon.nil? || mon != time.mon
      min = @data[:min].first
      hour = @data[:hour].first
      day = @data[:day].first
    end
    mon = @data[:mon].first unless mon

    year = time.year + forward

    date = nil
    while date.nil?
      date = Date.new(year, mon, day) rescue nil
      unless date
        min = @data[:min].first
        hour = @data[:hour].first

        day = @data[:day][@data[:day].find_index { |i| i == day } + 1]
        unless day
          day = @data[:day].first
          mon = @data[:mon][@data[:mon].find_index { |i| i == mon } + 1]
          unless mon
            mon = @data[:mon].first
            year += 1
          end
        end
      end
    end

    Time.local(year, mon, day, hour, min)
  end

  def last(time = TIme.now)
    Time.now
  end

  private

  def initialize(cron_time_format)
    elems = cron_time_format.split
    @data = {}
    [:min, :hour, :day, :mon, :wday].each_with_index do |t, idx|
      @data[t] = parse_elem(elems[idx], TIME_RANGE[t])
    end
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

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
    time_items = [:min, :hour, :day, :mon]
    time_data = {}
    time_items.each_with_index do |time_item, idx|
      time_data[time_item] = @data[time_item].find do |x| 
        if time_item == :min
          x > (time.send(time_item) + forward)
        else
          x >= (time.send(time_item) + forward)
        end
      end
      forward = time_data[time_item].nil? ? 1 : 0
      if time_data[time_item].nil? || time_data[time_item] != time.send(time_item)
        idx.times do |i|
          time_data[time_items[i]] = @data[time_items[i]].first
        end
      end
      time_data[time_item] = @data[time_item].first unless time_data[time_item]
    end

    time_data[:year] = time.year + forward

    date = nil
    while date.nil?
      date = Date.new(time_data[:year], time_data[:mon], time_data[:day]) rescue nil
      next if date

      time_data[:min] = @data[:min].first
      time_data[:hour] = @data[:hour].first

      time_data[:day] = @data[:day][@data[:day].find_index { |i| i == time_data[:day] } + 1]
      unless time_data[:day]
        time_data[:day] = @data[:day].first
        time_data[:mon] = @data[:mon][@data[:mon].find_index { |i| i == time_data[:mon] } + 1]
        unless time_data[:mon]
          time_data[:mon] = @data[:mon].first
          time_data[:year] += 1
        end
      end
    end

    return Time.local(time_data[:year], time_data[:mon], time_data[:day], time_data[:hour], time_data[:min])
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

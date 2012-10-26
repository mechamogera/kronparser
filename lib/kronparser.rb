require File.expand_path('kronparser/simple_process', File.dirname(__FILE__))
require File.expand_path("kronparser/version", File.dirname(__FILE__))
require 'date'

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

  def initialize(cron_time_format)
    elems = cron_time_format.split
    @data = {}
    [:min, :hour, :day, :mon, :wday].each_with_index do |t, idx|
      @data[t] = parse_elem(elems[idx], TIME_RANGE[t])
    end

    if elems[4] == "*"
      @day_type = :day
    elsif elems[2] == "*"
      @day_type = :wday
    else
      @day_type = :each
    end
  end

  def next(time = Time.now)
    forward = 1
    time_items = [:min, :hour, :day, :mon]
    time_data = {}
    time_items.each_with_index do |time_item, idx|
      time_data[time_item], forward = next_elem(time_item, 
                                                time.send(time_item) + forward,
                                                :mon => time.mon,
                                                :year => time.year)
      if (forward == 1) || (time_data[time_item] != time.send(time_item))
        idx.times do |i|
          time_data[time_items[i]] = first_elem(time_items[i], :mon => time.mon, :year => time.year)
        end
      end
    end

    time_data[:year] = time.year + forward

    date = nil
    while date.nil?
      date = Date.new(time_data[:year], time_data[:mon], time_data[:day]) rescue nil
      next if date

      time_data[:min] = first_elem(:min)
      time_data[:hour] = first_elem(:hour)

      time_data[:day], forward = next_elem(:day, time_data[:day] + 1, time_data)
      time_data[:mon], forward = next_elem(:mon, time_data[:mon] + forward)
      time_data[:year] += forward
    end

    return Time.local(time_data[:year], time_data[:mon], time_data[:day], time_data[:hour], time_data[:min])
  end

  def last(time = TIme.now)
    Time.now
  end

  private

  def first_elem(type, options = {})
    if (type != :day) || (@day_type == :day)
       return @data[type].first
    end

    value = nil
    next_mon, forward = next_elem(:mon, options[:mon] + 1)
    date = Date.new(options[:year] + forward, next_mon, 1) rescue nil
    next_wday = @data[:wday].find { |x| x >= date.wday }
    value = 1 + (next_wday ? (next_wday - date.wday) : (7 - date.wday + @data[:wday].first))
    
    case @day_type
    when :wday
      return value
    when :each
      return [value, @data[type].first].min
    end
  end

  def next_elem(type, value, options = {})
    next_value = forward = nil

    if (type != :day) || (@day_type != :wday)
      next_value = @data[type].find { |x| x >= value }
      forward = next_value.nil? ? 1 : 0 
      next_value = @data[type].first unless next_value
    end

    if (type != :day) || (@day_type == :day)
      return next_value, forward
    end

    wday_forward = nil
    next_wday_value = value
    date = Date.new(options[:year], options[:mon], value) rescue nil
    if date
      next_wday = @data[:wday].find { |x| x >= date.wday }
      next_wday_value += next_wday ? (next_wday - date.wday) : (7 - date.wday + @data[:wday].first)
      if next_wday_value <= 31
        wday_forward = 0
      else
        next_wday_value, wday_forward = first_elem(type, options), 1
      end
    else
      next_wday_value, wday_forward = first_elem(type, options), 1
    end

    case @day_type
    when :wday
      return next_wday_value, wday_forward
    when :each
      return *(((forward > wday_forward) || ((forward == wday_forward) && (next_value > next_wday_value))) ? [next_wday_value, wday_forward] : [next_value, forward])
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

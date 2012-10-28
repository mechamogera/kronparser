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

  MONTH_LAST_DATE = {
    1 => 31,
    2 => 28,
    3 => 31,
    4 => 30,
    5 => 31,
    6 => 30,
    7 => 31,
    8 => 31,
    9 => 30,
    10 => 31,
    11 => 30,
    12 => 31
  }
    
  def self.parse(cron_time_format)
    return KronParser.new(cron_time_format)
  end

  def initialize(cron_time_format)
    elems = cron_time_format.split
    raise ArgumentError.new("invalid format #{cron_time_format}") if elems.size != 5
    
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

    @is_time_exist = time_exist?
  end

  def next(time = Time.now)
    return nil unless @is_time_exist

    forward = 1
    time_items = [:min, :hour, :day, :mon]
    time_data = {}
    time_items.each_with_index do |time_item, idx|
      time_data[time_item], forward = next_elem(time_item, 
                                                time.send(time_item) + forward,
                                                :mon => time.mon,
                                                :year => time.year)
      if (forward != 0) || (time_data[time_item] != time.send(time_item))
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

  def prev(time = TIme.now)
    return nil unless @is_time_exist

    back = 0
    time_items = [:min, :hour, :day, :mon]
    time_data = {}
    time_items.each_with_index do |time_item, idx|
      time_data[time_item], back = prev_elem(time_item,
                                             time.send(time_item) - back,
                                             :mon => time.mon,
                                             :year => time.year)
      if (back != 0) || (time_data[time_item] != time.send(time_item))
        idx.times do |i|
          time_data[time_items[i]] = last_elem(time_items[i], :mon => time.mon, :year => time.year)
        end
      end
    end
    time_data[:year] = time.year - back

    date = nil
    while date.nil?
      date = Date.new(time_data[:year], time_data[:mon], time_data[:day]) rescue nil
      next if date

      time_data[:min] = last_elem(:min)
      time_data[:hour] = last_elem(:hour)

      time_data[:day], back = prev_elem(:day, time_data[:day] - 1, time_data)
      time_data[:mon], back = prev_elem(:mon, time_data[:mon] - back)
      time_data[:year] -= back
    end

    return Time.local(time_data[:year], time_data[:mon], time_data[:day], time_data[:hour], time_data[:min])
  end

  private

  def time_exist? 
    return true if @day_type != :day
    @data[:mon].each do |mon|
      last_date = MONTH_LAST_DATE[mon] + (mon == 2 ? 1 : 0)
      return true if last_date == 31
      return true if @data[:day].find { |x| x <= last_date }
    end

    return false
  end

  def first_elem(type, options = {})
    if (type != :day) || (@day_type == :day)
       return @data[type].first
    end

    value = nil
    next_mon, forward = next_elem(:mon, options[:mon] + 1)
    date = Date.new(options[:year] + forward, next_mon, 1)
    next_wday = @data[:wday].find { |x| x >= date.wday }
    value = 1 + (next_wday ? (next_wday - date.wday) : (7 - date.wday + @data[:wday].first))
    
    case @day_type
    when :wday
      return value
    when :each
      return [value, @data[type].first].min
    end
  end

  def last_elem(type, options = {})
    if (type != :day) || (@day_type == :day)
      return @data[type].last
    end

    value = nil
    last_mon, back = prev_elem(:mon, options[:mon] - 1)
    date = Date.new(options[:year] - back, last_mon, MONTH_LAST_DATE[last_mon])
    date = date.next if date.leap?
    last_wday = @data[:wday].reverse.find { |x| x <= date.wday }
    value = date.day + (last_wday ? (last_wday - date.wday) : (-7 - date.wday + @data[:wday].last))

    case @day_type
    when :wday
      return value
    when :each
      return [value, @data[type].last].max
    end
  end

  def next_elem(type, value, options = {})
    next_value = forward = nil

    if (type != :day) || (@day_type != :wday)
      next_value = @data[type].find { |x| x >= value }
      forward = next_value.nil? ? 1 : 0 
      next_value = first_elem(type, options) unless next_value

      return next_value, forward if (type != :day) || (@day_type == :day)
    end

    wday_forward = 1
    next_wday_value = nil
    date = Date.new(options[:year], options[:mon], value) rescue nil
    if date
      next_wday = @data[:wday].find { |x| x >= date.wday }
      next_wday_value = value + (next_wday ? (next_wday - date.wday) : (7 - date.wday + @data[:wday].first))
      wday_forward = 0 if next_wday_value <= 31
    end
    next_wday_value = first_elem(type, options) if wday_forward == 1

    case @day_type
    when :wday
      return next_wday_value, wday_forward
    when :each
      return *(((forward > wday_forward) || ((forward == wday_forward) && (next_value > next_wday_value))) ? [next_wday_value, wday_forward] : [next_value, forward])
    end
  end
 
  def prev_elem(type, value, options = {})
    last_value = back = nil

    if (type != :day) || (@day_type != :wday)
      last_value = @data[type].reverse.find { |x| x <= value }
      back = last_value.nil? ? 1 : 0
      last_value = last_elem(type, options) unless last_value

      return last_value, back if (type != :day) || (@day_type == :day)
    end

    wday_back = 1
    last_wday_value = nil
    date = Date.new(options[:year], options[:mon], value) rescue nil
    if date
      last_wday = @data[:wday].reverse.find { |x| x <= date.wday }
      last_wday_value = value + (last_wday ? (last_wday - date.wday) : (-7 - date.wday + @data[:wday].last))
      wday_back = 0 if last_wday_value > 0
    end
    last_wday_value = last_elem(type, options) if wday_back == 1

    case @day_type
    when :wday
      return last_wday_value, wday_back
    when :each
      return *(((back > wday_back) || ((back == wday_back) && (last_value < last_wday_value))) ? [last_wday_value, wday_back] : [last_value, back])
    end
  end

  def parse_elem(format, range)
    case format
    when /,/
      return format.split(",").inject([]) { |t, x| t += parse_elem(x, range); t }.sort.uniq
    when "*"
      return range.to_a
    when /^\d+$/
      raise ArgumentError.new("out of range #{format}") unless range.member?(format.to_i)
      return [format.to_i]
    when /^(\d+)-(\d+)$/
      first = $1.to_i
      last = $2.to_i
      raise ArgumentError.new("out of range #{format}") unless range.member?(first) && range.member?(last)
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
    else
      raise ArgumentError.new("invalid format #{format}")
    end
  end
end

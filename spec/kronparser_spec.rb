require 'spec_helper'
require 'time'

describe KronParser do
  it "could get next time" do
    test_data = [
      ["1 * * * *",     :next, "2011/12/21 12:31:52", "2011/12/21 13:01:00"],
      ["* 1 * * *",     :next, "2011/12/21 12:31:52", "2011/12/22 01:00:00"],
      ["* * 1 * *",     :next, "2011/12/21 12:31:52", "2012/01/01 00:00:00"],
      ["* * * 1 *",     :next, "2011/12/21 12:31:52", "2012/01/01 00:00:00"],
      ["* * * * *",     :next, "2011/12/21 12:31:52", "2011/12/21 12:32:00"],

      ["5,30 * * * *",  :next, "2011/12/21 12:01:52", "2011/12/21 12:05:00"],
      ["5,30 * * * *",  :next, "2011/12/21 12:05:52", "2011/12/21 12:30:00"],
      ["5,30 * * * *",  :next, "2011/12/21 12:30:52", "2011/12/21 13:05:00"],
      ["*/20 * * * *",  :next, "2011/12/21 12:30:52", "2011/12/21 12:40:00"],
      ["*/20 * * * *",  :next, "2011/12/21 12:40:52", "2011/12/21 13:00:00"],
      ["41-43 * * * *",  :next, "2011/12/21 12:00:52", "2011/12/21 12:41:00"],
      ["41-43 * * * *",  :next, "2011/12/21 12:40:52", "2011/12/21 12:41:00"],
      ["41-43 * * * *",  :next, "2011/12/21 12:41:52", "2011/12/21 12:42:00"],
      ["41-43 * * * *",  :next, "2011/12/21 12:42:52", "2011/12/21 12:43:00"],
      ["41-43 * * * *",  :next, "2011/12/21 12:43:52", "2011/12/21 13:41:00"],
      ["30-0 * * * *",   :next, "2011/12/21 12:43:52", "2011/12/21 12:44:00"],
      ["30-0 * * * *",   :next, "2011/12/21 12:15:52", "2011/12/21 12:30:00"],
      ["30-0 * * * *",   :next, "2011/12/21 12:00:52", "2011/12/21 12:30:00"],
      ["30-0 * * * *",   :next, "2011/12/21 11:59:52", "2011/12/21 12:00:00"],
      ["30-0 * * * *",   :next, "2011/12/21 12:30:52", "2011/12/21 12:31:00"],
      ["30-10 * * * *",  :next, "2011/12/21 12:15:52", "2011/12/21 12:30:00"],
      ["30-10 * * * *",  :next, "2011/12/21 12:29:52", "2011/12/21 12:30:00"],
      ["30-10 * * * *",  :next, "2011/12/21 12:30:52", "2011/12/21 12:31:00"],
      ["30-10 * * * *",  :next, "2011/12/21 12:45:52", "2011/12/21 12:46:00"],
      ["30-10 * * * *",  :next, "2011/12/21 12:03:52", "2011/12/21 12:04:00"],
      ["30-10 * * * *",  :next, "2011/12/21 12:09:52", "2011/12/21 12:10:00"],
      ["30-10 * * * *",  :next, "2011/12/21 12:10:52", "2011/12/21 12:30:00"],
      ["3-3 * * * *",    :next, "2011/12/21 12:10:52", "2011/12/21 13:03:00"],
      ["3-3 * * * *",    :next, "2011/12/21 12:03:52", "2011/12/21 13:03:00"],
      ["3-3 * * * *",    :next, "2011/12/21 12:02:52", "2011/12/21 12:03:00"],
      ["15-30/7 * * * *",  :next, "2011/12/21 12:04:52", "2011/12/21 12:15:00"],
      ["15-30/7 * * * *",  :next, "2011/12/21 12:14:52", "2011/12/21 12:15:00"],
      ["15-30/7 * * * *",  :next, "2011/12/21 12:15:52", "2011/12/21 12:22:00"],
      ["15-30/7 * * * *",  :next, "2011/12/21 12:16:52", "2011/12/21 12:22:00"],
      ["15-30/7 * * * *",  :next, "2011/12/21 12:21:52", "2011/12/21 12:22:00"],
      ["15-30/7 * * * *",  :next, "2011/12/21 12:22:52", "2011/12/21 12:29:00"],
      ["15-30/7 * * * *",  :next, "2011/12/21 12:23:52", "2011/12/21 12:29:00"],
      ["15-30/7 * * * *",  :next, "2011/12/21 12:28:52", "2011/12/21 12:29:00"],
      ["15-30/7 * * * *",  :next, "2011/12/21 12:29:52", "2011/12/21 13:15:00"],
      ["15-30/7 * * * *",  :next, "2011/12/21 12:30:52", "2011/12/21 13:15:00"],
      ["15-30/7 * * * *",  :next, "2011/12/21 12:31:52", "2011/12/21 13:15:00"],
      ["15-30/7 * * * *",  :next, "2011/12/21 12:40:52", "2011/12/21 13:15:00"],
      ["15-30/9,3 * * * *",  :next, "2011/12/21 12:02:52", "2011/12/21 12:03:00"],
      ["15-30/9,3 * * * *",  :next, "2011/12/21 12:03:52", "2011/12/21 12:15:00"],
      ["15-30/9,3 * * * *",  :next, "2011/12/21 12:04:52", "2011/12/21 12:15:00"],
      ["15-30/9,3 * * * *",  :next, "2011/12/21 12:14:52", "2011/12/21 12:15:00"],
      ["15-30/9,3 * * * *",  :next, "2011/12/21 12:15:52", "2011/12/21 12:24:00"],
      ["15-30/9,3 * * * *",  :next, "2011/12/21 12:16:52", "2011/12/21 12:24:00"],
      ["15-30/9,3 * * * *",  :next, "2011/12/21 12:23:52", "2011/12/21 12:24:00"],
      ["15-30/9,3 * * * *",  :next, "2011/12/21 12:24:52", "2011/12/21 13:03:00"],
      ["15-30/9,3 * * * *",  :next, "2011/12/21 12:25:52", "2011/12/21 13:03:00"],

      ["5 * * * *",         :next, "2011/12/31 23:25:52", "2012/01/01 00:05:00"],
      ["5 * * * *",         :next, "2011/12/30 23:25:52", "2011/12/31 00:05:00"],
      ["5 * * * *",         :next, "2011/12/30 22:25:52", "2011/12/30 23:05:00"],
      ["5 * * * *",         :next, "2011/12/30 22:03:52", "2011/12/30 22:05:00"],
      ["* 5 * * *",         :next, "2011/12/31 23:06:52", "2012/01/01 05:00:00"],
      ["* 5 * * *",         :next, "2011/12/30 23:06:52", "2011/12/31 05:00:00"],
      ["* 5 * * *",         :next, "2011/12/30 01:06:52", "2011/12/30 05:00:00"],
      ["3,5 5 * * *",       :next, "2011/12/31 23:06:52", "2012/01/01 05:03:00"],
      ["3,5 5 * * *",       :next, "2011/12/30 23:06:52", "2011/12/31 05:03:00"],
      ["3,5 5 * * *",       :next, "2011/12/30 01:06:52", "2011/12/30 05:03:00"],
      ["* * 5 * *",         :next, "2011/12/31 01:06:52", "2012/01/05 00:00:00"],
      ["* * 5 * *",         :next, "2011/12/01 01:06:52", "2011/12/05 00:00:00"],
      ["6-10 * 5 * *",      :next, "2011/12/31 01:06:52", "2012/01/05 00:06:00"],
      ["6-10 * 5 * *",      :next, "2011/12/01 01:06:52", "2011/12/05 00:06:00"],
      ["*/4 9-13 5 * *",    :next, "2011/12/01 01:06:52", "2011/12/05 09:00:00"],
      ["*/4 9-13 5 * *",    :next, "2011/12/31 01:06:52", "2012/01/05 09:00:00"],
      ["10-40/5 9 5 * *",   :next, "2011/12/01 01:06:52", "2011/12/05 09:10:00"],
      ["10-40/5 9 5 * *",   :next, "2011/12/31 01:06:52", "2012/01/05 09:10:00"],
      ["* * 31 * *",        :next, "2012/02/01 01:06:52", "2012/03/31 00:00:00"],
      ["* * 31 * *",        :next, "2012/03/31 23:59:59", "2012/05/31 00:00:00"],
      ["5 5 29 * *",        :next, "2012/02/28 05:05:59", "2012/02/29 05:05:00"],
      ["5 5 29 * *",        :next, "2012/02/29 05:05:59", "2012/03/29 05:05:00"],
      ["* * * 5 *",         :next, "2012/03/06 06:03:22", "2012/05/01 00:00:00"],
      ["* * * 5 *",         :next, "2012/05/06 06:03:22", "2012/05/06 06:04:00"],
      ["* * * 5 *",         :next, "2012/06/06 06:03:22", "2013/05/01 00:00:00"],
      ["5 * * 5 *",         :next, "2012/03/06 06:03:22", "2012/05/01 00:05:00"],
      ["5 * * 5 *",         :next, "2012/05/06 06:03:22", "2012/05/06 06:05:00"],
      ["5 * * 5 *",         :next, "2012/05/06 06:05:22", "2012/05/06 07:05:00"],
      ["5 * * 5 *",         :next, "2012/05/31 23:05:22", "2013/05/01 00:05:00"],
      ["5 * * 5 *",         :next, "2012/06/06 06:03:22", "2013/05/01 00:05:00"],
      ["* 5 * 5 *",         :next, "2012/04/06 04:03:22", "2012/05/01 05:00:00"],
      ["* 5 * 5 *",         :next, "2012/05/06 05:03:22", "2012/05/06 05:04:00"],
      ["* 5 * 5 *",         :next, "2012/06/06 05:03:22", "2013/05/01 05:00:00"],
      ["* 5 * 5 *",         :next, "2012/05/31 05:58:22", "2012/05/31 05:59:00"],
      ["* 5 * 5 *",         :next, "2012/05/31 05:59:22", "2013/05/01 05:00:00"],
      ["* * 5 5 *",         :next, "2012/05/04 05:59:22", "2012/05/05 00:00:00"],
      ["* * 5 5 *",         :next, "2012/05/05 05:59:22", "2012/05/05 06:00:00"],
      ["* * 5 5 *",         :next, "2012/05/06 05:59:22", "2013/05/05 00:00:00"],
      ["* * 5 5 *",         :next, "2012/05/05 23:59:22", "2013/05/05 00:00:00"],
      ["* * 5 5 *",         :next, "2012/05/05 23:58:22", "2012/05/05 23:59:00"],
      ["5 5 * 5 *",         :next, "2012/05/05 05:05:22", "2012/05/06 05:05:00"],
      ["5 5 * 5 *",         :next, "2012/05/31 05:05:22", "2013/05/01 05:05:00"],
      ["5 * 5 5 *",         :next, "2012/05/31 05:05:22", "2013/05/05 00:05:00"],
      ["5 * 5 5 *",         :next, "2012/04/31 05:05:22", "2012/05/05 00:05:00"],
      ["10 10 29 2 *",      :next, "2007/01/01 05:05:59", "2008/02/29 10:10:00"],
      ["10 10 29 2 *",      :next, "2008/01/01 05:05:59", "2008/02/29 10:10:00"],
      ["10 10 29 2 *",      :next, "2008/02/29 10:10:59", "2012/02/29 10:10:00"],
      
      ["* * * * 3",         :next, "2012/10/07 10:10:59", "2012/10/10 00:00:00"],
      ["* * * * 3",         :next, "2012/10/10 10:10:59", "2012/10/10 10:11:00"],
      ["* * * * 3",         :next, "2012/10/10 23:59:59", "2012/10/17 00:00:00"],
      ["* * * * 3",         :next, "2012/10/11 13:59:59", "2012/10/17 00:00:00"],
      ["* * * * 3",         :next, "2012/10/31 23:59:59", "2012/11/07 00:00:00"],
      ["* * * * 3",         :next, "2012/12/27 23:59:59", "2013/01/02 00:00:00"],
      ["* * * * 3",         :next, "2012/07/31 23:59:59", "2012/08/01 00:00:00"],
      ["* * * * */3",       :next, "2012/07/01 23:59:59", "2012/07/04 00:00:00"],
      ["* * * * */3",       :next, "2012/07/02 23:59:59", "2012/07/04 00:00:00"],
      ["* * * * */3",       :next, "2012/07/03 23:59:59", "2012/07/04 00:00:00"],
      ["* * * * */3",       :next, "2012/07/04 23:59:59", "2012/07/07 00:00:00"],
      ["* * * * */3",       :next, "2012/07/05 23:59:59", "2012/07/07 00:00:00"],
      ["* * * * */3",       :next, "2012/07/06 23:59:59", "2012/07/07 00:00:00"],
      ["* * * * */3",       :next, "2012/07/07 23:59:59", "2012/07/08 00:00:00"],
      ["10 * * * */3",      :next, "2012/07/07 23:59:59", "2012/07/08 00:10:00"],
      ["* 10 * * */3",      :next, "2012/07/07 23:59:59", "2012/07/08 10:00:00"],
      ["* * * 10 */3",      :next, "2012/07/07 23:59:59", "2012/10/03 00:00:00"],

      ["* * 29 2 5",        :next, "2011/07/07 23:59:59", "2012/02/03 00:00:00"],
      ["* * 29 2 5",        :next, "2012/02/03 23:59:59", "2012/02/10 00:00:00"],
      ["* * 29 2 5",        :next, "2012/02/24 23:59:59", "2012/02/29 00:00:00"],
      ["* * 29 2 5",        :next, "2012/02/29 23:59:59", "2013/02/01 00:00:00"],
    ]

    test_data.each do |cron_time_format, target_method, now_date, get_date|
      result_date = KronParser.parse(cron_time_format).send(target_method, Time.parse(now_date))
      result_date.should == Time.parse(get_date)
    end
  end

  it "could get nil if next time is not exist" do
    data = [
      ["* * 31 1 *",        :next, "2012/01/31 23:59:59", "2013/01/31 00:00:00"],
      ["* * 31 2 *",        :next, "2012/01/31 23:59:59", nil],
      ["* * 30 2 *",        :next, "2012/01/31 23:59:59", nil],
      ["* * 29 2 *",        :next, "2012/02/29 23:59:59", "2016/02/29 00:00:00"],
      ["* * 28 2 *",        :next, "2012/02/29 23:59:59", "2013/02/28 00:00:00"],
      ["* * 31 3 *",        :next, "2012/02/29 23:59:59", "2012/03/31 00:00:00"],
      ["* * 30 4 *",        :next, "2012/02/29 23:59:59", "2012/04/30 00:00:00"],
      ["* * 31 4 *",        :next, "2012/02/29 23:59:59", nil],
      ["* * 31 5 *",        :next, "2012/02/29 23:59:59", "2012/05/31 00:00:00"],
      ["* * 30 6 *",        :next, "2012/02/29 23:59:59", "2012/06/30 00:00:00"],
      ["* * 31 6 *",        :next, "2012/02/29 23:59:59", nil],
      ["* * 31 7 *",        :next, "2012/02/29 23:59:59", "2012/07/31 00:00:00"],
      ["* * 31 8 *",        :next, "2012/02/29 23:59:59", "2012/08/31 00:00:00"],
      ["* * 30 9 *",        :next, "2012/02/29 23:59:59", "2012/09/30 00:00:00"],
      ["* * 31 9 *",        :next, "2012/02/29 23:59:59", nil],
      ["* * 31 10 *",       :next, "2012/02/29 23:59:59", "2012/10/31 00:00:00"],
      ["* * 30 11 *",       :next, "2012/02/29 23:59:59", "2012/11/30 00:00:00"],
      ["* * 31 11 *",       :next, "2012/02/29 23:59:59", nil],
      ["* * 31 12 *",       :next, "2012/02/29 23:59:59", "2012/12/31 00:00:00"],
      ["* * 31 2,4,6,9,11 *",       :next, "2012/02/29 23:59:59", nil],
      ["* * 31 1,2,4,6,9,11 *",     :next, "2012/02/29 23:59:59", "2013/01/31 00:00:00"],
      ["* * 31 2-3 *",              :next, "2012/02/29 23:59:59", "2012/03/31 00:00:00"],
    ]

    data.each do |cron_time_format, target_method, now_date, get_date|
      result_date = KronParser.parse(cron_time_format).send(target_method, Time.parse(now_date))
      result_date.should == (get_date ? Time.parse(get_date) : nil)
    end
  end

  it "should raise ArgmentError when value is out of range" do
    data = [
      ["-1 * * * *",  false],
      ["0 * * * *",   true],
      ["59 * * * *",  true],
      ["60 * * * *",  false],
      ["* -1 * * *",  false],
      ["* 0 * * *",   true],
      ["* 23 * * *",  true],
      ["* 24 * * *",  false],
      ["* * 0 * *",   false],
      ["* * 1 * *",   true],
      ["* * 31 * *",  true],
      ["* * 32 * *",  false],
      ["* * * 0 *",   false],
      ["* * * 1 *",   true],
      ["* * * 12 *",  true],
      ["* * * 13 *",  false],
      ["* * * * 0",   true],
      ["* * * * 6",   true],
      ["* * * * 7",   false],
      ["9-60 * * * *",  false],
      ["9-23 * * * *",  true],
      ["-1-23 * * * *", false],
      ["* 22-24 * * *", false],
      ["* 22-23 * * *", true],
      ["* -1-23 * * *", false],
      ["* * 0-15 * *",  false],
      ["* * 1-12 * *",  true],
      ["* * 16-32 * *", false],
      ["* * 16-30 * *", true],
      ["* * * 0-5 *",   false],
      ["* * * 2-5 *",   true],
      ["* * * 5-13 *",  false],
      ["* * * 5-11 *",  true],
      ["* * * * 4-7",   false],
      ["* * * * 4-4",   true],
    ]

    data.each do |time, is_range|
      s = is_range ? :should_not : :should
      lambda { KronParser.parse(time) }.send(s, raise_error(ArgumentError))
    end
  end

  it "should raise ArgmentError by invalid format" do
    data = [
      ["a * * * *",       false],
      ["1-5/* * * * *",   false],
      ["*/* * * * *",     false],
      ["*/a * * * *",     false],
      ["1-a * * * *",     false],
      ["a-1 * * * *",     false],
      ["3+5 * * * *",     false],
      ["* * * * * *",     false],
      ["* * * *",         false],
      ["* * *",           false],
      ["* *",             false],
      ["*",               false],
    ]

    data.each do |time, is_range|
      s = is_range ? :should_not : :should
      lambda { KronParser.parse(time) }.send(s, raise_error(ArgumentError))
    end
  end
end

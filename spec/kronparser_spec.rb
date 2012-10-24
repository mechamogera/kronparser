require 'spec_helper'
require 'time'

describe "could get next and last time" do
  test_data = [
    ["* * * * *", :next, "2011/12/21 12:31:52", "2011/12/21 12:32:00"],
    ["* * * * *", :last, "2011/12/21 12:31:52", "2011/12/21 12:31:00"]
  ]

  test_data.each do |cron_time_format, target_method, now_date, get_date|
    result_date = KronParser.parse(cron_time_format).send(target_method, Time.parse(now_date))
    result_date.should == Time.parse(get_date)
  end
end

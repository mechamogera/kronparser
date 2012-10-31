Kronparser
======================

datermine next scheduled crontab run

Installation
------------

Add this line to your application's Gemfile:

    gem 'kronparser'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kronparser

Usage
-----
 * Example1

```
require 'kronparser'
require 'time'

KronParser.parse("* * * * *").next(Time.parse("Fri Oct 26 11:27:44 +0900 2012"))
# => Fri Oct 26 11:28:00 +0900 2012
KronParser.parse("40 * * * *").prev(Time.parse("Fri Oct 26 11:27:44 +0900 2012"))
# => Fri Oct 26 10:40:00 +0900 2012
```

 * Example2

```
require 'kronparser'

KronParser.parse("* * * * *").next
# => Fri Oct 26 11:28:00 +0900 2012
# Default value is Time.now
```

 * Additional Example

```
gem 'kronparser'
require 'kronparser'

KronParser::SimpleProcess.every("* * * * *") do
  puts Time.now
end

while true
  sleep 10
end

# => Fri Oct 26 11:27:00 +0900 2012 
# => Fri Oct 26 11:28:00 +0900 2012
# => ...
```

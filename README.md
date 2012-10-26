Kronparser
======================

datermine next corntab scheduled run

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

KronParser.parser("* * * * *").next(Time.parse("Fri Oct 26 11:27:44 +0900 2012"))
# => Fri Oct 26 11:28:00 +0900 2012
```

 * Example2
```
require 'kronparser'

KronParser.parser("* * * * *").next
# => Fri Oct 26 11:28:00 +0900 2012
# Time.now is default value
```

 * Addition Example
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


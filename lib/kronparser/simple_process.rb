class KronParser
  module SimpleProcess
    def self.every(cron_format, *args, &block)
      parser =  KronParser.parse(cron_format)
      Thread.start(parser, block, *args) do |p, proc, *args|
        while true
          now = Time.now
          span = p.next(now) - now
          if span > 3600
            sleep 3550
          else
            sleep span
            proc.call(*args)
          end
        end
      end
    end
  end
end

module WallFlyBot

  class QueueLoop
    attr_accessor :queue

    def initialize
      @queue = Queue.new
      @queued = false
      queue_loop
      end

    def queue_loop
      Thread.new do
        loop do
          next if @queued

          event = @queue.pop
          run(event)
        end
      end
    end

    def run(event)
      @queued = true
      case event.message.to_s
      when CFG.cmds_goto
        GOTO.run(event)
      when CFG.cmds_status
        Status.new(event)
      end
      @queued = false
    end

  end
  WFQ = QueueLoop.new
end

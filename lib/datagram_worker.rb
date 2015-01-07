require 'datagram_worker/version'
require 'logger'
require 'bunny'
require 'json'
module DatagramWorker

  def self.subscribe(routing_key, logger = ::Logger.new(STDOUT),&block)
    if ENV['RABBITMQ_URL']
      logger.info("RabbitMQ Connecting to #{ENV['RABBITMQ_URL']}")
      $conn = Bunny.new(ENV['RABBITMQ_URL'])
    else
      logger.info("RabbitMQ connecting to localhost")
      $conn = Bunny.new
    end

    $conn.start

    $ch = $conn.create_channel
    $x  = $ch.topic('datagrams_topic_exchange', auto_delete: false)
    $datagram_responses =  $ch.queue("datagram_responses", :durable => true)

    $ch.queue('', durable: true).bind($x, routing_key: routing_key).subscribe(block: true) do |di, md, pl|
      yield(di,md,JSON.parse(pl))
    end


  end

end

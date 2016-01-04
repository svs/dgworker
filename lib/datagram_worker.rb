require 'datagram_worker/version'
require 'logger'
require 'bunny'
require 'json'
module DatagramWorker

  def self.subscribe(routing_key, logger = ::Logger.new(STDOUT),&block)
    @@responses ||= {}
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
    $datagram_responses =  $ch.queue("watch_responses", :durable => true)

    $ch.queue('', durable: true).bind($x, routing_key: routing_key).subscribe(block: true) do |di, md, pl|
      j = JSON.parse(pl)
      @@responses[j["key"]] = Time.now
      yield(di,md,j)
    end
  end

  def self.respond_with(responses)
    responses.each do |id, response|
      r = {
        status_code: 200,
        elapsed: Time.now - @@responses[id]
        data: {
          status_code: 200,
          data: response,
        },
        id: id
      }
      @@responses.delete(id)
      $datagram_responses.publish(r.to_json)

    end

  end


end

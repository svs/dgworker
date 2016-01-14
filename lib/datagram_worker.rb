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
      ap j
      @@responses[j["key"]] = [Time.now, j["datagram_id"]]
      yield(di,md,j)
    end
  end

  def self.respond_with(responses)
    responses.each do |id, response|
      ap @@responses
      ap id
      ap @@responses[id]
      r = {
        status_code: 200,
        elapsed: Time.now - @@responses[id][0],
        data: {
          status_code: 200,
          data: response,
        },
        id: id,
        timestamp: Time.now.to_i,
        datagram_id: @@responses[id][1]
      }
      @@responses.delete(id)
      $datagram_responses.publish(r.to_json)

    end

  end


end

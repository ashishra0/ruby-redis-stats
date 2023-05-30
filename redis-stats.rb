require 'redis'
require 'awesome_print'

# Create a Redis client instance
class RedisStats
  attr_reader :memory_info, :redis

  def initialize(host)
    @redis = Redis.new(host: host)
  end

  def memory_information
    @memory_info ||= redis.info('memory')
    max_memory = memory_info.dig('maxmemory')
    max_memory_policy = memory_info.dig('maxmemory_policy')
    used_memory_human = memory_info.dig('used_memory_human')
    used_memory_peak_human = memory_info.dig('used_memory_peak_human')
    total_system_memory_human = memory_info.dig('total_system_memory_human')

    {
      max_memory: max_memory,
      max_memory_policy: max_memory_policy,
      used_memory: used_memory_human,
      used_memory_peak: used_memory_peak_human,
      total_system_memory: total_system_memory_human,
    }
  end

  def memory_usage_for_key(key)
    ap redis.memory(:usage, key)
  end

  def uptime_seconds
    t = redis.info['uptime_in_seconds'].to_i

    Time.at(t).utc.strftime("%H:%M:%S")
  end

  def connected_clients
    redis.info['connected_clients']
  end

  def total_keys
    redis.dbsize
  end

  def data
    {
      memory_information: memory_information,
      uptime: uptime_seconds,
      connected_clients: connected_clients,
      total_keys: total_keys
    }
  end

  def report
    ap data, {indent: -2, color: {string: :red, hash: :blue}}
  end
end

require 'colored'

def backoff_check(condition, desc)
  slept_time = 0
  min = 0
  max = environment == :development ? 5 : 9

  # 2 ^ 9 = ~ 8.5 minutes
  # Max time waited: 17.05 minutes
  (min..max).each do |x|
    sleep_time = 2**x
    sleep(sleep_time)
    slept_time += sleep_time

    break if condition.call
    raise "#{desc} has taken too long. Have waited #{slept_time} seconds" if x >= max
  end
  puts "Total time waited to #{desc}: #{slept_time}"
end

def random_string
  "#{Time.now.to_i}::#{rand(100_000)}"
end

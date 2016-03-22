require 'colored'

def random_string
  "#{Time.now.to_i}::#{rand(100_000)}"
end

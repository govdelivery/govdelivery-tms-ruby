require 'colored'

After('@keyword') do |scenario|
  if !scenario.failed? && defined?(@keyword)
    STDOUT.puts 'Deleting keyword created for this test'.blue
    begin
      @keyword.delete
    rescue => e
      STDERR.puts "Could not delete keyword after run: #{e.message}"
    end
  end
end

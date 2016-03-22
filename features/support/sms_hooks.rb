require 'colored'

After('@keyword') do |scenario|
  if !scenario.failed? && defined?(@keyword)
    log.info 'Deleting keyword created for this test'.blue
    begin
      @keyword.delete
    rescue => e
      log.error "Could not delete keyword after run: #{e.message}"
    end
  end
end

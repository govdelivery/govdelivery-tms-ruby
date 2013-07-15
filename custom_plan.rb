require 'zeus/rails'

class CustomPlan < Zeus::Rails

  #see: https://github.com/burke/zeus/issues/242#issuecomment-13036936
  def rspec
    RSpec::Core::Runner.disable_autorun!
    exit RSpec::Core::Runner.run(ARGV)
  end

end

Zeus.plan = CustomPlan.new

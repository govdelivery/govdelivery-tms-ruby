require 'active_support/inflector'

module GovDelivery::TMS::CoreExt
  def demodulize(path)
    ActiveSupport::Inflector.demodulize(path)
  end

  def classify(str)
    ActiveSupport::Inflector.camelize(str)
  end

  def singularize(str)
    ActiveSupport::Inflector.singularize(str)
  end

  def pluralize(str)
    ActiveSupport::Inflector.pluralize(str)
  end

  def tmsify(klassname)
    ActiveSupport::Inflector.underscore(demodulize(klassname))
  end

  def instance_class(klass)
    ActiveSupport::Inflector.constantize(singularize(klass.to_s))
  end
end

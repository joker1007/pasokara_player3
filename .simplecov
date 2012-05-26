require 'simplecov'
require 'simplecov-rcov'

# Define SimpleCov::Formatter
class SimpleCov::Formatter::MergedFormatter
  def format(result)
     SimpleCov::Formatter::HTMLFormatter.new.format(result)
     SimpleCov::Formatter::RcovFormatter.new.format(result)
  end
end
SimpleCov.merge_timeout 3600
SimpleCov.use_merging true
SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
SimpleCov.start 'rails'

# vim:ft=ruby

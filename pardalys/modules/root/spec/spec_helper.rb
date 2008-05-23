dir = File.expand_path(File.dirname(__FILE__))
 
$LOAD_PATH.unshift("#{dir}/../plugins/")

require 'puppet'

require 'mocha'
require 'spec'
 
Spec::Runner.configure do |config|
  config.mock_with :mocha
end

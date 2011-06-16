require 'json'
require 'forwardable'

require 'rest-client'
require 'diffy'
require 'yaml'
require 'facets'

Dir.glob(File.dirname(__FILE__) + '/hot_or_not/**/*.rb').each { |f| require f }

require 'json'
require 'forwardable'

require 'rest-client'
require 'diffy'
require 'yaml'
require 'facets'
require 'hpricot'

Dir.glob(File.dirname(__FILE__) + '/hot_or_not/ext/*.rb').each { |f| require f }
Dir.glob(File.dirname(__FILE__) + '/hot_or_not/*.rb').each { |f| require f }
Dir.glob(File.dirname(__FILE__) + '/hot_or_not/**/*.rb').each { |f| require f }

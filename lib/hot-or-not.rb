require 'json'

require 'rest-client'
require 'diffy'
require 'yaml'
require 'facets'

Dir.glob(File.dirname(__FILE__) + '/hot-or-not/**.rb').each { |f| require f }

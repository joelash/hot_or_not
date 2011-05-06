require 'rest-client'
require 'diffy'
require 'yaml'

Dir.glob(File.dirname(__FILE__) + '/api-compare/**.rb').each { |f| require f }

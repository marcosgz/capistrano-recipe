require 'active_support/core_ext/hash/reverse_merge'
require 'capistrano'

Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb')).sort.each { |f| load f }

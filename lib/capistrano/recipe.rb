require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/indifferent_access'
require 'capistrano'

Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb')).sort.each { |f| load f }

class DeepToHash
  def self.to_hash(value)
    case value
    when Hash
      Hash[value.to_hash.map { |key, value| [key, to_hash(value)] }]
    else
      value
    end
  end
end

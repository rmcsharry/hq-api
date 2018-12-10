# frozen_string_literal: true

# Extend Hash with `to_dotted_hash` method
class Hash
  def self.to_dotted_hash(hash, recursive_key = '')
    hash.each_with_object({}) do |(k, v), ret|
      key = recursive_key + k.to_s
      if v.is_a? Hash
        ret.merge! to_dotted_hash(v, key + '.')
      else
        ret[key] = v
      end
    end
  end

  def to_dotted_hash
    Hash.to_dotted_hash self
  end
end

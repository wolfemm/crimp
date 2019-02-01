# frozen_string_literal: true

require 'digest/md5'
require 'set'
require 'deepsort'

class Crimp
  class << self
    def signature(obj, digest_class=Digest::MD5)
      digest_class.hexdigest(notation(obj))
    end

    def notation(obj)
      annotate(obj).flatten.join
    end

    def annotate(obj)
      obj = coerce(obj)

      case obj
      when String
        [obj, 'S']
      when Numeric
        [obj, 'N']
      when TrueClass, FalseClass
        [obj, 'B']
      when NilClass
        [nil, '_']
      when Array
        [sort(obj), 'A']
      when Hash
        [sort(obj), 'H']
      else
        raise TypeError, "Expected a (String|Number|Boolean|Nil|Hash|Array), Got #{obj.class}."
      end
    end

    private

    def sort(coll)
      coll.deep_sort_by { |obj| obj.to_s }.map { |obj| annotate(obj) }
    end

    def coerce(obj)
      case obj
      when Symbol then obj.to_s
      when Set    then obj.to_a
      else obj
      end
    end
  end
end

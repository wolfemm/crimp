# frozen_string_literal: true

require 'digest/md5'
require 'set'
require 'deepsort'

class Crimp
  module TypeFlag
    BOOL = "B"
    NIL = "_"
    STRING = "S"
    NUMERIC = "N"
    ARRAY = "A"
    HASH = "H"
  end

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
        [obj, TypeFlag::STRING]
      when Numeric
        [obj, TypeFlag::NUMERIC]
      when TrueClass
        @_annotated_true ||= [true, TypeFlag::BOOL].freeze
      when FalseClass
        @_annotated_false ||= [false, TypeFlag::BOOL].freeze
      when NilClass
        @_annotated_nil ||= [nil, TypeFlag::NIL].freeze
      when Array
        [sort(obj), TypeFlag::ARRAY]
      when Hash
        [sort(obj), TypeFlag::HASH]
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

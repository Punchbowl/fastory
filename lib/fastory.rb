require 'active_support'
require 'active_record'

module Punchbowl
  module InstanceMethods
    def self.included(receiver)
      Fastory.sql_inserts = []
      Fastory.fastories = {}

      receiver.instance_eval do
        alias_method_chain :teardown, :fastory_refresh
      end
    end

    def teardown_with_fastory_refresh
      Fastory.fastories.each do |k,v|
        Fastory.fastories[k][:templates_used] = 0
      end

      teardown_without_fastory_refresh
    end
  end

  class Fastory
    attr_accessor :name, :options    
    cattr_accessor :fastories, :sql_inserts, :record_sql
    
    @@fastories = {}
    @@sql_inserts = []
    @@record_sql = false

    def initialize(name, options = {})
      self.name = name
      self.options = options
    end

    def process! 
      options = transform_associations

      if template_available?
        cache = @@fastories[cache_key]
        cnt = cache[:templates_used] ||= 0
        cache[:templates_used] += 1

        fast_gen(cache[:templates][cnt][:sql])

        obj = build_class.find cache[:templates][cnt][:id]
      else
        @@sql_inserts = []
        @@record_sql = true
        obj = fg.build name, options
        obj.id = fg.next(:fastory_id_generator) if obj.id.blank? 
        obj.save!
        @@record_sql = false

        @@fastories[cache_key] ||= {}
        @@fastories[cache_key][:templates_available] ||= 0
        @@fastories[cache_key][:templates_available] += 1
        @@fastories[cache_key][:templates_used] = @@fastories[cache_key][:templates_available]

        res = @@fastories[cache_key][:templates] ||= []
        obj_meta = {:sql => @@sql_inserts.dup, :id => obj.id }
        res = @@fastories[cache_key][:templates] << obj_meta 
      end

      obj
    end

    private

    def transform_associations
      output_options = {}
      options.each do |k,v|
        unless v.is_a?(ActiveRecord::Base)
          output_options[k] = v
          next
        end

        raise 'Cannot deal with new records either... sorry' if v.new_record?
        assoc = build_class.reflect_on_all_associations.find {|a| a.name.to_s == k.to_s }
        raise "No association #{name} on #{k}" if assoc.blank?
        raise 'Can only deal with belongs_to right now' unless assoc.belongs_to?

        output_options[assoc.primary_key_name] = v.id
      end

      output_options
    end

    def build_class
      fg.factories[name].build_class
    end

    def template_available?
      @@fastories[cache_key].present? && (@@fastories[cache_key][:templates_available].to_i > @@fastories[cache_key][:templates_used].to_i)
    end

    def fg
      ::Factory
    end

    def fast_gen(sql)
      sql.each {|s| ActiveRecord::Base.connection.execute_without_query_capture(s) }
    end

    def cache_key
      options.to_a.map {|a,b| [a.to_s, b.to_s]}.sort {|a,b| a[0] <=> b[0]}.unshift([:name, name])
    end
  end
end

ActiveRecord::Base.connection.class_eval do
  define_method :execute_with_query_capture do |*args|
    sql = args[0]
    name = args[1]

    if Punchbowl::Fastory.record_sql
      case sql
      when /\A(DELETE|UPDATE|INSERT)/
        Punchbowl::Fastory.sql_inserts << sql
      end
    end

    execute_without_query_capture(sql, name)
  end

  alias_method_chain :execute, :query_capture
end

if defined?(ActiveSupport) && defined?(ActiveSupport::TestCase)
  ActiveSupport::TestCase.send :include, Punchbowl::InstanceMethods
end

Factory.sequence(:fastory_id_generator) {|n| n.to_i}

def Fastory(name, options = {})
  Punchbowl::Fastory.new(name, options).process!
end


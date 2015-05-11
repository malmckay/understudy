require 'understudy_log_recorder'
require 'understudy_statsd_recorder'

class Understudy
  RECORDERS = [UnderstudyLogRecorder, UnderstudyStatsdRecorder]

  def self.diff(lead, understudy, u_method, result_lead, result_understudy, ex_lead, ex_understudy, args, &block)
    if ex_lead && ex_understudy.nil?
      Understudy.record(:fail, lead, understudy, u_method, ex_lead, result_understudy, args)
    elsif ex_lead.nil? && ex_understudy
      Understudy.record(:fail, lead, understudy, u_method, result_lead, ex_understudy, args)
    elsif ex_lead && ex_understudy && ex_lead.message != ex_understudy.message
      Understudy.record(:fail, lead, understudy, u_method, ex_lead, ex_understudy, args)
    elsif ex_lead && ex_understudy && ex_lead.message == ex_understudy.message
      Understudy.record(:success, lead, understudy, u_method, ex_lead, ex_understudy, args)
    else

      compare_for_lead       = result_lead
      compare_for_understudy = result_understudy

      if block_given?
        compare_for_lead, compare_for_understudy = yield(result_lead, result_understudy)
      end

      diff = if compare_for_lead != compare_for_understudy
        [result_lead, result_understudy]
      end

      if diff
        Understudy.record(:fail, lead, understudy, u_method, result_lead, result_understudy, args)
      else
        Understudy.record(:success, lead, understudy, u_method, result_lead, result_understudy, args)
      end
    end
  end

  def self.record(status, lead, understudy, u_method, result_expected, result_got, args)
    RECORDERS.each{|recorder|recorder.__send__(status, lead, understudy, u_method, result_expected, result_got, args)}
  end

  def initialize(lead, understudy, u_methods, &block)
    if understudy.ancestors.include?(lead)
      raise "Infinite loop would happen. Make #{lead.name} and #{understudy.name} children of a base class, not of each other."
    end

    if u_methods.is_a?(Hash) && u_method = u_methods.delete(:self)
      shadow_self_methods(lead, understudy, u_method, &block)
    else
      Array(u_methods).each do |current_method|
        shadow_method(false, lead, understudy, current_method, &block)
      end
    end
  end

  def shadow_self_methods(lead, understudy, u_method, &block)
    Array(u_method).each do |current_method|
      shadow_method(true, lead, understudy, current_method, &block)
    end
  end

  def shadow_method(clazz_method, lead, understudy, u_method, &block)
    class_or_meta_class_lead = lead
    if clazz_method
      class_or_meta_class_lead = class << lead; self end
      return if lead.respond_to?("#{u_method}_with_understudy") # don't infinite loop
    else
      return if lead.new.respond_to?("#{u_method}_with_understudy") # don't infinite loop
    end

    class_or_meta_class_lead.__send__(:define_method, "#{u_method}_with_understudy") do |*args|
      result_lead, ex_lead = nil
      result_understudy, ex_understudy = nil

      begin
        result_lead = __send__("#{u_method}_without_understudy", *args)
      rescue => ex_lead
        # Captured ex_lead
      end

      begin
        result_understudy = clazz_method ? understudy.__send__(u_method, *args) : understudy.new.__send__(u_method, *args)
      rescue => ex_understudy
        # Captured ex_understudy
      end

      Understudy.diff(lead, understudy, u_method, result_lead, result_understudy, ex_lead, ex_understudy, args, &block)

      # return or raise, as if nothing happened
      if ex_lead
        raise ex_lead
      else
        return result_lead
      end
    end

    class_or_meta_class_lead.alias_method_chain u_method, 'understudy'
  end

end

# Understudy.new(MC::Multipart, MC::MultipartWithMail, {:self=>:parse}) do |a, b|
# end

require 'understudy_recorder'

class UnderstudyLogRecorder < UnderstudyRecorder
  def self.success(lead, understudy, method, result_expected, result_got, args)
    LOG.debug("UNDERSTUDY SUCCESS: #{understudy.name}##{method} #{log_message(result_got)}.")
  end
  def self.fail(lead, understudy, method, result_expected, result_got, args)
    LOG.info("UNDERSTUDY FAIL: #{understudy.name}##{method} #{log_message(result_got)}. It should have #{log_message(result_expected)}. args were: #{args.inspect}")
  end

  def self.log_message(obj)
    if obj.is_a?(Exception)
      "raised #{obj.class.name} with message \"#{obj.message}\""
    else
      "returned #{obj.inspect}"
    end
  end
end

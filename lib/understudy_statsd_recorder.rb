require 'understudy_recorder'

class UnderstudyStatsdRecorder < UnderstudyRecorder
  def self.success(lead, understudy, method, result_expected, result_got, args)
    STATSD.count("understudy.#{lead.name}.#{method}.success",1)
  end
  def self.fail(lead, understudy, method, result_expected, result_got, args)
    STATSD.count("understudy.#{lead.name}.#{method}.fail",1)
  end
end

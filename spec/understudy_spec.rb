require 'spec_helper'

class LeadActor
  def self.easy_self_role
    "Actor: A little more than kin, and less than kind"
  end
  def self.difficult_self_role
    "Actor: Not so, my lord; I am too much i' the sun."
  end
  def easy_role
    "A little more than kin, and less than kind"
  end
  def difficult_role
    "Not so, my lord; I am too much i' the sun."
  end
  def bees
    raise "OMG BEEESSS"
  end
  def fire_on_set
    "Would audience members please find their nearest exit."
  end
  def no_dressing_room
    raise "Ahhh, FREAK OUT!!"
  end
  def easy_acts
    [1, 2.3, 5]
  end
  def difficult_acts
    [7, 8, 9.1]
  end
  def easy_roles_and_acts
    {:hamlet=>[1,2], :horatio=>[2,3]}
  end
  def difficult_roles_and_acts
    {:hamlet=>[9], :horatio=>[9]}
  end
end

class UnderstudyActor
  def self.easy_self_role
    "Actor: A little more than kin, and less than kind"
  end
  def self.difficult_self_role
    "Actor: Not so, my lord. Eh..."
  end
  def easy_role
    "A little more than kin, and less than kind"
  end
  def difficult_role
    "Not so, my lord. Eh..."
  end
  def bees
    raise "OMG BEEESSS"
  end
  def fire_on_set
    raise "OMG I'M ON FIRE"
  end
  def no_dressing_room
    "I'll just use the alley out back"
  end
  def easy_acts
    [1, 2.3, 5]
  end
  def difficult_acts
    [7, 8]
  end
  def easy_roles_and_acts
    {:hamlet=>[1], :horatio=>[2]}
  end
  def difficult_roles_and_acts
    {:hamlet=>[9]}
  end
end

describe Understudy do
  before(:all) do
    LOG = mock('log') unless Object.const_defined?(:LOG)
    LOG.stub!(:info)
    LOG.stub!(:debug)
    STATSD = mock('log') unless Object.const_defined?(:STATSD)
    STATSD.stub!(:count)
  end

  describe "instance_methods" do
    before(:all) do
      Understudy.new(LeadActor, UnderstudyActor, [:easy_role, :difficult_role, :easy_acts, :difficult_acts, :fire_on_set, :no_dressing_room])
    end

    describe "that return strings" do
      it "should work when there is no difference" do
        LOG.should_not_receive(:info)
        LeadActor.new.easy_role
      end

      it "should work when there is a difference" do
        LOG.should_receive(:info).with(%q{UNDERSTUDY FAIL: UnderstudyActor#difficult_role returned "Not so, my lord. Eh...". It should have returned "Not so, my lord; I am too much i' the sun.". args were: []})
        LeadActor.new.difficult_role
      end
    end

    describe "that return objects" do
      it "should work when there is no difference" do
        LOG.should_not_receive(:info)
        LeadActor.new.easy_acts
      end

      it "should work when there is a difference" do
        LOG.should_receive(:info).with(%q{UNDERSTUDY FAIL: UnderstudyActor#difficult_acts returned [7, 8]. It should have returned [7, 8, 9.1]. args were: []})
        LeadActor.new.difficult_acts
      end
    end

    describe "that raise" do
      it "should work when both raise" do
        LOG.should_not_receive(:info)
        begin;LeadActor.new.bees;rescue => ex;end
      end

      it "should work when the lead raises" do
        LOG.should_receive(:info).with(%q{UNDERSTUDY FAIL: UnderstudyActor#no_dressing_room returned "I'll just use the alley out back". It should have raised RuntimeError with message "Ahhh, FREAK OUT!!". args were: []})
        begin;LeadActor.new.no_dressing_room;rescue => ex;end
      end

      it "should work when the understudy raises" do
        LOG.should_receive(:info).with(%q{UNDERSTUDY FAIL: UnderstudyActor#fire_on_set raised RuntimeError with message "OMG I'M ON FIRE". It should have returned "Would audience members please find their nearest exit.". args were: []})
        LeadActor.new.fire_on_set
      end
    end
  end

  describe "instance_methods with blocks" do
    before(:all) do
      Understudy.new(LeadActor, UnderstudyActor, [:easy_roles_and_acts, :difficult_roles_and_acts]) do |a,b|
        # I only care about keys:
        [a.keys, b.keys]
      end
    end

    describe "that return objects and compare with a block" do
      it "should work when there is no difference" do
        LOG.should_not_receive(:info)
        LeadActor.new.easy_roles_and_acts
      end

      it "should work when there is a difference" do
        LOG.should_receive(:info).with(%q{UNDERSTUDY FAIL: UnderstudyActor#difficult_roles_and_acts returned {:hamlet=>[9]}. It should have returned {:hamlet=>[9], :horatio=>[9]}. args were: []})
        LeadActor.new.difficult_roles_and_acts
      end
    end
  end

  describe "self methods" do
    before(:all) do
      Understudy.new(LeadActor, UnderstudyActor, {:self=>[:easy_self_role, :difficult_self_role]})
    end

    it "should work when there is no difference" do
      LOG.should_not_receive(:info)
      LeadActor.easy_self_role
    end

    it "should work when there is a difference" do
      LOG.should_receive(:info).with(%q{UNDERSTUDY FAIL: UnderstudyActor#difficult_self_role returned "Actor: Not so, my lord. Eh...". It should have returned "Actor: Not so, my lord; I am too much i' the sun.". args were: []})
      LeadActor.difficult_self_role
    end
  end
end

require 'test/unit'
require 'rbclips'

class Test_Template < Test::Unit::TestCase
  def test_exists
    assert Clips.constants.member?(:Template)
    assert Clips::Template.constants.member?(:Creator)
  end

  def test_new_hash
    assert_nothing_raised               { Clips::Template.new :name => 'human', :slots => [:name, 'age'] }
    assert_nothing_raised               { Clips::Template.new :name => 'human', :slots => %w(name age) }
    assert_nothing_raised               { Clips::Template.new :name => 'human', :slots => {:name => {:multislot => false}, 'age' => {:default => 30}} }
    assert_raise(Clips::UsageError)     { Clips::Template.new :name => 'human', :slots => %w() }
    assert_raise(Clips::UsageError)     { Clips::Template.new :name => 'human', :slots => {} }
    assert_raise(Clips::ArgumentError)  { Clips::Template.new :type => [:any] }
    assert_raise(Clips::ArgumentError)  { Clips::Template.new :name => 3 }
    assert_raise(Clips::ArgumentError)  { Clips::Template.new :name => 'human' }
    assert_raise(Clips::ArgumentError)  { Clips::Template.new :slots => [:name, :age] }
    assert_raise(Clips::ArgumentError)  { Clips::Template.new :name => 'human', :slots => [2, 1, 4] }
    assert_raise(Clips::ArgumentError)  { Clips::Template.new :name => 'human', :slots => { 2 => {:default => 30}} }
    assert_raise(Clips::ArgumentError)  { Clips::Template.new :name => 'human', :slots => { :name => {:pico => 30}} }
    assert_raise(Clips::ArgumentError)  { Clips::Template.new :name => 'human', :slots => { :name => {'pico' => 30}} }
    assert_raise(Clips::ArgumentError)  { Clips::Template.new :name => 'human', :slots => { :name => {2 => 30}} }

    a = Clips::Template.new :name => 'human', :slots => [:name, 'age']
    assert_equal a.instance_eval { @name }, 'human'
    assert_equal a.instance_eval { @slots }, { :name => nil, :age => nil }

    a = Clips::Template.new :name => 'human', :slots => %w(name age)
    assert_equal a.instance_eval { @name }, 'human'
    assert_equal a.instance_eval { @slots }, { :name => nil, :age => nil }

    a = Clips::Template.new :name => 'human', :slots => {:name => { :multislot => false}, :age => { :default => 30}}
    assert_equal a.instance_eval { @name }, 'human'
    assert_equal a.instance_eval { @slots }, { :name => {:multislot => false}, :age => {:default => 30} }
  end

  def test_new_block
    assert_raise(Clips::UsageError)     { Clips::Constraint::Creator.new }
    assert_nothing_raised               { Clips::Template.new('human') {|s| s.slot 'name' } }
    assert_nothing_raised               { Clips::Template.new('human') {|s| s.slot 'name', {} } }
    assert_nothing_raised               { Clips::Template.new('human') {|s| s.slot :name, :multislot => false; s.slot 'age', :default => 3 } }
    assert_raise(Clips::ArgumentError)  { Clips::Template.new(3) {|s| s.slot 'name' } }
    assert_raise(Clips::ArgumentError)  { Clips::Template.new('human') {|s| s.slot :name, :pico => false; s.slot 'age', :default => 3 } }
    assert_raise(Clips::ArgumentError)  { Clips::Template.new('human') {|s| s.slot :name, 'pico' => false; s.slot 'age', :default => 3 } }
    assert_raise(Clips::ArgumentError)  { Clips::Template.new('human') {|s| s.slot :name, 10 => false; s.slot 'age', :default => 3 } }
    assert_raise(Clips::ArgumentError)  { Clips::Template.new('human') {|s| s.slot 7, :multislot => false; s.slot 'age', :default => 3 } }

    a = Clips::Template.new 'human' do |s| 
      s.slot :name
      s.slot 'age'
    end
    assert_equal a.instance_eval { @name }, 'human'
    assert_equal a.instance_eval { @slots }, { :name => nil, :age => nil }

    a = Clips::Template.new 'human' do |s|
      s.slot :name, :multislot => false
      s.slot :age, :default => 30
    end
    assert_equal a.instance_eval { @name }, 'human'
    assert_equal a.instance_eval { @slots }, { :name => {:multislot => false}, :age => {:default => 30} }
  end

end

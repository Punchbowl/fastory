require 'test_helper'

class FastoryTest < Test::Unit::TestCase
  include Punchbowl::InstanceMethods
 
  should "define Fastory" do
    assert Fastory(:user).is_a?(User)
  end

  should "handle associations" do
    @user = Fastory :user
    @event = Fastory :event, :user => @user
  
    @user.reload
    @event.reload

    assert_equal @user, @event.user
  end

  def teardown
    ActiveRecord::Base.connection.execute 'delete from users'
    ActiveRecord::Base.connection.execute 'delete from events'
  end
end

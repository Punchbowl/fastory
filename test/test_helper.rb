require 'rubygems'
require 'test/unit'
require 'active_record'
require 'shoulda'
require 'factory_girl'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
                                        :database  => File.join(File.dirname(__FILE__), 'test.db')) 

ActiveRecord::Schema.define do
  execute 'DROP TABLE IF EXISTS users'
  execute 'DROP TABLE IF EXISTS events'
  
  create_table :users, :force => true do |t|
    t.string :name
    t.string :email
  end

  create_table :events, :force => true do |t|
    t.string :title
    t.integer :user_id
  end
end

require 'fastory'

class User < ActiveRecord::Base
  has_many :events
end

class Event < ActiveRecord::Base
  belongs_to :user
end

Factory.define(:user) do |u|
  u.name 'Ryan'
  u.email 'ryan@angilly.com'
end

Factory.define(:event) do |e|
  e.user { Factory :user }
  e.title 'My sweet party'
end

class Test::Unit::TestCase
end

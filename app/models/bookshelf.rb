require 'active_record'
class Bookshelf < ActiveRecord::Base
    belongs_to :user
end
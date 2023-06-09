require 'active_record'
class User < ActiveRecord::Base
    has_one :bookshelf
end
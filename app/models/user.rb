require 'active_record'
require_relative '../../config/environment.rb'
require_relative './bookstore_app'
class User < ActiveRecord::Base
    has_one :bookshelf
end
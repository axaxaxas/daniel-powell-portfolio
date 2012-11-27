class Source < ActiveRecord::Base
  attr_accessible :author, :body, :title
  has_and_belongs_to_many :markovs, :join_table => "markov_sources"
end

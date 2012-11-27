class Markov < ActiveRecord::Base
  attr_accessible :author, :name
  attr_accessible :paircount # integer
  serialize :ngrams, Hash

  has_and_belongs_to_many :sources, :join_table => "markov_sources"

  def make_universal_model
    self.name = "Universe"
    self.author = "Everybody"
    self.reset_hash
    Source.all.each do |source|
      self.sources<<(source)
      self.combine_hash_from(source)
    end
    self.save
  end

  def reset_hash
    self.ngrams = Hash.new
    self.paircount = 0
    self.save
  end

  def combine_hash_from(source) # adds to existing hash
    self.sources<<(source)
    previous_word = :text_start
    source.body.split.each do |word|
      self.paircount += 1
      if self.ngrams[previous_word] == nil
        self.ngrams[previous_word] = Hash.new
      end
        
      if self.ngrams[previous_word][word] == nil
        self.ngrams[previous_word][word] = 1
      else
        self.ngrams[previous_word][word] += 1
      end
      previous_word = word
    end
    self.save
  end

  def new_hash_from(source) # replaces existing hash
    self.ngrams = Hash.new
    self.combine_hash_from(source)
    self.save
    return
  end

end

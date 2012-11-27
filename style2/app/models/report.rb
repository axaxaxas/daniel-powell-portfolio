class Report < ActiveRecord::Base
  attr_accessible :model_probability, :universe_probability
  belongs_to :source
  belongs_to :markov
  
  def generate
    universe = Markov.where(:name => "Universe").first

    model_numerator = 0
    model_denominator = 0
    universe_numerator = 0
    universe_denominator = 0
    previous_word = :text_start
    self.source.body.split.each do |word|
      if self.markov.ngrams[previous_word][word] != nil
        model_numerator += self.markov.ngrams[previous_word][word]
        model_denominator += self.markov.paircount
        
        universe_numerator += universe.ngrams[previous_word][word]
        universe_denominator += universe.paircount
        
      end
    end
    self.model_probability = model_numerator/model_denominator.to_f
    self.universe_probability = universe_numerator/universe_denominator.to_f
    universe.delete
  end

end

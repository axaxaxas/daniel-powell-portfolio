class CreateMarkovSourcesJoinTable < ActiveRecord::Migration
  def change
    create_table :markov_sources, :id => false do |t|
      t.integer :markov_id
      t.integer :source_id
    end
  end
end

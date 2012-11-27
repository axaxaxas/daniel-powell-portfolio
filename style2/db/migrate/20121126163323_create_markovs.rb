class CreateMarkovs < ActiveRecord::Migration
  def change
    create_table :markovs do |t|
      t.string :name
      t.string :author
      t.integer :paircount
      t.text :ngrams # serializes Hash

      t.timestamps
    end
  end
end

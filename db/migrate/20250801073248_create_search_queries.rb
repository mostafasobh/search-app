class CreateSearchQueries < ActiveRecord::Migration[8.0]
  def change
    create_table :search_queries do |t|
      t.references :user, null: false, foreign_key: true
      t.text :query

      t.timestamps
    end

    add_index :search_queries, :query
  end
end

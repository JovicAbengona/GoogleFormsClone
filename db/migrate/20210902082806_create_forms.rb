class CreateForms < ActiveRecord::Migration[6.1]
  def change
    create_table :forms do |t|
      t.string :code
      t.integer :form_type
      t.string :title
      t.text :description
      t.text :question_order
      t.integer :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

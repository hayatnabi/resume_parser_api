class CreateResumes < ActiveRecord::Migration[8.0]
  def change
    create_table :resumes do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.text :skills
      t.text :experience
      t.text :education
      t.string :job_role

      t.timestamps
    end
  end
end

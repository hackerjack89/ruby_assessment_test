class Program < ApplicationRecord
  has_many :enrollments
  has_many :users, through: :enrollments
  has_many :teachers, through: :enrollments,
  foreign_key: :teacher_id, class_name: 'User'

end
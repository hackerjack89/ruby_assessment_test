class User < ApplicationRecord
  validate :validate_kind, on: :update

  enum :kind, {
    "student": 0,
    "teacher": 1,
    "student_teacher": 2
  }

  has_many :enrollments
  has_many :programs, through: :enrollments
  has_many :teaching_enrollments, foreign_key: :teacher_id, class_name: 'Enrollment' 
  has_many :teaching_programs, -> { distinct }, through: :teaching_enrollments, source: :program
  has_many :teachers, through: :enrollments do
    def favorites 
      where( { enrollments: { favorite: true } } )
    end
  end

  def ids 
    user_id
  end

  # users that have enrolled to same program

  def self.classmates(user)
    includes(:enrollments).where(
      enrollments: {
        program_id: user.programs
      }
    )
    .where.not(id: user.id).distinct
  end

  def validate_kind
    if kind_was == "teacher" and kind == "student" and not teaching_programs.empty?
      errors.add(:kind, "Kind can not be student because is teaching in at least one program")
    elsif kind_was == "student" and kind == "teacher" and not programs.empty?
      errors.add(:kind, "Kind can not be teacher because is studying in at least one program")
    end
  end
end

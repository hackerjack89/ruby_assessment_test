class User < ApplicationRecord
  before_update :validate_kind, :if => :kind_changed?

  enum :kind, {
    "student": 0,
    "teacher": 1,
    "student_teacher": 2
  }

  has_many :enrollments
  has_many :programs, through: :enrollments
  has_many :teachers, through: :enrollments do
    def favorites 
      where( { enrollments: { favorite: true } } )
    end
  end

  def ids 
    user_id
  end


  def self.classmates(user)
    joins(:enrollments).where(
      { 
        enrollments: {
          program_id: user.programs.collect(&:id) 
        }
      }
    )
    .where.not(
      {
        enrollments: {
          user_id: user.id
        }
      }
    ).distinct
  end

  def validate_kind
    # puts "$$$$$$$$$$$$$$$$$$$$$$$$ in before update callback $$$$$$$$$$"
    # puts "old kind_was: #{kind_was}, new kind is: #{kind}, enrollments not empty?: #{not enrollments.empty?}"
    # puts "printing user: name: #{self.name}, id:#{self.id}, kind:#{self.kind}"
    puts "Printing enrollments: #{Enrollment.where({teacher_id: id}).map(&:id)}"
    # puts "Printing programs: #{programs.map(&:id)}"
    if kind_was == "teacher" and kind == "student" and not Enrollment.where({teacher_id: id}).map(&:id).empty?
      puts "in student if"
      errors.add(:kind, "Kind can not be student because is teaching in at least one program")
      throw :abort
    elsif kind_was == "student" and kind == "teacher" and not programs.empty?
      puts 'in teacher if'
      errors.add(:kind, "Kind can not be teacher because is studying in at least one program")
      throw :abort
    end
  end
end

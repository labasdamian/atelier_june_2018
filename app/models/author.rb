class Author < ApplicationRecord
  def full_name
    self.firstname + ' ' + self.lastname
  end
end
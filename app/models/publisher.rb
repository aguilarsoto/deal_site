class Publisher < ActiveRecord::Base
  has_many   :advertisers
  belongs_to :parent, class_name: "Publisher"
  has_many   :publishers, foreign_key: :parent_id
  validates  :name, :uniqueness => true

  validate :parent_is_another_publisher

  delegate :name, :to => :parent, :prefix => true, :allow_nil => true
  delegate :theme, :to => :parent, :prefix => true, :allow_nil => true

  def parent_is_another_publisher
    if parent && parent == self
      errors.add :parent, " cannot be self"
    end
    true
  end

  def full_name
    parent_name ? "#{parent_name} #{name}" : name
  end
end

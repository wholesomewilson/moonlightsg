class Review < ActiveRecord::Base
  belongs_to :user
  after_create :update_solver_rating, if: ->(obj){ obj.rating_solver.present?}
  after_create :update_owner_rating, if: ->(obj){ obj.rating_owner.present?}

  def update_solver_rating
    User.find(user_id).update_rating_solver(rating_solver)
  end

  def update_owner_rating
    User.find(user_id).update_rating_owner(rating_owner)
  end
end

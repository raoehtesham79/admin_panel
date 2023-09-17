# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # Guest user

    if user.admin
      can :manage, :all # Admin can manage all resources
    else
      can :read, Post, user_id: user.id
      can :create, Post if user.persisted? 
      can :update, Post, user_id: user.id
      can :destroy, Post, user_id: user.id
    end
  end
end

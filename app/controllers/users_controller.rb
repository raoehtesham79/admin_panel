class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end  

  def destroy
    @user = User.find(params[:id])
    @user.posts.update_all(user_id: nil)
    @user.destroy
    create_audits_params(@user, 'destroy')
    redirect_to users_path, notice: "User was successfully deleted."
  end

  def update_role
    @user = User.find(params[:id])
    if @user.update(user_params)
      create_audits_params(@user, 'update_role')
      redirect_to users_path, notice: "User's role was successfully updated."
    else
      render :edit_role
    end
  end

  def create_new_role
    @user = User.new(user_params)
    @user.role = 'editor'
    if @user.save
      create_audits_params(@user, 'create_new_role')
      redirect_to users_path, notice: "User was successfully created."
    else
      render :new
    end
  end

  def get_new_role
    @user = User.new
  end

  def edit_role
    @user = User.find(params[:id])
  end
    
    
  private
    
  def user_params
    params.require(:user).permit(:role, :name, :email, :password, :password_confirmation)
  end

  def create_audits_params(user, action_name)
    audits_params =  {
      object_id: user.id,
      performed_by_id: current_user.id,
      performed_by: current_user.role,
      object_type: 'User',
      action_name: action_name,
      data: user
    }
    unless Audit.create(audits_params)
      self.errors.add(:audits, 'Unable to save audits')
    end
  end
end
  
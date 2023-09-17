class UsersController < ApplicationController
    before_action :authenticate_user!

    def index
        @users = User.all
    end

    def destroy
        @user = User.find(params[:id])
        @user.destroy
        get_audits_params(@user, 'destroy')
        redirect_to users_path, notice: "User was successfully deleted."
    end

    def update_role
        @user = User.find(params[:id])
        if @user.update(user_params)
          get_audits_params(@user, 'update_role')
          redirect_to users_path, notice: "User's role was successfully updated."
        else
          render :edit_role
        end
    end

    def edit_role
        @user = User.find(params[:id])
    end
      
      
    private
      
    def user_params
        params.require(:user).permit(:role)
    end

    def get_audits_params(user, action_name)
        audits_params =  {
          object_id: user.id,
          performed_by_id: current_user.id,
          performed_by: current_user.role,
          object_type: 'User',
          action_name: action_name,
          data: user_params
        }
        unless Audit.create(audits_params)
          self.errors.add(:audits, 'Unable to save audits')
        end
    end
end
  
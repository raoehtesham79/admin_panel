class PostsController < ApplicationController
  load_and_authorize_resource
  before_action :set_post, only: %i[ show edit update destroy ]

  def index
    if current_user.admin
      @posts = Post.all
    else
      @posts = Post.where(user_id: current_user.id)
    end
  end

  def show
    authorize! :show, @post
  end

  def new
    @post = Post.new
  end

  def edit
  end

  def dashboard
  end

  def create
    @user = current_user
    @post = Post.new(post_params)
    @post[:user_id] = @user.id
    @post.status = 'draft'
    respond_to do |format|
      if @post.save
        create_audits_params(@post, 'create')
        format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        create_audits_params(@post, 'update')
        format.html { redirect_to post_url(@post), notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy
    create_audits_params(@post, 'destroy')
    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  MethodConstants::GET_METHODS.each do |method_name|
    define_method "#{method_name}" do
      @posts = Post.where(status: "#{method_name}")
    end
  end
  
  MethodConstants::ACTION_METHOD.each do |method_name|
    define_method "#{method_name}" do
        @post = Post.find(params[:id])
        if method_name != 'approve'
          if @post.update(status: "#{method_name}ed")
           redirect_to "/posts/#{method_name}ed", notice: "Post has been '#{method_name}ed'."
          else
            redirect_to "/posts/#{method_name}ed", alert: "Failed to '#{method_name}' the post."
          end
        else
          if @post.update(status: "#{method_name}d")
            redirect_to "/posts/#{method_name}d", notice: "Post has been '#{method_name}d'."
           else
             redirect_to "/posts/#{method_name}d", alert: "Failed to '#{method_name}' the post."
           end
        end
    end
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :description, :image)
    end

    def create_audits_params(post, action_name)
      audits_params =  {
        object_id: post.id,
        performed_by_id: current_user.id,
        performed_by: current_user.role,
        object_type: 'Post',
        action_name: action_name,
        data: post
      }
      unless Audit.create(audits_params)
        self.errors.add(:audits, 'Unable to save audits')
      end
    end
end

class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update]
  before_filter :correct_user,   only: [:edit, :update]

  def show
  	@user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Rtastic! Your (such a nice) profile has been created!"
      redirect_to @user
      # Handle a successful save.
    else
      render 'new'
    end
  end

  def edit
    #@user = User.find(params[:id])    # tohle uz dela current user
  end

  def update
    #@user = User.find(params[:id])     # tohle uz dela current user
    if @user.update_attributes(params[:user])
      # handle a successful update
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def index
    @users = User.all
  end

  private

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
end

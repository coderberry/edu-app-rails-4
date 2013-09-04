class Admin::UsersController < ApplicationController
  before_filter :authorize_admin

  def index
    @users = User.page(params[:page]).order('created_at DESC')
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end
end

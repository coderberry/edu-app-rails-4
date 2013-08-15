class CartridgesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    render json: current_user.cartridges
  end

  def show
    render json: @review
  end

  def create
    
  end

  def update
    
  end

  def destroy
    
  end
end

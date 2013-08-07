class StaticController < ApplicationController
  
  def tutorials
    @page = params[:page] || "canvas"
  end

  def docs
    @section = params[:section] || "basics"
    @page    = params[:page]    || "index"
  end

end

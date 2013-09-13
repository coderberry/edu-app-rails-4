class StaticController < ApplicationController
  
  def tutorials
    @active_tab = 'tutorials'
    @page = params[:page] || "canvas"
  end

  def docs
    @active_tab = 'docs'
    @section = params[:section] || "basics"
    @page    = params[:page]    || "index"
  end

  def suggest
    @active_tab = 'suggest'
  end

end

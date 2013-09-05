class AdminController < ApplicationController
  before_filter :authorize_admin
  before_action :set_active_tab

  private

  def set_active_tab
    @active_tab = 'admin'
  end
end

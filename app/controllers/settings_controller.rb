class SettingsController < ApplicationController
  # layout "settings"
  before_action :authorize
  # before_action :set_active_tab

  # protected

  # def set_active_tab
  #   @active_tab = 'settings'
  # end
end

class XmlBuilderController < ApplicationController
  before_filter :authorize

  def index
    @active_tab = 'my_stuff'
  end
end

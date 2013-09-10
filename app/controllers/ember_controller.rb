class EmberController < ApplicationController
  layout 'ember'
  
  def app_list
    @env = {
      categories: Tag.categories.map {|c| { id: c.id, name: c.name }},
      education_levels: Tag.education_levels.map {|c| { id: c.id, name: c.name }},
      platforms: [
        { id: 'canvas', name: 'Canvas' },
        { id: 'blackboard', name: 'Blackboard' },
        { id: 'desire2learn', name: 'Desire2Learn' },
        { id: 'other', name: 'Other Platform' }
      ]
    }
  end
end

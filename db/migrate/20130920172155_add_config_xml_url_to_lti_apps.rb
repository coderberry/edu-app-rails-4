class AddConfigXmlUrlToLtiApps < ActiveRecord::Migration
  def change
    add_column :lti_apps, :config_xml_url, :string, limit: 1000
  end
end

require 'spec_helper'

describe "Configurations" do
  describe "GET /tools/xml_builder", type: :feature do
    before :each do
      @user = User.create(
        is_registering: true,
        name: 'Foo Bar',
        email: 'foo@example.com',
        password: 'secret',
        password_confirmation: 'secret')
      visit login_path
      fill_in 'email', with: 'foo@example.com'
      fill_in 'password', with: 'secret'
      click_button 'Login'
      expect(page).to have_content 'Logged in!'
      visit xml_builder_path
      expect(page).to have_content 'My Saved Configurations'
    end

    it "create from scratch with missing data", js: true do
      click_button 'Create'
      click_link 'From Scratch'

      expect(page).to have_content 'Configure XML'
      click_button 'Save'
      expect(page).to have_content 'Please correct the fields below'
      expect(page).to have_content "can't be blank"
      expect(page).to have_content 'must be one word, all lowercase with underscores (e.g. my_app)'
      expect(page).to have_content 'must be a valid URL (with http:// or https://)'
    end

    it "create from scratch", js: true do
      click_button 'Create'
      click_link 'From Scratch'

      expect(page).to have_content 'Configure XML'
      fill_in 'name', with: 'Vimeo'
      expect(page).to have_content '<blti:title>Vimeo</blti:title>'
      fill_in 'tool_id', with: 'test_vimeo'
      expect(page).to have_content '<lticm:property name="tool_id">test_vimeo</lticm:property>'
      fill_in 'launch_url', with: 'http://vimeo-lti.herokuapp.com'
      expect(page).to have_content '<blti:launch_url>http://vimeo-lti.herokuapp.com</blti:launch_url>'
      fill_in 'description', with: 'Test Description'
      expect(page).to have_content '<blti:description>Test Description</blti:description>'
      fill_in 'icon_url', with: 'http://vimeo-lti.herokuapp.com/images/vimeo_icon.png'
      expect(page).to have_content '<blti:icon>http://vimeo-lti.herokuapp.com/images/vimeo_icon.png</blti:icon>'
      fill_in 'text', with: 'Vimeo'
      expect(page).to have_content '<lticm:property name="text">Vimeo</lticm:property>'
      fill_in 'default_width', with: '500'
      fill_in 'default_height', with: '500'
      click_button 'Save'

      expect(page).to have_content 'Your cartridge has been saved!'
    end

    it "create from url with an invalid URL", js: true do
      click_button 'Create'
      click_link 'From XML Config URL'

      within(:css, "#import-panel") do
        fill_in 'import_url', with: 'foo'
        click_button 'Import'
      end
    
      expect(page).to have_content 'URL does not point to valid XML'
    end

    it "create from url", js: true do
      click_button 'Create'
      click_link 'From XML Config URL'

      within(:css, "#import-panel") do
        fill_in 'import_url', with: 'http://vimeo-lti.herokuapp.com/lti/config.xml'
        click_button 'Import'
      end
    
      expect(page).to have_content '<blti:title>Vimeo</blti:title>'
      expect(page).to have_content '<blti:description>Vimeo LTI application</blti:description>'
      expect(page).to have_content '<blti:launch_url>http://vimeo-lti.herokuapp.com/lti/launch</blti:launch_url>'
      expect(page).to have_content '<lticm:property name="text">Vimeo</lticm:property>'
      expect(page).to have_content '<lticm:property name="selection_width">500</lticm:property>'
      expect(page).to have_content '<lticm:property name="selection_height">500</lticm:property>'
    end

    it "create from pasted xml with invalid XML", js: true do
      click_button 'Create'
      click_link 'Paste XML Code'

      within(:css, "#create-from-xml-panel") do
        fill_in 'pasted_xml', with: '<hi></hi>'
        click_button 'Create'
      end

      expect(page).to have_content 'Invalid XML'
    end

    it "create from pasted xml", js: true do
      click_button 'Create'
      click_link 'Paste XML Code'

      within(:css, "#create-from-xml-panel") do
        fill_in 'pasted_xml', with: KITCHEN_SINK
        click_button 'Create'
      end
    
      expect(page).to have_content '<blti:title>Kitchen Sink</blti:title>'
      expect(page).to have_content '<blti:description>This is an example LTI configuration which has every option selected for testing purposes.</blti:description>'
      expect(page).to have_content '<blti:launch_url>https://example.com/kitchensink</blti:launch_url>'
      expect(page).to have_content '<blti:icon>https://example.com/icon.ico</blti:icon>'
      expect(page).to have_content '<lticm:property name="another_custom_field">{{opt_w_def}}</lticm:property>'
      expect(page).to have_content '<lticm:property name="req_w_def">{{req_w_def}}</lticm:property>'
      expect(page).to have_content '<lticm:property name="req_wo_def">{{req_wo_def}}</lticm:property>'
      expect(page).to have_content '<lticm:property name="tool_id">kitchen_sink</lticm:property>'
      expect(page).to have_content '<lticm:property name="icon_url">https://example.com/icon.ico</lticm:property>'
      expect(page).to have_content '<lticm:property name="domain">example.com</lticm:property>'
      expect(page).to have_content '<lticm:property name="privacy_level">name_only</lticm:property>'
      expect(page).to have_content '<lticm:property name="text">Click Me</lticm:property>'
      expect(page).to have_content '<lticm:property name="enabled">true</lticm:property>'
      expect(page).to have_content '<lticm:property name="text">Custom Launch Link</lticm:property>'
      expect(page).to have_content '<lticm:property name="icon_url">http://example.com/custom_icon.png</lticm:property>'
      expect(page).to have_content '<lticm:property name="selection_width">600</lticm:property>'
      expect(page).to have_content '<lticm:property name="selection_height">600</lticm:property>'
      expect(page).to have_content '<lticm:property name="url">https://example.com/kitchensink_override</lticm:property>'
      expect(page).to have_content '<lticm:property name="url">https://example.com/user_nav</lticm:property>'
    end
  end
end

require 'spec_helper'

describe "Cartridges" do

  let(:user) { FactoryGirl.create(:user) }

  let(:valid_xml) { xml = <<-EOS
<cartridge_basiclti_link
  xmlns='http://www.imsglobal.org/xsd/imslticc_v1p0'
  xmlns:blti='http://www.imsglobal.org/xsd/imsbasiclti_v1p0'
  xmlns:lticm='http://www.imsglobal.org/xsd/imslticm_v1p0'
  xmlns:lticp='http://www.imsglobal.org/xsd/imslticp_v1p0'
  xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation='http://www.imsglobal.org/xsd/imslticc_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticc_v1p0.xsd http://www.imsglobal.org/xsd/imsbasiclti_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imsbasiclti_v1p0.xsd http://www.imsglobal.org/xsd/imslticm_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticm_v1p0.xsd http://www.imsglobal.org/xsd/imslticp_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticp_v1p0.xsd'>
  <blti:title>LTI App</blti:title>
  <blti:description/>
  <blti:icon/>
  <blti:launch_url>http:&#x2F;&#x2F;example.com&#x2F;lti</blti:launch_url>
  <blti:custom>
    <property/>
  </blti:custom>
  <blti:extensions platform='canvas.instructure.com'>
    <lticm:property name='tool_id'></lticm:property>
    <lticm:property name='privacy_level'>anonymous</lticm:property>
    <lticm:property name='domain'></lticm:property>
    <lticm:property name='text'></lticm:property>
    <lticm:property name='selection_width'></lticm:property>
    <lticm:property name='selection_height'></lticm:property>
    <options/>
  </blti:extensions>
  <cartridge_bundle identifierref='BLTI001_Bundle'/>
  <cartridge_icon identifierref='BLTI001_Icon'/>
</cartridge_basiclti_link>
      EOS
  }

  before do
    @cartridge_1 = user.cartridges.create_from_xml(valid_xml)
    @cartridge_2 = user.cartridges.create_from_xml(valid_xml)
    @cartridge_3 = user.cartridges.create_from_xml(valid_xml)
    @token = user.current_api_key.access_token
  end

  after do
    session[:user_id] = nil
  end

  describe "GET /api/v1/cartridges" do
    it "gets list" do
      get "/api/v1/cartridges?token=#{@token}"
      response.status.should be(200)
      json = JSON.parse(response.body)
      json['cartridges'].size.should == 3
    end
  end

  describe "GET /api/v1/cartridges/:uid" do
    it "gets list" do
      get "/api/v1/cartridges/#{@cartridge_1.uid}"
      json = JSON.parse(response.body)
      json['cartridge']['uid'].should eq(@cartridge_1.uid)
      json['cartridge']['name'].should eq(@cartridge_1.name)
    end
  end
end

require 'spec_helper'

describe Cartridge do

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

  it "#generate_uid" do
    cartridge = Cartridge.new
    cartridge.send(:generate_uid)
    cartridge.uid.should match /\S{15}/
  end

  describe "create_from_xml" do
    it "with invalid XML" do
      cartridge = user.cartridges.create_from_xml('INVALID XML')
      cartridge.should be_nil
    end

    it "with valid XML" do
      cartridge = user.cartridges.create_from_xml(valid_xml)
      cartridge.name.should == 'LTI App'
      cartridge.new_record?.should be_false
      cartridge.user.id.should == user.id
    end
  end

  describe "create_from_url" do
    let(:read) { double('open') }

    it "with an invalid URL" do
      cartridge = user.cartridges.create_from_url('foo')
      cartridge.should be_nil
    end

    it "with URL to bad XML" do
      read.stub(:read).and_return('NOT VALID XML')
      Cartridge.should_receive(:open).and_return(read)

      cartridge = user.cartridges.create_from_url('http://example.com/foo.xml')
      cartridge.should be_nil
    end

    it "with URL to valid XML" do
      read.stub(:read).and_return(valid_xml)
      Cartridge.should_receive(:open).and_return(read)

      cartridge = user.cartridges.create_from_url('http://example.com/foo.xml')
      cartridge.name.should == 'LTI App'
      cartridge.new_record?.should be_false
      cartridge.user.id.should == user.id
    end
  end
end

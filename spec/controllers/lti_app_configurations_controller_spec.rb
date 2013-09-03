require 'spec_helper'

describe LtiAppConfigurationsController do
  before :each do
    @current_user = User.new.tap {|u| u.id = 27 } 
    controller.stub!(:current_user).and_return(@current_user)
  end

  describe "POST 'create_from_xml'" do
    it "returns a cartridge as json" do
      xml = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<cartridge_basiclti_link xmlns="http://www.imsglobal.org/xsd/imslticc_v1p0"
    xmlns:blti = "http://www.imsglobal.org/xsd/imsbasiclti_v1p0"
    xmlns:lticm ="http://www.imsglobal.org/xsd/imslticm_v1p0"
    xmlns:lticp ="http://www.imsglobal.org/xsd/imslticp_v1p0"
    xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation = "http://www.imsglobal.org/xsd/imslticc_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticc_v1p0.xsd
    http://www.imsglobal.org/xsd/imsbasiclti_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imsbasiclti_v1p0.xsd
    http://www.imsglobal.org/xsd/imslticm_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticm_v1p0.xsd
    http://www.imsglobal.org/xsd/imslticp_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticp_v1p0.xsd">
    <blti:title>CourseSmart</blti:title>
    <blti:description>&lt;p&gt;Provides faculty and students with direct access to their personalized CourseSmart Bookshelf and individual eTextbooks from within the environment they use daily.&lt;/p&gt;
&lt;p&gt;&lt;a href=&quot;https://googledrive.com/host/0B5ghu5Vrh0j7X3FCOERVQ1dLSms/coursesmart.png&quot; target=&quot;_blank&quot;&gt;&lt;img style=&quot;padding: 10px; float: left;&quot; src=&quot;https://googledrive.com/host/0B5ghu5Vrh0j7X3FCOERVQ1dLSms/coursesmart.png&quot; alt=&quot;CourseSmart Bookshelf&quot; width=&quot;300&quot; height=&quot;214&quot; /&gt;&lt;/a&gt;&lt;/p&gt;
&lt;p&gt;Students benefit from search within a single book or across an entire stack; highlighting and note-taking; cut and paste as well as email sections, notes and highlighted text; selective printing; and page fidelity and preservation.&lt;/p&gt;
&lt;p&gt;Faculty benefit from the Faculty Instant Access Program to streamline discovery, evaluation and adoption of course materials with single-sign-on access to the CourseSmart catalog. Faculty can embed digital learning materials as well as deep link to specific sections or pages.&lt;/p&gt;
&lt;p&gt;Click the Support link located on this page to contact CourseSmart for configuration assistance.&lt;/p&gt;</blti:description>
    <blti:icon>http://www.edu-apps.org/tools/coursesmart/icon.png</blti:icon>
      <blti:launch_url>asdfasdf</blti:launch_url>
    <blti:extensions platform="canvas.instructure.com">
      <lticm:property name="tool_id">coursesmart</lticm:property>
      <lticm:property name="privacy_level">public</lticm:property>
    </blti:extensions>
    <cartridge_bundle identifierref="BLTI001_Bundle"/>
    <cartridge_icon identifierref="BLTI001_Icon"/>
</cartridge_basiclti_link>  
      EOS
      post 'create_from_xml', { xml: xml }
      response.should be_success
      json = JSON.parse(response.body)
      json['lti_app_configuration']['uid'].should =~ /\S{15}/
      json['lti_app_configuration']['user_id'].should == 27
      
      config = JSON.parse(json['lti_app_configuration']['config'])
      config['title'].should == 'CourseSmart'
    end
  end

end

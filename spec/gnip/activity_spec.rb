require "rexml/document"
require File.dirname(__FILE__) + '/../spec_helper'

describe Gnip::Activity do
  setup do
    @sample_activity = {
      :at                 => "2008-07-02T11:16:16+00:00",
      :action             => "post",
      :activityID         => "yk994589klsl",
      :URL                => "http://www.gnipcentral.com",
      :source             => [{"source" => "web"}],
      :sources            => [{"source" => "web"},{"source" => "sms"}],
                          
      :keyword            => [{"keyword" => "ping"}],
      :keywords           => [{"keyword" => "ping"},{"keyword" => "pong"}],
      :place              => [Gnip::Place.new("45.256 -71.92", nil, nil, nil, nil, nil)],
      :places             => [Gnip::Place.new("45.256 -71.92", nil, nil, nil, nil, nil), Gnip::Place.new("22.778 -54.998", "5280", "3", "City", "Boulder", nil), Gnip::Place.new("77.900 - 23.998")],
      :actor              => [{"actor" => "Joe", "metaURL" => "http://www.gnipcentral.com/users/joe", "uid" => "1222"}],
      :actors             => [{"actor" => "Joe", "metaURL" => "http://www.gnipcentral.com/users/joe", "uid" => "1222"},
                                {"actor" => "Bob", "metaURL" => "http://www.gnipcentral.com/users/bob"},
                                {"actor" => "Susan", "uid" => "1444"}],
      :destinationURL     => [{"destinationURL" => "http://somewhere.com", "metaURL" => "http://somewhere.com/someplace"}],
      :destinationURLs    => [{"destinationURL" => "http://somewhere.com"}, 
                              {"metaURL" => "http://somewhere.com/someplace"},
                              {"destinationURL" => "http://flickr.com"}],
      :tag                => [{"tag" => "horses", "metaURL" => "http://gnipcentral.com/tags/horses"}],
      :tags               => [{"tag" => "horses","metaURL" => "http://gnipcentral.com/tags/horses"},
                              {"tag" => "cows"}],
      :to                 => [{"to" => "Mary", "metaURL" => "http://gnipcentral.com/users/mary"}],
      :tos                => [{"to" => "Mary", "metaURL" => "http://gnipcentral.com/users/mary"},
                              {"to" => "James"}],
      :regardingURL       => [{"regardingURL" => "http://blogger.com/users/posts/mary", "metaURL" => "http://blogger.com/users/mary"}],
      :regardingURLs      => [{"regardingURL" => "http://blogger.com/users/posts/mary", "metaURL" => "http://blogger.com/users/mary"},
                              {"regardingURL" => "http://blogger.com/users/posts/james"}],
      :payload            => Gnip::Payload.new("raw"),
      :payloads           => Gnip::Payload.new("raw", "title", "body", [{"mediaURL"=>"http://www.flickr.com/tour", "type" => "image", "mimeType" => "image/png"}, {"mediaURL" => "http://www.gnipcentral.com/login", "type" => "movie", "mimeType" => "video/quicktime"}])
    }
    @sa = @sample_activity
  end
  
  it 'should correctly convert to xml' do
    sa = @sa
    expected_xml = File.read('./spec/gnip/samples/activity.xml')
    a = Gnip::Activity.new(sa[:actor], sa[:action], sa[:at], sa[:URL], sa[:to], sa[:regardingURL], sa[:source], sa[:tag], nil, sa[:destinationURL], sa[:keyword], nil, sa[:activityID])
    a.to_xml.should == expected_xml
  end
  
  it 'should generate proper xml when optional fields are all nil' do
    expected_xml = File.read('./spec/gnip/samples/activity_only_required.xml')
    a = Gnip::Activity.new(nil, @sa[:action], @sa[:at], nil, nil, nil, nil, nil, nil, nil, nil, nil)
    a.to_xml.should == expected_xml
  end
  
  it 'should correctly convert with place' do
    sa = @sa
    expected_xml = File.read('./spec/gnip/samples/activity_with_place.xml')
    a = Gnip::Activity.new(sa[:actor], sa[:action], sa[:at], sa[:URL], sa[:to], sa[:regardingURL], sa[:source], sa[:tag], nil, sa[:destinationURL], sa[:keyword], sa[:place])
    a.to_xml.should == expected_xml
  end
  
  it 'should correctly convert with payload' do
    sa = @sa
    expected_xml = File.read('./spec/gnip/samples/activity_with_payload.xml')
    
    # Need this here because raw_value seems to vary its output for the same source
    insert_current_payload_raw(expected_xml)
    
    a = Gnip::Activity.new(sa[:actor], sa[:action], sa[:at], sa[:URL], sa[:to], sa[:regardingURL], sa[:source], sa[:tag], sa[:payload], sa[:destinationURL], sa[:keyword], sa[:place])
    a.to_xml.should == expected_xml
  end
  
  it 'should correctly handle unbounded values' do
    sa = @sa
    expected_xml = File.read('./spec/gnip/samples/activity_without_bounds.xml')
    a = Gnip::Activity.new(sa[:actors], sa[:action], sa[:at], sa[:URL], sa[:tos], sa[:regardingURLs], sa[:sources], sa[:tags], nil, sa[:destinationURLs], sa[:keywords], nil)
    a.to_xml.should == expected_xml
  end
  
  it 'should correctly handle unbounded place' do
    sa = @sa
    expected_xml = File.read('./spec/gnip/samples/activity_with_place_wo_bounds.xml')
    a = Gnip::Activity.new(sa[:actors], sa[:action], sa[:at], sa[:URL], sa[:tos], sa[:regardingURLs], sa[:sources], sa[:tags], nil, sa[:destinationURLs], sa[:keywords], sa[:places])
    a.to_xml.should == expected_xml
  end
  
  it 'should correctly handle unbounded mediaURLs in Payload' do
    sa = @sa
    expected_xml = File.read('./spec/gnip/samples/activity_with_unbounded_media_urls.xml')
    
    insert_current_payload_raw(expected_xml)
    
    a = Gnip::Activity.new(sa[:actors], sa[:action], sa[:at], sa[:URL], sa[:tos], sa[:regardingURLs], sa[:sources], sa[:tags], sa[:payloads], sa[:destinationURLs], sa[:keywords], sa[:places])
    a.to_xml.should == expected_xml
  end
  
  it 'should correctly convert valid XML back into an Activity' do
    xml_src = File.read('./spec/gnip/samples/activity.xml')
    act = Gnip::Activity.from_xml(xml_src)
    
    act.at.should           == @sa[:at]
    act.action.should       == @sa[:action]
    act.activity_id.should  == @sa[:activityID]
    act.url.should          == @sa[:URL]
    act.sources.should      == @sa[:source]
    act.keywords.should     == @sa[:keyword]
    act.actors.should       == @sa[:actor]
    act.destinationURLs.should == @sa[:destinationURL]
    act.tags.should         == @sa[:tag]
    act.tos.should          == @sa[:to]
    act.regardingURLs.should   == @sa[:regardingURL]
  end
  
  it 'should correctly convert XML with nulls back into a valid activity' do
    xml_src = File.read('./spec/gnip/samples/activity_only_required.xml')
    act = Gnip::Activity.from_xml(xml_src)
    
    act.at.should           == @sa[:at]
    act.action.should       == @sa[:action]
    act.activity_id.should  == nil
    act.url.should          == nil
    act.sources.should      == nil
    act.keywords.should     == nil
    act.actors.should       == nil
    act.destinationURLs.should == nil
    act.tags.should         == nil
    act.tos.should          == nil
    act.regardingURLs.should   == nil
  end

  it 'should correctly convert XML with place back into a valid activity' do
    xml_src = File.read('./spec/gnip/samples/activity_with_place.xml')
    act = Gnip::Activity.from_xml(xml_src)
    
    act.places.should == @sa[:place]
  end

  it 'should correctly convert XML with payload back into a valid activity' do    
    xml_src = File.read('./spec/gnip/samples/activity_with_payload.xml')
    insert_current_payload_raw(xml_src)
    act = Gnip::Activity.from_xml(xml_src)
    act.payload.should == @sa[:payload]
  end
  
  it 'should correctly convert XML with unbounds back into a valid activity' do
    xml_src = File.read('./spec/gnip/samples/activity_without_bounds.xml')
    act = Gnip::Activity.from_xml(xml_src)
    
    act.sources.should      == @sa[:sources]
    act.keywords.should     == @sa[:keywords]
    act.actors.should       == @sa[:actors]
    act.destinationURLs.should == @sa[:destinationURLs]
    act.tags.should         == @sa[:tags]
    act.tos.should          == @sa[:tos]
    act.regardingURLs.should   == @sa[:regardingURLs]
    
  end
  
  it 'should correctly convert XML with multiple places back into a valid activity' do
    xml_src = File.read('./spec/gnip/samples/activity_with_place_wo_bounds.xml')
    act = Gnip::Activity.from_xml(xml_src)
    act.places.should == @sa[:places]
    
  end
  
  it 'should correctly convert XML with multiple media urls back into a valid activity' do
    xml_src = File.read('./spec/gnip/samples/activity_with_unbounded_media_urls.xml')
    insert_current_payload_raw(xml_src, @sa[:payloads])
    
    act = Gnip::Activity.from_xml(xml_src)
    act.payload.should == @sa[:payloads]
  end

end
describe Gnip::Activity do
  it 'should known when another activity is equal to itself' do
    a = Gnip::Activity::Builder.new("added_friend", Time.parse('2007-05-23T00:53:11Z')).actor("joe").build()
    b = Gnip::Activity::Builder.new("added_friend", Time.parse('2007-05-23T00:53:11Z')).actor("joe").build()

    (a == b).should be_true
    a.eql?(b).should be_true
  end

  it 'should know when another activity is not equal to itself' do
    a = Gnip::Activity::Builder.new("added_friend", Time.parse('2007-05-23T00:53:11Z')).actor("joe").build()
    b = Gnip::Activity::Builder.new("added_friend", Time.parse('2008-05-23T00:53:11Z')).actor("joe").build()

    (a == b).should be_false
    a.eql?(b).should be_false
  end

  describe '.from_xml(activity_xml)' do

    it 'should have the correct activities' do
      activity_xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<activities publisher="test">
    <activity>
        <at>2007-05-23T00:53:11Z</at>
        <action>added_friend</action>
        <actor>joe</actor>        
    </activity>
    <activity>
        <at>2008-08-23T00:53:11Z</at>
        <action>added_application</action>
        <actor>jane</actor>
    </activity>
    <activity>
        <at>2008-08-23T00:53:11Z</at>
        <action>added_application</action>
        <actor>joe</actor>
    </activity>
</activities>
XML

      publisher, activities = Gnip::Activity.list_from_xml(activity_xml)
      publisher.name.should == 'test'
      activities.should have(3).items
      activities.should include(Gnip::Activity::Builder.new("added_friend", Time.parse('2007-05-23T00:53:11Z')).actor("joe").build())
      activities.should include(Gnip::Activity::Builder.new("added_application", Time.parse('2008-08-23T00:53:11Z')).actor("jane").build())
      activities.should include(Gnip::Activity::Builder.new("added_application", Time.parse('2008-08-23T00:53:11Z')).actor("joe").build())

    end

    it 'should handle activities xml without activities' do
      activity_xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<activities>
</activities>
XML

      Gnip::Activity.from_xml(activity_xml).should be_nil
    end
  end

  describe '.list_to_xml(activities)' do
    it 'should marshal a list of activities to xml' do
      activity_list = []
      activity_list << Gnip::Activity::Builder.new("added_friend", Time.parse('2007-05-23T00:53:11Z')).actor("joe").build()
      activity_list << Gnip::Activity::Builder.new("added_application", Time.parse('2008-05-23T00:53:11Z')).actor("jane").build()

      document = REXML::Document.new Gnip::Activity.list_to_xml(activity_list)

      activity_list.each_with_index do |activity, index|
        activity_element = document.elements["activities/*[#{(index + 1).to_s}]"]
        activity_element.elements["at"].text.should ==  activity.at
        activity_element.elements["action"].text.should == activity.action
        activity_element.elements["actor"].text.should == activity.actor
      end
    end

    it 'should marshal an empty list of activities to xml' do
      activity_list = []

      Gnip::Activity.list_to_xml(activity_list).should == <<XML
<?xml version="1.0" encoding="UTF-8"?>
<activities>
</activities>
XML
    end
  end

  it "should marshall to xml correctly" do
    now = Time.now
    activity = Gnip::Activity::Builder.new('upload', now).actor('bob').build()

    document = REXML::Document.new activity.to_xml
    document.elements["activity/at"].text.should == activity.at
    document.elements["activity/action"].text.should == activity.action
    document.elements["activity/actor"].text.should == activity.actor
  end

  it "should marshall to xml correctly with to" do
    now = Time.now
    activity = Gnip::Activity::Builder.new('upload', now).actor('bob').to('to').build()

    document = REXML::Document.new activity.to_xml
    document.elements["activity/at"].text.should == activity.at
    document.elements["activity/action"].text.should == activity.action
    document.elements["activity/actor"].text.should == activity.actor
    document.elements.each("activity/to") { |element| element.text.should == activity.to(0) }
  end

  it "should marshall to xml correctly with payload" do
    now = Time.now
    payload = Gnip::Payload::Builder.new("raw").body("body").build()
    activity = Gnip::Activity::Builder.new('upload', now).actor('bob').to('to').payload(payload).build()

    document = REXML::Document.new activity.to_xml
    document.elements["activity/at"].text.should == activity.at
    document.elements["activity/action"].text.should == activity.action
    document.elements["activity/actor"].text.should == activity.actor
    document.elements.each("activity/to") { |element| element.text.should == activity.to(0) }
    document.elements["activity/payload/body"].text.should == activity.payload.body
    document.elements["activity/payload/raw"].text.should == activity.payload.raw_value

  end

  it "should unmarshall from xml correctly" do
    now = Time.now
    activity_xml = "<activity><at>#{now.xmlschema}</at><actor>bob</actor><action>upload</action></activity>"

    activity = Gnip::Activity.from_xml(activity_xml)

    activity.at.should == now.xmlschema
    activity.actor.should == 'bob'
    activity.action.should == 'upload'
    activity.payload.should be_nil
  end

  it "should unmarshal from xml correctly with to" do
    now = Time.now
    activity_xml = "<activity><at>#{now.xmlschema}</at><actor>bob</actor><action>upload</action><to>to</to></activity>"

    activity = Gnip::Activity.from_xml(activity_xml)

    activity.at.should == now.xmlschema
    activity.action.should == 'upload'
    activity.actor.should == 'bob'
    activity.to(0).should == 'to'
    activity.payload.should be_nil
  end

  it "should unmarshal from xml correctly with all fields" do
    now = Time.now
    activity_xml = '<activity><at>2007-05-23T00:53:11Z</at><action>added_friend</action><actor>joe</actor><to>jane</to><regardingURL>def456</regardingURL><tag>dogs</tag><tag>cats</tag><source>web</source></activity>'

    activity = Gnip::Activity.from_xml(activity_xml)

    activity.at.should == '2007-05-23T00:53:11Z'
    activity.action.should == 'added_friend'
    activity.actors.should == ['joe']
    activity.to(0).should == 'jane'
    activity.regardingURLs.should == ['def456']
    activity.sources.should == ['web']
    activity.tags[0].should == 'dogs'
    activity.tags[1].should == 'cats'
    activity.payload.should be_nil

  end

end

def insert_current_payload_raw(expected_xml, src=@sa[:payload])
  expected_xml.gsub!('<<raw-value>>',src.raw_value.chomp)
end
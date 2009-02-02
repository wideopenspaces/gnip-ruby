require File.dirname(__FILE__) + '/../spec_helper'

describe Gnip::Rule do
  it "should create rule with correct xml format" do
    rule = Gnip::Rule.new('actor', 'jud')

=begin
  Expected XML
<?xml version="1.0" encoding="UTF-8"?>
<rule type="actor">jud</rule>
=end
    rule.to_xml.should include("<rule")
    rule.to_xml.should include("type=\"actor\"")
    rule.to_xml.should include(">jud</rule")  
  end

   it 'should unmarshal from xml correctly' do
    rule_xml =  <<HEREDOC
<?xml version="1.0" encoding="UTF-8"?>
<rule type="actor">jud</rule>
HEREDOC
    rule = Gnip::Rule.from_xml(rule_xml)
    rule.type.should == 'actor'
    rule.value.should == 'jud'
   end
end

# Depend on rack/lilypad/rails to set ENV['RACK_ENV'] from this
ENV['RAILS_ENV'] = 'production'

require File.expand_path("#{File.dirname(__FILE__)}/../require")
Require.spec_helper!

Spec::Runner.configure do |config|
end

def stub_net_http
  @http_ok = Net::HTTPOK.new(nil, nil, nil)
  @http = mock(:http)
  @http.stub!(:read_timeout=)
  @http.stub!(:open_timeout=)
  @http.stub!(:post).and_return @http_ok
  Net::HTTP.stub!(:start).and_yield(@http)
  Net::HTTP.stub!(:post_form).and_return(@http_ok)
end

def validate_xml
  xsd = Nokogiri::XML::Schema(File.read(SPEC + '/fixtures/hoptoad_2_0.xsd'))
  doc = Nokogiri::XML(Lilypad::Hoptoad::XML.last_request)
  
  errors = xsd.validate(doc)
  errors.each do |error|
    puts error.message
  end
  errors.length.should == 0
end

class TestError < RuntimeError
end
require 'spaceship'
require 'webmock/rspec'

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

WebMock.disable_net_connect!

ENV["DELIVER_USER"] = "spaceship@krausefx.com"
ENV["DELIVER_PASSWORD"] = "so_secret"

def read_fixture_file(filename)
  File.read(File.join('spec', 'fixtures', filename))
end

RSpec.configure do |config|

  config.before(:each) do

    stub_request(:get, "https://developer.apple.com/devcenter/ios/index.action").
      to_return(:status => 200, :body => read_fixture_file("landing_page.html"), :headers => {})

    stub_request(:post, "https://idmsa.apple.com/IDMSWebAuth/authenticate").
      with(:body => {"accountPassword"=>"so_secret", "appIdKey"=>"2089349823abbababa98239839", "appleId"=>"spaceship@krausefx.com"},
           :headers => {'Content-Type'=>'application/x-www-form-urlencoded'}).
      to_return(:status => 200, :body => "", :headers => {'Set-Cookie' => "myacinfo=abcdef;"})

    stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/listTeams.action').
      with(:body => {}, :headers => {'Cookie' => 'myacinfo=abcdef;'}).
      to_return(:status => 200, :body => read_fixture_file('listTeams.action.json'), :headers => {'Content-Type' => 'application/json'})

    stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/listAppIds.action').
      with(:body => {:teamId => 'XXXXXXXXXX', :pageSize => "500", :pageNumber => "1", :sort => 'name=asc'}, :headers => {'Cookie' => 'myacinfo=abcdef;'}).
      to_return(:status => 200, :body => read_fixture_file('listApps.action.json'), :headers => {'Content-Type' => 'application/json'})

    stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/ios/device/listDevices.action').
      with(:body => {:teamId => 'XXXXXXXXXX', :pageSize => "500", :pageNumber => "1", :sort => 'name=asc'}, :headers => {'Cookie' => 'myacinfo=abcdef;'}).
      to_return(:status => 200, :body => read_fixture_file('listDevices.action.json'), :headers => {'Content-Type' => 'application/json'})

    stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/certificate/listCertRequests.action").
       with(:body => {"pageNumber"=>"1", "pageSize"=>"500", "sort"=>"certRequestStatusCode=asc", "teamId"=>"XXXXXXXXXX", "types"=>"5QPB9NHCEI,R58UK2EWSO,9RQEK7MSXA,LA30L5BJEU,BKLRAVXMGM,3BQKVH9I2X,Y3B2F3TYSI,3T2ZP62QW8,E5D663CMZW,4APLUP237T"},
            :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'Cookie'=>'myacinfo=abcdef;'}).
       to_return(:status => 200, :body => read_fixture_file('listCertRequests.action.json'), :headers => {'Content-Type' => 'application/json'})

    stub_request(:get, "https://developer.apple.com/account/ios/certificate/certificateContentDownload.action?displayId=XC5PH8DAAA&type=R58UK2EAAA").
         with(:headers => {'Cookie'=>'myacinfo=abcdef'}).
         to_return(:status => 200, :body => read_fixture_file('aps_development.cer'))
  end
end

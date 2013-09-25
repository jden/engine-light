require 'spec_helper'

describe WebApplicationsController do
  before do 
    FactoryGirl.create(:user, email: "erica@cfa.org") 
    session[:email] = "erica@cfa.org"
  end

  shared_examples "an action that requires login" do
    it "successfully renders the page if the user is logged in" do
      session[:email] = "erica@cfa.org"
      get action, params
      response.should be_success
    end

    it "redirects when the user is not logged in" do
      session[:email] = nil
      get action, params
      response.should be_redirect
    end
  end

  describe "#show" do
    let(:action)  { :show }
    let(:web_app) { FactoryGirl.create(:web_application, name: "monkey") }
    let(:params)  { {id: web_app.name} }
 
    it_behaves_like "an action that requires login"

    before do
      body_string = "{\"status\":\"ok\",\"updated\":1379539549,\"dependencies\":null,\"resources\":null}"
      FakeWeb.register_uri(:get, "http://www.codeforamerica.org/.well-known/status", body: body_string)
      session[:email] = "erica@cfa.org"
    end

    it "returns ok with a valid application" do
      get action, id: web_app.name
      response.should be_success
    end

    it "throws an exception when passed a non-existent application" do
      expect{
        get action, id: "pretend_monkey"
      }.to raise_error(ActionController::RoutingError)
    end
  end

  describe "#index" do
    let(:action) { :index }
    let(:params)  { {} }

    it_behaves_like "an action that requires login"

    it "returns ok" do
      get action
      response.should be_success
    end
  end
end

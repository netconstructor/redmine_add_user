require 'test_helper'

class DesignatedContactsControllerTest < ActionController::TestCase
  context "routing" do
    should_route :get, "/projects/testingroutes/designated_contacts/new", { :action => :new, :project_id => 'testingroutes' }
    should_route :post, "/projects/testingroutes/designated_contacts", { :action => :create, :project_id => 'testingroutes' }
  end

  should_have_before_filter :find_project
  should_have_before_filter :authorize

  context "on GET to :new" do
    setup do
      setup_anonymous_role
      setup_non_member_role
      setup_plugin_configuration
      @project = Project.generate!
      generate_user_and_login_for_project(@project)

      get :new, :project_id => @project
    end

    should_respond_with :success
    should_assign_to :user
    should_render_template :new
  end

  context "on POST to :create" do
    setup do
      Setting.bcc_recipients = '1'
      setup_anonymous_role
      setup_non_member_role
      setup_plugin_configuration
      @project = Project.generate!
      generate_user_and_login_for_project(@project)

      post :create, :project_id => @project.to_param, :user => {
        :mail => 'test_new_contact@example.com',
        :firstname => 'John',
        :lastname => 'Doe'
      },
      :send_information => true,
      :back_url => "/projects/#{@project.to_param}/issues"

    end

    should_assign_to :user
    should_redirect_to("the back url") { "/projects/#{@project.to_param}/issues" }
    should_set_the_flash_to(/Successful creation/i)

    should "email the user their account information" do
      assert_sent_email do |email|
        email.subject =~ /account activation/ &&
          email.bcc.include?('test_new_contact@example.com')
      end
    end
  end
end

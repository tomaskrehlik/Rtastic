require 'spec_helper'

describe "User pages" do
	subject { page }
	describe "signup page" do
		before { visit signup_path }

		it { should have_selector('h1', text: 'Sign up') }
		it { should have_selector('title', text: full_title('Sign up')) }  # text: 'Sign up'//text: full_title('Sign up') # rspec failure
	end

	describe "profil page" do
		let(:user) { FactoryGirl.create(:user) }
		before { visit user_path(user) }

		it { should have_selector('h1', text: "Profile") } #text: user.name
		it { should have_selector('title', text: user.name) } # rspec failure
	end

	describe "signup" do

    	before { visit signup_path }

    	let(:submit) { "Create account" }

    	describe "with invalid information" do
			it "should not create a user" do
				expect { click_button submit }.not_to change(User, :count)
			end
		
			describe "after submission" do
	        	before { click_button submit }

	        	it { should have_selector('title', text: 'Sign up') } # rspec failure
	        	it { should have_content('error') }
	      	end
    	end

	    describe "with valid information" do
			before do
				fill_in "Name",         with: "Example User"
				fill_in "Email",        with: "user@example.com"
				fill_in "Password",     with: "foobar"
				fill_in "Confirmation", with: "foobar"
			end

			describe "after saving the user" do
				before { click_button submit }

				let(:user) { User.find_by_email('user@example.com') }
				
				it { should have_selector('title', text: user.name) } # rspec failure
				it { should have_selector('div.alert.alert-success', text: 'Welcome') } # snad ok overeni, 
				it { should have_link('Sign out') }
			end

	      	it "should create a user" do
	        	expect { click_button submit }.to change(User, :count).by(1)
	      	end
	    end
  	end
end
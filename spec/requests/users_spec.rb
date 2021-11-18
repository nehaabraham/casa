require "rails_helper"

RSpec.describe "/users", type: :request do
  describe "GET /edit" do
    context "with a volunteer signed in" do
      it "renders a successful response" do
        sign_in build(:volunteer)

        get edit_users_path

        expect(response).to be_successful
      end
    end

    context "with an admin signed in" do
      it "renders a successful response" do
        sign_in build(:casa_admin)

        get edit_users_path

        expect(response).to be_successful
      end
    end
  end

  describe "PATCH /update" do
    it "updates the user" do
      volunteer = build(:volunteer)
      sign_in volunteer

      patch users_path, params: {user: {display_name: "New Name"}}

      expect(volunteer.display_name).to eq "New Name"
    end
  end

  describe "PATCH /update_password" do
    subject do
      patch update_password_users_path(user),
        params: {
          user: {
            current_password: "12345678",
            password: "new_pass",
            password_confirmation: "new_pass"
          }
        }
    end

    before { sign_in user }

    context "when volunteer" do
      let(:user) { create(:volunteer) }

      context "when successfully" do
        it "updates the user password" do
          subject

          expect(user.valid_password?("new_pass")).to be_truthy
        end

        it "calls UserMailer to reminder the user that password has changed" do
          mailer = double(UserMailer, deliver: nil)
          allow(UserMailer).to receive(:password_changed_reminder).with(user).and_return(mailer)
          expect(mailer).to receive(:deliver)

          subject
        end
      end

      context "when failure" do
        subject do
          patch update_password_users_path(user),
            params: {
              user: {
                password: "",
                password_confirmation: "wrong"
              }
            }
        end

        it "does not update the user password", :aggregate_failures do
          subject

          expect(user.valid_password?("wrong")).to be_falsey
          expect(user.valid_password?("")).to be_falsey
        end

        it "does not call UserMailer to reminder the user that password has changed" do
          mailer = double(UserMailer, deliver: nil)
          allow(UserMailer).to receive(:password_changed_reminder).with(user).and_return(mailer)
          expect(mailer).not_to receive(:deliver)

          subject
        end
      end
    end

    context "when supervisor" do
      let(:user) { create(:supervisor) }

      context "when successfully" do
        it "updates the user password" do
          subject

          expect(user.valid_password?("new_pass")).to be_truthy
        end

        it "calls UserMailer to reminder the user that password has changed" do
          mailer = double(UserMailer, deliver: nil)
          allow(UserMailer).to receive(:password_changed_reminder).with(user).and_return(mailer)
          expect(mailer).to receive(:deliver)

          subject
        end

        it "bypasses sign in if the current user is the true user" do
          expect_any_instance_of(UsersController).to receive(:bypass_sign_in).with(user)
          subject
        end

        it "does not bypass sign in when the current user is not the true user" do
          allow_any_instance_of(UsersController).to receive(:true_user).and_return(User.new)
          expect_any_instance_of(UsersController).to_not receive(:bypass_sign_in).with(user)
          subject
        end
      end

      context "when failure" do
        subject do
          patch update_password_users_path(user),
            params: {
              user: {
                password: "",
                password_confirmation: "wrong"
              }
            }
        end

        it "does not update the user password", :aggregate_failures do
          subject

          expect(user.valid_password?("wrong")).to be_falsey
          expect(user.valid_password?("")).to be_falsey
        end

        it "does not call UserMailer to reminder the user that password has changed" do
          mailer = double(UserMailer, deliver: nil)
          allow(UserMailer).to receive(:password_changed_reminder).with(user).and_return(mailer)
          expect(mailer).not_to receive(:deliver)

          subject
        end
      end
    end

    context "when casa_admin" do
      let(:user) { create(:casa_admin) }

      context "when successfully" do
        it "updates the user password" do
          subject

          expect(user.valid_password?("new_pass")).to be_truthy
        end

        it "calls UserMailer to reminder the user that password has changed" do
          mailer = double(UserMailer, deliver: nil)
          allow(UserMailer).to receive(:password_changed_reminder).with(user).and_return(mailer)
          expect(mailer).to receive(:deliver)

          subject
        end

        it "bypasses sign in if the current user is the true user" do
          expect_any_instance_of(UsersController).to receive(:bypass_sign_in).with(user)
          subject
        end

        it "does not bypass sign in when the current user is not the true user" do
          allow_any_instance_of(UsersController).to receive(:true_user).and_return(User.new)
          expect_any_instance_of(UsersController).to_not receive(:bypass_sign_in).with(user)
          subject
        end
      end

      context "when failure" do
        subject do
          patch update_password_users_path(user),
            params: {
              user: {
                password: "",
                password_confirmation: "wrong"
              }
            }
        end

        it "does not update the user password", :aggregate_failures do
          subject

          expect(user.valid_password?("wrong")).to be_falsey
          expect(user.valid_password?("")).to be_falsey
        end

        it "does not call UserMailer to reminder the user that password has changed" do
          mailer = double(UserMailer, deliver: nil)
          allow(UserMailer).to receive(:password_changed_reminder).with(user).and_return(mailer)
          expect(mailer).not_to receive(:deliver)

          subject
        end
      end
    end
  end
end

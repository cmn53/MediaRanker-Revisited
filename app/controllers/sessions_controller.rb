class SessionsController < ApplicationController
  def login
    auth_hash = request.env['omniauth.auth']

    if auth_hash['uid']
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user.nil?
        # User doesn't match anything in the DB
        # Attempt to create a new user
        @user = User.build_from_github(auth_id)
          if @user.save
            login_success
          else
            login_failure
          end
        else
          login_success
        end
      else
        login_failure
      end
      redirect_to root_path
    end

    def logout
      session[:user_id] = nil
      flash[:status] = :success
      flash[:result_text] = "Successfully logged out"
      redirect_to root_path
    end

    private
    def login_success
      session[:user_id] = @user.id
      flash[:status] = :success
      flash[:result_text] = "Successfully created new user #{@user.username} with ID #{@user.id}"
    end

    def login_failure
      flash.now[:status] = :failure
      flash.now[:result_text] = "Could not log in"
      flash.now[:messages] = @user.errors.messages
    end

  # def login_form
  # end

  # def login
  #   username = params[:username]
  #   if username and user = User.find_by(username: username)
  #     session[:user_id] = user.id
  #     flash[:status] = :success
  #     flash[:result_text] = "Successfully logged in as existing user #{user.username}"
  #   else
  #     user = User.new(username: username)
  #     if user.save
  #       session[:user_id] = user.id
  #       flash[:status] = :success
  #       flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
  #     else
  #       flash.now[:status] = :failure
  #       flash.now[:result_text] = "Could not log in"
  #       flash.now[:messages] = user.errors.messages
  #       render "login_form", status: :bad_request
  #       return
  #     end
  #   end
  #   redirect_to root_path
  # end
end

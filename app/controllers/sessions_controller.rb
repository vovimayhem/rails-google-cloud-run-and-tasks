class SessionsController < ApplicationController
  # GET /session
  def show
  end

  # GET /sign-in
  def new
    redirect_to root_path, notice: 'Already signed in' if user_signed_in?
  end

  # POST /session
  def create
    @token = GoogleIdToken.new(session_params[:token])
    sign_in_user(@token.user) if @token.valid?

    respond_to do |format|
      if user_signed_in?
        format.html { redirect_to root_path, notice: 'Session was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # DELETE /session
  def destroy
    sign_out_user
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Session was successfully destroyed.' }
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def session_params
      params.require(:session).permit(:token)
    end
end

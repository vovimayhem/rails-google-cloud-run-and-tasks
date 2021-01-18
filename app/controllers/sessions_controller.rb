class SessionsController < ApplicationController
  # GET /session
  def show
  end

  # GET /sign-in
  def new
  end

  # POST /session
  def create
    token_payload, token_header = JWT.decode session_params[:token], nil, false
    puts "==="

    respond_to do |format|
      # if @session.save
        format.html { redirect_to @session, notice: 'Session was successfully created.' }
      # else
      #   format.html { render :new }
      # end
    end
  end

  # DELETE /session
  def destroy
    @session.destroy
    respond_to do |format|
      format.html { redirect_to sessions_url, notice: 'Session was successfully destroyed.' }
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def session_params
      params.require(:session).permit(:token)
    end
end

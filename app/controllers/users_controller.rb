class UsersController < ApplicationController
    before_action :set_user, only: [:show, :edit, :update, :destroy]
    before_action :signed_in_user, only: [:edit, :update, :index]
    before_action :correct_user, only: [:edit, :update]
    
    # GET /users
    # GET /users.json
    def index
        @users = User.all
    end
    
    # GET /users/1
    # GET /users/1.json
    def show
    end
    
    # GET /users/new
    def new
        @user = User.new
    end
    
    # GET /users/1/edit
    def edit
        # Unnesseary from Hartl tutorial, because of before_action :set_user (+ see private methods...)
        # @user = User.find(params[:id])
    end
    
    # POST /users
    # POST /users.json
    def create
        @user = User.new(user_params)
        
        respond_to do |format|
            if @user.save
                sign_in @user
                format.html { redirect_to @user, notice: 'User was successfully created.' }
                format.json { render action: 'show', status: :created, location: @user }
            else
                format.html { render action: 'new' }
                format.json { render json: @user.errors, status: :unprocessable_entity }
            end
        end
    end
    
    # PATCH/PUT /users/1
    # PATCH/PUT /users/1.json
    def update
        respond_to do |format|
            if @user.update_attributes(user_params)
                format.html { redirect_to @user, notice: 'User was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: 'edit' }
                format.json { render json: @user.errors, status: :unprocessable_entity }
            end
        end
    end
    
    # DELETE /users/1
    # DELETE /users/1.json
    def destroy
        @user.destroy
        respond_to do |format|
            format.html { redirect_to users_url }
            format.json { head :no_content }
        end
    end
    
    def request_pocket
        code = HTTParty.post("https://getpocket.com/v3/oauth/request", { headers: POCKET_HEADERS, body: { consumer_key: POCKET_KEY, redirect_uri: "www.test.com"}.to_json })["code"]
        
        # puts "Got this code from Pocket #{code}, now redirecting to pocket auth"
        redirect_to "https://getpocket.com/auth/authorize?request_token=#{code}&redirect_uri=http://localhost:3000/addpocket"
    end    
        
    def add_pocket
        puts "Sending response with #code}"
        # Send authorised code to get username and access_token
        response = HTTParty.post("https://getpocket.com/v3/oauth/authorize",{ headers: POCKET_HEADERS, body: { consumer_key: POCKET_KEY, code: code}.to_json })
        
        puts response
        # Save result to the database record
    end
    
    def subscribe
        current_user.subscribe!(User.find(params[:subscribe_to_user]))
        redirect_to User.find(params[:subscribe_to_user])
    end
    
    def unsubscribe
        current_user.unsubscribe!(User.find(params[:unsubscribe_to_user]))
        redirect_to User.find(params[:unsubscribe_to_user])
    end

    private
        # Use callbacks to share common setup or constraints between actions.
        def set_user
            @user = User.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def user_params
            params.require(:user).permit(:username, :email, :password, :password_confirmation)
        end
        
        def correct_user
            @user = User.find(params[:id])
            redirect_to(root_url) unless current_user?(@user)
        end
end

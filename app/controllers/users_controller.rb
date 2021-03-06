class UsersController < ApplicationController
    before_action :set_user, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!, only: [:edit, :update, :subscribe, :unsubscribe]
    before_action :correct_user, only: [:edit, :update]
    after_filter :store_location
    
    # GET /users
    # GET /users.json
    def index
        @users = User.search(params[:search]).paginate(per_page: 10, page: params[:page])
    end
    
    # GET /users/1
    # GET /users/1.json
    def show
        if @user.pocket
            # Currently only getting 2 weeks worth of articles, prevents heavy users of pocket slowing down load.
            @articles = user_articles(@user, "all", (Time.now - 1.weeks))
            if @user != current_user and current_user.pocket
                @current_user_articles = user_articles(current_user, "all")
            end
        end
    end
    
    # GET /users/new
    def new
        @user = User.new
    end
    
    # GET /users/1/edit
    def edit
        
    end
    
    # POST /users
    # POST /users.json
    def create
        
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
    
    def subscribe
        if !request.xhr?
            current_user.subscribe!(User.find(params[:subscribe_to_user]))
            redirect_to root_path
        else
            current_user.subscribe!(User.find(params[:subscribe_to_user]))
            head :no_content
        end     
    end
    
    def unsubscribe
        if !request.xhr?
            current_user.unsubscribe!(User.find(params[:unsubscribe_to_user]))
            redirect_to root_path
        else
            current_user.unsubscribe!(User.find(params[:unsubscribe_to_user]))
            head :no_content
        end
    end

    def recommendations
        @article_feed = order_by_popularity(article_feed(current_user))    
    end
    
    def add_article
        add_article_helper params[:article], current_user.pocket.access_token
        redirect_to root_path
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
            redirect_to(root_url) unless current_user == @user
        end

        def store_location
        # store last url - this is needed for post-login redirect to whatever the user last visited.
            if (request.fullpath != "/users/sign_in" &&
                request.fullpath != "/users/sign_up" &&
                request.fullpath != "/users/password" &&
                request.fullpath != "/users/sign_out" &&
                !request.xhr?) # don't store ajax calls
                session[:previous_url] = request.fullpath 
            end
        end
end

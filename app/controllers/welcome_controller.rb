class WelcomeController < ApplicationController

    def index
        if signed_in?
            if current_user.new_user?
                redirect_to subscription_recommendations_path
            end
            @user = current_user
            @article_feed = order_by_date(article_feed(@user))
        end
    end

    def subscription_recommendations
        @user = current_user
        if @user.new_user?
            @twitter_following = []
            @user.twitter_following.each do |uid|
                if User.find_by(uid: uid).pocket
                    @twitter_following << User.find_by(uid: uid)
                end
            end
            
            # If they don't have any recommendations from Twitter
            if @twitter_following.empty?
                @popular_users = [User.find_by(id: 'mattclifford'), User.find_by(id: "nicangeli"), User.find_by(id: "UBC_founder")]
            end
        end
        current_user.update_attributes(new_user?: false)
    end
end

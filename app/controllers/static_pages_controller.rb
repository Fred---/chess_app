class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @user = current_user
    end
  end

  def help
  end

  def about
  end

  def contact
  end

  def wall
    if signed_in?
      @user = current_user
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

end

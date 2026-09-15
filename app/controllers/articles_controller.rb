class ArticlesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @article = Article.find(params[:id])
    unless current_user.admin? || @article.author == current_user
      redirect_to articles_path, alert: 'Access denied.'
    end
  end
end
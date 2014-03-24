class Schedules::Apps::NotesController < Schedules::Apps::AppsApplicationController
  
  before_filter :get_opponent, :only => [:index]

  def index
    @notes_categories    = @opponent.notes_categories.includes(:notes_category_posts)
    @notes_category_post = NotesCategoryPost.new
    @notes_category      = NotesCategory.new
  end

  #create notes category
  def create_category
    @notes_category = NotesCategory.new(params[:notes_category])
    @notes_category.save  
  end

  #add new category post
    def new_category_post
    @category           = NotesCategory.find_by_id(params[:note_category_id])
    @new_category_post  = @category.notes_category_posts.new
  end

  #create notes category post
  def create_category_post
    @notes_category_post = NotesCategoryPost.new(params[:notes_category].merge(:user_id => current_user.id))
    @notes_category_post.save
  end

  def category_posts
    @notes_category = NotesCategory.includes(:notes_category_posts).find_by_id(params[:notes_category])
    @notes_category_posts = @notes_category.notes_category_posts.includes(:user)
  end

  def notes_categories
    @notes_categories = current_opponent.notes_categories
  end

  def destroy_post
    post = NotesCategoryPost.find_by_id(params[:category_post])
    @post_id = post.id
    post.destroy
  end

end

class MoviesController < ApplicationController
 
   def movie_ratings
    Movie.select(:rating).uniq.map(&:rating)
    #Movie.select('distinct rating').map(&:ratng)
  end
  
  def index
  @all_ratings = movie_ratings
  @selected_ratings = params[:ratings] || session[:ratings] || {}
  sort = params[:sort] || session[:sort]
  case sort
    when 'id'
      ordering = {:order => :id}
      @id_header = 'hilite'
    when 'title'
      ordering = {:order => :title}
      @title_header = 'hilite'
    when 'release_date'
      ordering = {:order => :release_date}
      @date_header = 'hilite'
  end
  if @selected_ratings == {}
    @selected_ratings = Hash[@all_ratings.map {|rating| [rating,rating]}]
  end
 
  if session[:sort] != params[:sort] or session[:ratings] != params[:ratings]
    session[:sort] = sort
    session[:ratings] = @selected_ratings
    flash.keep
    return redirect_to :sort => sort, :ratings => @selected_ratings
  end
  @movies = Movie.find_all_by_rating(@selected_ratings.keys, ordering)
  end

  
  def search_tmdb
   # @movies = Movie.find_in_tmdb(params[:search_terms])
    @movies = Tmdb::Movie.find(params[:search_terms])
#debugger
    if @movies.empty?
      flash[:warning] = "'#{params[:search_terms]}' was not found in TMDb."
      return redirect_to movies_path
    end
  end

  def show
    if params[:from] == "tmdb"
      @movie_temp = Tmdb::Movie.detail(params[:tmdb_id])

      @movie = Movie.new
      @movie.id = @movie_temp["id"]
      @movie.title = @movie_temp["title"]
      @movie.rating = @movie_temp["vote_average"]
      @movie.release_date = @movie_temp["release_date"]
      @movie.description = @movie_temp["overview"]
      @movie.poster_path = @movie_temp["poster_path"]
    else
      @movie = Movie.find params[:id] # look up movie by unique IDi
    end  
    rescue ActiveRecord::RecordNotFound
        flash[:notice] = "Movie ID ##{id} not found!"
        redirect_to :action => 'index' #movies_path
  # will render app/views/movies/show.html.haml by default
end




def new
# default: render 'new' template
end


def create
  #debugger
  @movie= Movie.create!(params[:movie])
  flash[:notice] = "#{@movie.title} was successfully created!"
  redirect_to movies_path
end

def edit
  @movie = Movie.find params[:id]
end

def update
  @movie = Movie.find params[:id]
  @movie.update_attributes!(params[:movie])
  flash[:notice] = "#{@movie.title} was successfully updated!"
  redirect_to movie_path(@movie)

end

def destroy
  @movie = Movie.find params[:id]
  @movie.destroy
  flash[:notice] = "#{@movie.title} was successfully deleted!"
  redirect_to movies_path

end

end


class MoviesController < ApplicationController
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  def index
    # CLearing the session on loading
    if request.env['PATH_INFO'] == '/'
      session.clear
    end
    # Getting the parameters from the URL
    ref_clicked = params[:ref_clicked]
    sort_items = params[:sort_items]
    #Initializing all the variables
    @all_ratings = Movie.all_ratings
    generatedRatings = {}
    @all_ratings.each{ |rating| generatedRatings[rating] = 1 }
    ratings = {}
    # Setting sort_times using session
    if(sort_items)
      session[:sort_items] = sort_items
    elsif session[:sort_items]
      sort_items = session[:sort_items]
    end
    # Setting ratings using session
    if(ref_clicked)
      if(!params[:ratings])
        ratings = generatedRatings
        session[:ratings] = nil
      else
        ratings = params[:ratings]
        session[:ratings] = ratings
      end
    elsif(session[:ratings])
      ratings = session[:ratings]
    elsif(params[:ratings]) 
      ratings = params[:ratings]
      session[:ratings] = ratings
    else
      ratings = generatedRatings
      session[:ratings] = nil
    end
    
    # Sorting logic for both movie title and release date
    case sort_items
      when "movies_title"
        @movies = Movie.order(:title)
        @sort_items = "movies_title"
      when "release_date"
        @movies = Movie.order(:release_date)
        @sort_items = "release_date"
      else
        @movies = Movie.all
        @sort_items = ''
    end
    
    # Setting final movies and ratings to show 
    @movies = @movies.with_ratings(ratings.keys)
    @ratings_to_show = ratings == generatedRatings ? generatedRatings.keys : ratings.keys
  end
  def new
    # default: render 'new' template
  end
  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end
  def edit
    @movie = Movie.find params[:id]
  end
  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end
  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end

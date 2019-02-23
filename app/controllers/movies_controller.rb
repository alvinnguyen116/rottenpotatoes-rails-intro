class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # session.clear
    @all_ratings = Movie.all_ratings
    @keys = @all_ratings
    @redirect_hash = {:sort_title => false, :sort_release_date => false}
    @should_redirect = false

    if params[:sort_title] == "true"
      @should_sort = false
      @redirect_hash[:sort_title] = params[:sort_title]
    elsif params[:sort_title] == "false"
      @should_sort = true
      @redirect_hash[:sort_title] = params[:sort_title]
    elsif session[:sort_title] == "true"
      @should_redirect = true
      @redirect_hash[:sort_title] = session[:sort_title]
      @should_sort = false
    elsif session[:sort_title] == "false"
      @should_redirect = true
      @redirect_hash[:sort_title] = session[:sort_title]
      @should_sort = true
    else 
      @should_sort = true
    end

    if params[:sort_release_date] == "true"
      @redirect_hash[:sort_release_date] = params[:sort_release_date]
      @should_sort_rd = false
    elsif params[:sort_release_date] == "false"
      @redirect_hash[:sort_release_date] = params[:sort_release_date]
      @should_sort_rd = true
    elsif session[:sort_release_date] == "true"
      @should_redirect = true
      @redirect_hash[:sort_release_date] = session[:sort_release_date]
      @should_sort_rd = false
    elsif session[:sort_release_date] == "false"
      @should_redirect = true
      @redirect_hash[:sort_release_date] = session[:sort_release_date]
      @should_sort_rd = true
    else 
      @should_sort_rd = true
    end

    if params[:ratings]
      @keys = params[:ratings].is_a?(Hash) ? params[:ratings].keys : params[:ratings]
      @movies = Movie.with_ratings(@keys)
      session[:ratings] = @keys
    elsif session[:ratings]
      @should_redirect = true
      @keys = session[:ratings]
      @movies = Movie.with_ratings(@keys)
    end
    
    @redirect_hash[:ratings] = @keys

    if params[:sort_title] == "true"
      @redirect_hash[:sort_title] = params[:sort_title]
      session[:sort_title] = params[:sort_title]
      @title_class = "hilite"
      if @movies 
        @movies = @movies.order(:title)
      else
        @movies = Movie.order(:title)
      end
    elsif params[:sort_title] == "false"
      @redirect_hash[:sort_title] = params[:sort_title]
      session[:sort_title] = false
    elsif session[:sort_title]
      @should_redirect = true
      @redirect_hash[:sort_title] = session[:sort_title]
      @title_class = "hilite"
      if @movies 
        @movies = @movies.order(:title)
      else
        @movies = Movie.order(:title)
      end
    end

    if params[:sort_release_date] == "true"
      @redirect_hash[:sort_release_date] = params[:sort_release_date]
      session[:sort_release_date] = params[:sort_release_date]
      @release_date_class = "hilite"
      if @movies 
        @movies = @movies.order(:release_date)
      else
        @movies = Movie.order(:release_date)
      end
    elsif params[:sort_release_date] == "false"
      @redirect_hash[:sort_release_date] = params[:sort_release_date]
      session[:sort_release_date] = false
    elsif session[:sort_release_date]
      @should_redirect = true
      @redirect_hash[:sort_release_date] = session[:sort_release_date]
      @release_date_class = "hilite"
      if @movies 
        @movies = @movies.order(:release_date)
      else
        @movies = Movie.order(:release_date)
      end
    end

    if !@movies
      @movies = Movie.all
    end

    if @should_redirect
      flash.keep
      redirect_to movies_path(@redirect_hash)
    end
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

end

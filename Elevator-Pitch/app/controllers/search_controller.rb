class SearchController < ApplicationController
  
  def lookup
    result = []
    params[:query].split(',').each do |tag|
      result = result + search_key(tag)
    end
    respond_to do |format|
      format.json {render :json => {:options => result}}
    end
  end
  
  private 
  def search_key(query)
    result = []
    $redis.keys.each do |key|
      result << key if key.match(query.downcase.squish)
    end  
  end
    
end

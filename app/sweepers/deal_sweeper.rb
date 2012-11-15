class DealSweeper < ActionController::Caching::Sweeper

observe Deal, Publisher, Advertiser

  def sweep(deal)
    expire_page deals_path
    FileUtils.rm_rf "#{page_cache_directory}/deals.*"
  end   
  
  alias_method :after_update, :sweep 
  alias_method :after_create, :sweep 
  alias_method :after_destroy, :sweep 

end

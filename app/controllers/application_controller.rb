class ApplicationController < ActionController::Base
  cattr_accessor :temp_files
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  protected

  self.temp_files = Queue.new

  def not_cacheable!
    expires_now
  end
end
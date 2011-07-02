class HelpController < ApplicationController
  before_filter :no_tag_load

  def usage
  end
end

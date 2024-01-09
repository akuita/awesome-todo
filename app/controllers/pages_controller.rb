# typed: true
class PagesController < ApplicationController
  def health
    head :ok
  end
end

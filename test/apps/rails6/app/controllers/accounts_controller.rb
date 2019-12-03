class AccountspsController < ApplicationController
  def login
    if request.get?
      # Do something benign
    else
      # Do something sensitive because it's a POST
      # but actually it could be a HEAD :(
    end
  end
end

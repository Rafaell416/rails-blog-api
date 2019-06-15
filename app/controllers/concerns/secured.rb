module Secured 
  def authenticate_user!
    # read auth header
    token_regex = /Bearer (\w+)/
    headers = request.headers
    # check if  auth header is valid
    if headers['Authorization'].present? && headers['Authorization'].match(token_regex)
      token = headers['Authorization'].match(token_regex)[1]
      # check if token is realted to a user
      if ( Current.user = User.find_by_auth_token(token) ) 
        return 
      end

    end

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
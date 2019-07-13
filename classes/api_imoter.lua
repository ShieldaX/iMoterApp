-----------------------------------------------------------------------------------------
-- iMoter API
-----------------------------------------------------------------------------------------
return {
  base_url = "http://localhost:3000",
  name = "iMoter API",
  version = "0.1.0",
  methods = {
    
    -- Album
    getAlbumById = {
      method = "GET",
      path = "api/albums/:album_id",
      required_params = {"album_id"},
    },
    
    listAlbums = {
      method = "GET",
      path = "api/albums",
      optional_params = { "skip", "limit" },
      required_params = {"moter"},
    },
    
    -- Moter
    getMoterById = {
      method = "GET",
      path = "api/moters/:moter_id",
      optional_params = { "fetchcover" },
      required_params = {"moter_id"},
    },

    -- Users
    createUser = {
      path = "api/accounts/register",
      required_params = { "nickname", "signin_id", "password" },
      optional_params = { "avatar_id" },
      method = "POST",
      required_payload = true,
    },

    login = {
      path = "api/accounts/signin",
      required_params = { "signin_id", "password" },
      method = "POST",
      required_payload = true,
    },

    -- Avatar
    uploadAvatarWithFileName = {
      path = "api/accounts/avatar/:filename",
      required_params = { "filename" },
      method = "POST",
      required_payload = true,
    },

    uploadAvatar = {
      path = "api/accounts/avatar",
      required_params = { "avatar_file" },
      method = "POST",
      required_payload = true,
    },

    --Session
    getRefreshSeeds = {
      path = "api/accounts/refresh",
      method = "GET",
    },
    
    refreshSession = {
      path = "api/accounts/refresh",
      required_params = { "token", "ficus_user_session" },
      method = "POST",
      required_payload = true,
    },

  },
}


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
    
    listAlbumsOfMoter = {
      method = "GET",
      path = "api/albums",
      optional_params = { "skip", "limit" },
      required_params = {"moter"},
    },
    
    listAlbums = {
      method = "GET",
      path = "api/albums",
      optional_params = { "skip", "limit" },
    },
    
    listAlbumsByTag = {
      method = "GET",
      path = "api/galleries/:tag_id",
      optional_params = { "skip", "limit" },
      required_params = {"tag_id"},
    },
    
    -- Moter
    getMoterById = {
      method = "GET",
      path = "api/moters/:moter_id",
      optional_params = { "fetchcover" },
      required_params = {"moter_id"},
    },
    
    -- Tag
    searchTags = {
      method = "GET",
      path = "api/tags/search",
      required_params = {"name"}
    },
    
    -- Users
    register = {
      path = "api/auth/register",
      required_params = { "name", "email", "password" },
--      optional_params = { "avatar_id" },
      method = "POST",
      required_payload = true,
    },

    login = {
      path = "api/auth/sign_in",
      required_params = { "email", "password" },
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
    }

  },

}


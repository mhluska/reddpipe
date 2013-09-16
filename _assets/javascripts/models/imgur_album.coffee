class window.ImgurAlbumModel extends Backbone.Model
  defaults:
    albumID: null
    images:  null

  url: -> "https://api.imgur.com/3/album/#{@get('albumID')}"

  parse: (response) -> images: _.map(response.data.images, (image) -> image.link)

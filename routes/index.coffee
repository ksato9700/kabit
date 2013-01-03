#
# Copyright 2013 Kenichi Sato <ksato9700@gmail.com>
#
#

#
#routes
#

exports.index = (req, res)->
  res.render 'index'

exports.type = (req, res)->
  res.render req.params.type,
    host_url: "http://" + req.headers.host

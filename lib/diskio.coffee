helpers = require('./helpers')
drive = require('./drive')

exports.write = (device, buffer, offset, length, position, callback) ->
	helpers.prepareDrive device, (done) ->
		drive.writeBufferToDevice(device, buffer, offset, length, position, done)
	, callback

exports.writeStream = (device, stream, callback) ->
	helpers.prepareDrive device, (done) ->
		drive.pipeStreamToDevice(device, stream, done)
	, callback

exports.read = drive.readFromDevice

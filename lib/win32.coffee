_ = require('lodash-contrib')
os = require('os')
helpers = require('./helpers')
drive = require('./drive')

if os.platform() is 'win32'
	diskpart = require('diskpart')

exports.generateNullBuffer = (length) ->
	if not length?
		throw new Error('Missing buffer length')

	if not _.isNumber(length) or length < 0
		throw new Error('Invalid buffer length')

	buffer = new Buffer(length)
	buffer.fill(0)

	return buffer

# TODO: Find a way to test this
exports.eraseMBR = (device, callback) ->
	bufferSize = 512
	buffer = exports.generateNullBuffer(bufferSize)
	drive.writeBufferToDevice(device, buffer, 0, bufferSize, 0, callback)

# TODO: Find a way to test this
exports.rescanDrives = (callback) ->
	diskpart?.evaluate([ 'rescan' ], callback)

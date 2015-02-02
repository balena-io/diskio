_ = require('lodash-contrib')
os = require('os')
async = require('async')
win32 = require('./win32')

exports.translateError = (callback) ->
	if not callback?
		throw new Error('Missing callback')

	if not _.isFunction(callback)
		throw new Error('Invalid callback')

	return (error) ->
		return callback() if not error?

		if error.code is 'EBUSY'
			error.message = "Try umounting #{error.path} first."

		if error.code is 'ENOENT'
			error.message = "Invalid device #{error.path}"

			# Prevents outer handler to take
			# it as an usual ENOENT error
			delete error.code

		return callback(error)

exports.prepareDrive = (device, writeFunction, callback) ->

	if not device?
		throw new Error('Missing device')

	if not writeFunction?
		throw new Error('Missing write function')

	if not _.isFunction(writeFunction)
		throw new Error('Invalid write function')

	isWindows = os.platform() is 'win32'

	async.waterfall([

		(callback) ->
			return callback() if not isWindows
			win32.eraseMBR(device, callback)

		(callback) ->
			return callback() if not isWindows
			win32.rescanDrives(callback)

		writeFunction

		(callback) ->
			return callback() if not isWindows
			win32.rescanDrives(callback)

	], exports.translateError(callback))

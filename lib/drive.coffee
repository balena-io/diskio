async = require('async')
fs = require('fs')
_ = require('lodash-contrib')
chunkingStreams = require('chunking-streams')

IO_FLAGS = 'rs+'

# TODO: Find a way to unit test this

exports.readFromDevice = (device, buffer, offset, length, position, callback) ->
	async.waterfall([

		(callback) ->
			fs.open(device, IO_FLAGS, null, callback)

		(fd, callback) ->
			fs.read fd, buffer, offset, length, position, (error, bytesWritten, readBuffer) ->
				return callback(error) if error?
				return callback(null, bytesWritten, fd)

		(bytesWritten, fd, callback) ->
			if bytesWritten isnt length
				error = "Bytes written: #{bytesWritten}, expected #{length}"
				return callback(error)

			# TODO: What happens if an error ocurr after the file is opened?
			# This fs.close() call will never be reached.
			# Investigate if this is a problem.
			fs.close(fd, callback)

	], callback)

exports.writeBufferToDevice = (device, buffer, offset, length, position, callback) ->
	async.waterfall([

		(callback) ->
			fs.open(device, IO_FLAGS, null, callback)

		(fd, callback) ->
			fs.write fd, buffer, offset, length, position, (error, bytesWritten) ->
				return callback(error) if error?
				return callback(null, bytesWritten, fd)

		(bytesWritten, fd, callback) ->
			if bytesWritten isnt length
				error = "Bytes written: #{bytesWritten}, expected #{length}"
				return callback(error)

			# TODO: What happens if an error ocurr after the file is opened?
			# This fs.close() call will never be reached.
			# Investigate if this is a problem.
			fs.close(fd, callback)

	], callback)

exports.pipeStreamToDevice = (device, stream, callback) ->

	deviceFileStream = fs.createWriteStream device,
		flags: IO_FLAGS

	deviceFileStream.on('error', callback)

	chunker = new chunkingStreams.SizeChunker
		chunkSize: 512
		flushTail: false

	chunker.on 'data', (chunk) ->
		deviceFileStream.write(chunk.data)

	chunker.on('end', callback)

	stream.pipe(chunker)

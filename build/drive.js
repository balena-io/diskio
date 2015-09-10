var IO_FLAGS, StreamChunker, async, fs, _;

async = require('async');

fs = require('fs');

_ = require('lodash-contrib');

StreamChunker = require('stream-chunker');

IO_FLAGS = 'rs+';

exports.readFromDevice = function(device, buffer, offset, length, position, callback) {
  return async.waterfall([
    function(callback) {
      return fs.open(device, IO_FLAGS, null, callback);
    }, function(fd, callback) {
      return fs.read(fd, buffer, offset, length, position, function(error, bytesWritten, readBuffer) {
        if (error != null) {
          return callback(error);
        }
        return callback(null, bytesWritten, fd);
      });
    }, function(bytesWritten, fd, callback) {
      var error;
      if (bytesWritten !== length) {
        error = "Bytes written: " + bytesWritten + ", expected " + length;
        return callback(error);
      }
      return fs.close(fd, callback);
    }
  ], callback);
};

exports.writeBufferToDevice = function(device, buffer, offset, length, position, callback) {
  return async.waterfall([
    function(callback) {
      return fs.open(device, IO_FLAGS, null, callback);
    }, function(fd, callback) {
      return fs.write(fd, buffer, offset, length, position, function(error, bytesWritten) {
        if (error != null) {
          return callback(error);
        }
        return callback(null, bytesWritten, fd);
      });
    }, function(bytesWritten, fd, callback) {
      var error;
      if (bytesWritten !== length) {
        error = "Bytes written: " + bytesWritten + ", expected " + length;
        return callback(error);
      }
      return fs.close(fd, callback);
    }
  ], callback);
};

exports.pipeStreamToDevice = function(device, stream, callback) {
  return stream.pipe(StreamChunker(512 * 2, {
    flush: true
  })).pipe(fs.createWriteStream(device, {
    flags: IO_FLAGS
  })).on('end', callback).on('error', callback);
};

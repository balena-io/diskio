var IO_FLAGS, async, fs, _;

async = require('async');

fs = require('fs');

_ = require('lodash-contrib');

IO_FLAGS = 'rs+';

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
  var deviceFileStream;
  deviceFileStream = fs.createWriteStream(device, {
    flags: IO_FLAGS
  });
  deviceFileStream.on('error', callback);
  return stream.pipe(deviceFileStream).on('error', _.unary(callback)).on('close', _.unary(callback));
};

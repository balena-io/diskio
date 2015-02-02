var drive, helpers;

helpers = require('./helpers');

drive = require('./drive');

exports.write = function(device, buffer, offset, length, position, callback) {
  return helpers.prepareDrive(device, function(done) {
    return drive.writeBufferToDevice(device, buffer, offset, length, position, done);
  }, callback);
};

exports.writeStream = function(device, stream, callback) {
  return helpers.prepareDrive(device, function(done) {
    return drive.pipeStreamToDevice(device, stream, done);
  }, callback);
};

exports.read = drive.readFromDevice;

var diskpart, drive, helpers, os, _;

_ = require('lodash-contrib');

os = require('os');

helpers = require('./helpers');

drive = require('./drive');

if (os.platform() === 'win32') {
  diskpart = require('diskpart');
}

exports.generateNullBuffer = function(length) {
  var buffer;
  if (length == null) {
    throw new Error('Missing buffer length');
  }
  if (!_.isNumber(length) || length < 0) {
    throw new Error('Invalid buffer length');
  }
  buffer = new Buffer(length);
  buffer.fill(0);
  return buffer;
};

exports.eraseMBR = function(device, callback) {
  var buffer, bufferSize;
  bufferSize = 512;
  buffer = exports.generateNullBuffer(bufferSize);
  return drive.writeBufferToDevice(device, buffer, 0, bufferSize, 0, callback);
};

exports.rescanDrives = function(callback) {
  return diskpart != null ? diskpart.evaluate(['rescan'], _.unary(callback)) : void 0;
};

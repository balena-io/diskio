var async, os, win32, _;

_ = require('lodash-contrib');

os = require('os');

async = require('async');

win32 = require('./win32');

exports.translateError = function(callback) {
  if (callback == null) {
    throw new Error('Missing callback');
  }
  if (!_.isFunction(callback)) {
    throw new Error('Invalid callback');
  }
  return function(error) {
    if (error == null) {
      return callback();
    }
    if (error.code === 'EBUSY') {
      error.message = "Try umounting " + error.path + " first.";
    }
    if (error.code === 'ENOENT') {
      error.message = "Invalid device " + error.path;
      delete error.code;
    }
    return callback(error);
  };
};

exports.prepareDrive = function(device, writeFunction, callback) {
  var isWindows;
  if (device == null) {
    throw new Error('Missing device');
  }
  if (writeFunction == null) {
    throw new Error('Missing write function');
  }
  if (!_.isFunction(writeFunction)) {
    throw new Error('Invalid write function');
  }
  isWindows = os.platform() === 'win32';
  return async.waterfall([
    function(callback) {
      if (!isWindows) {
        return callback();
      }
      return win32.eraseMBR(device, callback);
    }, function(callback) {
      if (!isWindows) {
        return callback();
      }
      return win32.rescanDrives(callback);
    }, writeFunction, function(callback) {
      if (!isWindows) {
        return callback();
      }
      return win32.rescanDrives(callback);
    }
  ], exports.translateError(callback));
};

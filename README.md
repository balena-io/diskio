diskio
------

[![npm version](https://badge.fury.io/js/diskio.svg)](http://badge.fury.io/js/diskio)
[![dependencies](https://david-dm.org/resin-io/diskio.png)](https://david-dm.org/resin-io/diskio.png)
[![Build Status](https://travis-ci.org/resin-io/diskio.svg?branch=master)](https://travis-ci.org/resin-io/diskio)
[![Build status](https://ci.appveyor.com/api/projects/status/yv2wf3gyidv3hlyx?svg=true)](https://ci.appveyor.com/project/jviotti/diskio)

Raw disk I/O that works in all major operating systems.

**DEPRECATED in favor of https://github.com/resin-io/resin-image-write**

Notice this module requires running with admin privileges. Use modules such as [windosu](https://www.npmjs.com/package/windosu) to provide elevation if you require that feature on Windows.

This module is special as it addresses Windows issues when writing directly to a physical drive.

Windows needs the following quirks before attempting to write data correctly:

- Erase the Master Boot Record.
- Rescan drives.

`diskio` takes care of this for you, and also triggers a rescan after the data was written, so the volume get's mounted by Windows afterwards.

The API is similar to NodeJS's [fs module](http://nodejs.org/api/fs.html#fs_file_system) write and read operations so you should be able to be up and running easily.

Example:

```coffee
var fs = require('fs');
var diskio = require('diskio');
var stream = fs.createReadStream('../path/to/ubuntu.iso');

diskio.writeStream('\\\\.\\PhysicalDrive1', stream, function(error) {
		if (error) throw error;
		console.log('Ubuntu ISO written to \\\\.\\PhysicalDrive1');
});
```

In order to list available devices, take a look at [drivelist](https://github.com/resin-io/drivelist).

Installation
------------

Install `diskio` by running:

```sh
$ npm install --save diskio
```

Documentation
-------------

#### diskio.write(String device, Buffer buffer, Number offset, Number length, Number position, Function callback)

Similar to [fs.write](http://nodejs.org/api/fs.html#fs_fs_write_fd_buffer_offset_length_position_callback).

It accepts a device string, such as `/dev/disk1` or `\\.\PhysicalDrive1`.

The callback gets one argument: `(error)`.

#### diskio.writeStream(String device, Readable Stream stream, Function callback)

Pipe a readable stream to a device.

It accepts a device string, such as `/dev/disk1` or `\\.\PhysicalDrive1`.

The callback gets one argument: `(error)`.

#### diskio.read(String device, Buffer buffer, Number offset, Number length, Number position, Function callback)

Similar to [fs.read](http://nodejs.org/api/fs.html#fs_fs_read_fd_buffer_offset_length_position_callback).

It accepts a device string, such as `/dev/disk1` or `\\.\PhysicalDrive1`.

The callback gets two arguments: `(error, buffer)`.

Tests
-----

Run the test suite by doing:

```sh
$ gulp test
```

Contribute
----------

- Issue Tracker: [github.com/resin-io/diskio/issues](https://github.com/resin-io/diskio/issues)
- Source Code: [github.com/resin-io/diskio](https://github.com/resin-io/diskio)

Before submitting a PR, please make sure that you include tests, and that [coffeelint](http://www.coffeelint.org/) runs without any warning:

```sh
$ gulp lint
```

TODO
----

- Allow to read a device as a stream.
- Improve testing in some areas of the code.

Support
-------

If you're having any problem, please [raise an issue](https://github.com/resin-io/diskio/issues/new) on GitHub.

License
-------

The project is licensed under the MIT license.

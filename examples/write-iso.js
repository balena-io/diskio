var diskio = require('../build/diskio');
var fs = require('fs');

var devicePath = process.argv[2];
var isoPath = process.argv[3];

if(!devicePath || !isoPath) {
	console.info('Usage: node write-iso.js <device> <iso>')
	process.exit(1);
}

var stream = fs.createReadStream(isoPath);

diskio.writeStream(devicePath, stream, function(error) {
		if (error) throw error;
		console.log(isoPath + ' written to ' + devicePath);
});

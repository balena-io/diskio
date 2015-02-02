_ = require('lodash-contrib')
chai = require('chai')
expect = chai.expect
win32 = require('../lib/win32')

describe 'Win32', ->

	describe '.generateNullBuffer()', ->

		it 'should throw an error if no length', ->
			expect ->
				win32.generateNullBuffer()
			.to.throw('Missing buffer length')

		it 'should throw an error if length is not a number', ->
			expect ->
				win32.generateNullBuffer('24')
			.to.throw('Invalid buffer length')

		it 'should throw an error if length is negative', ->
			expect ->
				win32.generateNullBuffer(-512)
			.to.throw('Invalid buffer length')

		it 'should generate a buffer of the given length', ->
			buffer = win32.generateNullBuffer(512)
			expect(buffer.length).to.equal(512)

		it 'should generate a buffer of null bytes', ->
			buffer = win32.generateNullBuffer(256)
			isNull = (data) -> return data is 0
			expect(_.every(buffer, isNull)).to.be.true

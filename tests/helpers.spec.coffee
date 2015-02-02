os = require('os')
sinon = require('sinon')
_ = require('lodash-contrib')
chai = require('chai')
chai.use(require('sinon-chai'))
expect = chai.expect
helpers = require('../lib/helpers')
win32 = require('../lib/win32')

describe 'Helpers:', ->

	describe '.translateError()', ->

		it 'should return a function', ->
			handler = helpers.translateError(_.noop)
			expect(_.isFunction(handler)).to.be.true

		it 'should return an error if no callback', ->
			expect ->
				helpers.translateError()
			.to.throw('Missing callback')

		it 'should return an error if callback is not a function', ->
			expect ->
				helpers.translateError([ _.noop ])
			.to.throw('Invalid callback')

		describe 'the returned function', ->

			describe 'given an error', ->

				beforeEach ->
					@spy = sinon.spy()
					@handler = helpers.translateError(@spy)

				it 'should call the callback with the error', ->
					error = new Error('Hello')
					@handler(error)
					expect(@spy).to.have.been.calledOnce
					expect(@spy).to.have.been.calledWithExactly(error)

				it 'should override error message if EBUSY', ->
					error = new Error('Hello')
					error.code = 'EBUSY'
					error.path = '/hello'

					@handler(error)

					returnedError = @spy.firstCall.args[0]
					expect(returnedError.message).to.equal('Try umounting /hello first.')

				it 'should override error message if ENOENT', ->
					error = new Error('Hello')
					error.code = 'ENOENT'
					error.path = '/hello'

					@handler(error)

					returnedError = @spy.firstCall.args[0]
					expect(returnedError.message).to.equal('Invalid device /hello')

				it 'should remove the error code if ENOENT', ->
					error = new Error('Hello')
					error.code = 'ENOENT'
					error.path = '/hello'

					@handler(error)

					returnedError = @spy.firstCall.args[0]
					expect(returnedError.code).to.not.exist

	describe '.prepareDrive()', ->

		it 'should make use of translateError()', (done) ->
			translateErrorSpy = sinon.spy(helpers, 'translateError')

			helpers.prepareDrive 'myDevice', (callback) ->
				return callback()
			, (error) ->
				expect(translateErrorSpy).to.have.been.calledOnce
				translateErrorSpy.restore()
				done()

		it 'should throw an error if no device', ->
			expect ->
				helpers.prepareDrive(null, _.noop, _.noop)
			.to.throw('Missing device')

		it 'should throw an error if no write function', ->
			expect ->
				helpers.prepareDrive('myDevice', null, _.noop)
			.to.throw('Missing write function')

		it 'should throw an error if write function is not a function', ->
			expect ->
				helpers.prepareDrive('myDevice', [ _.noop ], _.noop)
			.to.throw('Invalid write function')

		describe 'if platform is win32', ->

			beforeEach ->
				@osPlatformStub = sinon.stub(os, 'platform')
				@osPlatformStub.returns('win32')

				@eraseMBRStub = sinon.stub(win32, 'eraseMBR')
				@eraseMBRStub.yields()

				@rescanDrivesStub = sinon.stub(win32, 'rescanDrives')
				@rescanDrivesStub.yields()

			afterEach ->
				@osPlatformStub.restore()
				@eraseMBRStub.restore()
				@rescanDrivesStub.restore()

			it 'should erase the MBR before writing to the device', (done) ->
				helpers.prepareDrive 'myDevice', (callback) =>
					expect(@eraseMBRStub).to.have.been.calledOnce
					return callback()
				, (error) =>
					expect(error).to.not.exist
					expect(@eraseMBRStub).to.have.been.calledOnce
					return done()

			it 'should rescan the drives before and after writing to the device', (done) ->
				helpers.prepareDrive 'myDevice', (callback) =>
					expect(@rescanDrivesStub).to.have.been.calledOnce
					return callback()
				, (error) =>
					expect(error).to.not.exist
					expect(@rescanDrivesStub).to.have.been.calledTwice
					return done()

		describe 'if platform is not win32', ->

			beforeEach ->
				@osPlatformStub = sinon.stub(os, 'platform')
				@osPlatformStub.returns('darwin')

				@eraseMBRStub = sinon.stub(win32, 'eraseMBR')
				@eraseMBRStub.yields()

				@rescanDrivesStub = sinon.stub(win32, 'rescanDrives')
				@rescanDrivesStub.yields()

			afterEach ->
				@osPlatformStub.restore()
				@eraseMBRStub.restore()
				@rescanDrivesStub.restore()

			it 'should not erase the MBR nor rescan the drives', (done) ->
				helpers.prepareDrive 'myDevice', (callback) =>
					expect(@eraseMBRStub).to.not.have.been.called
					expect(@rescanDrivesStub).to.not.have.been.called
					return callback()
				, (error) =>
					expect(error).to.not.exist
					expect(@eraseMBRStub).to.not.have.been.called
					expect(@rescanDrivesStub).to.not.have.been.called
					return done()

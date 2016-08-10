fs = require 'fs'
log = require 'simplog'

# 0x0080 O_SYNC
# 0x0020 O_EXLOCK
# 0x0400 O_TRUNC
# 0x0200 O_CREAT
# 0x0004 O_NONBLOCK
# 0x0002 F_WRITE
flags = 0x0080 | 0x0020 | 0x0400 | 0x0200 | 0x0004 | 0x0002

tryAquireLock = (lockFilePath, cb) ->
  cbHandler = (e, fd) ->
    if (e)
      # EAGAIN is raised if it's already locked which means
      # we couldn't aquire the lock
      if e.message.indexOf("EAGAIN") is -1
        # so something unexpected, happened, log it and don't grant the lock
        log.error "error #{e.message} while trying to lock #{lockFilePath}"
        return cb(e)
      log.debug "tried to lock already locked file #{lockFilePath}"
      return cb(null)
    else
      writeCbHandler = (err) ->
        if err
          log.warn "trouble writing to the lock file, not necessarily a problem as it was already locked (opened)"
        cb(null, fd)
      return fs.write(fd, new Date() + " - " + process.pid, writeCbHandler)
  return fs.open(lockFilePath, flags, cbHandler)

releaseLock = (lockFileDescriptor, cb) ->
  cbHandler = (e) ->
    # trying to unlock an already unlocked (closed) file is considered the same as
    # successful unlock, so if there is an EBADF in the message, it's not an issue
    return cb(e) if e and e.message.indexOf('EBADF') is -1
    return cb()
  return fs.close(lockFileDescriptor, cbHandler)
    

module.exports.releaseLock = releaseLock
module.exports.tryAquireLock = tryAquireLock

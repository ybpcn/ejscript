#
#   build.sh -- Build It Shell Script to build Embedthis Ejscript
#

PLATFORM="win-i686-debug"
CC="cl"
CFLAGS="-nologo -GR- -W3 -Zi -Od -MDd"
DFLAGS="-D_REENTRANT -D_MT"
IFLAGS="-Iwin-i686-debug/inc"
LDFLAGS="-nologo -nodefaultlib -incremental:no -libpath:${PLATFORM}/bin -debug -machine:x86
LIBS="ws2_32.lib advapi32.lib user32.lib kernel32.lib oldnames.lib msvcrt.lib"

export PATH="%VS%/Bin:%VS%/VC/Bin:%VS%/Common7/IDE:%VS%/Common7/Tools:%VS%/SDK/v3.5/bin:%VS%/VC/VCPackages"
export INCLUDE="%VS%/INCLUDE:%VS%/VC/INCLUDE"
export LIB="%VS%/lib:%VS%/VC/lib"
[ ! -x ${PLATFORM}/inc ] && mkdir -p ${PLATFORM}/inc ${PLATFORM}/obj ${PLATFORM}/lib ${PLATFORM}/bin
[ ! -f ${PLATFORM}/inc/buildConfig.h ] && cp projects/buildConfig.${PLATFORM} ${PLATFORM}/inc/buildConfig.h

rm -rf win-i686-debug/inc/mpr.h
cp -r src/deps/mpr/mpr.h win-i686-debug/inc/mpr.h

rm -rf win-i686-debug/inc/mprSsl.h
cp -r src/deps/mpr/mprSsl.h win-i686-debug/inc/mprSsl.h

"${CC}" -c -Fo${PLATFORM}/obj/mprLib.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/deps/mpr/mprLib.c

"link" -dll -out:${PLATFORM}/bin/libmpr.dll -entry:_DllMainCRTStartup@12 -def:${PLATFORM}/bin/libmpr.def ${LDFLAGS} ${PLATFORM}/obj/mprLib.obj ${PLATFORM}/bin/libws2_32.lib ${PLATFORM}/bin/libadvapi32.lib ${PLATFORM}/bin/libuser32.lib ${PLATFORM}/bin/libkernel32.lib ${PLATFORM}/bin/liboldnames.lib ${PLATFORM}/bin/libmsvcrt.lib

"${CC}" -c -Fo${PLATFORM}/obj/manager.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/deps/mpr/manager.c

"link" -out:${PLATFORM}/bin/ejsman -entry:WinMainCRTStartup -subsystem:Windows ${LDFLAGS} ${PLATFORM}/obj/manager.obj ${PLATFORM}/bin/libws2_32.lib ${PLATFORM}/bin/libadvapi32.lib ${PLATFORM}/bin/libuser32.lib ${PLATFORM}/bin/libkernel32.lib ${PLATFORM}/bin/liboldnames.lib ${PLATFORM}/bin/libmsvcrt.lib ${PLATFORM}/bin/libmpr.lib shell32.lib

"${CC}" -c -Fo${PLATFORM}/obj/makerom.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/deps/mpr/makerom.c

"link" -out:${PLATFORM}/bin/makerom.exe -entry:mainCRTStartup -subsystem:console ${LDFLAGS} ${PLATFORM}/obj/makerom.obj ${PLATFORM}/bin/libws2_32.lib ${PLATFORM}/bin/libadvapi32.lib ${PLATFORM}/bin/libuser32.lib ${PLATFORM}/bin/libkernel32.lib ${PLATFORM}/bin/liboldnames.lib ${PLATFORM}/bin/libmsvcrt.lib ${PLATFORM}/bin/libmpr.lib

rm -rf win-i686-debug/inc/pcre.h
cp -r src/deps/pcre/pcre.h win-i686-debug/inc/pcre.h

"${CC}" -c -Fo${PLATFORM}/obj/pcre.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/deps/pcre/pcre.c

"link" -dll -out:${PLATFORM}/bin/libpcre.dll -entry:_DllMainCRTStartup@12 -def:${PLATFORM}/bin/libpcre.def ${LDFLAGS} ${PLATFORM}/obj/pcre.obj ${PLATFORM}/bin/libws2_32.lib ${PLATFORM}/bin/libadvapi32.lib ${PLATFORM}/bin/libuser32.lib ${PLATFORM}/bin/libkernel32.lib ${PLATFORM}/bin/liboldnames.lib ${PLATFORM}/bin/libmsvcrt.lib

rm -rf win-i686-debug/inc/http.h
cp -r src/deps/http/http.h win-i686-debug/inc/http.h

"${CC}" -c -Fo${PLATFORM}/obj/httpLib.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/deps/http/httpLib.c

"link" -dll -out:${PLATFORM}/bin/libhttp.dll -entry:_DllMainCRTStartup@12 -def:${PLATFORM}/bin/libhttp.def ${LDFLAGS} ${PLATFORM}/obj/httpLib.obj ${PLATFORM}/bin/libws2_32.lib ${PLATFORM}/bin/libadvapi32.lib ${PLATFORM}/bin/libuser32.lib ${PLATFORM}/bin/libkernel32.lib ${PLATFORM}/bin/liboldnames.lib ${PLATFORM}/bin/libmsvcrt.lib ${PLATFORM}/bin/libmpr.lib ${PLATFORM}/bin/libpcre.lib

"${CC}" -c -Fo${PLATFORM}/obj/http.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/deps/http/http.c

"link" -out:${PLATFORM}/bin/http.exe -entry:mainCRTStartup -subsystem:console ${LDFLAGS} ${PLATFORM}/obj/http.obj ${PLATFORM}/bin/libws2_32.lib ${PLATFORM}/bin/libadvapi32.lib ${PLATFORM}/bin/libuser32.lib ${PLATFORM}/bin/libkernel32.lib ${PLATFORM}/bin/liboldnames.lib ${PLATFORM}/bin/libmsvcrt.lib ${PLATFORM}/bin/libhttp.lib ${PLATFORM}/bin/libmpr.lib ${PLATFORM}/bin/libpcre.lib

rm -rf win-i686-debug/inc/sqlite3.h
cp -r src/deps/sqlite/sqlite3.h win-i686-debug/inc/sqlite3.h

"${CC}" -c -Fo${PLATFORM}/obj/sqlite3.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/deps/sqlite/sqlite3.c

"link" -dll -out:${PLATFORM}/bin/libsqlite3.dll -entry:_DllMainCRTStartup@12 -def:${PLATFORM}/bin/libsqlite3.def ${LDFLAGS} ${PLATFORM}/obj/sqlite3.obj ${PLATFORM}/bin/libws2_32.lib ${PLATFORM}/bin/libadvapi32.lib ${PLATFORM}/bin/libuser32.lib ${PLATFORM}/bin/libkernel32.lib ${PLATFORM}/bin/liboldnames.lib ${PLATFORM}/bin/libmsvcrt.lib

rm -rf win-i686-debug/inc/ejs.cache.local.slots.h
cp -r src/slots/ejs.cache.local.slots.h win-i686-debug/inc/ejs.cache.local.slots.h

rm -rf win-i686-debug/inc/ejs.slots.h
cp -r src/slots/ejs.slots.h win-i686-debug/inc/ejs.slots.h

rm -rf win-i686-debug/inc/ejs.zlib.slots.h
cp -r src/slots/ejs.zlib.slots.h win-i686-debug/inc/ejs.zlib.slots.h

rm -rf win-i686-debug/inc/ejs.db.sqlite.slots.h
cp -r src/slots/ejs.db.sqlite.slots.h win-i686-debug/inc/ejs.db.sqlite.slots.h

rm -rf win-i686-debug/inc/ejs.web.slots.h
cp -r src/slots/ejs.web.slots.h win-i686-debug/inc/ejs.web.slots.h

rm -rf win-i686-debug/inc/ejsCompiler.h
cp -r src/ejsCompiler.h win-i686-debug/inc/ejsCompiler.h

rm -rf win-i686-debug/inc/ejs.h
cp -r src/ejs.h win-i686-debug/inc/ejs.h

rm -rf win-i686-debug/inc/ejsByteCode.h
cp -r src/ejsByteCode.h win-i686-debug/inc/ejsByteCode.h

rm -rf win-i686-debug/inc/ejsCustomize.h
cp -r src/ejsCustomize.h win-i686-debug/inc/ejsCustomize.h

rm -rf win-i686-debug/inc/ejsByteCodeTable.h
cp -r src/ejsByteCodeTable.h win-i686-debug/inc/ejsByteCodeTable.h

"${CC}" -c -Fo${PLATFORM}/obj/ecModuleWrite.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/compiler/ecModuleWrite.c

"${CC}" -c -Fo${PLATFORM}/obj/ecCodeGen.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/compiler/ecCodeGen.c

"${CC}" -c -Fo${PLATFORM}/obj/ecCompiler.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/compiler/ecCompiler.c

"${CC}" -c -Fo${PLATFORM}/obj/ecLex.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/compiler/ecLex.c

"${CC}" -c -Fo${PLATFORM}/obj/ecAst.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/compiler/ecAst.c

"${CC}" -c -Fo${PLATFORM}/obj/ecParser.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/compiler/ecParser.c

"${CC}" -c -Fo${PLATFORM}/obj/ecState.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/compiler/ecState.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsApp.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsApp.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsNamespace.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsNamespace.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsCache.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsCache.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsBlock.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsBlock.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsFileSystem.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsFileSystem.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsType.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsType.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsNull.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsNull.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsObject.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsObject.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsRegExp.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsRegExp.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsBoolean.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsBoolean.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsGC.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsGC.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsVoid.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsVoid.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsJSON.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsJSON.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsArray.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsArray.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsString.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsString.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsDate.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsDate.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsSystem.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsSystem.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsMath.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsMath.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsError.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsError.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsPath.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsPath.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsMprLog.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsMprLog.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsHttp.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsHttp.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsCmd.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsCmd.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsNumber.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsNumber.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsIterator.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsIterator.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsDebug.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsDebug.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsGlobal.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsGlobal.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsByteArray.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsByteArray.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsMemory.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsMemory.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsFrame.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsFrame.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsPot.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsPot.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsXMLLoader.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsXMLLoader.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsFile.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsFile.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsWorker.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsWorker.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsXMLList.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsXMLList.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsFunction.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsFunction.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsSocket.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsSocket.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsConfig.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsConfig.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsTimer.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsTimer.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsXML.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsXML.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsLocalCache.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsLocalCache.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsUri.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/core/src/ejsUri.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsException.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/vm/ejsException.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsService.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/vm/ejsService.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsModule.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/vm/ejsModule.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsByteCode.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/vm/ejsByteCode.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsInterp.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/vm/ejsInterp.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsHelper.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/vm/ejsHelper.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsScope.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/vm/ejsScope.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsLoader.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/vm/ejsLoader.c

"link" -dll -out:${PLATFORM}/bin/libejs.dll -entry:_DllMainCRTStartup@12 -def:${PLATFORM}/bin/libejs.def ${LDFLAGS} ${PLATFORM}/obj/ecModuleWrite.obj ${PLATFORM}/obj/ecCodeGen.obj ${PLATFORM}/obj/ecCompiler.obj ${PLATFORM}/obj/ecLex.obj ${PLATFORM}/obj/ecAst.obj ${PLATFORM}/obj/ecParser.obj ${PLATFORM}/obj/ecState.obj ${PLATFORM}/obj/ejsApp.obj ${PLATFORM}/obj/ejsNamespace.obj ${PLATFORM}/obj/ejsCache.obj ${PLATFORM}/obj/ejsBlock.obj ${PLATFORM}/obj/ejsFileSystem.obj ${PLATFORM}/obj/ejsType.obj ${PLATFORM}/obj/ejsNull.obj ${PLATFORM}/obj/ejsObject.obj ${PLATFORM}/obj/ejsRegExp.obj ${PLATFORM}/obj/ejsBoolean.obj ${PLATFORM}/obj/ejsGC.obj ${PLATFORM}/obj/ejsVoid.obj ${PLATFORM}/obj/ejsJSON.obj ${PLATFORM}/obj/ejsArray.obj ${PLATFORM}/obj/ejsString.obj ${PLATFORM}/obj/ejsDate.obj ${PLATFORM}/obj/ejsSystem.obj ${PLATFORM}/obj/ejsMath.obj ${PLATFORM}/obj/ejsError.obj ${PLATFORM}/obj/ejsPath.obj ${PLATFORM}/obj/ejsMprLog.obj ${PLATFORM}/obj/ejsHttp.obj ${PLATFORM}/obj/ejsCmd.obj ${PLATFORM}/obj/ejsNumber.obj ${PLATFORM}/obj/ejsIterator.obj ${PLATFORM}/obj/ejsDebug.obj ${PLATFORM}/obj/ejsGlobal.obj ${PLATFORM}/obj/ejsByteArray.obj ${PLATFORM}/obj/ejsMemory.obj ${PLATFORM}/obj/ejsFrame.obj ${PLATFORM}/obj/ejsPot.obj ${PLATFORM}/obj/ejsXMLLoader.obj ${PLATFORM}/obj/ejsFile.obj ${PLATFORM}/obj/ejsWorker.obj ${PLATFORM}/obj/ejsXMLList.obj ${PLATFORM}/obj/ejsFunction.obj ${PLATFORM}/obj/ejsSocket.obj ${PLATFORM}/obj/ejsConfig.obj ${PLATFORM}/obj/ejsTimer.obj ${PLATFORM}/obj/ejsXML.obj ${PLATFORM}/obj/ejsLocalCache.obj ${PLATFORM}/obj/ejsUri.obj ${PLATFORM}/obj/ejsException.obj ${PLATFORM}/obj/ejsService.obj ${PLATFORM}/obj/ejsModule.obj ${PLATFORM}/obj/ejsByteCode.obj ${PLATFORM}/obj/ejsInterp.obj ${PLATFORM}/obj/ejsHelper.obj ${PLATFORM}/obj/ejsScope.obj ${PLATFORM}/obj/ejsLoader.obj ${PLATFORM}/bin/libws2_32.lib ${PLATFORM}/bin/libadvapi32.lib ${PLATFORM}/bin/libuser32.lib ${PLATFORM}/bin/libkernel32.lib ${PLATFORM}/bin/liboldnames.lib ${PLATFORM}/bin/libmsvcrt.lib ${PLATFORM}/bin/libmpr.lib ${PLATFORM}/bin/libpcre.lib ${PLATFORM}/bin/libhttp.lib

"${CC}" -c -Fo${PLATFORM}/obj/ejs.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/cmd/ejs.c

"link" -out:${PLATFORM}/bin/ejs.exe -entry:mainCRTStartup -subsystem:console ${LDFLAGS} ${PLATFORM}/obj/ejs.obj ${PLATFORM}/bin/libws2_32.lib ${PLATFORM}/bin/libadvapi32.lib ${PLATFORM}/bin/libuser32.lib ${PLATFORM}/bin/libkernel32.lib ${PLATFORM}/bin/liboldnames.lib ${PLATFORM}/bin/libmsvcrt.lib ${PLATFORM}/bin/libejs.lib ${PLATFORM}/bin/libmpr.lib ${PLATFORM}/bin/libpcre.lib ${PLATFORM}/bin/libhttp.lib

"${CC}" -c -Fo${PLATFORM}/obj/ejsc.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/cmd/ejsc.c

"link" -out:${PLATFORM}/bin/ejsc.exe -entry:mainCRTStartup -subsystem:console ${LDFLAGS} ${PLATFORM}/obj/ejsc.obj ${PLATFORM}/bin/libws2_32.lib ${PLATFORM}/bin/libadvapi32.lib ${PLATFORM}/bin/libuser32.lib ${PLATFORM}/bin/libkernel32.lib ${PLATFORM}/bin/liboldnames.lib ${PLATFORM}/bin/libmsvcrt.lib ${PLATFORM}/bin/libejs.lib ${PLATFORM}/bin/libmpr.lib ${PLATFORM}/bin/libpcre.lib ${PLATFORM}/bin/libhttp.lib

"${CC}" -c -Fo${PLATFORM}/obj/ejsmod.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc -Isrc/cmd src/cmd/ejsmod.c

"${CC}" -c -Fo${PLATFORM}/obj/doc.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc -Isrc/cmd src/cmd/doc.c

"${CC}" -c -Fo${PLATFORM}/obj/docFiles.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc -Isrc/cmd src/cmd/docFiles.c

"${CC}" -c -Fo${PLATFORM}/obj/listing.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc -Isrc/cmd src/cmd/listing.c

"${CC}" -c -Fo${PLATFORM}/obj/slotGen.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc -Isrc/cmd src/cmd/slotGen.c

"link" -out:${PLATFORM}/bin/ejsmod.exe -entry:mainCRTStartup -subsystem:console ${LDFLAGS} ${PLATFORM}/obj/ejsmod.obj ${PLATFORM}/obj/doc.obj ${PLATFORM}/obj/docFiles.obj ${PLATFORM}/obj/listing.obj ${PLATFORM}/obj/slotGen.obj ${PLATFORM}/bin/libws2_32.lib ${PLATFORM}/bin/libadvapi32.lib ${PLATFORM}/bin/libuser32.lib ${PLATFORM}/bin/libkernel32.lib ${PLATFORM}/bin/liboldnames.lib ${PLATFORM}/bin/libmsvcrt.lib ${PLATFORM}/bin/libejs.lib ${PLATFORM}/bin/libmpr.lib ${PLATFORM}/bin/libpcre.lib ${PLATFORM}/bin/libhttp.lib

"${CC}" -c -Fo${PLATFORM}/obj/ejsrun.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/cmd/ejsrun.c

"link" -out:${PLATFORM}/bin/ejsrun.exe -entry:mainCRTStartup -subsystem:console ${LDFLAGS} ${PLATFORM}/obj/ejsrun.obj ${PLATFORM}/bin/libws2_32.lib ${PLATFORM}/bin/libadvapi32.lib ${PLATFORM}/bin/libuser32.lib ${PLATFORM}/bin/libkernel32.lib ${PLATFORM}/bin/liboldnames.lib ${PLATFORM}/bin/libmsvcrt.lib ${PLATFORM}/bin/libejs.lib ${PLATFORM}/bin/libmpr.lib ${PLATFORM}/bin/libpcre.lib ${PLATFORM}/bin/libhttp.lib

ejsc --out ${PLATFORM}/bin/ejs.mod --debug --optimize 9 --bind --require null src/core/*.es 
ejsmod --require null --listing --cslots ${PLATFORM}/bin/ejs.mod
cp ejs.slots.h ${PLATFORM}/inc
cp src/jems/ejs.bit/bit.es ${PLATFORM}/bin
cp src/jems/ejs.utest/utest.es ${PLATFORM}/bin
rm -fr ${PLATFORM}/bin/bits
cp -r src/jems/ejs.bit/bits ${PLATFORM}/bin
ejsc --out ${PLATFORM}/bin/ejs.unix.mod --debug --optimize 9 src/jems/ejs.unix/Unix.es
cp src/jems/ejs.jem/jem.es ${PLATFORM}/bin
ejsc --out ${PLATFORM}/bin/ejs.db.mod --debug --optimize 9 src/jems/ejs.db/*.es
ejsc --out ${PLATFORM}/bin/ejs.db.mapper.mod --debug --optimize 9 src/jems/ejs.db.mapper/*.es
ejsc --out ${PLATFORM}/bin/ejs.db.sqlite.mod --debug --optimize 9 src/jems/ejs.db.sqlite/*.es
"${CC}" -c -Fo${PLATFORM}/obj/ejsSqlite.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc src/jems/ejs.db.sqlite/src/ejsSqlite.c

"link" -dll -out:${PLATFORM}/bin/ejs.db.sqlite.dll -entry:_DllMainCRTStartup@12 -def:${PLATFORM}/bin/ejs.db.sqlite.def ${LDFLAGS} ${PLATFORM}/obj/ejsSqlite.obj ${PLATFORM}/bin/libws2_32.lib ${PLATFORM}/bin/libadvapi32.lib ${PLATFORM}/bin/libuser32.lib ${PLATFORM}/bin/libkernel32.lib ${PLATFORM}/bin/liboldnames.lib ${PLATFORM}/bin/libmsvcrt.lib ${PLATFORM}/bin/libmpr.lib ${PLATFORM}/bin/libejs.lib ${PLATFORM}/bin/libpcre.lib ${PLATFORM}/bin/libhttp.lib ${PLATFORM}/bin/libsqlite3.lib

ejsc --out ${PLATFORM}/bin/ejs.web.mod --debug --optimize 9 src/jems/ejs.web/*.es
ejsmod --cslots ${PLATFORM}/bin/ejs.web.mod
cp ejs.web.slots.h ${PLATFORM}/inc
"${CC}" -c -Fo${PLATFORM}/obj/ejsHttpServer.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc -Isrc/jems/ejs.web/src src/jems/ejs.web/src/ejsHttpServer.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsWeb.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc -Isrc/jems/ejs.web/src src/jems/ejs.web/src/ejsWeb.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsRequest.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc -Isrc/jems/ejs.web/src src/jems/ejs.web/src/ejsRequest.c

"${CC}" -c -Fo${PLATFORM}/obj/ejsSession.obj -Fd${PLATFORM}/obj ${CFLAGS} ${DFLAGS} -I${PLATFORM}/inc -Isrc/jems/ejs.web/src src/jems/ejs.web/src/ejsSession.c

"link" -dll -out:${PLATFORM}/bin/ejs.web.dll -entry:_DllMainCRTStartup@12 -def:${PLATFORM}/bin/ejs.web.def ${LDFLAGS} ${PLATFORM}/obj/ejsHttpServer.obj ${PLATFORM}/obj/ejsWeb.obj ${PLATFORM}/obj/ejsRequest.obj ${PLATFORM}/obj/ejsSession.obj ${PLATFORM}/bin/libws2_32.lib ${PLATFORM}/bin/libadvapi32.lib ${PLATFORM}/bin/libuser32.lib ${PLATFORM}/bin/libkernel32.lib ${PLATFORM}/bin/liboldnames.lib ${PLATFORM}/bin/libmsvcrt.lib ${PLATFORM}/bin/libmpr.lib ${PLATFORM}/bin/libhttp.lib ${PLATFORM}/bin/libpcre.lib ${PLATFORM}/bin/libpcre.lib ${PLATFORM}/bin/libejs.lib

rm -fr ${PLATFORM}/bin/www
cp -r src/jems/ejs.web/www ${PLATFORM}/bin
ejsc --out ${PLATFORM}/bin/ejs.template.mod --debug --optimize 9 src/jems/ejs.template/TemplateParser.es
ejsc --out ${PLATFORM}/bin/ejs.tar.mod/ --debug --optimize 9 src/jems/ejs.tar/*.es
cp src/jems/ejs.mvc/mvc.es ${PLATFORM}/bin
ejsc --out ${PLATFORM}/bin/ejs.mvc.mod/ --debug --optimize 9 src/jems/ejs.mvc/*.es
cp src/jems/ejs.utest/utest.worker ${PLATFORM}/bin

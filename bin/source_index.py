#!/usr/bin/env python
# Copyright (c) 2011 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Usage: <win-path-to-pdb.pdb>
This tool will take a PDB on the command line, extract the source files that
were used in building the PDB, query SVN for which repository and revision
these files are at, and then finally write this information back into the PDB
in a format that the debugging tools understand.  This allows for automatic
source debugging, as all of the information is contained in the PDB, and the
debugger can go out and fetch the source files via SVN.
"""

import sys
import os
import time
import subprocess
import tempfile
import ctypes

srcToolPath = "C:\\Program Files (x86)\\Windows Kits\\10\\Debuggers\\x64\\srcsrv\\srctool.exe"
symStorePath = "C:\\Program Files (x86)\\Windows Kits\\10\\Debuggers\\x64\\symstore.exe"
pdbStrPath = "C:\\Program Files (x86)\\Windows Kits\\10\\Debuggers\\x64\\srcsrv\\pdbstr.exe"

def FindFile(filename):
  """Return the full windows path to a file in the same dir as this code."""
  thisdir = os.path.dirname(os.path.join(os.path.curdir, __file__))
  return os.path.abspath(os.path.join(thisdir, filename))


def ExtractSourceFiles(pdb_filename):
  """Extract a list of local paths of the source files from a PDB."""
  srctool = subprocess.Popen([srcToolPath, '-r', pdb_filename],
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  filelist = srctool.stdout.read()
  res = srctool.wait()

  if res == 0 or res == -1 or filelist.startswith("srctool: "):
    print "Res: %d" % res
    raise "srctool failed: " + filelist
  return [x for x in filelist.split('\r\n') if len(x) != 0]

def ReadSourceStream(pdb_filename):
  """Read the contents of the source information stream from a PDB."""
  srctool = subprocess.Popen([pdbStrPath,
                              '-r', '-s:srcsrv',
                              '-p:%s' % pdb_filename],
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)  

  data = srctool.stdout.read()
  res = srctool.wait()

  if (res != 0 and res != -1 and res != 1) or data.startswith("pdbstr: "):        
    raise "pdbstr failed: " + data
  return data


def WriteSourceStream(pdb_filename, data):
  """Write the contents of the source information stream to a PDB."""
  # Write out the data to a temporary filename that we can pass to pdbstr.
  (f, fname) = tempfile.mkstemp()
  f = os.fdopen(f, "wb")
  f.write(data)
  f.close()

  #print data
  
  srctool = subprocess.Popen([pdbStrPath,
                              '-w', '-s:srcsrv',
                              '-i:%s' % fname,
                              '-p:%s' % pdb_filename],
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  data = srctool.stdout.read()
  res = srctool.wait()

  if (res != 0 and res != -1) or data.startswith("pdbstr: "):    
    raise "pdbstr failed: " + data

  os.unlink(fname)

def ExtractGitInfo():
  curPath = os.getcwd()  
  srctool = subprocess.Popen(['git.exe', '--git-dir=' + curPath + '\\..\\..\\..\\Beef\\.git', 'rev-parse', 'HEAD'],
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  info = srctool.stdout.read()  
  res = srctool.wait()
  if res != 0:
    return None

  return info

rtGetActualPath = None
def GetActualPath(path):
  global rtGetActualPath

  if not rtGetActualPath:
    dllPath = FindFile('..\..\Beef\IDE\dist\Beef042Rt64.dll')
    rtDll = ctypes.WinDLL(dllPath)

    apiProto = ctypes.WINFUNCTYPE (
      None,      # Return type.
      ctypes.c_char_p,   # Parameters 1 ...
      ctypes.c_char_p,
      ctypes.c_void_p,
      ctypes.c_void_p)   # ... thru 4.
    apiParams = (1, "inPath", 0), (1, "outPath", 0), (1, "inOutPathSize",0), (1, "outResult",0),

    rtGetActualPath = apiProto (("BfpFile_GetActualPath", rtDll), apiParams)
  
  p1 = ctypes.c_char_p (path)
  p2 = ctypes.create_string_buffer(260)
  p3 = ctypes.c_int (260)
  p4 = ctypes.c_int (0)
  rtGetActualPath (p1, p2, ctypes.byref (p3), ctypes.byref (p4))
  return p2.value

def UpdatePDB(pdb_filename, verbose=False):  
  #print "UpdatePDB: %s" % pdb_filename

  gitHash = ExtractGitInfo()      
  if gitHash == None:
    raise "Failed to retrieve git hash"
  gitHash = gitHash.replace('\n', '')

  """Update a pdb file with source information."""
  dir_blacklist = { }
  # TODO(deanm) look into "compressing" our output, by making use of vars
  # and other things, so we don't need to duplicate the repo path and revs.
  lines = [
    'SRCSRV: ini ------------------------------------------------',
    'VERSION=2',
    'INDEXVERSION=2',
    'VERCTRL=http',
    'DATETIME=%s' % time.asctime(),
    'SRCSRV: variables ------------------------------------------',
    'HTTP_ALIAS=http://raw.githubusercontent.com/beefytech/Beef/%s/' % gitHash,
    'HTTP_EXTRACT_TARGET=%HTTP_ALIAS%%var2%',
    'SRCSRVTRG=%HTTP_EXTRACT_TARGET%',    
    'SRCSRV: source files ---------------------------------------',
  ]
  
  if ReadSourceStream(pdb_filename):
    raise "PDB already has source indexing information!"

  filelist = ExtractSourceFiles(pdb_filename)
  for filename in filelist:
    filedir = os.path.dirname(filename)

    beefIdx = filename.lower().find("\\beef\\")
    if beefIdx == -1:
      continue
    if filename.lower().find(".pdb") != -1:
      continue

    if verbose:
      print "Processing: %s" % filename
    # This directory is blacklisted, either because it's not part of the SVN
    # repository, or from one we're not interested in indexing.
    if dir_blacklist.get(filedir, False):
      if verbose:
        print "  skipping, directory is blacklisted."
      continue        
            
    actualPath = GetActualPath(filename)
    if verbose:
        print "Actual: %s" % actualPath
    
    url = actualPath[beefIdx + 6:].replace('\\', '/')
    lines.append('%s*%s' % (actualPath, url));

    if verbose:
      print "  indexed file."

  lines.append('SRCSRV: end ------------------------------------------------')

  WriteSourceStream(pdb_filename, '\r\n'.join(lines))


def main():


  if len(sys.argv) < 2 or len(sys.argv) > 3:
    print "usage: file.pdb [-v]"
    return 1

  verbose = False
  if len(sys.argv) == 3:
    verbose = (sys.argv[2] == '-v')

  UpdatePDB(sys.argv[1], verbose=verbose)
  return 0


if __name__ == '__main__':
  sys.exit(main())

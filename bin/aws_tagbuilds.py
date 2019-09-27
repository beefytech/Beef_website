import os
import subprocess
import shlex

def GetAbsPath(filename):
  """Return the full windows path to a file in the same dir as this code."""
  thisdir = os.path.dirname(os.path.join(os.path.curdir, __file__))
  return os.path.abspath(os.path.join(thisdir, filename))

for (dirPath, dirNames, fileNames) in os.walk(GetAbsPath('..\public\setup')):
  for fileName in fileNames:
    if not fileName.startswith("BeefSetup_"):
	  continue
    ver = fileName[10:len(fileName)-4].replace('_', '.')
    print "Name: %s Ver: %s" % (fileName, ver)

    args = 'aws.exe s3api put-object-tagging --bucket www.beeflang.org --key setup/' + fileName + ' --tagging TagSet=[{"Key"="setup","Value"="' + ver + '"}]'
    print "Args: %s" % args

    awsProc = subprocess.Popen(shlex.split(args))
    #info = srctool.stdout.read()  
    res = awsProc.wait()
    if res != 0:
      raise "Failed";
    #aws put-object-tagging --bucket www.beeflang.org --key setup/
